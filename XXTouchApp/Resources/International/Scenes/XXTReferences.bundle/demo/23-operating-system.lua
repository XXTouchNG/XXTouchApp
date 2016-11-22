-- Date with format
io.write("The date is ", os.date("%m/%d/%Y"),"\n")

-- Date and time
io.write("The date and time is ", os.date(),"\n")

-- Time
io.write("The OS time is ", os.time(),"\n")

-- Wait for some time
for i=1,1000000 do
end

-- Time since Lua started
io.write("Lua started before ", os.clock(),"\n")

io.flush()
