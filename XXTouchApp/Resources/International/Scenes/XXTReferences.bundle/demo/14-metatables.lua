-- __index

mytable = setmetatable({key1 = "value1"}, {
   __index = function(mytable, key)
      if key == "key2" then
         return "metatablevalue"
      else
         return mytable[key]
      end
   end
})

print(mytable.key1,mytable.key2)

-- __newindex

mymetatable = {}
mytable = setmetatable({key1 = "value1"}, { __newindex = mymetatable })

print(mytable.key1)

mytable.newkey = "new value 2"
print(mytable.newkey,mymetatable.newkey)

mytable.key1 = "new  value 1"
print(mytable.key1,mymetatable.newkey1)

mytable = setmetatable({key1 = "value1"}, {

   __newindex = function(mytable, key, value)
      rawset(mytable, key, "\""..value.."\"")
   end
})

mytable.key1 = "new value"
mytable.key2 = 4

print(mytable.key1,mytable.key2)

-- Adding Operator Behavior to Tables

mytable = setmetatable({ 1, 2, 3 }, {
   __add = function(mytable, newtable)
      for i = 1, table.maxn(newtable) do
         table.insert(mytable, table.maxn(mytable)+1,newtable[i])
      end
      return mytable
   end
})

secondtable = {4,5,6}

mytable = mytable + secondtable

for k,v in ipairs(mytable) do
   print(k,v)
end

-- __call

mytable = setmetatable({10}, {
   __call = function(mytable, newtable)
   sum = 0
      for i = 1, table.maxn(mytable) do
         sum = sum + mytable[i]
      end
      for i = 1, table.maxn(newtable) do
         sum = sum + newtable[i]
      end
      return sum
   end
})

newtable = {10,20,30}
print(mytable(newtable))

-- __tostring

mytable = setmetatable({ 10, 20, 30 }, {
   __tostring = function(mytable)
   sum = 0
      for k, v in pairs(mytable) do
         sum = sum + v
      end
      return "The sum of values in the table is " .. sum
   end
})
print(mytable)
