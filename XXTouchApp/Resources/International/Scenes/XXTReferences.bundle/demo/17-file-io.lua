-- Implicit File Descriptors

-- Opens a file in read
file = io.open("test.lua", "r")

-- sets the default input file as test.lua
io.input(file)

-- prints the first line of the file
print(io.read())

-- closes the open file
io.close(file)

-- Opens a file in append mode
file = io.open("test.lua", "a")

-- sets the default output file as test.lua
io.output(file)

-- appends a word test to the last line of the file
io.write("-- End of the test.lua file")

-- closes the open file
io.close(file)

-- Explicit File Descriptors

-- Opens a file in read mode
file = io.open("test.lua", "r")

-- prints the first line of the file
print(file:read())

-- closes the opened file
file:close()

-- Opens a file in append mode
file = io.open("test.lua", "a")

-- appends a word test to the last line of the file
file:write("--test")

-- closes the open file
file:close()
