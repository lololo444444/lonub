--=============================================================
--  MyUI v3
--  Изменения: квадратная кнопка по центру, шляпа (size/pos/color),
--  ESP (skeleton/tracer/nick/hp/color), автофарм по клику на парт
--=============================================================

local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local Lighting     = game:GetService("Lighting")
local Workspace    = game:GetService("Workspace")

local plr = Players.LocalPlayer
local playerGui = plr:WaitForChild("PlayerGui")
local camera = Workspace.CurrentCamera

--=============================================================
--  ИКОНКА
--=============================================================
local ICON_URL      = "https://raw.githubusercontent.com/lololo444444/lonub/main/icon.png"
local ICON_FALLBACK = "rbxassetid://0" -- залей свою и вставь ID

local function loadIcon()
    if writefile and getcustomasset and game.HttpGet then
        local path = "MyUI_icon.png"
        local exists = (isfile and isfile(path)) or false
        if not exists then
            local ok, data = pcall(function() return game:HttpGet(ICON_URL) end)
            if ok and data and #data > 0 then pcall(writefile, path, data) end
        end
        local ok2, asset = pcall(getcustomasset, path)
        if ok2 and asset then return asset end
    end
    return ICON_FALLBACK
end
local ICON_ID = loadIcon()

--=============================================================
--  УТИЛИТЫ
--=============================================================
local function new(class, props, parent)
    local o = Instance.new(class)
    for k,v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end
