--[[
;
; AKT Automation
; Discovery loop example
;
--]]
master = require("master")
setup = require("setup")
rtos = require("freertos")
term = require("term")

-- Perform a soft reset
print("Soft reset...")
ok, msg = setup.reset("soft")

-- Discover on A2B0
do
    local N = 0
    function discover()
        print(string.format("Discover #%d...", N))
        ok, msg = setup.setBus("a2b0")
        ok, msg = setup.setNetwork("3x-3x.xml")
        if not ok then
            print("setup.setNetwork() error")
            print(msg)
            return false
        end
        ok, msg, nodes, retries = master.discover()
        if not ok then
            print("master.discover() error")
            print(msg)
            return false
        end
        N = N + 1
        return 0
    end
end

-- Exit on error or keypress
repeat
    ok = discover()
    if ok then
        rtos.sleep(1)
    end
    key = term.getchar(term.NOWAIT)
until not ok or key ~= -1

-- Exit
print("Goodbye")
