-- Testing and Validation Patterns in Lua

-- Simple assertion
local function assertEqual(a, b)
    if a ~= b then error('Assertion failed: ' .. tostring(a) .. ' ~= ' .. tostring(b)) end
end
assertEqual(2+2, 4)

-- Unit test example (busted framework)
-- describe('math', function()
--   it('adds', function()
--     assert.are.equal(2+2, 4)
--   end)
-- end)

-- Table-driven tests
local cases = {
    { input = 1, expected = 2 },
    { input = 2, expected = 3 },
}
for _, case in ipairs(cases) do
    assertEqual(case.input+1, case.expected)
end
