-- Asserts

local function add(a,b)
   assert(type(a) == "number", "a is not a number")
   assert(type(b) == "number", "b is not a number")
   return a+b
end

add(10)

-- pcall and xpcall

function myfunction ()
   n = n/nil
end

if pcall(myfunction) then
   print("Success")
else
   print("Failure")
end

function myfunction ()
   n = n/nil
end

function myerrorhandler( err )
   print( "ERROR:", err )
end

status = xpcall( myfunction, myerrorhandler )
print(status)
