require("almost/abilities")
require("game/projectile")

SHOT_SPEED = 200
SHOT_DIST = 180

Shoot = Action:new{maxcd = 0.5}
function Shoot:ready()
    return Action.ready(self)
end

function Shoot:use(point)
    if self:ready() then
        --love.audio.play(JumpSound)
        Action.use(self)
        self.owner.status:add(Animation, 0.25)
        local diff = point - self.owner.p
        local shot = Skillshot:new{p=self.owner.p, v = Vscale(diff, SHOT_SPEED), speed=SHOT_SPEED, dist = SHOT_DIST}
        table.insert(entities, shot)
    end
end


Shoot2 = Action:new{maxcd = 2.5}
function Shoot2:ready()
    return Action.ready(self)
end

function Shoot2:use(unit)
    if self:ready() then
        --love.audio.play(JumpSound)
        Action.use(self)
        self.owner.status:add(Animation, 0.4)
        local shot = Missile:new{p=self.owner.p, speed=SHOT_SPEED, target=unit}
        table.insert(entities, shot)
    end
end
