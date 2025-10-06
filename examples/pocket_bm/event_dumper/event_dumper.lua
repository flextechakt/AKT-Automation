--[[ Lua Modules --]]
pretty = require('pl.pretty')
term = require('term')
bm = require('bm')

-- Subscribe to all events
for _, e in pairs(bm.event) do
    if type(e) == 'number' then
        bm.subscribe(e)
    end
end

-- Loop
print('Flextech AKT Pocket Bus Monitor')
print('Raw Event Dumper')
print('Press "q" to quit...')
repeat
  -- Process BM events
  status = bm.status()
  if status.events > 0 then
    e = bm.getEvent()
    e.event = bm.event[e.event]
    print(pretty.write(e, ''))
  end
  -- Exit on keypress
  key = term.getchar(term.NOWAIT)
  if key ~= -1 and key ~= string.byte('q') then
    print('Press "q" to quit...')
  end
until key == string.byte('q')

