local wm8960 = { }
wm8960.__index = wm8960

wm8960.i2cAddr = 0x1A

wm8960.reg = {
    -- WM8960 register addresses
    WM8960_REG_LEFT_INPUT_VOLUME = 0x00,
    WM8960_REG_RIGHT_INPUT_VOLUME = 0x01,
    WM8960_REG_LOUT1_VOLUME = 0x02,
    WM8960_REG_ROUT1_VOLUME = 0x03,
    WM8960_REG_CLOCKING_1 = 0x04,
    WM8960_REG_ADC_DAC_CTRL_1 = 0x05,
    WM8960_REG_ADC_DAC_CTRL_2 = 0x06,
    WM8960_REG_AUDIO_INTERFACE_1 = 0x07,
    WM8960_REG_CLOCKING_2 = 0x08,
    WM8960_REG_AUDIO_INTERFACE_2 = 0x09,
    WM8960_REG_LEFT_DAC_VOLUME = 0x0A,
    WM8960_REG_RIGHT_DAC_VOLUME = 0x0B,
    WM8960_REG_RESET = 0x0F,
    WM8960_REG_3D_CONTROL = 0x10,
    WM8960_REG_ALC1 = 0x11,
    WM8960_REG_ALC2 = 0x12,
    WM8960_REG_ALC3 = 0x13,
    WM8960_REG_NOISE_GATE = 0x14,
    WM8960_REG_LEFT_ADC_VOLUME = 0x15,
    WM8960_REG_RIGHT_ADC_VOLUME = 0x16,
    WM8960_REG_ADDITIONAL_CONTROL_1 = 0x17,
    WM8960_REG_ADDITIONAL_CONTROL_2 = 0x18,
    WM8960_REG_PWR_MGMT_1 = 0x19,
    WM8960_REG_PWR_MGMT_2 = 0x1A,
    WM8960_REG_ADDITIONAL_CONTROL_3 = 0x1B,
    WM8960_REG_ANTI_POP_1 = 0x1C,
    WM8960_REG_ANTI_POP_2 = 0x1D,
    WM8960_REG_ADCL_SIGNAL_PATH = 0x20,
    WM8960_REG_ADCR_SIGNAL_PATH = 0x21,
    WM8960_REG_LEFT_OUT_MIX_1 = 0x22,
    WM8960_REG_RIGHT_OUT_MIX_2 = 0x25,
    WM8960_REG_MONO_OUT_MIX_1 = 0x26,
    WM8960_REG_MONO_OUT_MIX_2 = 0x27,
    WM8960_REG_LOUT2_VOLUME = 0x28,
    WM8960_REG_ROUT2_VOLUME = 0x29,
    WM8960_REG_MONO_OUT_VOLUME = 0x2A,
    WM8960_REG_INPUT_BOOST_MIXER_1 = 0x2B,
    WM8960_REG_INPUT_BOOST_MIXER_2 = 0x2C,
    WM8960_REG_BYPASS_1 = 0x2D,
    WM8960_REG_BYPASS_2 = 0x2E,
    WM8960_REG_PWR_MGMT_3 = 0x2F,
    WM8960_REG_ADDITIONAL_CONTROL_4 = 0x30,
    WM8960_REG_CLASS_D_CONTROL_1 = 0x31,
    WM8960_REG_CLASS_D_CONTROL_3 = 0x33,
    WM8960_REG_PLL_N = 0x34,
    WM8960_REG_PLL_K_1 = 0x35,
    WM8960_REG_PLL_K_2 = 0x36,
    WM8960_REG_PLL_K_3 = 0x37
}

