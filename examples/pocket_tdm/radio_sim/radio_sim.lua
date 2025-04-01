-- Builtin modules
system = require('system')
qwiic = require('qwiic')
os = require('freertos')
term = require('term')

-- Lua modules
QwiicButton = require('QwiicButton')
QwiicJoystick = require('QwiicJoystick')
ssd1306 = require('ssd1306')
framebuffer = require('framebuffer')
font = require('pixeloperator')
rtc = require('rv8803')
wm8960 = require('wm8960')

-- Button and Joystick objects
button = QwiicButton.new(qwiic.i2c)
joystick = QwiicJoystick.new(qwiic.i2c)

-- OLED and Framebuffer objects
oled = ssd1306.new(qwiic.i2c, 128, 64)
fb = framebuffer.new(128, 64)

-- CODEC
codec = wm8960.new(qwiic.i2c)

-- Constants
brightness = 250  -- The maximum brightness of the pulsing LED. Can be between 0 (min) and 255 (max)
cycleTime = 1000  -- The total time for the pulse to take. Set to a bigger number for a slower pulse, or a smaller number for a faster pulse
offTime = 200     -- The total time to stay off between pulses. Set to 0 to be pulsing continuously.
DEFAULT_VOLUME = 90
DEFAULT_SOURCE = 3
DEFAULT_MUTE = false
SOURCES = { 'USB', 'Tone', 'Pink', 'White' }

volume = DEFAULT_VOLUME
mute = DEFAULT_MUTE
source = DEFAULT_SOURCE

pbState = false
jsState = 0

function pollJoystick()
    local h = joystick:get_horizontal()
    local v = joystick:get_vertical()
    if h > 768 then
        if jsState ~= 1 then
            if source == #SOURCES then
                source = 1
            else
                source = source + 1
            end
            --print(SOURCES[source])
            jsState = 1
        end
    elseif h < 256 then
        if jsState ~= 2 then
            if source == 1 then
                source = #SOURCES
            else
                source = source - 1
            end
            --print(SOURCES[source])
            jsState = 2
        end
    else
        jsState = 0
    end
    if v > 768 then
        if volume > 48 then
            volume = volume - 1
        end
        --print(volume)
    elseif v < 256 then
        if volume < 121 then
            volume = volume + 1
        end
        --print(volume)
    end
    if joystick:check_button() == 1 then
        volume = DEFAULT_VOLUME
        source = DEFAULT_SOURCE
        mute = DEFAULT_MUTE
    end
end

function pollPushbutton()
    local pbPressed = button:isPressed()
    if pbPressed ~= pbState then
        if pbPressed then
            mute = not mute
            --if mute then print('Mute') else print('Unmute') end
        end
        pbState = pbPressed
    end
end

function pollDisplay()
    fb:clear()
    fb:print(font, 'Flextech AKT\n')
    fb:print(font, 'Automation\n')
    fb:print(font, '\n')
    fb:print(font, string.format('Source: %s\n', SOURCES[source]))
    fb:print(font, string.format('State: %s\n', mute and 'Mute' or 'Unmute'))
    fb:print(font, string.format('Volume: %d\n', volume))
    fb:print(font, '\n')
    fb:print(font, system.date() .. '\n')
    oled:show(fb.buf)
    os.delay(0.100)
end

function setTime()
    local ok, y, m, d, hh, mm, ss = rtc.getTime(qwiic.i2c)
    if ok then
        local rfc3339 = string.format(
            '%04d-%02d-%02dT%02d:%02d:%02dZ',
            y, m, d, hh, mm, ss
        );
        ok = system.date(rfc3339)
        if ok then
            system.syslog('RTC: ' .. rfc3339)
        else
            system.syslog('RTC: system.date error')
        end
    else
        system.syslog('RTC: rtc.getTime error')
    end
end

function initCodec()
    --print('Reset')
    codec:reset()
    --print('Enable VREF')
    codec:enableVREF()
    codec:setVMID(codec.enum.WM8960_VMIDSEL_2X50KOHM)
    --print('Configure PLL')
    codec:setPLLPRESCALE(1)        -- 24MHz -> 12MHz
    codec:setSDM(1)                -- Fractional PLL
    codec:setPLLN(8)               -- Set N
    codec:setPLLK(0x31,0x26,0xE8)  -- Set K
    codec:setCLKSEL(1)             -- Set PLL_output
    codec:setSYSCLKDIV(2)          -- Div by 2
    codec:enablePLL()              -- Enable PLL
    --print('I2S Clocking')
    --print('DAC')
    codec:enableDacLeft()          -- Enable DAC L
    codec:enableDacRight()         -- Enable DAC R
    codec:disableDacMute()         -- Unmute DAC
    --print('Output Mixer')
    codec:enableLOMIX()            -- Enable Left Output Mixer
    codec:enableLD2LO()            -- Enable Left DAC to Left Out
    codec:enableROMIX()            -- Enable Right Output Mixer
    codec:enableRD2RO()            -- Enable Right DAC to Right Out
    --print('Headphone')
    codec:setHeadphoneVolume(0x79) -- Set Headphone Volume (0dB)
    codec:enableHeadphones()       -- Enable Headphones
    codec:enableOUT3MIX()          -- Enable OUT3MIX
end

function initSystem()
    -- Soft reset
    system.shell('reset soft')
    -- Generators
    --system.shell('gen 0 tone 440')
    --system.shell('gen 1 pink')
    --system.shell('gen 2 white')
    -- TDM (I2S)
    system.shell('tdm clk dir out')
    system.shell('tdm clk option falling')
    system.shell('tdm sync dir out')
    system.shell('tdm sync option none falling early 50%')
    system.shell('tdm word size 32')
    system.shell('tdm slot size 2')
    system.shell('tdm 01 dir out')
    system.shell('tdm 01 pins primary')
    system.shell('tdm 23 dir in')
    system.shell('tdm 23 pins primary')
    system.shell('tdm start')
end

oldMute = nil
oldVolume = nil
function pollVolume()
    if oldMute ~= mute or oldVolume ~= volume then
        if mute then
            codec:setHeadphoneVolume(0)
            button:LEDoff()
        else
            codec:setHeadphoneVolume(volume)
            button:LEDconfig(brightness, cycleTime, offTime)
        end
        oldMute = mute
        oldVolume = volume
    end
end

oldSource = nil
function pollSystem()
    if oldSource ~= source then
        if source == 1 then
            system.shell('route 0 usb 0 tdm01 0 2')
        elseif source == 2 then
            system.shell('gen 0 tone 440')
            system.shell('route 0 gen 0 tdm01 0 2')
        elseif source == 3 then
            system.shell('gen 0 pink')
            system.shell('route 0 gen 0 tdm01 0 2')
        elseif source == 4 then
            system.shell('gen 0 white')
            system.shell('route 0 gen 0 tdm01 0 2')
        else
        end
        oldSource = source
    end
end

setTime()
initCodec()
initSystem()

key = nil
repeat
    if key ~= -1 then
        print('Press "q" to quit..')
    end
    pollPushbutton()
    pollJoystick()
    pollDisplay()
    pollVolume()
    pollSystem()
    os.delay(0.020)
    key = term.getchar(term.NOWAIT)
until key == string.byte('q')

codec:reset()
fb:clear()
oled:show(fb.buf)
button:LEDoff()
system.shell('reset soft')

