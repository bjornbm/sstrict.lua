require("sstrict")

local function fail(msg)
  print("\nTEST FAILED")
  if msg then print("Expected: " .. msg) end
  os.exit(1)
end

local function try(src, msg)
  local res, err = loadstring(src)
  if res then
    print("VALID")
    print(src)
    if msg then fail(msg) end  -- a failure was expected
  else
    print("INVALID")
    print(src)
    print(err)
    if not msg then fail("VALID") end  -- no failure was expected
    if not err:match(msg) then fail(msg) end  -- wrong error
  end
  print("\n")
end

-- undeclared
try([[local function myFunc() a = 5 end]], "undefined variable 'a'")
try([[a = 'undeclared']], "undefined variable 'a'")
try([[_G['undeclared'] = a]], "undefined variable 'a'")

-- var reuse
try([[local list = {1,2,3} for i, v in ipairs(list) do for i, w in ipairs(list) do end end return list]], "variable name 'i' redefinition")
try([[return function(a) local a = 5 return a end]], "variable name 'a' redefinition")
try([[return function(a) local a, b, a = 2 math.randomseed(a) end]], "duplicate variable 'a'")

-- empty blocks
try([[for i = 1, 100 do end]], "empty code block")
try([[local list = {1,2,3} for _ in ipairs(list) do end]], "empty code block")
try([[while true do end]], "empty code block")
try([[repeat until true]], "empty code block")
try([[return function(a, b) end]])
try([[local function oops() os.clock() end]])
try([[local obj = {} function obj:baz() end return obj]])
try([[while os.clock() do end]])
try([[while _G['a'] do end ]])
try([[while _G.a do end ]])

-- unnecessary code block
try([[for i = 1, 100 do local z = i z = z + 1 end]], "unnecessary code block")
try([[return function(a,b,c) local d = 5 d = d + 1 end]], "unnecessary code block")
try([[return function(a,b,c) local d = a+b+c d=d+1 end]])
try([[return function(q) q = q + 1 end]])
try([[return function() io = nil end]])


-- unused vars
try([[local function cc() local a, _ = os.clock() end]], "unused variable 'a'")
try([[local function cc() local _, b = os.clock() end]], "unused variable 'b'")
try([[local function cc() local a, b = os.clock() return b end]])

-- literals
try([[_G['q']={0x1ULL,0x1LL,0x1ull,0x1ll,1ULL,1LL,0x1p1,12.5i}]])
try([[_G['q']={"1 \"2\"",""}]])
try([[return (5+3)/3*.2]])
try([[return 1^-2]])
try([[return 1^(-2)^#{}^-2^3]])
try("return [=====[ [==[boo]==] ]=====], 123, '\\''")
try("-- ok [[ comment ]] -- ok")
try('--["p"]={ img="123.png" },')
try([=[
return function(item, other) 
  if --[[other.isSlope or]] other.isSolid then
    return "cross"
  end
end
]=])

try([[print("a\"b")]])
try([[return "\"житното зърно,"]])
try([[return "житното зърно,"]])

-- assignment values count
try([[local a,b=1,2,3 return a]], "too many values in assignment")
try([[local a,b,c=1,2 return a]])
try([[local a,b,c=unpack(_G) return a]])

-- constant condition
try([[if true then print('ok') end]], "constant if/else condition")
try([[if 2+2 > 3 then print('ok') end]], "constant if/else condition")
try([[local a = 0 while true do a = a + 1 end return a]])

-- table constructor duplicates
try([[return { ['a'] = 1, a = 1 }]], "duplicate field 'a' in table constructor")
try([[return { [1] = 1, 1 }]], "duplicate field '1' in table constructor")
try([[return { [1+2^3*4%5] = 1, 1,2,3 }]], "duplicate field '3' in table constructor")
try([[return { ['a' .. 4]=1, a4=1 }]], "duplicate field 'a4' in table constructor")

print("OK")