wm8960.enum = {
    -- PGA input selections
    WM8960_PGAL_LINPUT2 = 0,
    WM8960_PGAL_LINPUT3 = 1,
    WM8960_PGAL_VMID = 2,
    WM8960_PGAR_RINPUT2 = 0,
    WM8960_PGAR_RINPUT3 = 1,
    WM8960_PGAR_VMID = 2,

    -- Mic (aka PGA) BOOST gain options
    WM8960_MIC_BOOST_GAIN_0DB = 0,
    WM8960_MIC_BOOST_GAIN_13DB = 1,
    WM8960_MIC_BOOST_GAIN_20DB = 2,
    WM8960_MIC_BOOST_GAIN_29DB = 3,

    -- Boost Mixer gain options
    -- These are used to control the gain (aka volume) at the following settings:
    -- LIN2BOOST
    -- LIN3BOOST
    -- RIN2BOOST
    -- RIN3BOOST
    WM8960_BOOST_MIXER_GAIN_MUTE = 0,
    WM8960_BOOST_MIXER_GAIN_NEG_12DB = 1,
    WM8960_BOOST_MIXER_GAIN_NEG_9DB = 2,
    WM8960_BOOST_MIXER_GAIN_NEG_6DB = 3,
    WM8960_BOOST_MIXER_GAIN_NEG_3DB = 4,
    WM8960_BOOST_MIXER_GAIN_0DB = 5,
    WM8960_BOOST_MIXER_GAIN_3DB = 6,
    WM8960_BOOST_MIXER_GAIN_6DB = 7,

    -- Output Mixer gain options
    -- These are used to control the gain (aka volume) at the following settings:
    -- LI2LOVOL
    -- LB2LOVOL
    -- RI2LOVOL
    -- RB2LOVOL
    -- These are useful as analog bypass signal path options.
    WM8960_OUTPUT_MIXER_GAIN_0DB = 0,
    WM8960_OUTPUT_MIXER_GAIN_NEG_3DB = 1,
    WM8960_OUTPUT_MIXER_GAIN_NEG_6DB = 2,
    WM8960_OUTPUT_MIXER_GAIN_NEG_9DB = 3,
    WM8960_OUTPUT_MIXER_GAIN_NEG_12DB = 4,
    WM8960_OUTPUT_MIXER_GAIN_NEG_15DB = 5,
    WM8960_OUTPUT_MIXER_GAIN_NEG_18DB = 6,
    WM8960_OUTPUT_MIXER_GAIN_NEG_21DB = 7,

    -- Mic Bias voltage options
    WM8960_MIC_BIAS_VOLTAGE_0_9_AVDD = 0,
    WM8960_MIC_BIAS_VOLTAGE_0_65_AVDD = 1,

    -- SYSCLK divide
    WM8960_SYSCLK_DIV_BY_1 = 0,
    WM8960_SYSCLK_DIV_BY_2 = 2,
    WM8960_CLKSEL_MCLK = 0,
    WM8960_CLKSEL_PLL = 1,
    WM8960_PLL_MODE_INTEGER = 0,
    WM8960_PLL_MODE_FRACTIONAL = 1,
    WM8960_PLLPRESCALE_DIV_1 = 0,
    WM8960_PLLPRESCALE_DIV_2 = 1,

    -- Class d clock divide
    WM8960_DCLKDIV_16 = 7,

    -- Word length settings (aka bits per sample)
    -- Audio Data Word Length
    WM8960_WL_16BIT = 0,
    WM8960_WL_20BIT = 1,
    WM8960_WL_24BIT = 2,
    WM8960_WL_32BIT = 3,

    -- Additional Digital Audio Interface controls
    -- LRP (aka left-right-polarity)
    -- Right, left and I2S modes – LRCLK polarity
    -- 000 = normal LRCLK polarity
    -- 1 = inverted LRCLK polarity
    WM8960_LR_POLARITY_NORMAL = 0,
    WM8960_LR_POLARITY_INVERT = 1,

    -- ALRSWAP (aka ADC left/right swap)
    -- Left/Right ADC channel swap
    -- 1 = Swap left and right ADC data in audio interface
    -- 000 = Output left and right data as normal
    WM8960_ALRSWAP_NORMAL = 0,
    WM8960_ALRSWAP_SWAP = 1,

    -- Gain mins, maxes, offsets and step-sizes for all the amps within the codec.
    WM8960_PGA_GAIN_MIN = -17.25,
    WM8960_PGA_GAIN_MAX = 30.00,
    WM8960_PGA_GAIN_OFFSET = 17.25,
    WM8960_PGA_GAIN_STEPSIZE = 0.75,
    WM8960_HP_GAIN_MIN = -73.00,
    WM8960_HP_GAIN_MAX = 6.00,
    WM8960_HP_GAIN_OFFSET = 121.00,
    WM8960_HP_GAIN_STEPSIZE = 1.00,
    WM8960_SPEAKER_GAIN_MIN = -73.00,
    WM8960_SPEAKER_GAIN_MAX = 6.00,
    WM8960_SPEAKER_GAIN_OFFSET = 121.00,
    WM8960_SPEAKER_GAIN_STEPSIZE = 1.00,
    WM8960_ADC_GAIN_MIN = -97.00,
    WM8960_ADC_GAIN_MAX = 30.00,
    WM8960_ADC_GAIN_OFFSET = 97.50,
    WM8960_ADC_GAIN_STEPSIZE = 0.50,
    WM8960_DAC_GAIN_MIN = -97.00,
    WM8960_DAC_GAIN_MAX = 30.00,
    WM8960_DAC_GAIN_OFFSET = 97.50,
    WM8960_DAC_GAIN_STEPSIZE = 0.50,

    -- Automatic Level Control Modes
    WM8960_ALC_MODE_OFF = 0,
    WM8960_ALC_MODE_RIGHT_ONLY = 1,
    WM8960_ALC_MODE_LEFT_ONLY = 2,
    WM8960_ALC_MODE_STEREO = 3,

    -- Automatic Level Control Target Level dB
    WM8960_ALC_TARGET_LEVEL_NEG_22_5DB = 0,
    WM8960_ALC_TARGET_LEVEL_NEG_21DB = 1,
    WM8960_ALC_TARGET_LEVEL_NEG_19_5DB = 2,
    WM8960_ALC_TARGET_LEVEL_NEG_18DB = 3,
    WM8960_ALC_TARGET_LEVEL_NEG_16_5DB = 4,
    WM8960_ALC_TARGET_LEVEL_NEG_15DB = 5,
    WM8960_ALC_TARGET_LEVEL_NEG_13_5DB = 6,
    WM8960_ALC_TARGET_LEVEL_NEG_12DB = 7,
    WM8960_ALC_TARGET_LEVEL_NEG_10_5DB = 8,
    WM8960_ALC_TARGET_LEVEL_NEG_9DB = 9,
    WM8960_ALC_TARGET_LEVEL_NEG_7_5DB = 10,
    WM8960_ALC_TARGET_LEVEL_NEG_6DB = 11,
    WM8960_ALC_TARGET_LEVEL_NEG_4_5DB = 12,
    WM8960_ALC_TARGET_LEVEL_NEG_3DB = 13,
    WM8960_ALC_TARGET_LEVEL_NEG_1_5DB = 14,

    -- Automatic Level Control Max Gain Level dB
    WM8960_ALC_MAX_GAIN_LEVEL_NEG_12DB = 0,
    WM8960_ALC_MAX_GAIN_LEVEL_NEG_6DB = 1,
    WM8960_ALC_MAX_GAIN_LEVEL_0DB = 2,
    WM8960_ALC_MAX_GAIN_LEVEL_6DB = 3,
    WM8960_ALC_MAX_GAIN_LEVEL_12DB = 4,
    WM8960_ALC_MAX_GAIN_LEVEL_18DB = 5,
    WM8960_ALC_MAX_GAIN_LEVEL_24DB = 6,
    WM8960_ALC_MAX_GAIN_LEVEL_30DB = 7,

    -- Automatic Level Control Min Gain Level dB
    WM8960_ALC_MIN_GAIN_LEVEL_NEG_17_25DB = 0,
    WM8960_ALC_MIN_GAIN_LEVEL_NEG_11_25DB = 1,
    WM8960_ALC_MIN_GAIN_LEVEL_NEG_5_25DB = 2,
    WM8960_ALC_MIN_GAIN_LEVEL_0_75DB = 3,
    WM8960_ALC_MIN_GAIN_LEVEL_6_75DB = 4,
    WM8960_ALC_MIN_GAIN_LEVEL_12_75DB = 5,
    WM8960_ALC_MIN_GAIN_LEVEL_18_75DB = 6,
    WM8960_ALC_MIN_GAIN_LEVEL_24_75DB = 7,

    -- Automatic Level Control Hold Time (MS and SEC)
    WM8960_ALC_HOLD_TIME_0MS = 0,
    WM8960_ALC_HOLD_TIME_3MS = 1,
    WM8960_ALC_HOLD_TIME_5MS = 2,
    WM8960_ALC_HOLD_TIME_11MS = 3,
    WM8960_ALC_HOLD_TIME_21MS = 4,
    WM8960_ALC_HOLD_TIME_43MS = 5,
    WM8960_ALC_HOLD_TIME_85MS = 6,
    WM8960_ALC_HOLD_TIME_170MS = 7,
    WM8960_ALC_HOLD_TIME_341MS = 8,
    WM8960_ALC_HOLD_TIME_682MS = 9,
    WM8960_ALC_HOLD_TIME_1365MS = 10,
    WM8960_ALC_HOLD_TIME_3SEC = 11,
    WM8960_ALC_HOLD_TIME_5SEC = 12,
    WM8960_ALC_HOLD_TIME_10SEC = 13,
    WM8960_ALC_HOLD_TIME_23SEC = 14,
    WM8960_ALC_HOLD_TIME_44SEC = 15,

    -- Automatic Level Control Decay Time (MS and SEC)
    WM8960_ALC_DECAY_TIME_24MS = 0,
    WM8960_ALC_DECAY_TIME_48MS = 1,
    WM8960_ALC_DECAY_TIME_96MS = 2,
    WM8960_ALC_DECAY_TIME_192MS = 3,
    WM8960_ALC_DECAY_TIME_384MS = 4,
    WM8960_ALC_DECAY_TIME_768MS = 5,
    WM8960_ALC_DECAY_TIME_1536MS = 6,
    WM8960_ALC_DECAY_TIME_3SEC = 7,
    WM8960_ALC_DECAY_TIME_6SEC = 8,
    WM8960_ALC_DECAY_TIME_12SEC = 9,
    WM8960_ALC_DECAY_TIME_24SEC = 10,

    -- Automatic Level Control Attack Time (MS and SEC)
    WM8960_ALC_ATTACK_TIME_6MS = 0,
    WM8960_ALC_ATTACK_TIME_12MS = 1,
    WM8960_ALC_ATTACK_TIME_24MS = 2,
    WM8960_ALC_ATTACK_TIME_482MS = 3,
    WM8960_ALC_ATTACK_TIME_964MS = 4,
    WM8960_ALC_ATTACK_TIME_1928MS = 5,
    WM8960_ALC_ATTACK_TIME_3846MS = 6,
    WM8960_ALC_ATTACK_TIME_768MS = 7,
    WM8960_ALC_ATTACK_TIME_1536MS = 8,
    WM8960_ALC_ATTACK_TIME_3SEC = 9,
    WM8960_ALC_ATTACK_TIME_6SEC = 10,

    -- Speaker Boost Gains (DC and AC)
    WM8960_SPEAKER_BOOST_GAIN_0DB = 0,
    WM8960_SPEAKER_BOOST_GAIN_2_1DB = 1,
    WM8960_SPEAKER_BOOST_GAIN_2_9DB = 2,
    WM8960_SPEAKER_BOOST_GAIN_3_6DB = 3,
    WM8960_SPEAKER_BOOST_GAIN_4_5DB = 4,
    WM8960_SPEAKER_BOOST_GAIN_5_1DB = 5,

    -- VMIDSEL settings
    WM8960_VMIDSEL_DISABLED = 0,
    WM8960_VMIDSEL_2X50KOHM = 1,
    WM8960_VMIDSEL_2X250KOHM = 2,
    WM8960_VMIDSEL_2X5KOHM = 3,

    -- VREF to Analogue Output Resistance
    -- (Disabled Outputs)
    -- 000 = 500 VMID to output
    -- 1 = 20k VMID to output
    WM8960_VROI_500 = 0,
    WM8960_VROI_20K = 1,

    -- Analogue Bias Optimisation
    -- 00 = Reserved
    -- 01 = Increased bias current optimized for
    -- AVDD=2.7V
    -- 1X = Lowest bias current, optimized for
    -- AVDD=3.3V
    WM8960_VSEL_INCREASED_BIAS_CURRENT = 1,
    WM8960_VSEL_LOWEST_BIAS_CURRENT = 3,

    -- JACK DETECT INPUT
    WM8960_JACKDETECT_GPIO1 = 0,
    WM8960_JACKDETECT_LINPUT3 = 1,
    WM8960_JACKDETECT_RINPUT3 = 2
}

