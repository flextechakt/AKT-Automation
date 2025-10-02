##############################################################################
# Requires the following modules to be installed:
#   requests
#   json
#   serial
##############################################################################
import requests
import json
import serial

from jsonrpcclient import request, parse, Ok, Error, parse_json

class A2BBridgeAPI():

    def __init__(self, config):
        self.API_LOCKED = 0
        self.OLD_BUS = None
        if not 'bus' in config:
            raise ValueError('Must set "bus" in config')
        self.bus = config['bus']
        if 'ser' in config:
            self.ser = serial.Serial(config['ser'], 115200, timeout = 5)
            self.url = None
        elif 'url' in config:
            self.url = config['url']
            self.ser = None
            pass
        else:
            raise ValueError('Must set "ser" or "url" in config')
        if 'verbose' in config:
            self.verbose = config['verbose']
        else:
            self.verbose = False

    def postRequest(self, api):
        if self.verbose:
            if self.verbose:
                print(json.dumps(api, separators=(',', ':')))
        if self.ser is not None:
            req = '\x1B]0;' + json.dumps(api) + '\x07'
            self.ser.write(req.encode())
            resp = self.ser.read_until(expected=b'\x07')
            if len(resp) > 7:
                resp = resp[4:-3].decode()
                if self.verbose:
                    print(resp)
                resp = parse_json(resp)
            else:
                return False
        else:
            response = requests.post(self.url, json=api)
            if response.status_code == 200:
                if self.verbose:
                    print(response.json())
                resp = parse(response.json())
            else:
                print('HTTP: ', response.status_code)
                return False
        ok = isinstance(resp, Ok)
        if not ok:
            print(f'Request: {api}')
            print(f'Error: {resp.code}, {resp.message}')
            return ok, resp.message
        return ok, resp.result

    def lock(self):
        if self.API_LOCKED == 0:
            ok = self.postRequest(request('api.lock', params = { }))
            if ok:
                ok, resp = self.postRequest(request('setup.getBus'))
            if ok:
                self.OLD_BUS = resp['bus']
            if ok:
                self.postRequest(request('setup.setBus', params = {'bus':self.bus}))
        self.API_LOCKED = self.API_LOCKED + 1

    def unlock(self, force=False):
        if force and self.API_LOCKED == 0:
            return
        if force:
            self.API_LOCKED = 0
        elif self.API_LOCKED > 0:
            self.API_LOCKED = self.API_LOCKED - 1
        if self.API_LOCKED == 0:
            if self.OLD_BUS is not None:
                self.postRequest(request('setup.setBus', params = {'bus':self.OLD_BUS}))
                self.OLD_BUS = None
            ok = self.postRequest(request('api.unlock', params = { }))

    def execute(self, method, p):
        ok, resp = self.postRequest(request(method, params = p))
        return ok, resp
