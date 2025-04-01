--[[
Lua port of the SparkFun Python Module
https://github.com/sparkfun/Qwiic_Joystick_Py/blob/main/qwiic_joystick.py
--]]
local QwiicJoystick = { }
QwiicJoystick.__index = QwiicJoystick

QwiicJoystick.i2cAddr = 0x20

QwiicJoystick.reg = {
    JOYSTICK_ID             = 0x00,
    JOYSTICK_VERSION1       = 0x01,
    JOYSTICK_VERSION2       = 0x02,
    JOYSTICK_X_MSB          = 0x03,
    JOYSTICK_X_LSB          = 0x04,
    JOYSTICK_Y_MSB          = 0x05,
    JOYSTICK_Y_LSB          = 0x06,
    JOYSTICK_BUTTON         = 0x07,
    JOYSTICK_STATUS         = 0x08,   -- 1  -> button clicked
    JOYSTICK_I2C_LOCK       = 0x09,
    JOYSTICK_CHANGE_ADDREESS = 0x0A
}

QwiicJoystick.enum = {
}

--[[
    Returns the 10-bit ADC value of the joystick horizontal position

    :return: The next button value
    :rtype: byte as integer
--]]
function QwiicJoystick:get_horizontal()
    local result1, msb = self.i2c(self.i2cAddr, { self.reg.JOYSTICK_X_MSB }, 1)
    local result2, lsb = self.i2c(self.i2cAddr, { self.reg.JOYSTICK_X_LSB }, 1)
    local ret = nil
    if result1 and result2 then
        ret = ((msb[1] << 8) | lsb[1])>>6
    end
    return ret
end

--[[
    Returns the 10-bit ADC value of the joystick vertical position

    :return: The next button value
    :rtype: byte as integer
--]]
function QwiicJoystick:get_vertical()
    local result1, msb = self.i2c(self.i2cAddr, { self.reg.JOYSTICK_Y_MSB }, 1)
    local result2, lsb = self.i2c(self.i2cAddr, { self.reg.JOYSTICK_Y_LSB }, 1)
    local ret = nil
    if result1 and result2 then
        ret = ((msb[1] << 8) | lsb[1])>>6
    end
    return ret
end

--[[
    Returns 0 button is currently being pressed.

    :return: button status
    :rtype: integer
--]]
function QwiicJoystick:get_button()
    local result, reg = self.i2c(self.i2cAddr, { self.reg.JOYSTICK_BUTTON }, 1)
    local ret = nil
    if result then
        ret = reg[1]
    end
    return ret
end

--[[
    Returns 1 if button was pressed between reads of .getButton() or .checkButton()
    the register is then cleared after read.

    :return: button status
    :rtype: integer
--]]
function QwiicJoystick:check_button()
    local result, reg = self.i2c(self.i2cAddr, { self.reg.JOYSTICK_STATUS }, 1)
    local ret = nil
    if result then
        self.i2c(self.i2cAddr, { self.reg.JOYSTICK_STATUS, 0 })
        ret = reg[1]
    end
    return ret
end

--[[
    Returns a string of the firmware version number

    :return: The firmware version
    :rtype: string
--]]
function QwiicJoystick:get_version()
    local result1, vMajor = self.i2c(self.i2cAddr, { self.reg.JOYSTICK_VERSION1 }, 1)
    local result2, vMinor = self.i2c(self.i2cAddr, { self.reg.JOYSTICK_VERSION2 }, 1)
    local ret = nil
    if result1 and result2 then
        ret = string.format('v %d.%d', vMajor[1], vMinor[1])
    end
    return ret
end

function QwiicJoystick.new(i2c)
    local _qjs = { }
    setmetatable(_qjs, QwiicJoystick)
    _qjs.i2c = i2c
    return _qjs
end

return QwiicJoystick