-- The WM8960 does not support I2C reads
-- This means we must keep a local copy of all the register values
-- We will instantiate with default values
-- As we write to the device, we will also make sure
-- To update our local copy as well, stored here in this array.
-- Each register is 9-bits, so we will store them as a uint16_t
-- They are in order from R0-R55, and we even keep blank spots for the
-- "reserved" registers. This way we can use the register address macro
-- defines above to easiy access each local copy of each register.
-- Example: _registerLocalCopy[WM8960_REG_LEFT_INPUT_VOLUME]

wm8960._registerDefaults = {
    [ 0x00 ] = 0x0097, -- R0 (0x00)
    [ 0x01 ] = 0x0097, -- R1 (0x01)
    [ 0x02 ] = 0x0000, -- R2 (0x02)
    [ 0x03 ] = 0x0000, -- R3 (0x03)
    [ 0x04 ] = 0x0000, -- R4 (0x04)
    [ 0x05 ] = 0x0008, -- F5 (0x05)
    [ 0x06 ] = 0x0000, -- R6 (0x06)
    [ 0x07 ] = 0x000A, -- R7 (0x07)
    [ 0x08 ] = 0x01C0, -- R8 (0x08)
    [ 0x09 ] = 0x0000, -- R9 (0x09)
    [ 0x0A ] = 0x00FF, -- R10 (0x0A)
    [ 0x0B ] = 0x00FF, -- R11 (0x0B)
    [ 0x0C ] = 0x0000, -- R12 (0x0C)
    [ 0x0C ] = 0x0000, -- R13 (0x0D)
    [ 0x0E ] = 0x0000, -- R14 (0x0E)
    [ 0x0F ] = 0x0000, -- R15 (0x0F)
    [ 0x10 ] = 0x0000, -- R16 (0x10)
    [ 0x11 ] = 0x007B, -- R17 (0x11)
    [ 0x12 ] = 0x0100, -- R18 (0x12)
    [ 0x13 ] = 0x0032, -- R19 (0x13)
    [ 0x14 ] = 0x0000, -- R20 (0x14)
    [ 0x15 ] = 0x00C3, -- R21 (0x15)
    [ 0x16 ] = 0x00C3, -- R22 (0x16)
    [ 0x17 ] = 0x01C0, -- R23 (0x17)
    [ 0x18 ] = 0x0000, -- R24 (0x18)
    [ 0x19 ] = 0x0000, -- R25 (0x19)
    [ 0x1A ] = 0x0000, -- R26 (0x1A)
    [ 0x1B ] = 0x0000, -- R27 (0x1B)
    [ 0x1C ] = 0x0000, -- R28 (0x1C)
    [ 0x1D ] = 0x0000, -- R29 (0x1D)
    [ 0x1E ] = 0x0000, -- R30 (0x1E)
    [ 0x1F ] = 0x0000, -- R31 (0x1F)
    [ 0x20 ] = 0x0100, -- R32 (0x20)
    [ 0x21 ] = 0x0100, -- R33 (0x21)
    [ 0x22 ] = 0x0050, -- R34 (0x22)
    [ 0x23 ] = 0x0000, -- R34 (0x23)
    [ 0x24 ] = 0x0000, -- R34 (0x24)
    [ 0x25 ] = 0x0050, -- R37 (0x25)
    [ 0x26 ] = 0x0000, -- R38 (0x26)
    [ 0x27 ] = 0x0000, -- R39 (0x27)
    [ 0x28 ] = 0x0000, -- R40 (0x28)
    [ 0x29 ] = 0x0000, -- R41 (0x29)
    [ 0x2A ] = 0x0040, -- R42 (0x2A)
    [ 0x2B ] = 0x0000, -- R43 (0x2B)
    [ 0x2C ] = 0x0000, -- R44 (0x2C)
    [ 0x2D ] = 0x0050, -- R45 (0x2D)
    [ 0x2E ] = 0x0050, -- R46 (0x2E)
    [ 0x2F ] = 0x0000, -- R47 (0x2F)
    [ 0x30 ] = 0x0002, -- R48 (0x30)
    [ 0x31 ] = 0x0037, -- R49 (0x31)
    [ 0x32 ] = 0x0000, -- R49 (0x32)
    [ 0x33 ] = 0x0080, -- R51 (0x33)
    [ 0x34 ] = 0x0008, -- R52 (0x34)
    [ 0x35 ] = 0x0031, -- R53 (0x35)
    [ 0x36 ] = 0x0026, -- R54 (0x36)
    [ 0x37 ] = 0x00e9  -- R55 (0x37)
}

