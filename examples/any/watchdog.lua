wd=require('watchdog')
rtos=require('freertos')

print('Enable 1 second watchdog...')
wd.enable(1)

start = rtos.time()
pet = true

print('Pet for 3 seconds...')
while true do
   now = rtos.time()
   if pet then
      wd.pet()
      if now - start > 3 then
         print('Stop petting...')
         pet = false
      end
   else
      rtos.sleep(0.100)
   end
end
