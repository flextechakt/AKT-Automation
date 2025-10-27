# Introduction

This example demonstates the setup and execution of bi-directional
Mailbox communication between A2B nodes using the RESTful interface
of the A2B Bridge.

It can be run on any AD242x or AD243x A2B network.

# Setup

Ensure your Python environment has the following modules installed:

```
requests
json
serial
jsonrpcclient
```

Edit the `API_CFG` object in both `mbox_sub.py` and `mbox_main.py` as
required to reflect the COM ports assigned to the A2B Bridges.

Connect the "B" side of the A2B Bridge Main node to the "A" side of
the A2B Bridge Sub node.

Transfer `mbox.xml` to the SD card on your Main node A2B Bridge.

# Running

In a suitable Python environment, launch `mbox_sub.py` to configure the
A2B Bridge Sub node:

```
python ./mbox_sub.py
```

In a separate Python window, launch `mbox_main.py` to discover the
network and configure the mailboxes:

```
python ./mbox_main.py
```

From either node, press 'm' to send a message to the other node.  Press
'q' to quit.

# Notes

It is very helpful to insert a Pocket A2B Bus Monitor between the nodes to
capture the underlying traffic for a deeper understanding of the
mailbox communication and interrupts.