--[[
// writeRegister(uint8_t reg, uint16_t value)
// General-purpose write to a register
// Returns 1 if successful, 0 if something failed (I2C error)
// The WM8960 has 9 bit registers.
// To write a register, we must do the following
// Send 3 bytes
// Byte0 = device address + read/write bit
// Control_byte_1 = register-to-write address (7-bits) plus 9th bit of data
// Control_byte_2 = remaining 8 bits of register data
--]]
function wm8960:writeRegister(reg, value)
    local control_bytes = {
        ((reg & 0x3F) << 1) | ((value & 0x100) >> 8),
        value & 0xFF
    }
    local result = self.i2c(self.i2cAddr, control_bytes)
    --print(string.format("%02d (0x%02x): 0x%03x (%s)", reg, reg, value, result and 'OK' or 'ERR'))
    return result
end

--[[
// writeRegisterBit
// Writes a 0 or 1 to the desired bit in the desired register
--]]
function wm8960:_writeRegisterBit(registerAddress, bitNumber, bitValue)
    -- Get the local copy of the register
    local regvalue = self._registerLocalCopy[registerAddress];

    if bitValue == 1 then
      regvalue = regvalue | (1<<bitNumber) -- Set only the bit we want
    else
      regvalue = regvalue & ~(1<<bitNumber) -- Clear only the bit we want
    end

    -- Write modified value to device
    -- If successful, update local copy
    if self:writeRegister(registerAddress, regvalue) then
        self._registerLocalCopy[registerAddress] = regvalue
        return true
    end

    return false
