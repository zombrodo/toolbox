local toolbox = (...):gsub("matrix", "")
local Vector3 = require(toolbox .. "vector3")

local Matrix = {}
Matrix.__index = Matrix

function Matrix.new()
  local self = setmetatable({
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1
  }, Matrix)
  return self
end

function Matrix.__tostring(m)
  local result = m[1] .. " " .. m[2] .. " " .. m[3] .. " " .. m[4] .. "\n"
  result = result .. m[5] .. " " .. m[6] .. " " .. m[7] .. " " .. m[8] .. "\n"
  result = result .. m[9] .. " " .. m[10] .. " " .. m[11] .. " " .. m[12] .. "\n"
  result = result .. m[13] .. " " .. m[14] .. " " .. m[15] .. " " .. m[16] .. "\n"
  return result
end

-- =============================================================================
-- Pooling
-- =============================================================================

local function setIdentity(matrix)
  matrix[1] = 1
  matrix[2] = 0
  matrix[3] = 0
  matrix[4] = 0

  matrix[5] = 0
  matrix[6] = 1
  matrix[7] = 0
  matrix[8] = 0

  matrix[9] = 0
  matrix[10] = 0
  matrix[11] = 1
  matrix[12] = 0

  matrix[13] = 0
  matrix[14] = 0
  matrix[15] = 0
  matrix[16] = 1
  return matrix
end

local MAX_POOL_SIZE = 64
local objectPool = {}

function Matrix.request()
  if #objectPool > 0 then
    return table.remove(objectPool)
  end
  return Matrix.new()
end

function Matrix.fromPool()
  return setIdentity(Matrix.request())
end

function Matrix:release()
  if #objectPool < MAX_POOL_SIZE then
    table.insert(objectPool, self)
  end
end

function Matrix.flushPool()
  if #objectPool > 0 then
    objectPool = {}
  end
end

-- =============================================================================
-- Constructors
-- =============================================================================

function Matrix.transformMatrix(translation, rotation, scale)
  local result = Matrix.fromPool()

  -- Translation
  result[4] = translation.x
  result[8] = translation.y
  result[12] = translation.z

  -- Rotation
  local cosX = math.cos(rotation.x)
  local cosY = math.cos(rotation.y)
  local cosZ = math.cos(rotation.z)

  local sinX = math.sin(rotation.x)
  local sinY = math.sin(rotation.y)
  local sinZ = math.sin(rotation.z)

  result[1] = cosX * cosY
  result[2] = (cosX * sinY * sinZ) - (sinX * cosZ)
  result[3] = (cosX * sinY * cosZ) + (sinX * sinZ)

  result[5] = sinX * cosY
  result[6] = (sinX * sinY * sinZ) + (cosX * cosZ)
  result[7] = (sinX * sinY * cosZ) - (cosX * sinZ)

  result[9] = -sinX
  result[10] = cosY * sinZ
  result[11] = cosY * cosZ

  -- Scale
  result[1] = result[1] * scale.x
  result[2] = result[2] * scale.y
  result[3] = result[3] * scale.z

  result[5] = result[5] * scale.x
  result[6] = result[6] * scale.y
  result[7] = result[7] * scale.z

  result[9] = result[9] * scale.x
  result[10] = result[10] * scale.y
  result[11] = result[11] * scale.z

  return result
end

function Matrix.projectionMatrix(fov, near, far, aspectRatio)
  local result = Matrix.fromPool()

  local top = near * math.tan(fov / 2)
  local bottom = -top
  local right = top * aspectRatio
  local left = -right

  result[1] = 2 * near / (right - left)
  result[2] = 0
  result[3] = (right + left) / (right - left)
  result[4] = 0

  result[5] = 0
  result[6] = 2 * near / (top - bottom)
  result[7] = (top + bottom) / (top - bottom)
  result[8] = 0

  result[9] = 0
  result[10] = 0
  result[11] = -1 * (far + near) / (far - near)
  result[12] = -2 * (far * near) / (far - near)

  result[13] = 0
  result[14] = 0
  result[15] = -1
  result[16] = 0

  return result
end

function Matrix.viewMatrix(eye, target, down)
  local result = Matrix.fromPool()
  local zt = Vector3.normalised(eye - target)
  local xt = Vector3.normalised(Vector3.cross(down, zt))
  local yt = Vector3.cross(zt, xt)

  result[1] = xt.x
  result[2] = xt.y
  result[3] = xt.z
  result[4] = -1 * Vector3.dot(xt, eye)

  result[5] = yt.x
  result[6] = yt.y
  result[7] = yt.z
  result[8] = -1 * Vector3.dot(yt, eye)

  result[9] = zt.x
  result[10] = zt.y
  result[11] = zt.z
  result[12] = -1 * Vector3.dot(zt, eye)

  zt:release()
  xt:release()
  yt:release()

  return result
end

return Matrix