local function corner(p, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = p; return c
end
local function stroke(p, color, tr)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(110,110,110); s.Transparency = tr or 0.5
    s.Thickness = 1; s.Parent = p; return s
end

--=============================================================
--  GUI КАРКАС
--=============================================================
local gui = new("ScreenGui", {
    Name = "MyUI", ResetOnSpawn = false, IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

-- КВАДРАТНАЯ кнопка по центру экрана
local toggle = new("ImageButton", {
    Name = "Toggle",
    Size = UDim2.fromOffset(48,48),
    Position = UDim2.new(0.5,-24,0.5,-24),  -- ровно центр
    AnchorPoint = Vector2.new(0,0),
    BackgroundColor3 = Color3.fromRGB(50,50,50),
    BackgroundTransparency = 0.2,
    Image = ICON_ID or "",
    AutoButtonColor = false, ClipsDescendants = true,
}, gui)
corner(toggle, 8)   -- ← квадрат со скруглением 8, а не круг
stroke(toggle)

if not ICON_ID or ICON_ID == "rbxassetid://0" then
    new("TextLabel", {
        Size = UDim2.fromScale(1,1), BackgroundTransparency = 1,
        Text = "UI", TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.GothamBold, TextSize = 18,
    }, toggle)
end

-- перетаскивание
local dragBtn = {active=false, start=nil, startPos=nil}
toggle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragBtn.active = true; dragBtn.start = input.Position; dragBtn.startPos = toggle.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragBtn.active and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragBtn.start
        toggle.Position = UDim2.new(dragBtn.startPos.X.Scale, dragBtn.startPos.X.Offset+d.X, dragBtn.startPos.Y.Scale, dragBtn.startPos.Y.Offset+d.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragBtn.active = false
    end
end)

-- Основное окно
local frame = new("Frame", {
    Name = "Main", Size = UDim2.fromOffset(620,420),
    Position = UDim2.new(0.5,-310,0.5,-210),
    BackgroundColor3 = Color3.fromRGB(30,30,30),
    BackgroundTransparency = 0.15, Visible = false,
}, gui)
corner(frame, 10); stroke(frame, Color3.fromRGB(120,120,120), 0.4)

local topBar = new("Frame", {
    Size = UDim2.new(1,0,0,34),
    BackgroundColor3 = Color3.fromRGB(40,40,40),
    BackgroundTransparency = 0.3, BorderSizePixel = 0,
}, frame)
corner(topBar, 10)
new("Frame", {Size = UDim2.new(1,0,0,10), Position = UDim2.new(0,0,1,-10),
    BackgroundColor3 = Color3.fromRGB(40,40,40), BackgroundTransparency = 0.3, BorderSizePixel = 0}, topBar)
new("TextLabel", {Size = UDim2.new(1,-70,1,0), Position = UDim2.new(0,12,0,0),
    BackgroundTransparency = 1, Text = "MyUI v3", TextColor3 = Color3.fromRGB(220,220,220),
    Font = Enum.Font.GothamMedium, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left}, topBar)
local closeBtn = new("TextButton", {
    Size = UDim2.fromOffset(24,24), Position = UDim2.new(1,-30,0.5,-12),
    BackgroundColor3 = Color3.fromRGB(70,40,40), Text = "×",
    TextColor3 = Color3.fromRGB(255,200,200), Font = Enum.Font.GothamBold, TextSize = 16, AutoButtonColor = false,
}, topBar)
corner(closeBtn, 6)
closeBtn.MouseButton1Click:Connect(function() frame.Visible = false end)

local dragWin = {active=false, start=nil, startPos=nil}
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragWin.active = true; dragWin.start = input.Position; dragWin.startPos = frame.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragWin.active and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragWin.start
        frame.Position = UDim2.new(dragWin.startPos.X.Scale, dragWin.startPos.X.Offset+d.X, dragWin.startPos.Y.Scale, dragWin.startPos.Y.Offset+d.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragWin.active = false end
end)

local tabBar = new("Frame", {Size = UDim2.new(0,140,1,-44), Position = UDim2.new(0,8,0,40),
    BackgroundColor3 = Color3.fromRGB(25,25,25), BackgroundTransparency = 0.3}, frame)
corner(tabBar, 8)
new("UIListLayout", {Padding = UDim.new(0,6), SortOrder = Enum.SortOrder.LayoutOrder,
    HorizontalAlignment = Enum.HorizontalAlignment.Center}, tabBar)
new("UIPadding", {PaddingTop = UDim.new(0,8)}, tabBar)

local content = new("Frame", {Size = UDim2.new(1,-160,1,-52), Position = UDim2.new(0,156,0,40),
    BackgroundColor3 = Color3.fromRGB(28,28,28), BackgroundTransparency = 0.35}, frame)
corner(content, 8)

--=============================================================
--  UI ХЕЛПЕРЫ
--=============================================================
local function makeTabButton(text, order)
    local b = new("TextButton", {
        Size = UDim2.new(1,-12,0,28), BackgroundColor3 = Color3.fromRGB(45,45,45),
        BackgroundTransparency = 0.2, Text = text, TextColor3 = Color3.fromRGB(210,210,210),
        Font = Enum.Font.GothamMedium, TextSize = 13, AutoButtonColor = false, LayoutOrder = order or 0,
    }, tabBar)
    corner(b, 6); return b
end
local function makeToggle(parent, text, order, callback)
    local row = new("Frame", {Size = UDim2.new(1,-16,0,28), BackgroundTransparency = 1, LayoutOrder = order or 0}, parent)
    new("TextLabel", {Size = UDim2.new(1,-50,1,0), BackgroundTransparency = 1, Text = text,
        TextColor3 = Color3.fromRGB(210,210,210), Font = Enum.Font.Gotham, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left}, row)
    local track = new("Frame", {Size = UDim2.fromOffset(36,20), Position = UDim2.new(1,-36,0.5,-10),
        BackgroundColor3 = Color3.fromRGB(60,60,60), BackgroundTransparency = 0.2}, row)
    corner(track, 10)
    local knob = new("Frame", {Size = UDim2.fromOffset(16,16), Position = UDim2.new(0,2,0.5,-8),
        BackgroundColor3 = Color3.fromRGB(200,200,200)}, track)
    corner(knob, 8)
    local state = false
    local btn = new("TextButton", {Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, Text = ""}, track)
    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(track, TweenInfo.new(0.15), {BackgroundColor3 = state and Color3.fromRGB(90,140,90) or Color3.fromRGB(60,60,60)}):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {Position = state and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)}):Play()
        if callback then callback(state) end
    end)
    return row, function() return state end