end

--[[
// writeRegisterMultiBits
// This function writes data into the desired bits within the desired register
// Some settings require more than just flipping a single bit within a register.
// For these settings use this more advanced register write helper function.
//
// For example, to change the LIN2BOOST setting to +6dB,
// I need to write a setting of 7 (aka +6dB) to the bits [3:1] in the
// WM8960_REG_INPUT_BOOST_MIXER_1 register. Like so...
// _writeRegisterMultiBits(WM8960_REG_INPUT_BOOST_MIXER_1, 3, 1, 7);
--]]
function wm8960:_writeRegisterMultiBits(registerAddress, settingMsbNum, settingLsbNum, setting)
    local numOfBits = (settingMsbNum - settingLsbNum) + 1

    -- Get the local copy of the register
    local regvalue = self._registerLocalCopy[registerAddress]

    for i = 0, numOfBits - 1 do
        regvalue = regvalue & ~(1 << (settingLsbNum + i)) -- Clear bits we care about
    end

    -- Shift and set the bits from in incoming desired setting value
    regvalue = regvalue | (setting << settingLsbNum)

    -- Write modified value to device
    -- If successful, update local copy
    if self:writeRegister(registerAddress, regvalue) then
        self._registerLocalCopy[registerAddress] = regvalue
        return true
    end

    return false
end

--[[
// enableVREF
// Necessary for all other functions of the CODEC
// VREF is a single bit we can flip in Register 25 (19h), WM8960_REG_PWR_MGMT_1
// VREF is bit 6, 0 = power down, 1 = power up
// Returns 1 if successful, 0 if something failed (I2C error)
--]]
function wm8960:enableVREF()
  return self:_writeRegisterBit(self.reg.WM8960_REG_PWR_MGMT_1, 6, 1)
end

--[[
// disableVREF
// Use this to save power
// VREF is a single bit we can flip in Register 25 (19h), WM8960_REG_PWR_MGMT_1
// VREF is bit 6, 0 = power down, 1 = power up
// Returns 1 if successful, 0 if something failed (I2C error)
--]]
function wm8960:disableVREF()
  return self:_writeRegisterBit(self.reg.WM8960_REG_PWR_MGMT_1, 6, 0)
end

--[[
// Doesn't matter which bit we flip, writing anything will cause the reset
--]]
function wm8960:reset()
    if self:_writeRegisterBit(self.reg.WM8960_REG_RESET, 7, 1) then
        for i = 0, #wm8960._registerDefaults do
            self._registerLocalCopy[i] = wm8960._registerDefaults[i]
        end
        return true
    end
    return false
end

--[[
/////////////////////////////////////////////////////////
///////////////////////////////////////////////////////// DAC
/////////////////////////////////////////////////////////
--]]

function wm8960:enableDacLeft()
  return self:_writeRegisterBit(self.reg.WM8960_REG_PWR_MGMT_2, 8, 1)
end

function wm8960:disableDacLeft()
  return self:_writeRegisterBit(self.reg.WM8960_REG_PWR_MGMT_2, 8, 0)
end

function wm8960:enableDacRight()
  return self:_writeRegisterBit(self.reg.WM8960_REG_PWR_MGMT_2, 7, 1)
end

function wm8960:disableDacRight()
  return self:_writeRegisterBit(self.reg.WM8960_REG_PWR_MGMT_2, 7, 0)
end

--[[
// DAC digital volume
// Valid inputs are 0-255
// 0 = mute
// 1 = -127dB
// ... 0.5dB steps up to
// 255 = 0dB
--]]

function wm8960:setDacLeftDigitalVolume(volume)
  local result1 = self:_writeRegisterMultiBits(self.reg.WM8960_REG_LEFT_DAC_VOLUME,7,0,volume)
  local result2 = self:dacLeftDACVUSet()
  return (result1 and result2)
end

-- Causes left and right input dac digital volumes to be updated
function wm8960:setDacRightDigitalVolume(volume)
  local result1 = self:_writeRegisterMultiBits(self.reg.WM8960_REG_RIGHT_DAC_VOLUME,7,0,volume)
  local result2 = self:dacRightDACVUSet()
  return (result1 and result2)
end

-- Causes left and right input dac digital volumes to be updated
function wm8960:dacLeftDACVUSet()
  return self:_writeRegisterBit(self.reg.WM8960_REG_LEFT_DAC_VOLUME, 8, 1)
end

function wm8960:dacRightDACVUSet()
  return self:_writeRegisterBit(self.reg.WM8960_REG_RIGHT_DAC_VOLUME, 8, 1)
end

