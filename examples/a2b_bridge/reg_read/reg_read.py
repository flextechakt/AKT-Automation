import requests
import json
import serial
import time
import signal
import sys

from jsonrpcclient import request, parse, Ok, Error, parse_json

BRIDGE_COM_PORT = 'COM52'
VERBOSE = False

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
            req = json.dumps(api, separators=(',', ':'))
            if VERBOSE:
                print(req)
            req = '\x1B]0;' + req + '\x07'
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

def print_vpv(title, VPV):
    print(title)
    print(f" Vendor: {VPV['bytes'][0]:#x}")
    print(f" Product: {VPV['bytes'][1]:#x}")
    print(f" Version: {VPV['bytes'][2]:#x}")

# Register definitions
A2B_VENDOR_REG = 0x02

# Perform a soft reset
ok, resp = api.execute('setup.reset', {'type':'soft'})

# Read local vendor, product, version
ok, VPV = api.execute('master.i2cWriteRead',
    { 'nodeAddr':-1, 'wBuf':[A2B_VENDOR_REG], 'nRead':3}
)
if not ok:
    print('master.i2cWriteRead() error')
    print(VPV)
    exit()
print_vpv('Local', VPV)

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

# Read remote vendor, product, version
ok, VPV = api.execute('master.i2cWriteRead',
    { 'nodeAddr':0, 'wBuf':[A2B_VENDOR_REG], 'nRead':3}
)
if not ok:
    print('master.i2cWriteRead() error')
    print(VPV)
    exit()
print_vpv('Remote', VPV)

# Exit
print('Goodbye')
