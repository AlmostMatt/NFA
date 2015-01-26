Editor = State:new()

function editorUI()
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
    
    if EditorUI then
        EditorUI.ui = ui
    else
        EditorUI = UILayer(ui)
        Editor:addlayer(EditorUI)
    end
end

function Editor:load()
    editorUI()
end

function Editor:update(dt)
end

function Editor:mousepress(x,y, button)
    if button == "r" then
    elseif  button == "l" then
    end
end

function Editor:mouserelease(x,y, button)
end

function Editor:keypress(key, isrepeat)
    if key == "z" then
    end
end

function Editor:keyrelease(key)

end