local num1, num2 = 10, 5
local localAns = num1 + num2  -- Correct variable name

print("Input " .. num1 .. " + " .. num2 .. ": ")
local ans = io.read()

if tonumber(ans) == localAns then
	print("Correct")
else
	print("\nYour answer is " .. ans .. ", which is incorrect! Try again.")
end
