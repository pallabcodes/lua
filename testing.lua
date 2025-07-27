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

-- Mock/stub patterns (enterprise scenario)
local function createMock()
    local mock = { calls = {} }
    return setmetatable(mock, {
        __call = function(self, ...)
            table.insert(self.calls, {...})
            return 'mocked'
        end
    })
end
local mockFn = createMock()
print('Mock result:', mockFn('arg1', 'arg2'))
print('Mock calls:', #mockFn.calls)

-- Integration test scenario (product scenario)
local function integrationTest()
    local results = {}
    -- Test API -> DB -> Cache chain
    local api = function(id) return { id = id, name = 'User' .. id } end
    local db = function(user) print('Saved to DB:', user.name); return true end
    local cache = function(user) print('Cached:', user.name); return true end
    
    local user = api(123)
    local saved = db(user)
    local cached = cache(user)
    
    table.insert(results, { test = 'integration', passed = saved and cached })
    return results
end
local testResults = integrationTest()
print('Integration test passed:', testResults[1].passed)

-- Coverage reporting simulation (enterprise scenario)
local coverage = { lines = 0, covered = 0 }
local function trackCoverage(line)
    coverage.lines = coverage.lines + 1
    coverage.covered = coverage.covered + 1
end
trackCoverage(1); trackCoverage(2)
print('Coverage:', (coverage.covered / coverage.lines) * 100 .. '%')
