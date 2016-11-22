-- Creating a Simple Class

-- Meta class
Rectangle = {area = 0, length = 0, breadth = 0}

-- Derived class method new

function Rectangle:new (o,length,breadth)
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   self.length = length or 0
   self.breadth = breadth or 0
   self.area = length*breadth;
   return o
end

-- Derived class method printArea

function Rectangle:printArea ()
   print("The area of Rectangle is ",self.area)
end

-- Creating an Object

r = Rectangle:new(nil,10,20)

-- Accessing Properties

print(r.length)

-- Accessing Member Function

r:printArea()

-- Complete Example

-- Meta class
Shape = {area = 0}

-- Base class method new

function Shape:new (o,side)
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   side = side or 0
   self.area = side*side;
   return o
end

-- Base class method printArea

function Shape:printArea ()
   print("The area is ",self.area)
end

-- Creating an object
myshape = Shape:new(nil,10)
myshape:printArea()

Square = Shape:new()

-- Derived class method new

function Square:new (o,side)
   o = o or Shape:new(o,side)
   setmetatable(o, self)
   self.__index = self
   return o
end

-- Derived class method printArea

function Square:printArea ()
   print("The area of square is ",self.area)
end

-- Creating an object
mysquare = Square:new(nil,10)
mysquare:printArea()

Rectangle = Shape:new()

-- Derived class method new

function Rectangle:new (o,length,breadth)
   o = o or Shape:new(o)
   setmetatable(o, self)
   self.__index = self
   self.area = length * breadth
   return o
end

-- Derived class method printArea

function Rectangle:printArea ()
    print("The area of Rectangle is ",self.area)
end

-- Creating an object

myrectangle = Rectangle:new(nil,10,20)
myrectangle:printArea()
