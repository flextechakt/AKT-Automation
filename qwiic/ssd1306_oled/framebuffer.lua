local fb = {}
fb.__index = fb

function fb:lshift(x, y)
    return(x << y)
end

function fb:rshift(x, y)
    return(x >> y)
end

function fb:bor(x, y)
    return(x | y)
end

function fb.new(w, h)
    local _fb = { }
    setmetatable(_fb, fb)
    _fb.w = w
    _fb.h = h
    _fb.x = 0
    _fb.y = 0
    _fb.buf = {}
    return _fb
end

function fb:scroll()
    for x = 0, self.w-1 do
        for y = 1, self.h/32 do
            self.buf[x*(self.h/32) + y-1 + 1] = fb:rshift(self.buf[x*(self.h/32) + y-1 + 1] or 0, 8) or nil
            if y ~= self.h/32 then
                self.buf[x*(self.h/32) + y-1 + 1] = fb:bor(self.buf[x*(self.h/32) + y-1 + 1] or 0, fb:lshift(self.buf[x*(self.h/32) + y + 1] or 0, 24)) or nil
            end
        end
    end
    self.y = self.y - 8
end

function fb:put(font, c)
    if c == 10 then
        self.x = 0
        self.y = self.y + font.height
        return
    end
    if c < 32 or c > 126 then
        c = 0x3f
    end
    if self.y >= self.h then
        self:scroll()
    end
    local glyph = font.glyphs[c - 31]
    local fh = font.height/8
    for i = 1, string.len(glyph) do
        local x1 = (i-1) / fh
        local y8 = (i-1) % fh
        local fb8_o = self.y/8+y8 + (self.x+x1) * (self.h/8)
        local fb32_o = math.floor(fb8_o / 4 + 1)
        local fb32_s = (fb8_o % 4) * 8
        self.buf[fb32_o] = fb:bor(self.buf[fb32_o] or 0, fb:lshift(string.byte(glyph, i), fb32_s))
    end
    self.x = self.x + string.len(glyph) / fh + 2
    if self.x > self.w then
        self:put(font, 10)
    end
end

function fb:print(font, str)
    for i = 1, string.len(str) do
        self:put(font, string.byte(str, i))
    end
end

function fb:clear()
    self.x = 0
    self.y = 0
    self.buf = {}
end

function fb:draw_battery_8(x, y, p)
    self.buf[y/32 + x*self.h/32 + 1] = 0xff
    for i = 1, 10 do
        if p*2 >= i*15 then
            self.buf[y/32 + (x+i)*self.h/32 + 1] = 0xff
        else
            self.buf[y/32 + (x+i)*self.h/32 + 1] = 0x81
        end
    end
    if p*2 >= 11*15 then
        self.buf[y/32 + (x+11)*self.h/32 + 1] = 0xff
    else
        self.buf[y/32 + (x+11)*self.h/32 + 1] = 0xe7
    end
    if p*2 >= 12*15 then
        self.buf[y/32 + (x+12)*self.h/32 + 1] = 0x3c
    else
        self.buf[y/32 + (x+12)*self.h/32 + 1] = 0x24
    end
    self.buf[y/32 + (x+13)*self.h/32 + 1] = 0x3c
end

return fb
