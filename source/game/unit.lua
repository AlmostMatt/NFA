require("game/unit_abilities")
function getMaxZ(pos, radius)
    return 0
end
function getZ(pos)
    return 0
end

WANDERSPEED = 60
WANDERDISTANCE = 150
MAXSPEED = 100
ACCEL = 800
OTHERJUMP = 180
CLIMBSPEED = 60
WALKABLE = 17

Type.Unit = Type.new()
Unit = Entity:new{t=Type.Unit, z=20, vz=0, r=7, h=17,col={140,160,240},line={10,30,10}}
--Unit = Object:new{z=20,r=7, h=17,t=UNIT,life=100}
function Unit:new(o)
    o = o or {}
    o.actions = ActionMap:new(o)
    o.actions:add("shoot", Shoot:new())
    o.actions:add("shoot2", Shoot2:new())
    o.status = StatusMap:new(o)

    return Entity.new(self, o)
end

function Unit:update(dt)
    if self.enemy and self.strategy then
        local diff = Vsub(self.enemy.p, self.p)
        local s = self.strategy
        local dist = Vmagn(diff)
        if dist < s.mind then -- TOO CLOSE
            self.v = Vadd(self.v, Vscale(diff, - ACCEL * dt))
        elseif dist > s.maxd then --TOO FAR
            self.v = Vadd(self.v, Vscale(diff, ACCEL * dt)) 
        else 
            --ATTEMPT TO COPY TARGETS SPEED
            -- self.v = Vadd(self.v, Vscale(Vsub(self.enemy.v, self.v), ACCEL * dt))
        end
        if Vdd(self.v) > MAXSPEED * MAXSPEED then
            self.v = Vscale(self.v, MAXSPEED)
        end
    
        if not self.status:has(Animation) then
            if self.actions:ready("shoot2") then
                self.actions:use("shoot2", self.enemy)
            elseif self.actions:ready("shoot") then
                self.actions:use("shoot", self.enemy.p)
            end
        end
    else
        if self.dest then
            local diff = Vsub(self.dest, self.p)
            if Vdd(diff) < 10*10 then
                self.dest = nil
            else
                self.v = Vadd(self.v, Vscale(diff, ACCEL * dt))
                if Vdd(self.v) > WANDERSPEED * WANDERSPEED then
                    self.v = Vscale(self.v, WANDERSPEED)
                end
            end
            if self.collided then
                self.vz = OTHERJUMP
            end
        else
            self.dest = randompoint(self.p, WANDERDISTANCE)
        end
    end
    if not self.status:has(Animation) then
        self:move(dt)
    end
    self.actions:update(dt)
    self.status:update(dt)
end


function Unit:move(dt)
    self.collided = false
    local groundz = getMaxZ(self.p,self.r)
    self.onground = self.z <= groundz
    if self.onground then
        self.vz = math.max(0,self.vz)
        if self.z < groundz then
            self.z = math.min(groundz, self.z + CLIMBSPEED*dt)
        end
    else
        self.vz = self.vz - GRAVITY * dt
    end
    --friction
    local d = Vmagn(self.v)
    self.v = Vscale(self.v,math.max(0,d-FRICTION*dt))
    local p2 = Vadd(self.p,Vmult(dt,self.v))
    local z2 = self.z + self.vz * dt
    local groundz2 = getMaxZ(p2,self.r)
    if groundz2 > groundz and groundz2 > self.z+WALKABLE then
        --collision
        local vx = P(self.v[1],0)
        local vy = P(0,self.v[2])
        local pvx, pvy = Vadd(self.p,Vmult(dt,vx)),Vadd(self.p,Vmult(dt,vy))
        if getMaxZ(pvx,self.r) > self.z+WALKABLE then
            self.v = Vsub(self.v,vx)
            self.collided = true
        end
        if getMaxZ(pvy,self.r) > self.z+WALKABLE then
            self.v = Vsub(self.v,vy)
            self.collided = true
        end
        p2 = Vadd(self.p,Vmult(dt,self.v))
    --else
    end    
    self.p = p2
    self.z = z2
end

function Unit:draw(a)
    --tiledShadow(self.p,self.z,self.r)
    local h = self.h
    if self.status:has(Animation) then
        h = h * (1.0 - self.status:duration(Animation))
    end
    
    local col = self.col
    if self.status:has(Damaged) then
        local flash_dur = self.status:duration(Damaged)
        col = {col[1], col[2]* (1 - flash_dur), col[3] * (1 - flash_dur), 255}
    end
    local linecol = colormult(0.5, col)--TILECOLORS.LINE[t.t]
    if a then
        col[4] = a
        linecol[4] = a
    else
        col[4] = 255
        linecol[4] = 255
    end
    
    love.graphics.setColor(colormult(0.7,col))
    Ocylinder("fill",self.p,self.z,self.r,h)
    love.graphics.setColor(col)
    Ocircle("fill",self.p,self.z+h,self.r)

    if OUTLINES then
        love.graphics.setColor(linecol)
        Ocylinder("line",self.p,self.z,self.r,h)    
    end
    
    -- AI visualization
    if self.dest then
       Oline(self.p, self.z, self.dest, getZ(self.dest))
    end
    if self.strategy and self.enemy then
        local dist = Vdist(self.enemy.p, self.p)
        if dist < self.strategy.mind then
            love.graphics.setColor(128, 0, 0)
        else
            love.graphics.setColor(0, 128, 0)
        end
        Ocircle("line", self.p, self.z, self.strategy.mind)
        if dist > self.strategy.maxd then
            love.graphics.setColor(128, 0, 0)
        else
            love.graphics.setColor(0, 128, 0)
        end
        Ocircle("line", self.p, self.z, self.strategy.maxd)
    end
end


