import requests
import json
import serial
import time
import signal
import sys

from jsonrpcclient import request, parse, Ok, Error, parse_json

BRIDGE_COM_PORT = 'COM52'

if len(sys.argv) > 1:
    BRIDGE_COM_PORT = sys.argv[1]

QUIT= False

def sig_int(sig, frame):
    global QUIT
    QUIT = True

signal.signal(signal.SIGINT, sig_int)

# Helper class for USB RESTful API
class A2BBridgeAPI():

    def __init__(self, com_port):
        self.ser = serial.Serial(com_port, 115200, timeout = 5)

    def postRequest(self, api):
        if self.ser is not None:
            req = '\x1B]0;' + json.dumps(api) + '\x07'
            self.ser.write(req.encode())
            resp = self.ser.read_until(expected=b'\x07')
            if len(resp) > 7:
                resp = parse_json(resp[4:-3].decode())
                ok = isinstance(resp, Ok)
                if not ok:
                    print(f'Request: {api}')
                    print(f'Error: {resp.code}, {resp.message}')
                    return ok, resp.message
                else:
                    return ok, resp.result
        return False, None

    def execute(self, method, p):
        ok, resp = self.postRequest(request(method, params = p))
        return ok, resp

api = A2BBridgeAPI(BRIDGE_COM_PORT)

# Perform a soft reset
ok, resp = api.execute('setup.reset', {'type':'soft'})
time.sleep(0.100)

# Set up and discover the network on A2B0
print('Discover...')
ok, resp = api.execute('setup.setBus', {'bus':'a2b0'})
ok, resp = api.execute('setup.setNetwork',
    {'network':'243x-spi-test.xml', 'type':'ss-xml'})
if not ok:
    print('setup.setNetwork() error')
    print(resp)
    exit()
ok, resp = api.execute('master.discover', {})
if not ok:
    print('master.discover() error')
    print(resp)
    exit()

# Enable ENDSNIFF bit in DATCTL
ok, resp = api.execute('master.i2cWriteRead', {
    'nodeAddr':-1, 'wBuf':[0x11, 0x23], 'nRead':0
})
if not ok:
    print('master.i2cWriteRead(DATCTL.ENDSNIFF) error')
    print(resp)
    exit()

# Create a 256 byte output buffer
outBuf = [ ]
for i in range(0, 256):
    outBuf.append(i)

#
# Loop forever doing a full-duplex poll of the SPI device on sub node 0
# chip selected by 'ADR1'.  The contents of 'outBuf' are shifted out while
# the contents of 'inBuf' are shifted in.
#
# If the 'sync' flag is true, the 'inBuf' data is from the current
# transaction.
#
# If 'sync' is false, the 'inBuf' data is from the previous transaction.
# The contents of 'inBuf' during the first transaction will be zeros.
#
# For full duplex transfers, the number of bytes read must be the same
# as the bytes written in 'outBuf'.
#

SUB_NODE = 0

print('Press any key to exit...')

loop = 0
while True:
    print('SPI Loop:', loop)
    ok, resp = api.execute('master.spiTunXfer', {
        'nodeAddr':SUB_NODE, 'wBuf':outBuf, 'nRead':len(outBuf),
        'type':9, 'ss':'ADR1', 'sync':True
    })
    if ok:
        print(resp)
    loop = loop + 1
    if QUIT:
        break

# Exit
print('Goodbye')