end
local function makeInput(parent, text, order, placeholder, callback)
    local row = new("Frame", {Size = UDim2.new(1,-16,0,28), BackgroundTransparency = 1, LayoutOrder = order or 0}, parent)
    new("TextLabel", {Size = UDim2.new(0.5,0,1,0), BackgroundTransparency = 1, Text = text,
        TextColor3 = Color3.fromRGB(210,210,210), Font = Enum.Font.Gotham, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left}, row)
    local box = new("TextBox", {Size = UDim2.new(0.5,0,1,0), Position = UDim2.new(0.5,0,0,0),
        BackgroundColor3 = Color3.fromRGB(45,45,45), BackgroundTransparency = 0.2, Text = "",
        PlaceholderText = placeholder or "", PlaceholderColor3 = Color3.fromRGB(140,140,140),
        TextColor3 = Color3.fromRGB(220,220,220), Font = Enum.Font.Gotham, TextSize = 13, ClearTextOnFocus = false}, row)
    corner(box, 6); stroke(box, Color3.fromRGB(100,100,100), 0.6)
    box.FocusLost:Connect(function() if callback then callback(box.Text) end end)
    return row
end
local function makeSection(parent, text, order)
    return new("TextLabel", {Size = UDim2.new(1,-16,0,22), BackgroundTransparency = 1, Text = text,
        TextColor3 = Color3.fromRGB(160,160,160), Font = Enum.Font.GothamBold, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = order or 0}, parent)
end
-- RGB-слайдер
local function makeColorSlider(parent, label, order, init, cb)
    local row = new("Frame", {Size = UDim2.new(1,-16,0,24), BackgroundTransparency = 1, LayoutOrder = order}, parent)
    new("TextLabel", {Size = UDim2.new(0,26,1,0), BackgroundTransparency = 1, Text = label,
        TextColor3 = Color3.fromRGB(200,200,200), Font = Enum.Font.Gotham, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left}, row)
    local track = new("Frame", {Size = UDim2.new(1,-36,0,6), Position = UDim2.new(0,32,0.5,-3),
        BackgroundColor3 = Color3.fromRGB(60,60,60)}, row)
    corner(track, 3)
    local fill = new("Frame", {Size = UDim2.fromScale(init/255,1), BackgroundColor3 = Color3.fromRGB(180,180,180)}, track)
    corner(fill, 3)
    local grab = new("TextButton", {Size = UDim2.fromOffset(12,18), Position = UDim2.new(init/255,-6,0.5,-9),
        BackgroundColor3 = Color3.fromRGB(220,220,220), Text = "", AutoButtonColor = false}, track)
    corner(grab, 4)
    local dragging = false
    grab.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UIS.InputChanged:Connect(function(i)
        if not dragging then return end
        local v = math.clamp((i.Position.X - track.AbsolutePosition.X)/track.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.fromScale(v,1); grab.Position = UDim2.new(v,-6,0.5,-9)
        cb(math.floor(v*255))
    end)
end

--=============================================================
--  ВКЛАДКИ
--=============================================================
local tabs, currentTab = {}, nil
local function switchTab(name)
    for n, t in pairs(tabs) do
        t.page.Visible = (n == name)
        t.button.BackgroundColor3 = (n == name) and Color3.fromRGB(80,80,80) or Color3.fromRGB(45,45,45)
    end
    currentTab = name
end
local function addTab(name, title, order)
    local page = new("ScrollingFrame", {
        Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 4, CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false,
    }, content)
    new("UIListLayout", {Padding = UDim.new(0,6), SortOrder = Enum.SortOrder.LayoutOrder}, page)
    new("UIPadding", {PaddingTop = UDim.new(0,8), PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8)}, page)
    local btn = makeTabButton(title, order)
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
    tabs[name] = {page = page, button = btn}
    return page
end

