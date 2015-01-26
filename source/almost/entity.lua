
-- collision layers
PLAYER1 = 0
PLAYER2 = 1
NEUTRAL = 2
PROJECTILE1 = 3
PROJECTILE2 = 4
NO_COLLISION = 5
LAST_LAYER = NO_COLLISION

function InitEntities()
    collisionlayer = {}
    entities = {}
    for layer = 0, LAST_LAYER do
        collisionlayer[layer] = {}
    end
end

-- a set of type identifiers
-- each type has a unique value, which is one more than the previous value
Type = {}
function Type.new()
    return #Type
end

Type.Drawable = Type.new()
Drawable = {t=Type.Drawable}
function Drawable:new(o)
    local o = o or {}
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
    local o = o or {}
    o.p = o.p or P(0,0)
    o.v = o.v or P(0,0)
    return Drawable.new(self, o)
end

function Entity:add(o, layer)
    local o = Entity.new(self, o)
    o.layer = layer
    table.insert(entities, o)
    table.insert(collisionlayer[layer], o)
    return o
end

function Entity:update(dt)
end