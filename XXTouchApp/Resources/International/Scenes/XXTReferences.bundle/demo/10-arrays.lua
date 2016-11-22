-- One-Dimensional Array
array = {"Lua", "Tutorial"}

for i= 0, 2 do
   print(array[i])
end

array = {}

for i= -2, 2 do
   array[i] = i *2
end

for i = -2,2 do
   print(array[i])
end

-- Multi-Dimensional Array

-- Initializing the array
array = {}

for i=1,3 do
   array[i] = {}
	
   for j=1,3 do
      array[i][j] = i*j
   end
	
end

-- Accessing the array

for i=1,3 do
   for j=1,3 do
      print(array[i][j])
   end
end

-- Initializing the array

array = {}

maxRows = 3
maxColumns = 3

for row=1,maxRows do
   for col=1,maxColumns do
      array[row*maxColumns +col] = row*col
   end
end

-- Accessing the array

for row=1,maxRows do
   for col=1,maxColumns do
      print(array[row*maxColumns +col])
   end
end
