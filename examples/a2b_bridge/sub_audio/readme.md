# Introduction

This example demonstrates setting up a variety of signals and routes on a
Sub node A2B Bridge.

It can be run on any AD242x or AD243x A2B network.

# Setup

Ensure your Python environment has the following modules installed:

```
requests
json
serial
jsonrpcclient
```

Edit the `API_CFG` object in `audio_sub.py` as required to reflect
the COM port assigned to the A2B Bridge.

Connect the "B" side of the Main node to the "A" side of the
Sub node A2B Bridge.

Transfer `piano.wav` to the SD card of the A2B Bridge.

If using an A2B Bridge as the Main node, copy the `ad242x-ad242x-16ch-lb.xml`
and `main.cmd` script to the SD card and run it after configuring the
A2B Bridge Sub node.

# Running

In a suitable Python environment, launch `audio_sub.py` to configure the
Sub node bridge:

```
python ./audio_sub.py
```

Discover the network on the Main node using the supplied
`ad242x-ad242x-16ch-lb.xml` or similar network configuration.  Audio
from the Sub node A2B Bridge will begin immediately upon discovery.

# Notes

The A2B Bridge configuration only needs to happen once.  Audio will continue
to be routed through discovery cycles until the device configuration is
reset (i.e. soft or hard reset).