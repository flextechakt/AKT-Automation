local ssd1306 = {}
ssd1306.__index = ssd1306

ssd1306.i2c_addr = 0x3d

ssd1306.CONTRAST = 0x81
ssd1306.ENTIRE_ON = 0xa4
ssd1306.NORM_INV = 0xa6
ssd1306.DISP = 0xae
ssd1306.MEM_ADDR = 0x20
ssd1306.COL_ADDR = 0x21
ssd1306.PAGE_ADDR = 0x22
ssd1306.DISP_START_LINE = 0x40
ssd1306.SEG_REMAP = 0xa0
ssd1306.MUX_RATIO = 0xa8
ssd1306.COM_OUT_DIR = 0xc0
ssd1306.DISP_OFFSET = 0xd3
ssd1306.COM_PIN_CFG = 0xda
ssd1306.DISP_CLK_DIV = 0xd5
ssd1306.PRECHARGE = 0xd9
ssd1306.VCOM_DESEL = 0xdb
ssd1306.CHARGE_PUMP = 0x8d

function ssd1306:rshift(x, y)
    return(x >> y)
end

function ssd1306:band(x, y)
    return(x & y)
end

function ssd1306:wc(byte)
    return self:wd({0x80, byte})
end

function ssd1306:wd(data)
    local ok = self.i2c(self.i2c_addr, data)
    return ok
end

function ssd1306.new(i2c, width, height, i2c_addr)
    self = { }
    setmetatable(self, ssd1306)
    self.i2c = i2c
    self.w = width
    self.h = height
    if self.i2c_addr ~= nil then
        self.i2c_addr = i2c_addr
    end
    local tab = {self.DISP, self.MEM_ADDR, 0x01, self.DISP_START_LINE, self.SEG_REMAP + 0x01,
        self.MUX_RATIO, height - 1, self.COM_OUT_DIR + 0x08, self.DISP_OFFSET, 0x00,
        self.COM_PIN_CFG, height == 32 and 0x02 or 0x12, self.DISP_CLK_DIV, 0x80,
        self.PRECHARGE, 0x88, self.VCOM_DESEL, 0x30, self.CONTRAST, 0x80, self.ENTIRE_ON,
        self.NORM_INV, self.CHARGE_PUMP, 0x14, self.DISP + 0x01, self.COL_ADDR, 0, 127,
        self.PAGE_ADDR, 0, height/8-1}
    for i, v in ipairs(tab) do
        self:wc(v)
    end
    return self
end

function ssd1306:contrast(contrast)
    local tab = {self.s_CONTRAST, contrast}
    for i, v in ipairs(tab) do
        ssd1306:wc(v)
    end
end

function ssd1306:show(fb)
    local txbuf = {0x40}
    for i = 1, self.w * self.h / 32, 32 do
        for j = 0, 31 do
            local dw = fb[i+j] or 0
            for k = 2, 5 do
                txbuf[j*4+k] = self:band(dw, 0xff)
                dw = self:rshift(dw, 8)
            end
        end
        self:wd(txbuf)
    end
end

return ssd1306
