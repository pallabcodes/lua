-- table / array

local arr = { 10, 15, 20, true, "Hello World", 2.2 }
-- This will print the memory address e.g. 0x55a6c9a56600
print(arr)

-- to access a specific element
print(arr[2])

-- to access the last element i.e. here 2.2
print(arr[#arr])

table.insert(arr, 2, "lol")

for i = 1, #arr do
    print(arr[i])
end    

arr = { "hello", "world", "I", "am john" }
-- so it will go to each element and suffix (except the last element) it e.g. hello!, world!, I!, 
print(table.concat(arr, "!"))

-- Matrix/2D array

arr = {
    {1, 2, 3},
    {6, 8, 0},
    {9, 99, 989}
}

print(arr[2][2]) -- 8

for i = 1, #arr do
    for j = 1, #arr[i] do
        print(arr[i][j])
    end -- Close the inner loop
end -- Close the outer loop
