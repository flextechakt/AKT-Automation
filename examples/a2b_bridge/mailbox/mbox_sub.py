#!/usr/bin/env python

##############################################################################
# This example demonstrates the configuration and control of A2B Mailbox
# communication.  A simply incrementing number is be sent from one side to
# the other and displayed.
#
# In this configuration, MBOX 0 is a receive MBOX and MBOX 1 is a transmit
# MBOX on the selected sub node.
##############################################################################
from jsonrpcclient import request
import atexit
import time
from KBHit import KBHit
from api import A2BBridgeAPI

# Adjust as required for your system
API_CFG = {
    #'url': 'http://169.254.205.11:4040/1',
    'ser': 'COM16',
    'bus': 'A2B0',
    'verbose': False
}

# Generic exit handler to unlock the API on script errors
def exit_handler():
    api.unlock(True)
atexit.register(exit_handler)

# Interesting registers
MBOX0B0  = 0x92
MBOX1B0  = 0x98

# Interesting defines
MBOX0_FULL_IRQ  = 48
MBOX0_EMPTY_IRQ = 49
MBOX1_FULL_IRQ  = 50
MBOX1_EMPTY_IRQ = 51

# Activate local processing of Mailbox interrupts.
# On the main node, enable:
#    49 - Mailbox 0 empty
#    50 - Mailbox 1 full
# On the sub node, enable
#    48 - Mailbox 0 full
#    51 - Mailbox 1 empty
def activate_irq():
    IRQ_SETUP_MAIN = [ MBOX0_EMPTY_IRQ, MBOX1_FULL_IRQ ]
    IRQ_SETUP_SUB = [ MBOX0_FULL_IRQ, MBOX1_EMPTY_IRQ ]
    ok, resp = api.execute('setup.getMode', {})
    if not ok:
        return False
    if resp['mode'] == 'main':
        IRQ = IRQ_SETUP_MAIN
    else:
        IRQ = IRQ_SETUP_SUB
    for i in range(len(IRQ)):
        ok, resp = api.execute('irq.activate', {'intType':IRQ[i]})
        if not ok:
            return False

# Send 4 bytes to the main node via Mailbox 1
def mbox_send(MSG):
    print(f'Sending: {MSG:#08x}')
    MSG_BYTES = [ MBOX1B0 ]
    MSG_BYTES.extend(MSG.to_bytes(4, 'big'))
    ok, resp = api.execute('master.i2cWriteRead',
        {'nodeAddr':-1, 'wBuf':MSG_BYTES, 'nRead':0})
    return ok

# Receive 4 bytes from the main node via Mailbox 0
def mbox_receive():
    MSG_BYTES = [ MBOX0B0 ]
    ok, resp = api.execute('master.i2cWriteRead',
        {'nodeAddr':-1, 'wBuf':MSG_BYTES, 'nRead':4})
    if ok:
        MSG = int.from_bytes(resp['bytes'], 'big')
        print(f'Received: {MSG:#08x}')
    return ok

# Instantiate an API instance
api = A2BBridgeAPI(API_CFG)

# Lock the JSON API
api.lock()

# Perform a soft reset
ok, resp = api.execute('setup.reset', {'type':'soft'})

# Switch to A2B0
ok, resp = api.execute('setup.setBus', {'bus':'a2b0'})

# Switch to sub node mode
ok, resp = api.execute('setup.setMode', {'mode':'sub'})

# Activate local Mailbox interrupts
activate_irq()

print('Press "m" send a new message, or "q" to quit')
with KBHit() as kb:
    MSG = 0xFFFFFFFF
    while True:
        ok, irq = api.execute('irq.poll', {})
        if ok and irq['active']:
            if irq['A2B_INTTYPE'] == MBOX1_EMPTY_IRQ:
                print('Mailbox 1 read by main node')
            elif irq['A2B_INTTYPE'] == MBOX0_FULL_IRQ:
                print('Mailbox 0 written by main node')
                mbox_receive()
        if kb.kbhit():
            c = kb.getch()
            if c == 'q':
                break
            elif c == 'm':
                mbox_send(MSG)
                MSG = MSG - 1
        time.sleep(0.100)

# Unlock the JSON API
api.unlock()
