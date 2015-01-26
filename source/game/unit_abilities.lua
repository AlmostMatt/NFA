require("almost/abilities")
require("game/projectile")

SHOT_SPEED = 200
SHOT_DIST = 180

-- fire a skillshot in a direction. it will hit any enemy unit.
Shoot = Action:new{maxcd = 0.8}
function Shoot:ready()
    return Action.ready(self)
end

function Shoot:use(point)
    if self:ready() then
        --love.audio.play(JumpSound)
        Action.use(self)
        self.owner.status:add(Animation, 0.25)
        local diff = point - self.owner.p
        local ownlayer = (self.owner.layer == PLAYER1) and PROJECTILE1 or PROJECTILE2
        local targetlayer = (self.owner.layer == PLAYER1) and PLAYER2 or PLAYER1
        local shot = Skillshot:add(
            {
                p=self.owner.p,
                v = Vscale(diff, SHOT_SPEED),
                speed=SHOT_SPEED,
                dist = SHOT_DIST,
                collides=targetlayer
             },
             ownlayer)
        table.insert(entities, shot)
    end
end

-- fire a homing missile at a unit
Shoot2 = Action:new{maxcd = 2.0}
function Shoot2:ready()
    return Action.ready(self)
end

function Shoot2:use(unit)
    if self:ready() then
        --love.audio.play(JumpSound)
        Action.use(self)
        self.owner.status:add(Animation, 0.25)
        local ownlayer = (self.owner.layer == PLAYER1) and PROJECTILE1 or PROJECTILE2
        local shot = Missile:add(
            {
                p=self.owner.p,
                speed=SHOT_SPEED,
                target=unit,
            }, 
             ownlayer)
        table.insert(entities, shot)
    end
end
