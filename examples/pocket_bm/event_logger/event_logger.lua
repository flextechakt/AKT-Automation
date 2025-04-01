--[[ Lua Modules --]]
term = require('term')
bm = require('bm')
pio = require('pio')
cbuf = require('cbuf')
route = require('route')
led = require('led')

--[[
------------------------------------------------------------------------
-- Script variables
------------------------------------------------------------------------
--]]
tracefile = nil
bias = false

--[[
------------------------------------------------------------------------
-- Helper functions
------------------------------------------------------------------------
--]]

-- Generate filename
function fileName()
  return string.format('%010d', math.floor(os.time()))
end

-- Pushbutton debounce
function debounce(bstate)
  local level = pio.gpio(bstate.gpio)
  local ret = nil
  if bstate.debounce > 0 then
    if level ~= bstate.new then
      bstate.debounce = os.clock() + 0.100
      bstate.new = level
    end
    if os.clock() > bstate.debounce then
      if level ~= bstate.level then
        bstate.level = level
        bstate.debounce = 0
        ret = bstate.level
      end
    end
  else
    if level ~= bstate.level then
      bstate.debounce = os.clock() + 0.050
      bstate.new = level
    end
  end
  return ret
end

--[[
------------------------------------------------------------------------
-- BM event trace output functions
------------------------------------------------------------------------
--]]

-- Write string to trace file
function output(x)
  if tracefile then
    tracefile:write(x)
  else
    --io.write(x)
  end
end

-- Timestamp
function printTs(ts)
  output(string.format('[ %15.6f ] ', ts))
end

-- Peripheral I2C condition events
i2c_conditions = {
  [ bm.i2c.I2C_START ] =
    function(event) return '<S> ' .. (event.rw and '<R> ' or '<W> ') end,
  [ bm.i2c.I2C_STOP ] =
    function() return '<P>\n' end,
  [ bm.i2c.I2C_RPTSTART ] =
    function(event) return '<Sr> ' .. (event.rw and '<R> ' or '<W> ') end,
  [ bm.i2c.I2C_ACK ] =
    function(event) return string.format('%02X ', event.data) end,
  [ bm.i2c.I2C_NACK ] =
    function(event) return string.format('%02X! ', event.data) end,
  [ bm.i2c.I2C_ERROR ] =
    function() return '<E> ' end,
  __index = function() return function() return '<?> ' end end
}
setmetatable(i2c_conditions, i2c_conditions)

-- Generic I2C event
function i2c(event)
  if event.type == bm.i2c.I2C_REG then
    output(string.format(
      "Node: %u, type: %s, reg: %s (0x%02X), data: 0x%02X\n",
      event.nodeAddr, event.rw and 'READ' or 'WRITE',
      bm.reg[event.addr], event.addr, event.data
    ))
  else
    if event.type == bm.i2c.I2C_PERIPHERAL then
      output(string.format(
        "Node: %u, type: PERIPH, addr: 0x%02X, i2c: ",
        event.nodeAddr, event.addr
      ))
    else
      output(i2c_conditions[event.condition](event))
    end
  end
end

-- Discovery event
function discovery(event)
  output(string.format(
    "Discovery %s, RESPCYCS 0x%02x\n",
    event.status, event.respCycles
  ))
end

-- SCF / SRF errors
function sxf(event)
  output(string.format(
    "%s ERROR: missed %u, hdcnt: %u, crc %u\n",
    event.type, event.missed, event.hdcnt, event.crc
  ))
end

-- Slave event
function se(event)
  output(string.format(
    "Slave SRF: nodeAddr: %d, %s\n",
    event.nodeAddr, event.errorStr
  ))
end

-- IRQ event
function irq(event)
  output(string.format(
    "IRQ: nodeAddr: %d, status: %02x\n",
    event.nodeAddr, event.status
  ))
end

-- Sequence error event
function seq(event)
  output(string.format(
    "Sequence Error: %u\n",
    event.seq
  ))
end

-- SPI event
function spi(event)
  if not event.error then
    output(string.format(
      "SPI: NodeAddr: %d, SS: %s, Type: %s, wLen: %u, rLen %u\n",
      event.respNode, event.ss, event.type, event.wLen, event.rLen
    ))
  else
    output(string.format(
      "SPI: NodeAddr: %d, Type: %s, Error %u\n",
      event.respNode, event.type, event.error
    ))
  end
end

-- Bias OK event
function biasOk(event)
  if tracefile then
    tracefile:close()
    tracefile = nil
  end
  local fname = fileName() .. '.txt'
  print('A2B trace start: ' .. fname)
  tracefile = io.open(fname, 'a')
  if tracefile == nil then
    print('ERROR opening ' .. fname)
  end
  cbuf.clear(); cbuf.enable()
  bias = true
  led.set('io', 'green', bias)
  output('Bias OK\n')
end

