

Missile = Entity:new{t=Type.Missile, z=4, vz=0, r=5, col={140,80,120},line={10,30,10}, speed=100}

function Missile:update(dt)
    local diff = self.target.p - self.p
    if Vdd(diff) < (self.speed * dt) * (self.speed * dt) then
        self.p = self.target.p
        self.target.status:add(Damaged, 0.4)
        self.destroyed = true
    else
        self.v = Vscale(diff, self.speed)
        self.p = self.p + Vmult(dt, self.v)
    end
end

function Missile:draw(a)
    local h = self.r
    local linecol = colormult(0.5,self.col)
    if a then
        self.col[4] = a
        linecol[4] = a
    else
        self.col[4] = 255
        linecol[4] = 255
    end
    
    love.graphics.setColor(colormult(0.7,self.col))
    Ocylinder("fill",self.p,self.z,self.r,h)
    love.graphics.setColor(self.col)
    Ocircle("fill",self.p,self.z+h,self.r)

    if OUTLINES then
        love.graphics.setColor(linecol)
        Ocylinder("line",self.p,self.z,self.r,h)    
    end
end

-- skillshot has a magnitude speed and number dist. after it has traveled for dist it fizzles. 
Skillshot = Entity:new{t=Type.Skillshot, z=4, vz=0, r=5, col={90,80,120},line={10,30,10}, speed=100, dist=100}

function Skillshot:update(dt)
    self.dist = self.dist - self.speed * dt
    local p2 = self.p + Vmult(dt, self.v)
    self.p = p2
    for _, u in ipairs(collisionlayer[self.collides]) do
        -- assuming u is a unit
        if Vdist(self.p, u.p) < self.r + u.r then
            u.status:add(Damaged, 0.4)
            self.destroyed = true
            break
        end
    end
    if self.dist <= 0 then
        self.destroyed = true
    end
end

function Skillshot:draw(a)
    local h = self.r
    local linecol = colormult(0.5,self.col)
    if a then
        self.col[4] = a
        linecol[4] = a
    else
        self.col[4] = 255
        linecol[4] = 255
    end
    
    love.graphics.setColor(colormult(0.7,self.col))
    Ocylinder("fill",self.p,self.z,self.r,h)
    love.graphics.setColor(self.col)
    Ocircle("fill",self.p,self.z+h,self.r)

    if OUTLINES then
        love.graphics.setColor(linecol)
        Ocylinder("line",self.p,self.z,self.r,h)    
    end
end