--[[
// DAC digital volume DB
// Sets the volume of the DAC to a specified dB value passed in as a float
// argument.
// Valid dB settings are -97.00 up to +30.0 (0.5dB steps)
// -97.50 (or lower) = MUTE
// -97.00 = -97.00dB (MIN)
// ... 0.5dB steps ...
// 30.00 = +30.00dB  (MAX)
--]]
function wm8960:setDacLeftDigitalVolumeDB(dB)
  -- Create an unsigned integer volume setting variable we can send to
  -- setDacLeftDigitalVolume()
  local volume = self:convertDBtoSetting(dB, self.enum.WM8960_DAC_GAIN_OFFSET, self.enum.WM8960_DAC_GAIN_STEPSIZE, self.enum.WM8960_DAC_GAIN_MIN, self.enum.WM8960_DAC_GAIN_MAX)

  return self:setDacLeftDigitalVolume(volume);
end

function wm8960:setDacRightDigitalVolumeDB(dB)
  -- Create an unsigned integer volume setting variable we can send to
  -- setDacRightDigitalVolume()
  local volume = self:convertDBtoSetting(dB, self.enum.WM8960_DAC_GAIN_OFFSET, self.enum.WM8960_DAC_GAIN_STEPSIZE, self.enum.WM8960_DAC_GAIN_MIN, self.enum.WM8960_DAC_GAIN_MAX)

  return self:setDacRightDigitalVolume(volume)
end

--[[
// DAC mute
--]]
function wm8960:enableDacMute()
  return self:_writeRegisterBit(self.reg.WM8960_REG_ADC_DAC_CTRL_1, 3, 1)
end

function wm8960:disableDacMute()
  return self:_writeRegisterBit(self.reg.WM8960_REG_ADC_DAC_CTRL_1, 3, 0)
end

--[[
/////////////////////////////////////////////////////////
///////////////////////////////////////////////////////// OUTPUT mixers
/////////////////////////////////////////////////////////
--]]

--[[
// What's connected to what? Oh so many options...
// LOMIX	Left Output Mixer
// ROMIX	Right Output Mixer
// OUT3MIX		Mono Output Mixer
-]]
function wm8960:enableLOMIX()
  return self:_writeRegisterBit(self.reg.WM8960_REG_PWR_MGMT_3, 3, 1)
end

function wm8960:disableLOMIX()
  return self:_writeRegisterBit(self.reg.WM8960_REG_PWR_MGMT_3, 3, 0)
end

function wm8960:enableROMIX()
  return self:_writeRegisterBit(self.reg.WM8960_REG_PWR_MGMT_3, 2, 1)
end

function wm8960:disableROMIX()
  return self:_writeRegisterBit(self.reg.WM8960_REG_PWR_MGMT_3, 2, 0)
end

function wm8960:enableOUT3MIX()
  return self:_writeRegisterBit(self.reg.WM8960_REG_PWR_MGMT_2, 1, 1)
end

function wm8960:disableOUT3MIX()
  return self:_writeRegisterBit(self.reg.WM8960_REG_PWR_MGMT_2, 1, 0)
end

function wm8960:enableLD2LO()
  return self:_writeRegisterBit(self.reg.WM8960_REG_LEFT_OUT_MIX_1, 8, 1)
end

function wm8960:disableLD2LO()
  return self:_writeRegisterBit(self.reg.WM8960_REG_LEFT_OUT_MIX_1, 8, 0)
end

function wm8960:enableRD2RO()
  return self:_writeRegisterBit(self.reg.WM8960_REG_RIGHT_OUT_MIX_2, 8, 1)
end

function wm8960:disableRD2RO()
  return self:_writeRegisterBit(self.reg.WM8960_REG_RIGHT_OUT_MIX_2, 8, 0)
end

--[[
// setVMID
// Sets the VMID signal to one of three possible settings.
// 4 options:
// WM8960_VMIDSEL_DISABLED
// WM8960_VMIDSEL_2X50KOHM (playback / record)
// WM8960_VMIDSEL_2X250KOHM (for low power / standby)
// WM8960_VMIDSEL_2X5KOHM (for fast start-up)
--]]
function wm8960:setVMID(setting)
  return self:_writeRegisterMultiBits(self.reg.WM8960_REG_PWR_MGMT_1, 8, 7, setting);
end

--[[
/////////////////////////////////////////////////////////
///////////////////////////////////////////////////////// Headphones
/////////////////////////////////////////////////////////
--]]
function wm8960:enableHeadphones()
  return (self:enableRightHeadphone() and self:enableLeftHeadphone());
end

function wm8960:disableHeadphones()
  return (self:disableRightHeadphone() and self:disableLeftHeadphone());
end

function wm8960:enableRightHeadphone()
  return self:_writeRegisterBit(self.reg.WM8960_REG_PWR_MGMT_2, 5, 1)
end

function wm8960:disableRightHeadphone()
  return self:_writeRegisterBit(self.reg.WM8960_REG_PWR_MGMT_2, 5, 0)
end

function wm8960:enableLeftHeadphone()
  return self:_writeRegisterBit(self.reg.WM8960_REG_PWR_MGMT_2, 6, 1)
end

function wm8960:disableLeftHeadphone()
  return self:_writeRegisterBit(self.reg.WM8960_REG_PWR_MGMT_2, 6, 0)
end

function wm8960:enableHeadphoneStandby()
  return self:_writeRegisterBit(self.reg.WM8960_REG_ANTI_POP_1, 0, 1)
end

function wm8960:disableHeadphoneStandby()
  return self:_writeRegisterBit(self.reg.WM8960_REG_ANTI_POP_1, 0, 0)
end

