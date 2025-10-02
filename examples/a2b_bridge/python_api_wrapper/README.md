# Intro

This component manages the JSON-RPC RESTful API details for the A2B Bridge AKT Automation interface over Ethernet or USB.  It ensures thread-safe access to API functions across multiple devices, A2B ports, and APIs (Lua, RESTful Ethernet/USB, and the command-line).

# Setup

Refer to example.py for details.  Configure the API connection in API_CFG as needed.  Select either a serial port or Ethernet URL  When both are give, the serial port takes priority.  

An API object maps to a single A2B port on a device.  For example, a four port A2B Bridge would need four API instances to control all ports.

# Troubleshooting

## Verbose

Enable the 'verbose' config option to observe the underlying JSON-RPC commands.  

## API Locking

The API can be locked recursively.  When doing so, an unlock() call must be made for every lock() call.   

It is OK to call unlock() with the 'force' parameter set to 'True' set as many times as is necessary to unlock the API on the A2B Bridge should the api wrapper nesting count fall out of sync with the Python wrapper.  

This situation can occur if a Python script exits due to an exception without an exit handler enabled to call unlock()


