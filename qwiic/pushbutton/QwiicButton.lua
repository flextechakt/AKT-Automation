local QwiicButton = { }
QwiicButton.__index = QwiicButton

QwiicButton.i2cAddr = 0x6F

QwiicButton.reg = {
    SFE_QWIIC_BUTTON_ID = 0x00,
    SFE_QWIIC_BUTTON_FIRMWARE_MINOR = 0x01,
    SFE_QWIIC_BUTTON_FIRMWARE_MAJOR = 0x02,
    SFE_QWIIC_BUTTON_BUTTON_STATUS = 0x03,
    SFE_QWIIC_BUTTON_INTERRUPT_CONFIG = 0x04,
    SFE_QWIIC_BUTTON_BUTTON_DEBOUNCE_TIME = 0x05,
    SFE_QWIIC_BUTTON_PRESSED_QUEUE_STATUS = 0x07,
    SFE_QWIIC_BUTTON_PRESSED_QUEUE_FRONT = 0x08,
    SFE_QWIIC_BUTTON_PRESSED_QUEUE_BACK = 0x0C,
    SFE_QWIIC_BUTTON_CLICKED_QUEUE_STATUS = 0x10,
    SFE_QWIIC_BUTTON_CLICKED_QUEUE_FRONT = 0x11,
    SFE_QWIIC_BUTTON_CLICKED_QUEUE_BACK = 0x15,
    SFE_QWIIC_BUTTON_LED_BRIGHTNESS = 0x19,
    SFE_QWIIC_BUTTON_LED_PULSE_GRANULARITY = 0x1A,
    SFE_QWIIC_BUTTON_LED_PULSE_CYCLE_TIME = 0x1B,
    SFE_QWIIC_BUTTON_LED_PULSE_OFF_TIME = 0x1D,
    SFE_QWIIC_BUTTON_I2C_ADDRESS = 0x1F,
}

QwiicButton.enum = {
    SFE_QWIIC_BUTTON_STATUS_EVENT_AVAILABLE = 1,
    SFE_QWIIC_BUTTON_STATUS_EVENT_HAS_BEEN_CLICKED = 2,
    SFE_QWIIC_BUTTON_STATUS_EVENT_IS_PRESSED = 4
}

--[[
/*------------------------------ Button Status ---------------------- */
--]]
function QwiicButton:isPressed()
    ok, reg = self:readSingleRegister(self.reg.SFE_QWIIC_BUTTON_BUTTON_STATUS)
    local value
    if ok then
        value = reg & self.enum.SFE_QWIIC_BUTTON_STATUS_EVENT_IS_PRESSED ~= 0
    end
    return value
end

--[[
/*------------------------ LED Configuration ------------------------ */
--]]
function QwiicButton:LEDconfig(brightness, cycleTime, offTime, granularity)
    if granularity == nil then
        granularity = 1
    end
    local success = self:writeSingleRegister(self.reg.SFE_QWIIC_BUTTON_LED_BRIGHTNESS, brightness)
    success = success and self:writeSingleRegister(self.reg.SFE_QWIIC_BUTTON_LED_PULSE_GRANULARITY, granularity)
    success = success and self:writeDoubleRegister(self.reg.SFE_QWIIC_BUTTON_LED_PULSE_CYCLE_TIME, cycleTime)
    success = success and self:writeDoubleRegister(self.reg.SFE_QWIIC_BUTTON_LED_PULSE_OFF_TIME, offTime)
    return success;
end

function QwiicButton:LEDoff()
    return self:LEDconfig(0, 0, 0)
end

function QwiicButton:LEDon(brightness)
    if brightness == nil then
        brightness = 255
    end
    return self:LEDconfig(brightness, 0, 0)
end

--[[
/*------------------------- Internal I2C Abstraction ---------------- */
--]]
function QwiicButton:writeSingleRegister(reg, data)
    local result = self.i2c(self.i2cAddr, {reg, data})
    return result
end

function QwiicButton:writeDoubleRegister(reg, data)
    local result = self.i2c(self.i2cAddr, {reg, data & 0xFF, (data >> 8) & 0xFF})
    return result
end

function QwiicButton:readSingleRegister(reg)
    local result, reg = self.i2c(self.i2cAddr, { reg }, 1)
    local value
    if result then
        value = reg[1]
    end
    return result, value
end

function QwiicButton:readDoubleRegister(reg)
    local result, reg = self.i2c(self.i2cAddr, { reg }, 2)
    local value
    if result then
        value = reg[1] | (reg[2] << 8)
    end
    return result, value
end

function QwiicButton.new(i2c)
    local _qb = { }
    setmetatable(_qb, QwiicButton)
    _qb.i2c = i2c
    return _qb
end

return QwiicButton
