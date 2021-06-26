local Vector3 = {}
Vector3.__index = Vector3

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

function Vector3.new(x, y, z)
  local self = setmetatable({}, Vector3)
  self.x = x
  self.y = y
  self.z = z
  return self
end

function Vector3:__tostring()
  return "(Vector3: " .. self.x .. ", " .. self.y .. ", " .. self.z .. ")"
end

function Vector3.zero()
  return Vector3.new(0, 0, 0)
end

function Vector3.one()
  return Vector3.new(1, 1, 1)
end

function Vector3:set(x, y, z)
  self.x = x
  self.y = y
  self.z = z
  return self
end

function Vector3:clone(pooled)
  if pooled then
    return Vector3.fromPool(self.x, self.y, self.z)
  end
  return Vector3.new(self.x, self.y, self.z)
end

function Vector3:unpack()
  return self.x, self.y, self.z
end

-- =============================================================================
-- Pooling
-- =============================================================================

local MAX_POOL_SIZE = 128
local objectPool = {}

-- Requests a Vector3 from the pool. If none available, a new Vector3.zero
-- is returned.
function Vector3.request()
  if #objectPool > 0 then
    return table.remove(objectPool)
  end
  return Vector3.zero()
end

-- Attempts to retrieve a Vector3 from the pool, with its values set to `x`
-- `y`, and `z`
function Vector3.fromPool(x, y, z)
  return Vector3.request():set(x, y, z)
end

-- Releases the Vector3 object to the pool
function Vector3:release()
  if #objectPool < MAX_POOL_SIZE then
    table.insert(objectPool, self)
  end
end

-- Empties the object pool
function Vector3.flushPool()
  if #objectPool > 0 then
    objectPool = {}
  end
end

-- =============================================================================
-- Operations
-- =============================================================================

function Vector3:invert()
  self.x = -self.x
  self.y = -self.y
  self.z = -self.y
  return self
end

function Vector3.__unm(a)
  return a:clone(true):invert()
end

function Vector3:add(other)
  self.x = self.x + other.x
  self.y = self.y + other.y
  self.z = self.z + other.z
  return self
end

function Vector3.__add(a, b)
  return a:clone(true):add(b)
end

function Vector3:sub(other)
  self.x = self.x - other.x
  self.y = self.y - other.y
  self.z = self.z - other.z
  return self
end

function Vector3.__sub(a, b)
  return a:clone(true):sub(b)
end

function Vector3:mul(other)
  self.x = self.x * other.x
  self.y = self.y * other.y
  self.z = self.z * other.z
  return self
end

function Vector3.__mul(a, b)
  return a:clone(true):mul(b)
end

function Vector3:div(other)
  self.x = self.x / other.x
  self.y = self.y / other.y
  self.z = self.z / other.z
  return self
end

function Vector3.__div(a, b)
  return a:clone(true):div(b)
end

function Vector3:distance(other)
  return math.sqrt(self:distanceSquared(other))
end

function Vector3:distanceSquared(other)
  return (self.x - other.x) * (self.x - other.x) +
    (self.y - other.y) * (self.y - other.y) +
    (self.z - other.z) * (self.z - other.z)
end

function Vector3:dot(other)
  return (self.x * other.x) + (self.y * other.y) + (self.z * other.z)
end

function Vector3:equals(other)
  if getmetatable(other) == Vector3
    or (type(other) == "table" and other.x and other.y and other.z)
  then
    return self.x == other.x and self.y == other.y and self.z == other.y
  end
  return false
end

function Vector3.__eq(a, b)
  return a:equals(b)
end

function Vector3:length()
  return math.sqrt((self.x * self.x) + (self.y * self.y) + (self.z * self.z))
end

function Vector3:lengthSquared()
  return (self.x * self.x) + (self.y * self.y) + (self.z * self.z)
end

function Vector3:normalise()
  local v = self:length()
  self.x = self.x / v
  self.y = self.y / v
  self.z = self.z / v
  return self
end

function Vector3:reflect(normal)
  local dot = (self.x * normal.x) + (self.y * normal.y) + (self.z * normal.z)
  self.x = self.x - (2 * normal.x) * dot
  self.y = self.y - (2 * normal.y) * dot
  self.z = self.z - (2 * normal.z) * dot
  return self
end

-- =============================================================================
-- Static Members
-- =============================================================================

function Vector3.cross(a, b)
  local x = a.y * b.z - a.z * b.y
  local y = a.z * b.x - a.x * b.z
  local z = a.x * b.y - a.y * b.x
  return Vector3.fromPool(x, y, z)
end

function Vector3.ceiling(vector)
    return Vector3.fromPool(
      math.ceil(vector.x),
      math.ceil(vector.y),
      math.ceil(vector.z))
end

function Vector3.floor(vector)
  return Vector3.fromPool(
    math.floor(vector.x),
    math.floor(vector.y),
    math.floor(vector.z))
end

function Vector3.clamp(vector, min, max)
  return Vector3.fromPool(
    clamp(vector.x, min.x, max.x),
    clamp(vector.y, min.y, max.y),
    clamp(vector.z, min.z, max.z)
  )
end

function Vector3.lerp(from, to, amount)
  return Vector3.fromPool(
    lerp(from.x, to.x, amount),
    lerp(from.y, to.y, amount),
    lerp(from.z, to.z, amount)
  )
end

function Vector3.max(a, b)
  return Vector3.fromPool(math.max(a.x, b.x), math.max(a.y, b.y), math.max(a.z, b.z))
end

function Vector3.min(a, b)
  return Vector3.fromPool(math.min(a.x, b.x), math.min(a.y, b.y), math.min(a.z, b.z))
end

function Vector3.normalised(vector)
  return vector:clone(true):normalise()
end

function Vector3.reflected(vector, normal)
  return vector:clone(true):reflect(normal)
end

return Vector3
