# Hardware Setup

## Audio save trigger button

Wire a momentary Normally Open (NO) pushbutton between GPIO 0 (pin 3) and
GND (pin 1).  The audio save feature is activated by shorting GPIO 1 to
ground.

# A2B

Wire the A2B "A" and "B" sides into the A2B network

# Automation script

1. Copy the automation script, `event_logger.lua`, to the SD card
2. Insert the SD card into the Bus Monitor

# Auto start

1. Create a `shell.cmd` on internal `sf:` filesystem to start the automation
   script.
   
   ```
   # edit sf:shell.cmd
   ```

2. Insert the the following content into the file
   
   ```
   lua event_logger.lua
   ```

3. Press `<CTRL-S>` to save the file

# Script operation

1. The Status LED will blink `GREEN` at a one second interval to indicate
   normal operation.

2. The I/O LED will illuminate `GREEN` to indicate an active A2B bus.

3. The I/O LED will illuminate `BLUE` while saving the audio buffer

4. The script saves all A2B events to a file on the SD card
   upon discovery.  This file has the same format and information as
   the Event trace in the Bus Monitor GUI.

5. The script will save up to 30 seconds of A2B audio when the momentary
   pushbutton is pressed.  The 30 second audio buffer is automatically
   started when discovery is complete and cleared upon saving.  The
   pushbutton can be pressed multiple times after discovery.

6. The name of all files is a 10 digit number of the Lua `os.time()` API
   call.  This is an actual timestamp of seconds elapsed since the
   UNIX epoch when a RTC is attached to the qwiic port or seconds elapsed
   from startup when no RTC is attached.

7. The SD card can be removed any time it is not being actively written.
   The SD card MUST be inserted whenever a file might be written.  This
   includes immediately following discovery and whenever the pushbutton
   is pressed.

# Relevant Lua modules

## term = require('term')

Terminal module. See [eLua](https://eluaproject.net/doc/v0.9/en_refman_gen_term.html) docs for more info

## bm = require('bm')

Bus Monitor API

## pio = require('pio')

Pocket I/O API

## cbuf = require('cbuf')

Circular Audio Buffer API

## route = require('route')

Audio Routing Engine API

## led = require('led')

LED control API

# Misc topics

1. Press 'q' to quit the script and return to the command line

2. The script can be re-launched with `lua event_logger.lua`

3. Refer to the Pocket A2B Bus Monitor User Guide for general command line
   usage.

4. The Lua [Penlight](https://github.com/lunarmodules/Penlight) collection
   is recommended during script development.  The `pretty` module, in
   particular, is very useful for dumping tables and module information.
   For example, the following will dump all methods and enumerations in
   the `bm` module.  To use, simply copy the penlight distribution into
   a `pl` folder on the SD card.
   
   ```
   bm = require('bm')
   pretty = require('pl.pretty')
   pretty.dump(bm)
   ```
