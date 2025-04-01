pretty = require('pl.pretty')

--[[
-- Substitute Plugin compatible variables and enumerations for standalone operation
--]]
BM_EVENTS = BM_EVENTS or {BIAS_OK_DETECTED=6.0,BIAS_OK_REMOVED=7.0,BIAS_REV_DETECTED=8.0,BIAS_REV_REMOVED=9.0,BUS_LOCK_LOCKED=4.0,BUS_LOCK_UNLOCKED=5.0,DISCOVERY_MODE=10.0,DOWNSTREAM_SCF_ERROR=12.0,I2C=2.0,IRQ=11.0,SEQUENCE_ERROR=15.0,SLAVE_ERROR=14.0,SPI=3.0,UPSTREAM_SRF_ERROR=13.0,[2]="I2C",[3]="SPI",[4]="BUS_LOCK_LOCKED",[5]="BUS_LOCK_UNLOCKED",[6]="BIAS_OK_DETECTED",[7]="BIAS_OK_REMOVED",[8]="BIAS_REV_DETECTED",[9]="BIAS_REV_REMOVED",[10]="DISCOVERY_MODE",[11]="IRQ",[12]="DOWNSTREAM_SCF_ERROR",[13]="UPSTREAM_SRF_ERROR",[14]="SLAVE_ERROR",[15]="SEQUENCE_ERROR"}
BM_I2C_TYPES = {I2C_PERIPHERAL=1.0,I2C_PERIPHERAL_CONDITION=2.0,I2C_REG=0.0,[0]="I2C_REG",[1]="I2C_PERIPHERAL",[2]="I2C_PERIPHERAL_CONDITION"}

plugin_trace = plugin_trace or function(ts, s, color) print(ts, s) end
plugin_debug = plugin_debug or plugin_trace

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