-- No bias
function noBias(event)
  bias = false
  led.set('io', 'green', bias)
  output('No Bias\n')
end

-- NEWSTRCT event
function newstrct(event)
  output(string.format(
    'NEWSTRCT: Down Slots %u, Up Slots: %u\n',
    event.dn.slots, event.up.slots
  ))
  print('A2B trace end')
  if tracefile then
    tracefile:close()
    tracefile = nil
  end
end

-- Unknown event (should never happen)
function unknown(event)
  output(string.format('Unknown Event: %d\n', event.event))
end

-- BM event handlers
BM_EVENT_HANDLER = {
 [ bm.event.BUS_LOCK_LOCKED ] = function() output('Bus Locked\n') end,
 [ bm.event.BUS_LOCK_UNLOCKED ] = function() output('Bus Unlocked\n') end,
 [ bm.event.BIAS_OK_DETECTED ] = biasOk,
 [ bm.event.BIAS_OK_REMOVED ] = noBias,
 [ bm.event.BIAS_REV_DETECTED ] = function() output('Bias Reversed\n') end,
 [ bm.event.BIAS_REV_REMOVED ] = function() output('No Bias\n') end,
 [ bm.event.DOWNSTREAM_SCF_ERROR ] = sxf,
 [ bm.event.UPSTREAM_SRF_ERROR ] = sxf,
 [ bm.event.DISCOVERY_MODE ] = discovery,
 [ bm.event.NEWSTRCT ] = newstrct,
 [ bm.event.SEQUENCE_ERROR ] = seq,
 [ bm.event.SLAVE_ERROR ] = se,
 [ bm.event.IRQ ] = irq,
 [ bm.event.I2C ] = i2c,
 [ bm.event.SPI ] = spi,
 __index = function() return unknown end
}
setmetatable(BM_EVENT_HANDLER, BM_EVENT_HANDLER)

--[[
------------------------------------------------------------------------
-- Main script
------------------------------------------------------------------------
--]]

-- Override LEDs
led.override()

-- Set GPIO 0 as input for button (active low)
pio.gpio(0, 'dir', 'in')

-- Initialize button state
bstate = { gpio = 0, debounce = 0, level = pio.gpio(0) }

-- Configure the audio circular buffer
-- 2-channels, 16-bit, 30 seconds
cbuf.reset()
cbuf.config(2, 2, 5760000)

-- Route the first two downstream audio slots to the circular buffer.
route.clear()
route.set(0, 'a2b-dn', 0, 'cbuf', 0, 2)

-- Subscribe to relevant BM events
bm.subscribe(bm.event.BUS_LOCK_LOCKED)
bm.subscribe(bm.event.BUS_LOCK_UNLOCKED)
bm.subscribe(bm.event.BIAS_OK_DETECTED)
bm.subscribe(bm.event.BIAS_OK_REMOVED)
bm.subscribe(bm.event.BIAS_REV_DETECTED)
bm.subscribe(bm.event.BIAS_REV_REMOVED)
bm.subscribe(bm.event.DISCOVERY_MODE)
bm.subscribe(bm.event.DOWNSTREAM_SCF_ERROR)
bm.subscribe(bm.event.UPSTREAM_SRF_ERROR)
bm.subscribe(bm.event.I2C)
bm.subscribe(bm.event.SPI)
bm.subscribe(bm.event.SLAVE_ERROR)
bm.subscribe(bm.event.SEQUENCE_ERROR)
bm.subscribe(bm.event.IRQ)
bm.subscribe(bm.event.NEWSTRCT)

-- Misc setup
ledtimer = os.time()

-- Loop
print('Flextech AKT Pocket Bus Monitor')
print('AKT Automation Example')
print('Press "q" to quit...')
repeat
  -- Process BM events
  status = bm.status()
  if status.events > 0 then
    event = bm.getEvent()
    if event.event ~= bm.event.I2C or
       event.type ~= bm.i2c.I2C_PERIPHERAL_CONDITION then
      printTs(event.timeStamp)
    end
    BM_EVENT_HANDLER[event.event](event)
  end
  -- Check the audio save button
  btn = debounce(bstate)
  if btn == false then
    local fname = fileName() .. '.wav'
    print("Audio save: " .. fname)
    led.set('io', 'all', 0); led.set('io', 'blue', 1)
    cbuf.save(fname); cbuf.clear()
    led.set('io', 'all', 0); led.set('io', 'green', bias)
    print('Audio save done')
  end
  -- LED
  if os.time() ~= ledtimer then
    if os.time() & 1 == 1 then
      led.set('status', 'green', 1)
    else
      led.set('status', 'green', 0)
    end
    ledtimer = os.time()
  end
  -- Exit on keypress
  key = term.getchar(term.NOWAIT)
  if key ~= -1 and key ~= string.byte('q') then
    print('Press "q" to quit...')
  end
until key == string.byte('q')

print(string.format('Dropped %d events\n', bm.status().dropped))