--=============================================================
--  USER
--=============================================================
local userPage = addTab("user", "user", 1)
do
    local function getHum()
        local c = plr.Character or plr.CharacterAdded:Wait()
        return c:FindFirstChildOfClass("Humanoid")
    end
    makeSection(userPage, "Внешность (локально)", 1)
    makeToggle(userPage, "Фейк Headless", 2, function(on)
        local c = plr.Character; if not c then return end
        local head = c:FindFirstChild("Head"); if not head then return end
        head.Transparency = on and 1 or 0
        head.LocalTransparencyModifier = on and 1 or 0
        for _, v in ipairs(head:GetChildren()) do
            if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = on and 1 or 0 end
        end
    end)
    makeToggle(userPage, "Фейк Korblox", 3, function(on)
        local c = plr.Character; if not c then return end
        local leg = c:FindFirstChild("RightUpperLeg") or c:FindFirstChild("Right Leg"); if not leg then return end
        if on then
            local m = Instance.new("SpecialMesh")
            m.MeshType = Enum.MeshType.FileMesh; m.MeshId = "rbxassetid://125447041"
            m.Scale = Vector3.new(1,1,1); m.Name = "FakeKorblox"; m.Parent = leg
        else
            local m = leg:FindFirstChild("FakeKorblox"); if m then m:Destroy() end
        end
    end)
    makeSection(userPage, "Движение", 10)
    makeInput(userPage, "Скорость", 11, "16", function(v)
        local h = getHum(); if h and tonumber(v) then h.WalkSpeed = tonumber(v) end
    end)
    makeInput(userPage, "Прыжок", 12, "50", function(v)
        local h = getHum(); if h and tonumber(v) then h.JumpPower = tonumber(v) end
    end)
    local spinning = false
    makeToggle(userPage, "Спин по Y", 13, function(on) spinning = on end)
    RunService.RenderStepped:Connect(function(dt)
        if not spinning then return end
        local c = plr.Character; if not c or not c.PrimaryPart then return end
        c:PivotTo(c:GetPivot() * CFrame.Angles(0, math.rad(180)*dt, 0))
    end)
    local backWalk = false
    makeToggle(userPage, "Идти спиной (Shift Lock)", 14, function(on) backWalk = on end)
    RunService.RenderStepped:Connect(function()
        if not backWalk then return end
        local c = plr.Character; if not c then return end
        local hum = c:FindFirstChildOfClass("Humanoid"); if not hum or not c.PrimaryPart then return end
        local mv = hum.MoveDirection
        if mv.Magnitude < 0.1 then return end
        local target = c.PrimaryPart.Position - mv
        local look = CFrame.lookAt(c.PrimaryPart.Position, target)
        local cur = c:GetPivot()
        c:PivotTo(CFrame.new(cur.Position) * (look - look.Position))
    end)
end

