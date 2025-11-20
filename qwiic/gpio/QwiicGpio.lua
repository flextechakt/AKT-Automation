--[[
qwiic_gpio.lua

Lua library for the SparkFun Qwiic GPIO sensor.
This is a port of the Python qwiic_gpio library.

The Qwiic GPIO is an I2C device based on the TCA9534 I/O Expander IC.
It provides 8 additional GPIO pins accessible via I2C.
]]

local QwiicGPIO = {}
QwiicGPIO.__index = QwiicGPIO

-- Device information
QwiicGPIO._DEFAULT_NAME = "Qwiic GPIO"
QwiicGPIO._AVAILABLE_I2C_ADDRESS = {0x27, 0x26, 0x25, 0x24, 0x23, 0x22, 0x21, 0x20}

-- I2C Registers
QwiicGPIO.REG_INPUT_PORT = 0x00
QwiicGPIO.REG_OUTPUT_PORT = 0x01
QwiicGPIO.REG_POLARITY_INVERSION = 0x02
QwiicGPIO.REG_CONFIGURATION = 0x03

-- GPIO Pin Constants
QwiicGPIO.GPIO_OUT = 0
QwiicGPIO.GPIO_IN = 1
QwiicGPIO.GPIO_HI = 1
QwiicGPIO.GPIO_LO = 0

-- Default I2C address
QwiicGPIO._DEFAULT_I2C_ADDRESS = 0x27

-- Create a new QwiicGPIO instance
function QwiicGPIO.new(i2c_device, address)
    local self = setmetatable({}, QwiicGPIO)

    self.i2c = i2c_device or error("I2C device required")
    self.address = address or QwiicGPIO._DEFAULT_I2C_ADDRESS

    -- Initialize pin mode registers (0 = output, 1 = input)
    self.mode = 0xFF

    -- Initialize output status registers
    self.out_status = 0x00

    -- Initialize polarity inversion registers
    self.polarity = 0x00

    return self
end

-- Check if device is connected
function QwiicGPIO:isConnected()
    local status, _ = self.i2c(self.address, {self.REG_CONFIGURATION}, 1)
    return status
end

-- Initialize the device
function QwiicGPIO:begin()
    if not self:isConnected() then
        return false
    end
    return true
end

-- Set the mode (input/output) for a specific pin
function QwiicGPIO:pinMode(pin, mode)
    if pin < 0 or pin > 7 then
        error("Invalid pin number: " .. pin)
    end
    if mode == QwiicGPIO.GPIO_OUT then
        self.mode = self.mode & ~(1 << pin)
    else
        self.mode = self.mode | (1 << pin)
    end
    self:setMode()
end

-- Set digital output value for a specific pin
function QwiicGPIO:digitalWrite(pin, value)
    if pin < 0 or pin > 7 then
        error("Invalid pin number: " .. pin)
    end
    if value == QwiicGPIO.GPIO_LO then
        self.out_status = self.out_status & ~(1 << pin)
    else
        self.out_status = self.out_status | (1 << pin)
    end
    self:setGPIO()
end

-- Read digital input value from a specific pin
function QwiicGPIO:digitalRead(pin)
    if pin < 0 or pin > 7 then
        error("Invalid pin number: " .. pin)
    end
    local port_value = self:getGPIO()
    if port_value then
        return (port_value >> pin) & 0x01
    end
    return 0
end

-- Send all 8 pin modes to the device
function QwiicGPIO:setMode()
    self.i2c(self.address, {self.REG_CONFIGURATION, self.mode})
end

-- Read mode values from device and update variables
function QwiicGPIO:getMode()
    local status, value = self.i2c(self.address, {self.REG_CONFIGURATION}, 1)
    if status then
        self.mode = value[1]
        return self.mode
    end
    return nil
end

-- Send all 8 GPIO output states to the device
function QwiicGPIO:setGPIO()
    self.i2c(self.address, {self.REG_OUTPUT_PORT, self.out_status})
end

-- Read GPIO input port and update output status variables
function QwiicGPIO:getGPIO()
    local status, value = self.i2c(self.address, {self.REG_INPUT_PORT}, 1)
    if status then
        self.out_status = value[1]
        return self.out_status
    end
    return nil
end

-- Set polarity inversion for a specific pin
function QwiicGPIO:setPolarity(pin, polarity)
    if pin < 0 or pin > 7 then
        error("Invalid pin number: " .. pin)
    end

    local polarity_var = "polarity_" .. pin
    self[polarity_var] = polarity
    self:setPolarityPort()
end

-- Send all polarity inversion settings to the device
function QwiicGPIO:setPolarityPort()
    self.i2c(self.address, {self.REG_POLARITY_INVERSION, self.polarity})
end

-- Read polarity inversion values from device
function QwiicGPIO:getPolarityPort()
    local status, value = self.i2c(self.address, { self.REG_POLARITY_INVERSION }, 1)
    value = value[1]
    if status then
        self.polarity = value[1]
        return self.polarity
    end
    return nil
end

return QwiicGPIO