--[[
-- This module parses a select set of event trace log items and creates
-- GUI plugin event objects for plugin testing.
--
-- It demonstrates plugin development outside of the GUI but can also be
-- loaded into the GUI with no changes.
--]]
pretty = require('pl.pretty')
nogui = require('nogui')

--[[
-- Bus Monitor GUI Plugin functions
--]]
function plugin_loaded()
    plugin_trace(0, 'Plugin Loaded')
end

function plugin_unloaded()
    plugin_trace(0, 'Plugin Unloaded')
end

function plugin_stop()
    plugin_trace(0, 'Plugin Stop')
end

function plugin_start()
    plugin_trace(0, 'Plugin Start')
end

function plugin_event(event)
    e.event = BM_EVENTS[e.event] or e.event
    plugin_trace(e.timeStamp, pretty.write(e, ''), PURPLE)
end

-- Load test file if not running as a plugin
if not BM_GUI_PLUGIN then
    plugin_loaded();
    plugin_start();
    file = arg[1]
    for line in io.lines(file) do
        print(line)
        -- Create BUS_LOCK_LOCKED event
        ts = string.match(line, '^%[(.*)%].*Bus Locked')
        if ts then
            e = {
                timeStamp = tonumber(ts), event = BM_EVENTS.BUS_LOCK_LOCKED
            }
            plugin_event(e)
        end
        -- Create BUS_LOCK_UNLOCKED event
        ts = string.match(line, '^%[(.*)%].*Bus Unlocked')
        if ts then
            e = {
                timeStamp = tonumber(ts), event = BM_EVENTS.BUS_LOCK_UNLOCKED
            }
            plugin_event(e)
        end
        -- Create I2C -> I2C_REG event
        ts,node,dir,reg,data = string.match(line, '^%[(.*)%].*Node.*(%d+).*type: (%a+).*%((.*)%).*data: (.*)$')
        if not ts then
            ts,dir,reg,data = string.match(line, '^%[(.*)%].*Node: BROADCAST, type: (%a+).*%((.*)%).*data: (.*)$')
            if ts then
                node = 255
            end
        end
        if ts then
            --print(ts,node,dir,reg,data)
            e = {
                timeStamp = tonumber(ts), event = BM_EVENTS.I2C, type = BM_I2C_TYPES.I2C_REG,
                nodeAddr = tonumber(node), rw = dir == 'READ',
                addr = tonumber(reg), data = tonumber(data)
            }
            plugin_event(e)
        end
    end
    plugin_stop();
    plugin_unloaded();
end