--=============================================================
--  VISUAL — включая полноценную шляпу
--=============================================================
local visualPage = addTab("visual", "visual", 2)
do
    local function resetLighting()
        Lighting.Brightness = 2; Lighting.FogEnd = 100000; Lighting.FogStart = 0
        Lighting.FogColor = Color3.fromRGB(192,192,192); Lighting.ClockTime = 14
    end
    local function clearWeather()
        local o = workspace:FindFirstChild("WeatherRain"); if o then o:Destroy() end
    end
    local function setRain(on)
        clearWeather()
        if not on then resetLighting(); return end
        Lighting.FogEnd = 400; Lighting.FogColor = Color3.fromRGB(90,90,100); Lighting.Brightness = 1
        local rain = Instance.new("Part")
        rain.Name = "WeatherRain"; rain.Size = Vector3.new(2000,1,2000); rain.Transparency = 1
        rain.CanCollide = false; rain.Anchored = true; rain.Parent = workspace
        local em = Instance.new("ParticleEmitter")
        em.Texture = "rbxassetid://241876428"; em.Rate = 1000; em.Lifetime = NumberRange.new(0.6,1)
        em.Speed = NumberRange.new(80,120); em.SpreadAngle = Vector2.new(5,5)
        em.Size = NumberSequence.new(0.6); em.Transparency = NumberSequence.new(0.4); em.Parent = rain
        local conn; conn = RunService.Heartbeat:Connect(function()
            if not rain.Parent then conn:Disconnect(); return end
            local c = plr.Character
            if c and c.PrimaryPart then rain.CFrame = CFrame.new(c.PrimaryPart.Position + Vector3.new(0,60,0)) end
        end)
    end
    makeSection(visualPage, "Погода", 1)
    makeToggle(visualPage, "Дождь", 2, setRain)
    local lightningOn = false
    makeToggle(visualPage, "Гроза (молнии)", 3, function(on) lightningOn = on end)
    task.spawn(function()
        while true do
            task.wait(math.random(4,10))
            if lightningOn then
                local old = Lighting.Brightness
                Lighting.Brightness = 6; task.wait(0.05)
                Lighting.Brightness = 1; task.wait(0.05)
                Lighting.Brightness = old
            end
        end
    end)
    makeToggle(visualPage, "Солнечно", 4, function(on)
        if on then resetLighting(); Lighting.Brightness = 4; Lighting.ClockTime = 12 end
    end)
    makeToggle(visualPage, "Метель (туман 50 studs)", 5, function(on)
        clearWeather()
        if not on then resetLighting(); return end
        Lighting.FogEnd = 50; Lighting.FogStart = 0
        Lighting.FogColor = Color3.fromRGB(220,220,230); Lighting.Brightness = 1.5
    end)

    makeSection(visualPage, "Скайбокс (6 вариантов)", 10)
    local skyRow = new("Frame", {Size = UDim2.new(1,-16,0,30), BackgroundTransparency = 1, LayoutOrder = 11}, visualPage)
    new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0,4),
        SortOrder = Enum.SortOrder.LayoutOrder}, skyRow)
    local skyboxes = {"159454299","159454296","159454293","159454286","159454301","159454320"}
    for i, id in ipairs(skyboxes) do
        local b = new("TextButton", {
            Size = UDim2.fromOffset(30,26), BackgroundColor3 = Color3.fromRGB(50,50,50),
            Text = tostring(i), TextColor3 = Color3.fromRGB(220,220,220),
            Font = Enum.Font.GothamBold, TextSize = 12, LayoutOrder = i,
        }, skyRow)
        corner(b, 6)
        b.MouseButton1Click:Connect(function()
            local sky = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", Lighting)
            sky.SkyboxBk = "rbxassetid://"..id
            sky.SkyboxDn = sky.SkyboxBk; sky.SkyboxFt = sky.SkyboxBk
            sky.SkyboxLf = sky.SkyboxBk; sky.SkyboxRt = sky.SkyboxBk; sky.SkyboxUp = sky.SkyboxBk
        end)
    end

    --=========================================================
    --  КИТАЙСКАЯ ШЛЯПА — с size / offset / color
    --=========================================================
    makeSection(visualPage, "Китайская шляпа", 20)
    local hatEnabled = false
    local hatState = {size = 3, offset = 1, color = Color3.fromRGB(180,50,50)}

    local function updateHat()
        local c = plr.Character; if not c then return end
        local head = c:FindFirstChild("Head"); if not head then return end
        local hat = head:FindFirstChild("ChinaHat")
        if not hatEnabled then if hat then hat:Destroy() end; return end
        if not hat then
            hat = Instance.new("Part")
            hat.Name = "ChinaHat"; hat.Material = Enum.Material.SmoothPlastic
            hat.CanCollide = false; hat.Massless = true; hat.Anchored = false
            hat.Parent = c
            local w = Instance.new("WeldConstraint")
            w.Part0 = head; w.Part1 = hat; w.Parent = hat
        end
        hat.Size = Vector3.new(hatState.size, 0.3, hatState.size)
        hat.Color = hatState.color
        hat.CFrame = head.CFrame * CFrame.new(0, hatState.offset, 0)
    end
    makeToggle(visualPage, "Включить шляпу", 21, function(on) hatEnabled = on; updateHat() end)

    -- Size (слайдер-инпут)
    makeInput(visualPage, "Размер", 22, "3", function(v)
        if tonumber(v) then hatState.size = tonumber(v); updateHat() end
    end)
    makeInput(visualPage, "Смещение вверх", 23, "1", function(v)
        if tonumber(v) then hatState.offset = tonumber(v); updateHat() end
    end)
    makeColorSlider(visualPage, "R", 24, 180, function(v) hatState.color = Color3.fromRGB(v, hatState.color.G*255, hatState.color.B*255); updateHat() end)
    makeColorSlider(visualPage, "G", 25, 50,  function(v) hatState.color = Color3.fromRGB(hatState.color.R*255, v, hatState.color.B*255); updateHat() end)
    makeColorSlider(visualPage, "B", 26, 50,  function(v) hatState.color = Color3.fromRGB(hatState.color.R*255, hatState.color.G*255, v); updateHat() end)

    -- обновляем позицию шляпы каждый кадр, чтобы не отставала
    RunService.RenderStepped:Connect(function()
        if not hatEnabled then return end
        local c = plr.Character; if not c then return end
        local head = c:FindFirstChild("Head"); local hat = c:FindFirstChild("ChinaHat")
        if head and hat then hat.CFrame = head.CFrame * CFrame.new(0, hatState.offset, 0) end
    end)