--[[
// SetHeadphoneVolume
// Sets the volume for both left and right headphone outputs
//
// Although you can control each headphone output independently, here we are
// Going to assume you want both left and right to do the same thing.
//
// Valid inputs: 47-127. 0-47 = mute, 48 = -73dB ... 1dB steps ... 127 = +6dB
--]]
function wm8960:setHeadphoneVolume(volume)
  -- Updates both left and right channels
  -- Handles the OUT1VU (volume update) bit control, so that it happens at the
  -- same time on both channels. Note, we must also make sure that the outputs
  -- are enabled in the WM8960_REG_PWR_MGMT_2 [6:5]
  -- Grab local copy of register
  -- Modify the bits we need to
  -- Write register in device, including the volume update bit write
  -- If successful, save locally.

  -- Limit inputs
  if (volume > 127) then volume = 127 end

  -- LEFT
    local result1 = self:_writeRegisterMultiBits(self.reg.WM8960_REG_LOUT1_VOLUME,6,0,volume)
  -- RIGHT
    local result2 = self:_writeRegisterMultiBits(self.reg.WM8960_REG_ROUT1_VOLUME,6,0,volume)
  -- UPDATES

  -- Updated left channel
    local result3 = self:_writeRegisterBit(self.reg.WM8960_REG_LOUT1_VOLUME, 8, 1)

  -- Updated right channel
    local result4 = self:_writeRegisterBit(self.reg.WM8960_REG_ROUT1_VOLUME, 8, 1)

    if (result1 and result2 and result3 and result4) then -- If all writes ACK'd
        return true
    end
  return false
end

--[[
// Set headphone volume dB
// Sets the volume of the headphone output buffer amp to a specified dB value
// passed in as a float argument.
// Valid dB settings are -74.0 up to +6.0
// Note, we are accepting float arguments here, in order to keep it consistent
// with other volume setting functions in this library that can do partial dB
// values (such as the PGA, ADC and DAC gains).
// -74 (or lower) = MUTE
// -73 = -73dB (MIN)
// ... 1dB steps ...
// 0 = 0dB
// ... 1dB steps ...
// 6 = +6dB  (MAX)
--]]
function wm8960:setHeadphoneVolumeDB(dB)
  -- Create an unsigned integer volume setting variable we can send to
  -- setHeadphoneVolume()
  volume = self:convertDBtoSetting(dB, self.enum.WM8960_HP_GAIN_OFFSET, self.enum.WM8960_HP_GAIN_STEPSIZE, self.enum.WM8960_HP_GAIN_MIN, self.enum.WM8960_HP_GAIN_MAX)

  return self:setHeadphoneVolume(volume)
end

--[[
//////////////////////////////////////////////
////////////////////////////////////////////// Digital audio interface control
//////////////////////////////////////////////
--]]

-- Defaults to I2S, peripheral-mode, 24-bit word length

--[[
/////////////////////////////////////////////////////////
///////////////////////////////////////////////////////// Clock controls
/////////////////////////////////////////////////////////

// Getting the Frequency of SampleRate as we wish
// Our MCLK (an external clock on the SFE breakout board) is 24.0MHz.
// According to table 40 (DS pg 58), we want SYSCLK to be 11.2896 for a SR of
// 44.1KHz. To get that Desired Output (SYSCLK), we need the following settings
// on the PLL stuff, as found on table 45 (ds pg 61):
// PRESCALE DIVIDE (PLLPRESCALE): 2
// POSTSCALE DVIDE (SYSCLKDIV[1:0]): 2
// FIXED POST-DIVIDE: 4
// R: 7.5264
// N: 7h
// K: 86C226h

// Example at bottom of table 46, shows that we should be in fractional mode
// for a 44.1KHz.

// In terms of registers, this is what we want for 44.1KHz
// PLLEN=1			(PLL enable)
// PLLPRESCALE=1	(divide by 2) *This get's us from MCLK (24MHz) down to 12MHZ
// for F2.
// PLLN=7h			(PLL N value) *this is "int R"
// PLLK=86C226h		(PLL K value) *this is int ( 2^24 * (R- intR))
// SDM=1			(Fractional mode)
// CLKSEL=1			(PLL select)
// MS=0				(Peripheral mode)
// WL=00			(16 bits)
// SYSCLKDIV=2		(Divide by 2)
// ADCDIV=000		(Divide by 1) = 44.1kHz
// DACDIV=000		(Divide by 1) = 44.1kHz
// BCLKDIV=0100		(Divide by 4) = 64fs
// DCLKDIV=111		(Divide by 16) = 705.6kHz

// And now for the functions that will set these registers...
--]]
function wm8960:enablePLL()
  return self:_writeRegisterBit(self.reg.WM8960_REG_PWR_MGMT_2, 0, 1)
end

function wm8960:disablePLL()
  return self:_writeRegisterBit(self.reg.WM8960_REG_PWR_MGMT_2, 0, 0)
end

function wm8960:setPLLPRESCALE(div)
  return self:_writeRegisterBit(self.reg.WM8960_REG_PLL_N, 4, div)
end

function wm8960:setPLLN(n)
  return self:_writeRegisterMultiBits(self.reg.WM8960_REG_PLL_N,3,0,n)
end

-- Send each nibble of 24-bit value for value K
function wm8960:setPLLK(one, two, three)
  local result1 = self:_writeRegisterMultiBits(self.reg.WM8960_REG_PLL_K_1,5,0,one)
  local result2 = self:_writeRegisterMultiBits(self.reg.WM8960_REG_PLL_K_2,8,0,two)
  local result3 = self:_writeRegisterMultiBits(self.reg.WM8960_REG_PLL_K_3,8,0,three)
  if (result1 and result2 and result3) then -- If all I2C sommands Ack'd, then...
    return true
  end
  return false
