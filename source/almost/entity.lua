-- a set of type identifiers
-- each type has a unique value, which is one more than the previous value
Type = {}
function Type.new()
    return #Type
end

Type.Drawable = Type.new()
Drawable = {t=Type.Drawable}
function Drawable:new(o)
    o = o or {}
    --o.p = o.p or P(0,0)
    setmetatable(o, self)
    self.__index = self
    return o
end

function Drawable:draw(a)
end

Type.Entity = Type.new()
Entity = Drawable:new{t=Type.Entity}
function Entity:new(o)
    o = o or {}
    o.p = o.p or P(0,0)
    o.v = o.v or P(0,0)
    return Drawable.new(self, o)
end

function Entity:update(dt)
end