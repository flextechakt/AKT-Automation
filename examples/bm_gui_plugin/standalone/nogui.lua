--[[
-- This module installs a Bus Monitor GUI compatible enviornment for
-- Plugin development outside of the GUI
--]]
BM_EVENTS = BM_EVENTS or {
  I2C = 2,
  SPI = 3,
  BUS_LOCK_LOCKED = 4,
  BUS_LOCK_UNLOCKED = 5,
  BIAS_OK_DETECTED = 6,
  BIAS_OK_REMOVED = 7,
  BIAS_REV_DETECTED = 8,
  BIAS_REV_REMOVED = 9,
  DISCOVERY_MODE = 10,
  IRQ = 11,
  DOWNSTREAM_SCF_ERROR = 12,
  UPSTREAM_SRF_ERROR = 13,
  SLAVE_ERROR = 14,
  SEQUENCE_ERROR = 15,
  I2C_A2B2 = 16,
  IRQ_QUERY_A2B2 = 17,
  IRQ_ACK_A2B2 = 18,
  DSH_ERROR_A2B2 = 19,
  USH_ERROR_A2B2 = 20,
  [2] = "I2C",
  [3] = "SPI",
  [4] = "BUS_LOCK_LOCKED",
  [5] = "BUS_LOCK_UNLOCKED",
  [6] = "BIAS_OK_DETECTED",
  [7] = "BIAS_OK_REMOVED",
  [8] = "BIAS_REV_DETECTED",
  [9] = "BIAS_REV_REMOVED",
  [10] = "DISCOVERY_MODE",
  [11] = "IRQ",
  [12] = "DOWNSTREAM_SCF_ERROR",
  [13] = "UPSTREAM_SRF_ERROR",
  [14] = "SLAVE_ERROR",
  [15] = "SEQUENCE_ERROR",
  [16] = "I2C_A2B2",
  [17] = "IRQ_QUERY_A2B2",
  [18] = "IRQ_ACK_A2B2",
  [19] = "DSH_ERROR_A2B2",
  [20] = "USH_ERROR_A2B2"
}

BM_I2C_TYPES = BM_I2C_TYPES or {
  I2C_REG = 0,
  I2C_PERIPHERAL = 1,
  I2C_PERIPHERAL_CONDITION = 2,
  [0] = "I2C_REG",
  [1] = "I2C_PERIPHERAL",
  [2] = "I2C_PERIPHERAL_CONDITION"
}

BM_I2C_SRC = BM_I2C_SRC or {
  [0] = "PE",
  [1] = "I2C",
  [2] = "SPI0",
  [3] = "SPI1",
  [4] = "BSD",
  PE = 0,
  I2C = 1,
  SPI0 = 2,
  SPI1 = 3,
  BSD = 4
}

plugin_trace = plugin_trace or function(ts, s, color) print(ts, s) end
plugin_debug = plugin_debug or plugin_trace
event_trace = event_trace or plugin_trace
