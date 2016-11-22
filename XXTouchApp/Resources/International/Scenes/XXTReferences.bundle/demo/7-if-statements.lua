--[ local variable definition --]
a = 10;

--[ check the boolean condition using if statement --]

if( a < 20 )
then
   --[ if condition is true then print the following --]
   print("a is less than 20" );
end

print("value of a is :", a);

--[ local variable definition --]
a = 100;

--[ check the boolean condition --]

if( a < 20 )
then
   --[ if condition is true then print the following --]
   print("a is less than 20" )
else
   --[ if condition is false then print the following --]
   print("a is not less than 20" )
end

print("value of a is :", a)

--[ local variable definition --]
a = 100;
b = 200;

--[ check the boolean condition --]

if( a == 100 )
then
   --[ if condition is true then check the following --]
   if( b == 200 )
   then
      --[ if condition is true then print the following --]
      print("Value of a is 100 and b is 200" );
   end
end

print("Exact value of a is :", a );
print("Exact value of b is :", b );
