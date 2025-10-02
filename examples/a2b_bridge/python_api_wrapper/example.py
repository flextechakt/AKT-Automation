#!/usr/bin/env python

##############################################################################
# Requires the following modules to be installed:
#   jsonrpcclient
##############################################################################
from jsonrpcclient import request
import atexit

from api import A2BBridgeAPI

# Generic exit handler to unlock the API on script errors
def exit_handler():
    api.unlock(True)
atexit.register(exit_handler)

# Prints Vendor, Product, Version
def print_vpv(title, VPV):
    print(title)
    print(f" Vendor: {VPV['bytes'][0]:#x}")
    print(f" Product: {VPV['bytes'][1]:#x}")
    print(f" Version: {VPV['bytes'][2]:#x}")

API_CFG = {
    #'url': 'http://169.254.205.11:4040/1',
    'ser': 'COM31',
    'bus': 'A2B0',
    'verbose': True
}

# Instantiate an API instance
api = A2BBridgeAPI(API_CFG)

# Lock the JSON API
api.lock()

# Register definitions
A2B_VENDOR_REG = 0x02

# Read local vendor, product, version
ok, VPV = api.execute('master.i2cWriteRead',
    { 'nodeAddr':-1, 'wBuf':[A2B_VENDOR_REG], 'nRead':3}
)
if ok:
    print_vpv('Local', VPV)
else:
    print('master.i2cWriteRead() error')
    print(VPV)

# Unlock the JSON API
api.unlock()
