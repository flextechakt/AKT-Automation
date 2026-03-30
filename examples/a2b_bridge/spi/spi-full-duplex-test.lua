--[[
--
-- Brief documentation for built-in modules can be printed by calling
-- the modules help() method, i.e. 'master.help()'
--
-- The term module is documented here:
--   http://www.eluaproject.net/doc/master/en_refman_gen_term.html
--
-- The latest Penlight modules can be downloaded here:
--   https://github.com/lunarmodules/Penlight
--
-- Place the 'pl' directory at the root of the SD card
--
-- The Penlight modules are documented here:
--   http://stevedonovan.github.io/Penlight/api/index.html
--
-- Place this script at the root of the SD card.
--
--]]

-- Built-in A2B and system modules
master = require('master')
setup = require('setup')
rtos = require('freertos')

-- eLua modules
term = require('term')

-- Penlight modules
pretty=require('pl.pretty')

-- Perform a soft reset
assert(setup.reset('soft'))
assert(rtos.delay(0.100))

-- Set up and discover the network on A2B0
assert(setup.setBus('a2b0'))
assert(setup.setNetwork('243x-spi-test.xml'))
assert(master.discover())

-- Enable ENDSNIFF bit in DATCTL
assert(master.i2cWriteRead(-1, { 0x11, 0x23 }, 0))

-- Create a zero filled 256 byte output buffer
outBuf = { }
for i = 1, 256 do
    outBuf[i] = i - 1
end

--[[
--
-- Loop forever doing a full-duplex poll of the SPI device on sub node 0
-- chip selected by 'ADR1'.  The contents of 'outBuf' are shifted out while
-- the contents of 'inBuf' are shifted in.
--
-- If the 'sync' flag is true, the 'inBuf' data is from the current
-- transaction.
--
-- If 'sync' is false, the 'inBuf' data is from the previous transaction.
-- The contents of 'inBuf' during the first transaction will be zeros.
--
-- For full duplex transfers, the number of bytes read must be the same
-- as the bytes written in 'outBuf'.
--
--]]

SUB_NODE = 0

print('Press any key to exit...')

loop = 1
repeat
    print(string.format('SPI Loop: %u', loop))
    ok, inBuf = master.spiTunXfer(
        SUB_NODE, master.FULL_DUPLEX, outBuf, #outBuf, 'ADR1', false
    )
    if ok then
       print(string.format('%s', pretty.write(inBuf,'',false)))
    else
       print(string.format('spiTunXfer() Error: %s\n', inBuf))
    end
    key = term.getchar(term.NOWAIT)
    loop = loop + 1
until key ~= -1

print("Done.")
