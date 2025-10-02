-- Required modules
pretty = require('pl.pretty')
master = require('master')
setup = require('setup')
irq = require('irq')
rtos = require('rtos')
term = require('term')

-- Interesting registers and bits
A2B_BECNT_REG      = 0x1F  -- Bit Error Count Register
A2B_BECCTL_REG     = 0x1E  -- Bit Error Control Register
A2B_BECCTL_ALL     = 0x1F  -- Enable All Bit Error Sources, Threshold 2
A2B_INTMSK0_REG    = 0x1B  -- Interrupt Mask 0 Register
A2B_INTMSK0_BECIEN = 0x20  -- Bit Error Interrupt Enable Bit
A2B_RAISE_REG      = 0x54  -- Interrupt Raise Register (for testing)
A2B_RAISE_BECOVF   = 0x04  -- Bit Error Counter Overflow Raise (for testing)
A2B_INTTYPE_BECOVF = 4     -- Bit Error Overflow Interrupt

-- Sub Node 0
A2B_SUB_NODE = 0

-- Perform a soft reset
ok, msg = setup.reset("soft")

-- Set the active network to A2B0
ok, msg = setup.setBus("a2b0")

-- Discover the network
ok, msg = setup.setNetwork("3x-3x.xml")
if not ok then print(msg) return end
ok, msg, nodes, retries = master.discover()
if not ok then print(msg) return end
print(string.format('Discovered %d nodes', nodes))

-- Activate local processing of Bit Error Count Overflow interrupts
irq.activate(A2B_INTTYPE_BECOVF)

-- Enable all Sub Node Bit Error sources
ok, msg = master.i2cWriteRead(A2B_SUB_NODE, { A2B_BECCTL_REG, A2B_BECCTL_ALL })
if not ok then
    print('Subnode I2C Error')
    return
end

-- Enable Sub Node Bit Error Count Interrupt (BECIEN)
ok, INTMSK = master.i2cWriteRead(A2B_SUB_NODE, { A2B_INTMSK0_REG }, 2)
INTMSK[1] = INTMSK[1] | A2B_INTMSK0_BECIEN
ok = master.i2cWriteRead(A2B_SUB_NODE, { A2B_INTMSK0_REG, INTMSK[1], INTMSK[2] })

-- Raise Sub Node Bit Error Count Overflow (BECOVF) interrupt
function raise_BECOVF()
    ok, msg = master.i2cWriteRead(A2B_SUB_NODE, { A2B_RAISE_REG, A2B_RAISE_BECOVF })
    if not ok then
        print('Error writing A2B_RAISE_REG')
    end
end

-- Read / Clear Sub Node Bit Error Count
function read_BECNT()
    ok, BECNT = master.i2cWriteRead(A2B_SUB_NODE, { A2B_BECNT_REG }, 1)
    if not ok then
        print('Error reading A2B_BECNT_REG')
    else
        print(string.format('A2B_BECNT: %u', BECNT[1]))
    end
    ok = master.i2cWriteRead(A2B_SUB_NODE, { A2B_BECNT_REG, 0 })
end

-- Show IRQ stats
function irq_stats()
    ok, stats = irq.stats()
    if ok then
        print(pretty.write(stats, ''))
    end
end

-- Main Loop
key = nil
repeat
    if key ~= -1 then
        if key == string.byte('r') then
            raise_BECOVF()
        elseif key == string.byte('s') then
            irq_stats()
        elseif key == string.byte('d') then
            print('A2B IRQ Disabled')
            irq.disable()
        elseif key == string.byte('e') then
            print('A2B IRQ Enable')
            irq.enable()
        else
            print("Functions:")
            print("  'r' - Raise subnode BECOVF interrupt")
            print("  's' - Show IRQ stats")
            print("  'd' - Disable A2B IRQ processing")
            print("  'e' - Enable A2B IRQ processing")
            print('Press "q" to quit..')
        end
    end
    ok, _IRQ = irq.next()
    if ok and _IRQ.active then
        print(pretty.write(_IRQ, ''))
        if _IRQ.type == 4 then
            read_BECNT()
        end
    end
    key = term.getchar(term.NOWAIT)
until key == string.byte('q')