end

--=============================================================
--  ESP — skeleton + tracer + nick + hp + color
--=============================================================
local espPage = addTab("esp", "esp", 3)
do
    local highlights, nickGuis, hpGuis, tracers, skeletons = {}, {}, {}, {}, {}
    local espEnabled = false
    local showTracer, showSkeleton, showNick, showHP = false, false, false, false
    local espColor = Color3.fromRGB(0,200,255)

    local function makeDrawing(class, props)
        if not Drawing then return nil end
        local ok, d = pcall(function() return Drawing.new(class) end)
        if not ok then return nil end
        for k,v in pairs(props or {}) do d[k] = v end
        return d
    end

    local function getChar(p)
        local c = p.Character
        if c and c:FindFirstChild("HumanoidRootPart") then return c end
    end

    local function clearAll()
        for p, h in pairs(highlights) do if h then h:Destroy() end end
        for p, g in pairs(nickGuis) do if g then g:Destroy() end end
        for p, g in pairs(hpGuis) do if g then g:Destroy() end end
        for p, list in pairs(tracers) do
            for _, d in ipairs(list) do if d and d.Remove then d:Remove() end end
        end
        for p, list in pairs(skeletons) do
            for _, d in ipairs(list) do if d and d.Remove then d:Remove() end end
        end
        highlights, nickGuis, hpGuis, tracers, skeletons = {}, {}, {}, {}, {}
    end

    local function buildFor(p)
        local char = getChar(p); if not char then return end
        if highlights[p] then highlights[p].Adornee = char else
            local h = Instance.new("Highlight")
            h.FillColor = espColor
            h.OutlineColor = Color3.fromRGB(255,255,255)
            h.FillTransparency = 0.5; h.OutlineTransparency = 0
            h.Adornee = char; h.Parent = char
            highlights[p] = h
        end
        local head = char:FindFirstChild("Head")
        if head then
            if showNick and not nickGuis[p] then
                local bb = Instance.new("BillboardGui", head)
                bb.Size = UDim2.fromOffset(120,20); bb.StudsOffset = Vector3.new(0,2.5,0); bb.AlwaysOnTop = true
                local t = Instance.new("TextLabel", bb)
                t.Size = UDim2.fromScale(1,1); t.BackgroundTransparency = 1
                t.Text = p.Name; t.TextColor3 = Color3.new(1,1,1)
                t.TextStrokeTransparency = 0.3; t.Font = Enum.Font.GothamBold; t.TextSize = 12
                nickGuis[p] = bb
            elseif not showNick and nickGuis[p] then
                nickGuis[p]:Destroy(); nickGuis[p] = nil
            end
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if head and hum and showHP and not hpGuis[p] then
            local bb = Instance.new("BillboardGui", head)
            bb.Size = UDim2.fromOffset(60,6); bb.StudsOffset = Vector3.new(0,1.8,0); bb.AlwaysOnTop = true
            local bg = Instance.new("Frame", bb)
            bg.Size = UDim2.fromScale(1,1); bg.BackgroundColor3 = Color3.fromRGB(40,40,40); bg.BorderSizePixel = 0
            Instance.new("UICorner", bg).CornerRadius = UDim.new(1,0)
            local fill = Instance.new("Frame", bg)
            fill.Size = UDim2.fromScale(hum.Health/hum.MaxHealth,1)
            fill.BackgroundColor3 = Color3.fromRGB(90,220,90); fill.BorderSizePixel = 0
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)
            hum.HealthChanged:Connect(function(h)
                fill.Size = UDim2.fromScale(math.clamp(h/hum.MaxHealth,0,1),1)
            end)
            hpGuis[p] = bb
        elseif not showHP and hpGuis[p] then
            hpGuis[p]:Destroy(); hpGuis[p] = nil
        end
    end

    -- периодическое обновление Drawing-элементов (трейсер, скелет)
    RunService.RenderStepped:Connect(function()
        if not espEnabled then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p == plr then continue end
            local char = getChar(p); if not char then continue end
            local hrp = char.HumanoidRootPart
            local screen, onScreen = camera:WorldToViewportPoint(hrp.Position)
            -- tracer
            if showTracer then
                local line = tracers[p]
                if not line then
                    local t = {}
                    t[1] = makeDrawing("Line", {Thickness = 1.5, Color = espColor, Transparency = 1})
                    if t[1] then tracers[p] = t end
                else
                    if onScreen then
                        line[1].From = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
                        line[1].To = Vector2.new(screen.X, screen.Y)
                        line[1].Color = espColor
                        line[1].Visible = true
                    else
                        line[1].Visible = false
                    end
                end
            elseif tracers[p] then
                for _, d in ipairs(tracers[p]) do if d.Remove then d:Remove() end end
                tracers[p] = nil
            end
            -- skeleton
            local connections = {
                {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
                {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
                {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
                {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
                {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
            }
            if showSkeleton then
                if not skeletons[p] then
                    local list = {}
                    for i = 1, #connections do
                        list[i] = makeDrawing("Line", {Thickness = 1, Color = espColor, Transparency = 1})
                    end
                    skeletons[p] = list
                end
                for i, pair in ipairs(connections) do
                    local a = char:FindFirstChild(pair[1]); local b = char:FindFirstChild(pair[2])
                    local line = skeletons[p][i]
                    if a and b and line then
                        local aS, aOn = camera:WorldToViewportPoint(a.Position)
                        local bS, bOn = camera:WorldToViewportPoint(b.Position)
                        if aOn and bOn then
                            line.From = Vector2.new(aS.X, aS.Y)
                            line.To = Vector2.new(bS.X, bS.Y)
                            line.Color = espColor
                            line.Visible = true
                        else
                            line.Visible = false
                        end
                    end
                end
            elseif skeletons[p] then
                for _, d in ipairs(skeletons[p]) do if d.Remove then d:Remove() end end
                skeletons[p] = nil
            end
        end
    end)

    makeToggle(espPage, "ESP (Highlight)", 1, function(on) espEnabled = on; if on then for _,p in ipairs(Players:GetPlayers()) do if p ~= plr then buildFor(p) end end else clearAll() end end)
    makeToggle(espPage, "Трейсер", 2, function(on) showTracer = on end)
    makeToggle(espPage, "Скелет", 3, function(on) showSkeleton = on end)
    makeToggle(espPage, "Ник", 4, function(on) showNick = on; for _,p in ipairs(Players:GetPlayers()) do if p ~= plr then buildFor(p) end end end)
    makeToggle(espPage, "HP-бар", 5, function(on) showHP = on; for _,p in ipairs(Players:GetPlayers()) do if p ~= plr then buildFor(p) end end end)

    makeSection(espPage, "Цвет ESP", 10)
    local presetRow = new("Frame", {Size = UDim2.new(1,-16,0,28), BackgroundTransparency = 1, LayoutOrder = 11}, espPage)
    new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0,4),
        SortOrder = Enum.SortOrder.LayoutOrder}, presetRow)
    local presets = {
        Color3.fromRGB(0,200,255), Color3.fromRGB(255,60,60), Color3.fromRGB(60,255,60),
        Color3.fromRGB(255,200,0), Color3.fromRGB(200,80,255), Color3.fromRGB(255,255,255),
    }
    for i, col in ipairs(presets) do
        local b = new("TextButton", {Size = UDim2.fromOffset(26,26), BackgroundColor3 = col, Text = "", LayoutOrder = i}, presetRow)
        corner(b, 6)
        b.MouseButton1Click:Connect(function()
            espColor = col
            for _, h in pairs(highlights) do h.FillColor = espColor end
        end)
    end
    local r,g,b = 0,200,255
    local function upd() espColor = Color3.fromRGB(r,g,b); for _, h in pairs(highlights) do h.FillColor = espColor end end
    makeColorSlider(espPage, "R", 12, r, function(v) r=v; upd() end)
    makeColorSlider(espPage, "G", 13, g, function(v) g=v; upd() end)
    makeColorSlider(espPage, "B", 14, b, function(v) b=v; upd() end)

    Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function() if espEnabled then buildFor(p) end end)
    end)
    Players.PlayerRemoving:Connect(function(p)
        if highlights[p] then highlights[p]:Destroy() end
        if nickGuis[p] then nickGuis[p]:Destroy() end
        if hpGuis[p] then hpGuis[p]:Destroy() end
    end)
