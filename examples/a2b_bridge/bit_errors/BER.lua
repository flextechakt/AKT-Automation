--[[
;
; AKT Automation
; Discovery and bit error example
;
--]]
master = require("master")
setup = require("setup")
rtos = require("freertos")
term = require("term")

-- Perform a soft reset
print("Soft reset...")
ok, msg = setup.reset("soft")

-- Delay 200mS
print("Delay...")
ok, msg = rtos.delay(0.200)

-- Route two channels between USB and A2B0
print("USB/A2B0 Routes...")
ok, msg = setup.setRoute(0, 'usb', 0, 0, 'a2b', 0, 0, 2)
ok, msg = setup.setRoute(1, 'a2b', 0, 0, 'usb', 0, 0, 2)
-- Route USB and A2B0 to the VU meters
print("VU Routes...")
ok, msg = setup.setRoute(2, 'usb', 0, 0, 'vu', 0, 0, 2)
ok, msg = setup.setRoute(3, 'a2b', 0, 0, 'vu', 0, 2, 2)

-- Discover on A2B0
print("Discover...")
ok, msg = setup.setBus("a2b0")
ok, msg = setup.setNetwork("a2b-test.xml")
if not ok then
    print("setup.setNetwork() error")
    print(msg)
    return
end
ok, msg, nodes, retries = master.discover()
if not ok then
    print("master.discover() error")
    print(msg)
    return
end

print("Monitoring Bit Errors...")
print("Press any key to exit...")

A2B_BECCTL_REG = 0x1E
A2B_BECCTL_ALL = 0x1F
A2B_BECNT_REG = 0x1F
A2B_SUB_NODE = 0

-- Enable monitoring of all bit errors on Sub node 0
ok = master.i2cWriteRead(A2B_SUB_NODE, { A2B_BECCTL_REG, A2B_BECCTL_ALL })
if not ok then
    print("Error enabling BER monitoring")
    return
end

-- Check for bit errors every second
-- Exit on error or keypress
repeat
    ok, BER = master.i2cWriteRead(A2B_SUB_NODE, { A2B_BECNT_REG }, 1)
    if ok and BER[1] > 0 then
        print(string.format("%u bit errors detected", BER[1]))
        master.i2cWriteRead(A2B_SUB_NODE, { A2B_BECNT_REG, 0 }) -- Clear
    else
        if not ok then
            print(BER)
        end
    end
    if ok then
        rtos.sleep(1)
    end
    key = term.getchar(term.NOWAIT)
until not ok or key ~= -1

-- Exit
print("Goodbye")