end

-- 0=integer, 1=fractional
function wm8960:setSDM(mode)
  return self:_writeRegisterBit(self.reg.WM8960_REG_PLL_N, 5, mode)
end

 -- 0=MCLK, 1=PLL_output
function wm8960:setCLKSEL(sel)
  return self:_writeRegisterBit(self.reg.WM8960_REG_CLOCKING_1, 0, sel)
end

-- (0=divide by 1), (2=div by 2) *1 and 3 are "reserved"
function wm8960:setSYSCLKDIV(div)
  return self:_writeRegisterMultiBits(self.reg.WM8960_REG_CLOCKING_1,2,1,div)
end

-- 000 = SYSCLK / (1.0*256). See ds pg 57 for other options
function wm8960:setADCDIV(div)
  return self:_writeRegisterMultiBits(self.reg.WM8960_REG_CLOCKING_1,8,6,div)
end

-- 000 = SYSCLK / (1.0*256). See ds pg 57 for other options
function wm8960:setDACDIV(div)
  return self:_writeRegisterMultiBits(self.reg.WM8960_REG_CLOCKING_1,5,3,div)
end

function wm8960:setBCLKDIV(div)
  return self._writeRegisterMultiBits(self.reg.WM8960_REG_CLOCKING_2,3,0,div)
end

-- Class D amp, 111= SYSCLK/16, so 11.2896MHz/16 = 705.6KHz
function wm8960:setDCLKDIV(div)
  return self:_writeRegisterMultiBits(self.reg.WM8960_REG_CLOCKING_2,8,6,div)
end

function wm8960:setALRCGPIO()
  -- This setting should not be changed if ADCs are enabled.
  return self:_writeRegisterBit(self.reg.WM8960_REG_AUDIO_INTERFACE_2, 6, 1)
end

function wm8960:enableMasterMode()
  return self:_writeRegisterBit(self.reg.WM8960_REG_AUDIO_INTERFACE_1, 6, 1)
end

function wm8960:enablePeripheralMode()
  return self:_writeRegisterBit(self.reg.WM8960_REG_AUDIO_INTERFACE_1, 6, 0)
end

function wm8960:setWL(word_length)
  return self:_writeRegisterMultiBits(self.reg.WM8960_REG_AUDIO_INTERFACE_1,3,2,word_length)
end

function wm8960:setLRP(polarity)
  return self:_writeRegisterBit(self.reg.WM8960_REG_AUDIO_INTERFACE_1, 4, polarity)
end

function wm8960:setALRSWAP(swap)
  return self:_writeRegisterBit(self.reg.WM8960_REG_AUDIO_INTERFACE_1, 8, swap)
end

function wm8960:setVROI(setting)
  return self:_writeRegisterBit(self.reg.WM8960_REG_ADDITIONAL_CONTROL_3, 6, setting)
end

function wm8960:setVSEL(setting)
  return self:_writeRegisterMultiBits(self.reg.WM8960_REG_ADDITIONAL_CONTROL_1,7,6,setting)
end

--[[
// convertDBtoSetting
// This function will take in a dB value (as a float), and return the
// corresponding volume setting necessary.
// For example, Headphone volume control goes from 47-120.
// While PGA gain control is from 0-63.
// The offset values allow for proper conversion.
//
// dB - float value of dB
//
// offset - the differnce from lowest dB value to lowest setting value
//
// stepSize - the dB step for each setting (aka the "resolution" of the setting)
// This is 0.75dB for the PGAs, 0.5 for ADC/DAC, and 1dB for most other amps.
//
// minDB - float of minimum dB setting allowed, note this is not mute on the
// amp. "True mute" is always one stepSize lower.
//
// maxDB - float of maximum dB setting allowed. If you send anything higher, it
// will be limited to this max value.
--]]

function wm8960:convertDBtoSetting(dB, offset, stepSize, minDB, maxDB)
  -- Limit incoming dB values to acceptable range. Note, the minimum limit we
  -- want to limit this too is actually one step lower than the minDB, because
  -- that is still an acceptable dB level (it is actually "true mute").
  -- Note, the PGA amp does not have a "true mute" setting available, so we
  -- must check for its unique minDB of -17.25.

  -- Limit max. This is the same for all amps.
  if (dB > maxDB) then dB = maxDB end

  -- PGA amp doesn't have mute setting, so minDB should be limited to minDB
  -- Let's check for the PGAs unique minDB (-17.25) to know we are currently
  -- converting a PGA setting.
  if(minDB == WM8960_PGA_GAIN_MIN) then
    if (dB < minDB) then dB = minDB end
  else -- Not PGA. All other amps have a mute setting below minDb
    if (dB < (minDB - stepSize)) then dB = (minDB - stepSize) end
  end

  -- Adjust for offset
  -- Offset is the number that gets us from the minimum dB option of an amp
  -- up to the minimum setting value in the register.
  dB = dB + offset

  -- Find out how many steps we are above the minimum (at this point, our
  -- minimum is "0". Note, because dB comes in as a float, the result of this
  -- division (volume) can be a partial number. We will round that next.
  local volume = dB / stepSize

  volume = math.round(volume); -- round to the nearest setting value.

  return volume; -- cast from float to unsigned 8-bit integer.
end

function wm8960.new(i2c)
    local w = { }
    setmetatable(w, wm8960)
    w._registerLocalCopy = { }
    for i = 0, #wm8960._registerDefaults do
        w._registerLocalCopy[i] = wm8960._registerDefaults[i]
    end
    w.i2c = i2c
    return w
end

return wm8960