end

--=============================================================
--  AUTOFARM — нажать на парт, потом телепорт к таким же
--=============================================================
local farmPage = addTab("autofarm", "autofarm", 4)
do
    local farmEnabled = false
    local pickedName = nil

    makeSection(farmPage, "1) Нажми на объект в мире", 1)
    new("TextLabel", {Size = UDim2.new(1,-16,0,20), BackgroundTransparency = 1,
        Text = "Выбрано: —", Name = "PickedLabel", TextColor3 = Color3.fromRGB(200,200,200),
        Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 2}, farmPage)

    local pickBtn = new("TextButton", {
        Size = UDim2.new(1,-16,0,28), BackgroundColor3 = Color3.fromRGB(45,45,45),
        Text = "Нажми, чтобы выбрать объект", TextColor3 = Color3.fromRGB(220,220,220),
        Font = Enum.Font.GothamMedium, TextSize = 13, AutoButtonColor = false, LayoutOrder = 3,
    }, farmPage)
    corner(pickBtn, 6); stroke(pickBtn, Color3.fromRGB(100,100,100), 0.6)

    local picking = false
    pickBtn.MouseButton1Click:Connect(function()
        picking = true
        pickBtn.Text = "Кликни по объекту в мире..."
    end)
    UIS.InputBegan:Connect(function(input, gp)
        if gp or not picking then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        local mouse = plr:GetMouse()
        local target = mouse.Target
        if target then
            pickedName = target.Name
            picking = false
            pickBtn.Text = "Выбрано: " .. pickedName
            local lbl = farmPage:FindFirstChild("PickedLabel")
            if lbl then lbl.Text = "Выбрано: " .. pickedName end
        end
    end)

    makeSection(farmPage, "2) Запусти телепорт", 10)
    makeToggle(farmPage, "Автофарм (телепорт раз в 5 сек)", 11, function(on)
        farmEnabled = on
        if not on then return end
        task.spawn(function()
            while farmEnabled do
                task.wait(5)
                if not pickedName then continue end
                local c = plr.Character
                if not c or not c.PrimaryPart then continue end
                local found
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj.Name == pickedName and obj:IsA("BasePart") then found = obj; break end
                end
                if found then
                    c:PivotTo(CFrame.new(found.Position + Vector3.new(0,3,0)))
                end
            end
        end)
    end)

    new("TextLabel", {Size = UDim2.new(1,-16,0,40), BackgroundTransparency = 1,
        Text = "⚠ Телепорт — это чит. Только для своей игры / Studio.",
        TextColor3 = Color3.fromRGB(220,150,150), Font = Enum.Font.Gotham, TextSize = 12,
        TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 12}, farmPage)
