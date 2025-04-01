-- Builtin modules
system = require('system')
qwiic = require('qwiic')
os = require('freertos')
term = require('term')

-- Lua display modules
ssd1306 = require('ssd1306')
framebuffer = require('framebuffer')
font = require('pixeloperator')

oled = ssd1306.new(qwiic.i2c, 128, 64)
fb = framebuffer.new(128, 64)

print("Press any key to quit...")
repeat
    fb:clear()
    fb:print(font, 'Flextech AKT\n')
    fb:print(font, 'Automation\n')
    fb:print(font, '\n')
    fb:print(font, string.format(' Line 4\n'))
    fb:print(font, string.format(' Line 5\n'))
    fb:print(font, string.format(' Line 6\n'))
    fb:print(font, '\n')
    fb:print(font, system.date() .. '\n')
    oled:show(fb.buf)
    os.delay(0.100)
    key = term.getchar(term.NOWAIT)
until key ~= -1
