#!/usr/bin/env python

##############################################################################
# This example demonstrates the configuration of a variety of audio sources
# and routes on an A2B Bridge Sub node.
##############################################################################
from jsonrpcclient import request
import atexit
from api import A2BBridgeAPI

# Adjust as required for your system
API_CFG = {
    #'url': 'http://169.254.205.11:4040/1',
    'ser': 'COM16',
    'bus': 'A2B0',
    'verbose': False
}
WAV_FILE = 'piano.wav'

# Generic exit handler to unlock the API on script errors
def exit_handler():
    api.unlock(True)
atexit.register(exit_handler)

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

# Route downstream slots 0 and 1 to upstream 14 and 15 respectively
ok, resp = api.execute('setup.setRoute', {'id':0, 'channels':2,
    'src':'a2b', 'srcId':0, 'srcOffset': 0,
    'dst':'a2b', 'dstId':0, 'dstOffset': 14})

# Route stereo 1KHz tone 0dB to upstream slot 2 and 3
ok, resp = api.execute('setup.setSigGen', {'id':0,
    'type':'tone', 'frequency':1000, 'amplitude':1.0})
ok, resp = api.execute('setup.setRoute', {'id':1, 'channels':2,
    'src':'gen', 'srcId':0, 'srcOffset': 0,
    'dst':'a2b', 'dstId':0, 'dstOffset': 2})

# Play stereo wav file to slots 4 and 5
ok, resp = api.execute('setup.setWave', {'id':0, 'dir':'src',
    'action':'on', 'filename':WAV_FILE})
ok, resp = api.execute('setup.setRoute', {'id':2, 'channels':2,
    'src':'wav', 'srcId':0, 'srcOffset': 0,
    'dst':'a2b', 'dstId':0, 'dstOffset': 4})

# Unlock the JSON API
api.unlock()
