# Overview

This script dumps all Bus Monitor events to the console.  It requires the
Penlight 'pretty' module for proper operation.

Copy entire contents of this folder to the SD card on the Pocket Bus Monitor.

# Run

   ```
   # lua event_dumper.lua
   ```

# Misc topics

1. Press 'q' to quit the script and return to the command line

2. Refer to the Pocket A2B Bus Monitor User Guide for general command line
   usage.

3. The Lua [Penlight](https://github.com/lunarmodules/Penlight) collection
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
