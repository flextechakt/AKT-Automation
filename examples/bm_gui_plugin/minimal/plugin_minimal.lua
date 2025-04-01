pretty = require('pl.pretty')

PURPLE = {177,156,217}

--[[
-- Bus Monitor GUI plugin functions
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

function plugin_event(e)
    e.event = BM_EVENTS[e.event] or e.event
    plugin_trace(e.timeStamp, pretty.write(e, ''), PURPLE)
end

