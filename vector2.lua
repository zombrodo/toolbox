local Vector2 = {}
Vector2.__index = Vector2

-- Returns `true` if value is of type `"number"`
local function isScalar(value)
  return type(value) == "number"
end

-- Clamps the value of `n`. If `n < min` then return min, else if `n > max` then
-- return `max`, otherwise return `n`
local function clamp(n, min, max)
  if n < min then
    return min
  elseif n > max then
    return max
  end
  return n
end

-- Lerps `amount` between `a` and `b`
local function lerp(a, b, amount)
  return a + (b - a) * amount
end

-- Returns a new Vector2 object with `x` and `y` component. If no `y` is
-- provided, then the new Vector2 will be `x, x`.
function Vector2.new(x, y)
  local self = setmetatable({}, Vector2)
  self.x = x
  self.y = y or x
  return self
end

function Vector2.__tostring(self)
  return "(Vector2: " .. self.x .. ", " .. self.y .. ")"
end

-- Returns a Vector2 with components `0, 0`
function Vector2.zero()
  return Vector2.new(0, 0)
end

-- Returns a Vector2 with components `1, 1`
function Vector2.one()
  return Vector2.new(1, 1)
end

-- Returns a new Vector2, with the same values as this one.
function Vector2:clone(pooled)
  if pooled then
    return Vector2.fromPool(self.x, self.y)
  end
  return Vector2.new(self.x, self.y)
end

-- =============================================================================
-- Pooling
-- =============================================================================

local MAX_POOL_SIZE = 128
local objectPool = {}

-- Requests a Vector2 from the pool. If none available, a new Vector2.zero
-- is returned.
function Vector2.request()
  if #objectPool > 0 then
    return table.remove(objectPool)
  end
  return Vector2.zero()
end

-- Attempts to retrieve a Vector2 from the pool, with its values set to `x`
-- and `y`
function Vector2.fromPool(x, y)
  return Vector2.request():set(x, y)
end

-- Releases the Vector2 object to the pool
function Vector2:release()
  if #objectPool < MAX_POOL_SIZE then
    table.insert(objectPool, self)
  end
end

-- Empties the object pool
function Vector2.flushPool()
  if #objectPool > 0 then
    objectPool = {}
  end
end

-- =============================================================================
-- Operations
-- =============================================================================

-- Inverts the values of the Vector2
function Vector2:invert()
  self.x = -self.x
  self.y = -self.y
  return self
end

function Vector2:__unm(a)
  return a:clone(true):invert()
end

-- Adds two values in place. `other` can either be a scalar value (`number`) or
-- another Vector2-like object.
function Vector2:add(other)
  if isScalar(other) then
    self.x = self.x + other
    self.y = self.y + other
    return self
  end

  self.x = self.x + other.x
  self.y = self.y + other.y
  return self
end

function Vector2.__add(a, b)
  return a:clone(true):add(b)
end

-- Subtracts two values in place. `other` can either be a scalar value
-- (`number`) or another Vector2-like object.
function Vector2:sub(other)
  if isScalar(other) then
    self.x = self.x - other
    self.y = self.y + other
    return self
  end

  self.x = self.x - other.x
  self.y = self.y - other.y
  return self
end

function Vector2.__sub(a, b)
  return a:clone(true):sub(b)
end

-- Multiplies two values in place. `other` can either be a scalar value
-- (`number`) or another Vector2-like object.
function Vector2:mul(other)
  if isScalar(other) then
    self.x = self.x * other
    self.y = self.y * other
    return self
  end

  self.x = self.x * other.x
  self.y = self.y * other.y
  return self
end

function Vector2.__mul(a, b)
  return a:clone(true):mul(b)
end

-- Divides two values in place. `other` can either be a scalar value
-- (`number`) or another Vector2-like object.
function Vector2:div(other)
  if isScalar(other) then
    self.x = self.x / other
    self.y = self.y / other
    return self
  end

  self.x = self.x / other.x
  self.y = self.y / other.y
  return self
