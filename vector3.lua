local Vector3 = {}
Vector3.__index = Vector3

local function clamp(n, min, max)
  if n < min then
    return min
  elseif n > max then
    return max
  end
  return n
end

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
  return "(" .. self.x .. ", " .. self.y .. ", " .. self.z .. ")"
end

function Vector3.zero()
  return Vector3.new(0, 0, 0)
end

function Vector3.one()
  return Vector3.new(1, 1, 1)
end

function Vector3.unitX()
  return Vector3.new(1, 0, 0)
end

function Vector3.unitY()
  return Vector3.new(0, 1, 0)
end

function Vector3.unitZ()
  return Vector3.new(0, 0, 1)
end

function Vector3.up()
  return Vector3.new(0, 1, 0)
end

function Vector3.down()
  return Vector3.new(0, -1, 0)
end

function Vector3.right()
  return Vector3.new(1, 0, 0)
end

function Vector3.left()
  return Vector3.new(-1, 0, 0)
end

function Vector3.forward()
  return Vector3.new(0, 0, -1)
end

function Vector3.backward()
  return Vector3.new(0, 0, 1)
end

function Vector3:clone()
  return Vector3.new(self.x, self.y, self.z)
end

function Vector3:invert()
  self.x = -self.x
  self.y = -self.y
  self.z = -self.y
  return self
end

function Vector3.__unm(a)
  return a:clone():invert()
end

function Vector3:add(other)
  self.x = self.x + other.x
  self.y = self.y + other.y
  self.z = self.z + other.z
  return self
end

function Vector3.__add(a, b)
  return a:clone():add(b)
end

function Vector3:sub(other)
  self.x = self.x - other.x
  self.y = self.y - other.y
  self.z = self.z - other.z
  return self
end

function Vector3.__sub(a, b)
  return a:clone():sub(b)
end

function Vector3:mul(other)
  self.x = self.x * other.x
  self.y = self.y * other.y
  self.z = self.z * other.z
  return self
end

function Vector3.__mul(a, b)
  return a:clone():mul(b)
end

function Vector3:div(other)
  self.x = self.x / other.x
  self.y = self.y / other.y
  self.z = self.z / other.z
  return self
end

function Vector3.__div(a, b)
  return a:clone():div(b)
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
  return self.x  * other.x + self.y * other.y + self.x * other.z
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
  local v = 1 / self:length()
  self.x = self.x * v
  self.y = self.y * v
  self.z = self.z * v
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
  local x = a.y * b.z - b.y * a.z
  local y = -(a.x * b.z - b.z * a.z)
  local z = a.x * b.y - b.x * a.y
  return Vector3.new(x, y, z)
end

function Vector3.ceiling(vector)
    return Vector3.new(
      math.ceil(vector.x),
      math.ceil(vector.y),
      math.ceil(vector.z))
end

function Vector3.floor(vector)
  return Vector3.new(
    math.floor(vector.x),
    math.floor(vector.y),
    math.floor(vector.z))
end

function Vector3.clamp(vector, min, max)
  return Vector3.new(
    clamp(vector.x, min.x, max.x),
    clamp(vector.y, min.y, max.y),
    clamp(vector.z, min.z, max.z)
  )
end

function Vector3.lerp(from, to, amount)
  return Vector3.new(
    lerp(from.x, to.x, amount),
    lerp(from.y, to.y, amount),
    lerp(from.z, to.z, amount)
  )
end

function Vector3.max(a, b)
  return Vector3.new(math.max(a.x, b.x), math.max(a.y, b.y), math.max(a.z, b.z))
end

function Vector3.min(a, b)
  return Vector3.new(math.min(a.x, b.x), math.min(a.y, b.y), math.min(a.z, b.z))
end

function Vector3.normalised(vector)
  return vector:clone():normalise()
end

function Vector3.reflected(vector, normal)
  return vector:clone():reflect(normal)
end

return Vector3
