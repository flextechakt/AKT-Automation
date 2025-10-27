#!/usr/bin/env python

##############################################################################
# This example demonstrates the configuration and control of A2B Mailbox
# communication.  A simple incrementing or decrementing number is sent from
# one node to the other and displayed.
#
# In this configuration, MBOX 0 is the receive MBOX and MBOX 1 is the transmit
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
    'ser': 'COM52',
    'bus': 'A2B0',
    'verbose': False
}
SUB_NODE = 0

# Generic exit handler to unlock the API on script errors
def exit_handler():
    api.unlock(True)
atexit.register(exit_handler)

# Interesting registers
MBOX0CTL = 0x90
MBOX1CTL = 0x91
MBOX0B0  = 0x92
MBOX1B0  = 0x98

# Interesting defines
MBOX0_FULL_IRQ  = 48
MBOX0_EMPTY_IRQ = 49
MBOX1_FULL_IRQ  = 50
MBOX1_EMPTY_IRQ = 51

# Enable bi-directional MBOX on the selected sub node.  These registers
# are normally configured in Sigma Studio and set during discovery.  They are
# included here so this example works regardless of the network configuration.
def mbox_enable():
    MBOX_SETUP_SUB = [
        [ MBOX0CTL, 0x3D ],
        [ MBOX1CTL, 0x3F ],
    ]
    for i in range(len(MBOX_SETUP_SUB)):
        ok, resp = api.execute('master.i2cWriteRead',
            {'nodeAddr':SUB_NODE, 'wBuf':MBOX_SETUP_SUB[i], 'nRead':0})
        if not ok:
            return False

# Activate local processing of Mailbox interrupts.
# On the main node, enable:
#    49 - Mailbox 0 empty
#    50 - Mailbox 1 full
# On the sub node, enable
#    48 - Mailbox 0 full
#    51 - Mailbox 1 empty
def mbox_irq_activate():
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

# Send 4 bytes to the sub node via Mailbox 0
def mbox_send(MSG):
    print(f'Sending: {MSG:#08x}')
    MSG_BYTES = [ MBOX0B0 ]
    MSG_BYTES.extend(MSG.to_bytes(4, 'big'))
    ok, resp = api.execute('master.i2cWriteRead',
        {'nodeAddr':SUB_NODE, 'wBuf':MSG_BYTES, 'nRead':0})
    return ok

# Receive 4 bytes from the sub node via Mailbox 1
def mbox_receive():
    MSG_BYTES = [ MBOX1B0 ]
    ok, resp = api.execute('master.i2cWriteRead',
        {'nodeAddr':SUB_NODE, 'wBuf':MSG_BYTES, 'nRead':4})
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

# Discover on A2B0
print('Discover...')
ok, resp = api.execute('setup.setNetwork',
    {'network':'mbox.xml', 'type':'ss-xml'})
if not ok:
    print('setup.setNetwork() error')
    print(resp)
    exit()
ok, resp = api.execute('master.discover', {})
if not ok:
    print('master.discover() error')
    print(resp)
    exit()

# Enable sub node Mailbox 0 and Mailbox 1
mbox_enable()

# Activate local Mailbox interrupts
mbox_irq_activate()

print('Press "m" send a new message, or "q" to quit')
with KBHit() as kb:
    MSG = 0x00000001
    while True:
        ok, irq = api.execute('irq.poll', {})
        if ok and irq['active']:
            if irq['A2B_INTTYPE'] == MBOX0_EMPTY_IRQ:
                print('Mailbox 0 read by sub node')
            elif irq['A2B_INTTYPE'] == MBOX1_FULL_IRQ:
                print('Mailbox 1 written by sub node')
                mbox_receive()
        if kb.kbhit():
            c = kb.getch()
            if c == 'q':
                break
            elif c == 'm':
                mbox_send(MSG)
                MSG = MSG + 1
        time.sleep(0.100)

# Unlock the JSON API
api.unlock()