end

--=============================================================
--  AIM — демо-алгоритм (без готовой боевой логики)
--=============================================================
local aimPage = addTab("aim", "aim", 5)
new("TextLabel", {
    Size = UDim2.new(1,-16,0,240), BackgroundTransparency = 1,
    Text = "Aim — техническая демонстрация.\n\n"
        .. "Принцип:\n"
        .. "1) выбрать цель (ник)\n"
        .. "2) брать Head.WorldPosition каждый кадр\n"
        .. "3) Camera.CFrame = CFrame.lookAt(cam.Position, targetPos)\n\n"
        .. "Это чит против других игроков — готовый код\n"
        .. "не даю. В Studio на своих NPC — вперёд, делай сам.",
    TextColor3 = Color3.fromRGB(180,180,180), Font = Enum.Font.Gotham,
    TextSize = 12, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
}, aimPage)

--=============================================================
--  СТАРТ + анимация открытия меню
--=============================================================
switchTab("user")

toggle.MouseButton1Click:Connect(function()
    if frame.Visible then
        -- закрываем
        TweenService:Create(frame, TweenInfo.new(0.15), {
            Size = UDim2.fromOffset(620,0),
        }):Play()
        task.wait(0.15)
        frame.Visible = false
        frame.Size = UDim2.fromOffset(620,420)
    else
        frame.Visible = true
        frame.Size = UDim2.fromOffset(620,0)
        TweenService:Create(frame, TweenInfo.new(0.2), {
            Size = UDim2.fromOffset(620,420),
        }):Play()
    end
end)

print("[MyUI v3] loaded | icon:", ICON_ID)
