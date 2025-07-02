pretty = require('pl.pretty')

PURPLE = {177,156,217}

--[[
-- Bus Monitor GUI plugin functions
--]]
function plugin_loaded()
    plugin_debug(0, 'Plugin Loaded')
    plugin_debug(0, os.date())
end

function plugin_unloaded()
    plugin_debug(0, 'Plugin Unloaded')
    plugin_debug(0, os.date())
end

function plugin_stop()
    plugin_debug(0, 'Plugin Stop')
    plugin_debug(0, os.date())
end

function plugin_start()
    plugin_debug(0, 'Plugin Start')
    plugin_debug(0, os.date())
end

function plugin_event(e)
    e.event = BM_EVENTS[e.event] or e.event
    event_trace(e.timeStamp, pretty.write(e, ''), PURPLE)
    plugin_trace(e.timeStamp, pretty.write(e, ''), PURPLE)
end
