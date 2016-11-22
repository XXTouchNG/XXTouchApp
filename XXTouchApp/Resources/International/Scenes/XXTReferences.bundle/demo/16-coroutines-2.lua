function getNumber()
   local function getNumberHelper()
      co = coroutine.create(function ()
      coroutine.yield(1)
      coroutine.yield(2)
      coroutine.yield(3)
      coroutine.yield(4)
      coroutine.yield(5)
      end)
      return co
   end
   if (numberHelper) then
      status, number = coroutine.resume(numberHelper);
      if coroutine.status(numberHelper) == "dead" then
         numberHelper = getNumberHelper()
         status, number = coroutine.resume(numberHelper);
      end
      return number
   else
      numberHelper = getNumberHelper()
      status, number = coroutine.resume(numberHelper);
      return number
   end
end

for index = 1, 10 do
   print(index, getNumber())
end