end

function Vector2.__div(a, b)
  return a:clone(true):div(b)
end

-- Returns the distance between `self` and `other`.
function Vector2:distance(other)
    local dx = self.x - other.x
    local dy = self.y - other.y
    return math.sqrt((dx * dx) + (dy * dy))
end

-- Returns the distance squared between `self` and `other`.
function Vector2:distanceSquared(other)
    local dx = self.x - other.x
    local dy = self.y - other.y
    return (dx * dx) + (dy * dy)
end

-- Returns the dot product of `self` and `other`.
function Vector2:dot(other)
  return (self.x * other.x) + (self.y * other.y)
end

-- Checks the equality between `self` and `other`. Returns `true` if `other` is
-- a vector, and has the same `x, y` values, else `false`.
function Vector2:equals(other)
  if getmetatable(other) == Vector2
    or (type(other) == "table" and other.x and other.y) then
    return self.x == other.x and self.y == other.y
  end

  return false
end

function Vector2:__eq(a, b)
  return a:equals(b)
end

-- Returns the length of `self`.
function Vector2:length()
  return math.sqrt((self.x * self.x) + (self.y * self.y))
end

-- Returns the length squared of `self`.
function Vector2:lengthSquared()
  return (self.x * self.x) + (self.y * self.y)
end

-- Normalises the values of `self` in place. Use `Vector2.normalised` to instead
-- return a new Vector with its values normalised.
function Vector2:normalise()
  local v = 1 / self:length()
  self.x = self.x * v
  self.y = self.y * v
  return self
end

-- Reflects the values of `self.` in place. Use `Vector2.reflected` to instead
-- return a new Vector with its values reflected.
function Vector2:reflect(normal)
  local v = 2 * ((self.x * normal.x) + (self.y * normal.y))
  self.x = self.x - (normal.x * v)
  self.y = self.y - (normal.y * v)
  return self
end

-- Returns the `x` and `y` components of `self.`
function Vector2:values()
  return self.x, self.y
end

-- =============================================================================
--  Static Functions
-- =============================================================================

-- Returns a new Vector2 where `x` and `y` are `> min` and `< max`.
function Vector2.clamp(vector, min, max)
  return Vector2.fromPool(
    clamp(vector.x, min.x, max.x),
    clamp(vector.y, min.y, max.y)
  )
end

-- Returns a new Vector2 interpolated between `from` and `to` by `amount`.
function Vector2.lerp(from, to, amount)
  return Vector2.fromPool(lerp(from.x, to.x, amount), lerp(from.y, to.y, amount))
end

-- Returns a new Vector2 in which its values are the largest integer value
-- less than `x` and `y` respectively.
function Vector2.floor(vector)
    return Vector2.fromPool(math.floor(vector.x), math.floor(vector.y))
end

-- Returns a new Vector2 in which its values are the largest integer value
-- more than `x` and `y` respectively
function Vector2.ceiling(vector)
  return Vector2.fromPool(math.ceil(vector.x), math.floor(vector.y))
end

-- Creates a new Vector2 which is the maximal values from the two vectors.
function Vector2.max(a, b)
  return Vector2.fromPool(math.max(a.x, b.x), math.max(a.y, b.y))
end

-- Creates a new Vector2 which is the minimal values from the two vectors.
function Vector2.min(a, b)
  return Vector2.fromPool(math.min(a.x, b.x), math.min(a.y, b.y))
end

-- Creates a new Vector2 in which its components are normalised based off of the
-- vector passed in.
function Vector2.normalised(vector)
  return vector:clone(true):normalise()
end

-- Creates a new Vector2 in which its components are reflected based off of the
-- vector and normal passed in.
function Vector2.reflected(vector, normal)
  return vector:clone(true):reflect(normal)
end

return Vector2