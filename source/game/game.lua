require("almost/ortho")
require("almost/entity")
require("game/unit")
require("almost/particles")

Game = State:new()
Canvas = Layer:new()
Game:addlayer(Canvas)

SMALL = 0
MEDIUM = 1
LARGE = 2

WINDOW_SIZES = {
    [SMALL] = {
        w=800,
        h=600,
        size=SMALL
        },
    [MEDIUM]={
        w = 900,
        h = 700,
        size=MEDIUM
        },
    [LARGE]={
        w = 1024,
        h = 768,
        size=LARGE
    }
}

camera = P(0,0)

SIZE = nil
function setSize(size)
    local s = WINDOW_SIZES[size]
    SIZE = s.size
    if s.w ~= width or s.h ~= height then
        love.window.setMode(s.w,s.h)
        width = s.w
        height = s.h
        gameUI()
    end
end

function gameUI()
    local ui = BoxRel(width,height)
    local b = BoxV(150,height-40,false)
    b.alignV = ALIGNV.BOTTOM
    ui:add(b,REL.E)
    
    local b2
    b2 = BoxV(120,30)
    b2.label = "Toggle Lines"
    b2.onclick = function() OUTLINES = not OUTLINES end
    b:add(b2)
    if SIZE ~= SMALL then
        b2 = BoxV(120,30)
        b2.label = "Small"
        b2.onclick = function() setSize(SMALL) end
        b:add(b2)
    end
    if SIZE ~= MEDIUM then
        b2 = BoxV(120,30)
        b2.label = "Medium"
        b2.onclick = function() setSize(MEDIUM) end
        b:add(b2)
    end
    if SIZE ~= LARGE then
        b2 = BoxV(120,30)
        b2.label = "Large"
        b2.onclick = function() setSize(LARGE) end
        b:add(b2)
    end
    
    if UI then
        UI.ui = ui
    else
        UI = UILayer(ui)
        Game:addlayer(UI)
    end
end

entities = {}
function Game:load()
    
    KEYS = {JUMP=" ",DASH="x",LEFT="a",RIGHT="d",UP="w",DOWN="s",ATTACK="c"}
    DIRS = {UP=P(-sqrt2/2,sqrt2/2), LEFT=P(-sqrt2/2,-sqrt2/2), RIGHT=P(sqrt2/2,sqrt2/2), DOWN=P(sqrt2/2,-sqrt2/2)}

    --check if the player knows his controls
    moved = {}
    for k,v in pairs(DIRS) do
        moved[k] = false
    end
    jumped = false
    clicked = false

    setSize(SMALL)
    OUTLINES = true
    gameUI()
    
    --player = Player(P(0,0),50)
    
    frame = 0
    
    Game:update(1/30) --force an update before any draw function is possible.
    
    
    for n = 0, 1 do
        o = Unit:new{p=P(80 * n, 0)}
        table.insert(entities, o)
    end
    entities[1].enemy = entities[2]
    entities[1].strategy = {mind=100, maxd=150}
    -- entities[2].enemy = entities[1]
    -- entities[2].strategy = {mind=100, maxd=150}
end


function Canvas:draw()
    local drawable = {}-- walls--
    --drawable = join(join(drawable,{player}),others)
    drawable = join(drawable,entities)
    drawable = join(drawable,particles)

    
    love.graphics.push()
    local p = ortho(camera, 0)
    love.graphics.translate(width/2-p[1],height/2-p[2])

    if OUTLINES then
        grid()
        Ovectors()
    end
    
    for i, o in ipairs(drawable) do
        o:draw()
    end
    
    love.graphics.pop()

    --[[
    local c = 0
    for k,v in pairs(moved) do
        if v then c = c + 1 end
    end
    if c < 2 then
        notify("W A S D to move",y)
        y = y + h
    end
    if not jumped then
        notify("Space to jump",y)
        y = y + h
    end
    if not clicked then
        notify("Click on stuff",y)
        y = y + h
    end
    ]]
end

function Game:update(dt)
	dt = math.min(dt,1/30)
    frame = frame + 1
    mx,my = love.mouse.getPosition()
    mouse = P(mx,my)
    
    --local p = ortho(player.p,player.z)
    omouse = cartesian(Vadd(Vsub(mouse,P(width/2,height/2)),camera),0)
    
    
    -- for i, o in ipairs(entities) do
        -- o:update(dt)
    -- end
    for i = #entities,1,-1 do
        local o = entities[i]
        o:update(dt)
        if o.destroyed then
            table.remove(entities, i)
        end
    end
    
    updateparticles(dt)
    
    if love.mouse.isDown("l") then
        burn(omouse, 0, 16)
    end
    if love.mouse.isDown("r") then
        blood(omouse, 0)
    end

    --player.v = P(0,0)
    for k,dir in pairs(DIRS) do
        if love.keyboard.isDown(KEYS[k]) then
            moved[k] = true
        end
    end
end


function Game:mousepress(x,y, button)
    if button == "r" then
    elseif  button == "l" then
    end
end

function Game:mouserelease(x,y, button)
end

function Game:keypress(key, isrepeat)
    if key == KEYS.JUMP and not isrepeat then
    end
end

function Game:keyrelease(key)

end

function grid()
    love.graphics.setColor(0,0,0,100)
    love.graphics.setLineWidth(1)
    local w,h = 10,10
    for x=-w*unit,w*unit,unit do
        Oline(P(x,-h*unit),0,P(x,h*unit))
    end
    for y=-h*unit,h*unit,unit do
        Oline(P(-w*unit,y),0,P(w*unit,y))
    end
end

function notify(msg,y)
    local w,h = 200,24
    local x = width - w - 15
    love.graphics.setColor(255,255,255,128)
    love.graphics.rectangle("fill",x,y,w,h)
    love.graphics.setColor(0,0,0,196)
    love.graphics.rectangle("line",x,y,w,h)
    love.graphics.printf(msg,x,y+5,w,"center")
end
