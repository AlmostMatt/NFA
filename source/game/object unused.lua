

--the largest cliff height that you can simply walk up
WALKABLE = 17
--WALKABLE = 40
CLIMBSPEED = 60
--CLIMBSPEED = 100

PRISM = "prism"
UNIT = "unit"
OTHER = "other"
TREE = "tree"

--skin color {180,161,147}
Object = {t=OTHER,p=P(0,0),v=P(0,0), z=0, vz = 0, col={115,70,60}, line={80,80,80}}
 
function Object:new(o)
    o = o or {}
    o.p = o.p or P(0,0)
    o.v = o.v or P(0,0)
    setmetatable(o,self)
    self.__index = self
    return o
end

Prism = Object:new{v1=V(unit,0,0),v2=V(0,unit,0), h=20,col={244,244,244},coltop={196,219,196},t=PRISM}
Tree = Object:new{r=15,h=40,t=TREE,col={30,60,30},line={10,30,10},life=15}

function Tree:draw(a)
    if self.z < WATERLEVEL then
        --silly tree, trees don't swim
        --fade as waterlevel increases
        a = (a or 255) * math.max(0, 1 - (WATERLEVEL - self.z) / 10 )
    end
    if a then
        self.col[4] = a
        self.line[4] = a
    else
        self.col[4] = 255
        self.line[4] = 255
    end
    if self.life <= 0 then
        love.graphics.setColor(self.col)
        Ocylinder("fill",self.p,self.z,self.r,self.h)
        if OUTLINES then
            love.graphics.setColor(self.line)
            Ocylinder("line",self.p,self.z,self.r,self.h)    
        end
    else
        love.graphics.setColor(self.col)
        Ocone("fill",self.p,self.z,self.r,self.h)
        if OUTLINES then
            love.graphics.setColor(self.line)
            Ocone("line",self.p,self.z,self.r,self.h)    
        end
    end
end

function Prism:draw(a)
    --love.graphics.setColor(self.line)
    --Oprismback("line",self.p,self.z,self.v1,self.v2,self.h)
    --love.graphics.setColor(self.col)
    --Oprismtop("fill",self.p,self.z,self.v1,self.v2,self.h)
    love.graphics.setColor(self.col)
    Oprismfront("fill",self.p,self.z,self.v1,self.v2,self.h)
    local newcol = map(function(x) return x-2*(self.z+self.h) end, self.coltop)
    newcol[4] = 255
    love.graphics.setColor(newcol)--self.coltop)
    Oprismtop("fill",self.p,self.z,self.v1,self.v2,self.h)
    love.graphics.setColor(self.line)
    Oprism("line",self.p,self.z,self.v1,self.v2,self.h)
end

function Player(p,z)
    return Unit:new({p=p,z=z,col={56,56,64}})
--    return Unit:new({p=p,z=z,col={183,196,183,255}})
end
function Other(p,z)
    return Unit:new({p=p,z=z})
end
sorted = false

function drawbefore(a,b)
    --0 is =, -1 is <, 1 is >
    --aka <=>
    local ax1,ax2
    local ay1,ay2
    local bx1,bx2
    local by1,by2
    local result = 0
    local a1,a2 = bounds(a)
    local b1,b2 = bounds(b)
            
    --these are either in front of each other, or on top of each other
    local dx,dy = 0,0
    if a1[1] >= b2[1] then
        dx = 1
    elseif a2[1] <= b1[1] then
        dx = -1
    end
    if a1[2] >= b2[2] then
        dy = -1
    elseif a2[2] <= b1[2] then
        dy = 1
    end
    if not sorted then
        --print ("a min max b min max result")
        --print ("x", ax1,ax2,bx1,bx2,dx)
        --print ("y", ay1,ay2,by1,by2,dy)
    end
    if dx == dy and dx ~= 0 then
        --a is either above or below on both axis
        result = dx
    elseif dx ~= 0 and dy ~= 0 then
        --above on one axis, below on the other
        result = 0--dx
    elseif (dx == 0 or dy == 0) and dx ~= dy then
        --only above or below on one axis
        result = dx+dy
    --else dx and dy both 0
    elseif a.z < b.z then
        result  = -1
    elseif a.z > b.z then
        result  = 1
    else
        --overlapping and same z
        result = 0
    end
    if not sorted then
        --print(dx,dy,result)
    end
    
    return result
    --return result == -1
end

function tableswap(t,i,j)
    local x = t[i]
    t[i] = t[j]
    t[j] = x
end

function verticalsort(objects)
    --built in sort assumes a definite a < b, b = c, c < d implies a < d, but it is complicated.
    --I want a "doesn't matter" but not a "is the same"
    --so I will write my own sort
    --table.sort(objects,drawbefore)

    --only need to check all but last i items after i iterations?
    local done = false
    local firstnode = 1
    local count = 0
    while not done do
        count = count + 1
        local a = objects[firstnode]
        local changed = false
        for i = firstnode + 1,#objects do
            if not changed then
                local b = objects[i]
                local diff = drawbefore(a,b)
                --print(diff)
                if diff == 1 then
                    changed = true
                    tableswap(objects,firstnode,i)
                end
            end
        end
        if (not changed) or (count > #objects-firstnode) then --infinite loop fix - just skip it
            firstnode = firstnode + 1
            count = 0
        end
        
        --[[
        local changed = false
        for i = 1,#objects-1 do
            local a,b = objects[i],objects[i+1]
            local diff = drawbefore(a,b)
            if diff == -1 then
                --oK!
            elseif diff == 1 then
                --swap
                changed = true
                tableswap(objects,i,i+1)
            else
                -- order doesn't matter, dunno what to do with these
                --afraid of infinite loop If I use this
            end
        end
        done = not changed
        ]]
        done = firstnode == #objects
    end
    --local result = mergesort(makepairs(objects))
    sorted = true
    --return result
end

function center(o)
    if o.t == PRISM then
        return Vadd(Vadd(o.p,Vmult(0.5,o.v1)) , Vmult(0.5,o.v2))  ,o.z+o.h/2
    elseif o.t == UNIT then
        return o.p,o.z+o.h/2
    end
end

--return p1,p2 with p1 being minx miny and p2 maxx maxy
function bounds(o)
    local x1,x2,y1,y2
    if o.t == PRISM then
        x1,x2 = math.min(o.p[1],o.p[1]+o.v1[1],o.p[1]+o.v2[1]),math.max(o.p[1],o.p[1]+o.v1[1],o.p[1]+o.v2[1])
        y1,y2 = math.min(o.p[2],o.p[2]+o.v1[2],o.p[2]+o.v2[2]),math.max(o.p[2],o.p[2]+o.v1[2],o.p[2]+o.v2[2])
    elseif o.t == UNIT or o.t == TREE or o.t == PARTICLE then
        x1,x2 = o.p[1] - o.r, o.p[1] + o.r
        y1,y2 = o.p[2] - o.r, o.p[2] + o.r
    elseif o.t == SHADOWTILE then
        x1,x2 = o.tile.p[1], o.tile.p[1] -- -TILESIZE/2 ?
        y1,y2 = o.tile.p[2], o.tile.p[2]
    end
    return P(x1,y1),P(x2,y2)
end
