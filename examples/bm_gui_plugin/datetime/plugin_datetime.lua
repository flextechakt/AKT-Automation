--[[
------------------------------------------------------------------------
-- Prints current date and time in main event trace window when
-- bus locks and unlocks
------------------------------------------------------------------------
--]]

--[[
-- Misc variables / constants
--]]
PURPLE = {177,156,217}

--[[
-- Event handlers
--]]
function bus_locked(event)
    event_trace(event.timeStamp, os.date(), PURPLE)
end

function bus_unlocked(event)
    event_trace(event.timeStamp, os.date(), PURPLE)
end

-- Unhandled Bus Monitor event
function unhandled_event(event)
    -- Do nothing
end

BM_EVENT_HANDLER = {
 [ BM_EVENTS.BUS_LOCK_LOCKED ] = bus_locked,
 [ BM_EVENTS.BUS_LOCK_UNLOCKED ] = bus_unlocked,
 [ BM_EVENTS.BIAS_OK_DETECTED ] = unhandled_event,
 [ BM_EVENTS.BIAS_OK_REMOVED ] = unhandled_event,
 [ BM_EVENTS.BIAS_REV_DETECTED ] = unhandled_event,
 [ BM_EVENTS.BIAS_REV_REMOVED ] = unhandled_event,
 [ BM_EVENTS.DOWNSTREAM_SCF_ERROR ] = unhandled_event,
 [ BM_EVENTS.UPSTREAM_SRF_ERROR ] = unhandled_event,
 [ BM_EVENTS.DISCOVERY_MODE ] = unhandled_event,
 [ BM_EVENTS.SEQUENCE_ERROR ] = unhandled_event,
 [ BM_EVENTS.SLAVE_ERROR ] = unhandled_event,
 [ BM_EVENTS.IRQ ] = unhandled_event,
 [ BM_EVENTS.I2C ] = unhandled_event,
 [ BM_EVENTS.SPI ] = unhandled_event,
 __index = function() return unhandled_event end
}
setmetatable(BM_EVENT_HANDLER, BM_EVENT_HANDLER)

--[[
-- Bus Monitor GUI plugin functions
--]]
function plugin_loaded()
    plugin_debug(0, 'Plugin Loaded')
end

function plugin_unloaded()
    plugin_debug(0, 'Plugin Unloaded')
end

function plugin_stop()
    plugin_debug(0, 'Plugin Stop')
end

function plugin_start()
    plugin_debug(0, 'Plugin Start')
end

function plugin_event(e)
    BM_EVENT_HANDLER[e.event](e)
end
