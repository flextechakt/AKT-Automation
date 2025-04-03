import requests
import json
import serial
import time
import signal
import sys

from jsonrpcclient import request, parse, Ok, Error, parse_json

BRIDGE_COM_PORT = 'COM39'

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

# Delay 200mS
print('Delay...')
time.sleep(0.200)

# Route two channels between USB and A2B0
print('USB/A2B0 Routes...')
ok, resp = api.execute('setup.setRoute',
    { 'id':0, 'src':'usb', 'srcId':0, 'srcOffset':0,
              'dst':'a2b', 'dstId':0, 'dstOffset':0, 'channels':2})
ok, resp = api.execute('setup.setRoute',
    { 'id':1, 'src':'a2b', 'srcId':0, 'srcOffset':0,
              'dst':'usb', 'dstId':0, 'dstOffset':0, 'channels':2})

# Route USB and A2B0 to the VU meters
print('VU Routes...')
ok, resp = api.execute('setup.setRoute',
    { 'id':0, 'src':'usb', 'srcId':0, 'srcOffset':0,
              'dst':'vu', 'dstId':0, 'dstOffset':0, 'channels':2})
ok, resp = api.execute('setup.setRoute',
    { 'id':1, 'src':'a2b', 'srcId':0, 'srcOffset':0,
              'dst':'vu', 'dstId':0, 'dstOffset':2, 'channels':2})

# Discover on A2B0
print('Discover...')
ok, resp = api.execute('setup.setBus', {'bus':'a2b0'})
ok, resp = api.execute('setup.setNetwork',
    {'network':'a2b-test.xml', 'type':'ss-xml'})
if not ok:
    print('setup.setNetwork() error')
    print(resp)
    exit()
ok, resp = api.execute('master.discover', {})
if not ok:
    print('master.discover() error')
    print(resp)
    exit()

print('Monitoring Bit Errors...')
print('Press <ctrl-c> to exit...')

A2B_BECCTL_REG = 0x1E
A2B_BECCTL_ALL = 0x1F
A2B_BECNT_REG = 0x1F
A2B_SUB_NODE = 0

# Enable monitoring of all bit errors on Sub node 0
ok, resp = api.execute('master.i2cWriteRead',
    { 'nodeAddr':A2B_SUB_NODE,
      'wBuf':[A2B_BECCTL_REG, A2B_BECCTL_ALL ], 'nRead':0})
if not ok:
    print('Error enabling BER monitoring')
    exit()


# Check for bit errors every second
# Exit on error or CTRL-C

while True:
    ok, BER = api.execute('master.i2cWriteRead',
        { 'nodeAddr':A2B_SUB_NODE, 'wBuf':[A2B_BECNT_REG], 'nRead':1}
    )
    if ok and BER['bytes'][0] >= 0:
        print(f"{BER['bytes'][0]} bit errors detected")
        ok, BER = api.execute('master.i2cWriteRead',
            { 'nodeAddr':A2B_SUB_NODE,
              'wBuf':[A2B_BECNT_REG,0], 'nRead':0}) # Clear
    else:
        if not ok:
            print(BER)
    if ok:
        time.sleep(1)
    if not ok or QUIT:
        break

# Exit
print('Goodbye')
