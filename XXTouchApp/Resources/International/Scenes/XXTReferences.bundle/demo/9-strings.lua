string1 = "Lua"
print("\"String 1 is\"",string1)

string2 = 'Tutorial'
print("String 2 is",string2)

string3 = [["Lua Tutorial"]]
print("String 3 is",string3)

-- Case Manipulation

string1 = "Lua";

print(string.upper(string1))
print(string.lower(string1))

-- Replacing a Substring

string = "Lua Tutorial"

newstring = string.gsub(string,"Tutorial","Language")
print("The new string is",newstring)

-- Finding and Reversing

string = "Lua Tutorial"

print(string.find(string,"Tutorial"))
reversedString = string.reverse(string)
print("The new string is",reversedString)

-- Formatting Strings

string1 = "Lua"
string2 = "Tutorial"

number1 = 10
number2 = 20

-- Basic string formatting
print(string.format("Basic formatting %s %s",string1,string2))

-- Date formatting
date = 2; month = 1; year = 2014
print(string.format("Date formatting %02d/%02d/%03d", date, month, year))

-- Decimal formatting
print(string.format("%.4f",1/3))

-- Character and Byte Representations

-- Byte conversion

-- First character
print(string.byte("Lua"))

-- Third character
print(string.byte("Lua",3))

-- first character from last
print(string.byte("Lua",-1))

-- Second character
print(string.byte("Lua",2))

-- Second character from last
print(string.byte("Lua",-2))

-- Internal Numeric ASCII Conversion
print(string.char(97))

-- Other Common Functions

string1 = "Lua"
string2 = "Tutorial"

-- String Concatenations using ..
print("Concatenated string",string1..string2)

-- Length of string
print("Length of string1 is ",string.len(string1))

-- Repeating strings
repeatedString = string.rep(string1,3)
print(repeatedString)
