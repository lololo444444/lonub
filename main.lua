--=============================================================
--  MyUI v10
--  Вкладки: user / visual / esp / fly / tp / aim / misc
--  Существа: Sahur, Ghost, Skeleton, Zombie, Golem
--  Korblox починен через MeshPart.MeshId
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
local ICON_FALLBACK = "rbxassetid://0" -- <<< ЗАМЕНИ на ID своей icon.png

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
--  КОРНЕВОЙ GUI
--=============================================================
local gui = new("ScreenGui", {
    Name = "MyUI", ResetOnSpawn = false, IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

local toggle = new("ImageButton", {
    Name = "Toggle",
    Size = UDim2.fromOffset(48,48),
    Position = UDim2.new(0.5,-24,0.5,-24),
    BackgroundColor3 = Color3.fromRGB(50,50,50),
    BackgroundTransparency = 0.2,
    Image = ICON_ID or "",
    AutoButtonColor = false, ClipsDescendants = true,
}, gui)
corner(toggle, 8); stroke(toggle)

if not ICON_ID or ICON_ID == "rbxassetid://0" then
    new("TextLabel", {
        Size = UDim2.fromScale(1,1), BackgroundTransparency = 1,
        Text = "UI", TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.GothamBold, TextSize = 16,
    }, toggle)
end

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

local frame = new("Frame", {
    Name = "Main", Size = UDim2.fromOffset(660,460),
    Position = UDim2.new(0.5,-330,0.5,-230),
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
    BackgroundTransparency = 1, Text = "MyUI v10", TextColor3 = Color3.fromRGB(220,220,220),
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
new("UIListLayout", {Padding = UDim.new(0,4), SortOrder = Enum.SortOrder.LayoutOrder,
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
        Size = UDim2.new(1,-12,0,26), BackgroundColor3 = Color3.fromRGB(45,45,45),
        BackgroundTransparency = 0.2, Text = text, TextColor3 = Color3.fromRGB(210,210,210),
        Font = Enum.Font.GothamMedium, TextSize = 12, AutoButtonColor = false, LayoutOrder = order or 0,
    }, tabBar)
    corner(b, 6); return b
end
local function makeToggle(parent, text, order, callback)
    local row = new("Frame", {Size = UDim2.new(1,-16,0,26), BackgroundTransparency = 1, LayoutOrder = order or 0}, parent)
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
    local row = new("Frame", {Size = UDim2.new(1,-16,0,26), BackgroundTransparency = 1, LayoutOrder = order or 0}, parent)
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
    return new("TextLabel", {Size = UDim2.new(1,-16,0,20), BackgroundTransparency = 1, Text = text,
        TextColor3 = Color3.fromRGB(160,160,160), Font = Enum.Font.GothamBold, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = order or 0}, parent)
end
local function makeButton(parent, text, order, callback)
    local b = new("TextButton", {
        Size = UDim2.new(1,-16,0,26), BackgroundColor3 = Color3.fromRGB(45,45,45),
        Text = text, TextColor3 = Color3.fromRGB(220,220,220),
        Font = Enum.Font.GothamMedium, TextSize = 13, AutoButtonColor = false, LayoutOrder = order or 0,
    }, parent)
    corner(b, 6); stroke(b, Color3.fromRGB(100,100,100), 0.6)
    b.MouseButton1Click:Connect(function() if callback then callback() end end)
    return b
end
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
--  СИСТЕМА ВКЛАДОК
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
    new("UIListLayout", {Padding = UDim.new(0,5), SortOrder = Enum.SortOrder.LayoutOrder}, page)
    new("UIPadding", {PaddingTop = UDim.new(0,8), PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8)}, page)
    local btn = makeTabButton(title, order)
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
    tabs[name] = {page = page, button = btn}
    return page
end

--=============================================================
--  СИСТЕМА СУЩЕСТВ (с сохранением и восстановлением)
--=============================================================
local appearanceSystem = {
    activeCreature = nil,
    saved = {},  -- [part] = {Color, Material, Size, MeshId, Transparency}
    extraParts = {}, -- созданные Part'ы (бита, корона и т.д.)
}

local function saveAppearance(part)
    if appearanceSystem.saved[part] then return end
    appearanceSystem.saved[part] = {
        Color = part.Color,
        Material = part.Material,
        Size = part.Size,
        MeshId = (part:IsA("MeshPart") and part.MeshId) or nil,
        Transparency = part.Transparency,
    }
end

local function restoreAppearance()
    for part, data in pairs(appearanceSystem.saved) do
        if part and part.Parent then
            part.Color = data.Color
            part.Material = data.Material
            part.Size = data.Size
            part.Transparency = data.Transparency
            if part:IsA("MeshPart") and data.MeshId then
                pcall(function() part.MeshId = data.MeshId end)
            end
        end
    end
    appearanceSystem.saved = {}
    for _, p in ipairs(appearanceSystem.extraParts) do
        if p and p.Parent then p:Destroy() end
    end
    appearanceSystem.extraParts = {}
    local c = plr.Character
    if c then
        local head = c:FindFirstChild("Head")
        if head then
            for _, d in ipairs(head:GetChildren()) do
                if d:IsA("Decal") or d:IsA("Texture") then d.Transparency = 0 end
            end
        end
    end
    appearanceSystem.activeCreature = nil
end

local function paintPart(part, color, material, size)
    if not part or not part:IsA("BasePart") then return end
    saveAppearance(part)
    part.Color = color
    part.Material = material
    if size then
        part.Size = size
        if part:IsA("MeshPart") then
            pcall(function() part.MeshId = "" end)
        end
    end
end

-- создания существ
local creatures = {}

creatures.sahur = function()
    local c = plr.Character; if not c then return end
    local wood = Color3.fromRGB(139,90,43)
    local dark = Color3.fromRGB(90,60,30)
    paintPart(c:FindFirstChild("UpperTorso"), wood, Enum.Material.Wood, Vector3.new(2,2,1))
    paintPart(c:FindFirstChild("LowerTorso"), dark, Enum.Material.Wood, Vector3.new(2,0.6,1))
    for _, n in ipairs({"LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand"}) do
        paintPart(c:FindFirstChild(n), wood, Enum.Material.Wood, Vector3.new(1,1,1))
    end
    for _, n in ipairs({"LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot"}) do
        paintPart(c:FindFirstChild(n), dark, Enum.Material.Wood, Vector3.new(1,2,1))
    end
    local head = c:FindFirstChild("Head")
    if head then
        paintPart(head, wood, Enum.Material.Wood, Vector3.new(1.2,1.2,1.2))
        for _, d in ipairs(head:GetChildren()) do
            if d:IsA("Decal") or d:IsA("Texture") then d.Transparency = 1 end
        end
    end
    -- бита
    local bat = Instance.new("Part")
    bat.Name = "SahurBat"
    bat.Size = Vector3.new(0.4,4,0.4)
    bat.Color = Color3.fromRGB(100,60,30)
    bat.Material = Enum.Material.Wood
    bat.CanCollide = false; bat.Massless = true
    local hand = c:FindFirstChild("RightHand") or c:FindFirstChild("Right Arm")
    if hand then
        bat.CFrame = hand.CFrame * CFrame.new(0,-2,-0.5) * CFrame.Angles(math.rad(90),0,0)
        bat.Parent = c
        local w = Instance.new("WeldConstraint")
        w.Part0 = hand; w.Part1 = bat; w.Parent = bat
        table.insert(appearanceSystem.extraParts, bat)
    else bat:Destroy() end
end

creatures.ghost = function()
    local c = plr.Character; if not c then return end
    for _, p in ipairs(c:GetChildren()) do
        if p:IsA("BasePart") then
            saveAppearance(p)
            p.Color = Color3.fromRGB(200,200,255)
            p.Material = Enum.Material.ForceField
            p.Transparency = 0.5
        end
    end
    local head = c:FindFirstChild("Head")
    if head then
        for _, d in ipairs(head:GetChildren()) do
            if d:IsA("Decal") or d:IsA("Texture") then d.Transparency = 1 end
        end
        local pe = Instance.new("ParticleEmitter")
        pe.Texture = "rbxassetid://241876428"
        pe.Rate = 30; pe.Lifetime = NumberRange.new(1,2)
        pe.Speed = NumberRange.new(0,1)
        pe.Size = NumberSequence.new(0.5)
        pe.Color = ColorSequence.new(Color3.fromRGB(200,200,255))
        pe.Transparency = NumberSequence.new(0.5)
        pe.Parent = head
        table.insert(appearanceSystem.extraParts, pe)
    end
end

creatures.skeleton = function()
    local c = plr.Character; if not c then return end
    local bone = Color3.fromRGB(230,230,220)
    for _, n in ipairs({"UpperTorso","LowerTorso","LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand","LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot","Head"}) do
        paintPart(c:FindFirstChild(n), bone, Enum.Material.SmoothPlastic, Vector3.new(0.8,0.8,0.8))
    end
    local head = c:FindFirstChild("Head")
    if head then
        for _, d in ipairs(head:GetChildren()) do
            if d:IsA("Decal") or d:IsA("Texture") then d.Transparency = 1 end
        end
    end
end

creatures.zombie = function()
    local c = plr.Character; if not c then return end
    local green = Color3.fromRGB(80,120,60)
    local dark = Color3.fromRGB(50,80,40)
    paintPart(c:FindFirstChild("UpperTorso"), green, Enum.Material.Sand)
    paintPart(c:FindFirstChild("LowerTorso"), dark, Enum.Material.Sand)
    for _, n in ipairs({"LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand"}) do
        paintPart(c:FindFirstChild(n), green, Enum.Material.Sand)
    end
    for _, n in ipairs({"LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot"}) do
        paintPart(c:FindFirstChild(n), dark, Enum.Material.Sand)
    end
    local head = c:FindFirstChild("Head")
    if head then paintPart(head, green, Enum.Material.Sand) end
    -- эффект гнили
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if hrp then
        local pe = Instance.new("ParticleEmitter")
        pe.Texture = "rbxassetid://241876428"
        pe.Rate = 10; pe.Lifetime = NumberRange.new(1,2)
        pe.Speed = NumberRange.new(0.5,1)
        pe.Size = NumberSequence.new(0.4)
        pe.Color = ColorSequence.new(Color3.fromRGB(100,150,80))
        pe.Transparency = NumberSequence.new(0.6)
        pe.Parent = hrp
        table.insert(appearanceSystem.extraParts, pe)
    end
end

creatures.golem = function()
    local c = plr.Character; if not c then return end
    local stone = Color3.fromRGB(100,100,100)
    local dark = Color3.fromRGB(60,60,60)
    for _, n in ipairs({"UpperTorso","LowerTorso","LeftUpperArm","LeftLowerArm","RightUpperArm","RightLowerArm"}) do
        paintPart(c:FindFirstChild(n), stone, Enum.Material.Slate, Vector3.new(2,2,2))
    end
    for _, n in ipairs({"LeftUpperLeg","LeftLowerLeg","RightUpperLeg","RightLowerLeg"}) do
        paintPart(c:FindFirstChild(n), dark, Enum.Material.Slate, Vector3.new(1.5,2,1.5))
    end
    paintPart(c:FindFirstChild("LeftHand"), dark, Enum.Material.Slate, Vector3.new(1.5,1.5,1.5))
    paintPart(c:FindFirstChild("RightHand"), dark, Enum.Material.Slate, Vector3.new(1.5,1.5,1.5))
    paintPart(c:FindFirstChild("Head"), stone, Enum.Material.Slate, Vector3.new(2,2,2))
    local head = c:FindFirstChild("Head")
    if head then
        for _, d in ipairs(head:GetChildren()) do
            if d:IsA("Decal") or d:IsA("Texture") then d.Transparency = 1 end
        end
    end
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

    makeSection(userPage, "Внешность", 1)
    makeToggle(userPage, "Фейк Headless", 2, function(on)
        local c = plr.Character; if not c then return end
        local head = c:FindFirstChild("Head"); if not head then return end
        head.Transparency = on and 1 or 0
        head.LocalTransparencyModifier = on and 1 or 0
        for _, v in ipairs(head:GetChildren()) do
            if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = on and 1 or 0 end
        end
    end)

    -- KORBLOX — починенный
    makeToggle(userPage, "Фейк Korblox", 3, function(on)
        local c = plr.Character; if not c then return end
        local leg = c:FindFirstChild("RightUpperLeg") or c:FindFirstChild("Right Leg")
        if not leg then return end
        if on then
            saveAppearance(leg)
            if leg:IsA("MeshPart") then
                -- R15: заменяем MeshId на Korblox-меш
                pcall(function()
                    leg.MeshId = "rbxassetid://1186899558"
                end)
                leg.Color = Color3.fromRGB(20,20,20)
                leg.Material = Enum.Material.SmoothPlastic
            else
                -- R6: SpecialMesh
                local m = Instance.new("SpecialMesh")
                m.MeshType = Enum.MeshType.FileMesh
                m.MeshId = "rbxassetid://1186899558"
                m.Scale = Vector3.new(1,1,1); m.Name = "FakeKorblox"; m.Parent = leg
                leg.Color = Color3.fromRGB(20,20,20)
            end
        else
            if leg:IsA("MeshPart") then
                pcall(function()
                    leg.MeshId = "rbxassetid://0" -- Roblox сам подставит дефолт
                end)
            else
                local m = leg:FindFirstChild("FakeKorblox"); if m then m:Destroy() end
            end
            leg.Color = Color3.fromRGB(163,162,165)
        end
    end)

    makeToggle(userPage, "Отключить анимации", 4, function(on)
        local c = plr.Character; if not c then return end
        local hum = c:FindFirstChildOfClass("Humanoid"); if not hum then return end
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do track:Stop() end
        end
        hum.AnimationPlayed = on and function(track) track:Stop() end or nil
    end)
    makeToggle(userPage, "Невидимость (локально)", 5, function(on)
        local c = plr.Character; if not c then return end
        for _, part in ipairs(c:GetDescendants()) do
            if part:IsA("BasePart") then part.LocalTransparencyModifier = on and 1 or 0 end
        end
    end)

    -- СУЩЕСТВА
    makeSection(userPage, "Превратиться в существо", 17)
    makeButton(userPage, "Tung Tung Tung Sahur", 18, function()
        if appearanceSystem.activeCreature == "sahur" then restoreAppearance(); return end
        restoreAppearance()
        appearanceSystem.activeCreature = "sahur"
        creatures.sahur()
    end)
    makeButton(userPage, "Призрак", 19, function()
        if appearanceSystem.activeCreature == "ghost" then restoreAppearance(); return end
        restoreAppearance()
        appearanceSystem.activeCreature = "ghost"
        creatures.ghost()
    end)
    makeButton(userPage, "Скелет", 20, function()
        if appearanceSystem.activeCreature == "skeleton" then restoreAppearance(); return end
        restoreAppearance()
        appearanceSystem.activeCreature = "skeleton"
        creatures.skeleton()
    end)
    makeButton(userPage, "Зомби", 21, function()
        if appearanceSystem.activeCreature == "zombie" then restoreAppearance(); return end
        restoreAppearance()
        appearanceSystem.activeCreature = "zombie"
        creatures.zombie()
    end)
    makeButton(userPage, "Каменный голем", 22, function()
        if appearanceSystem.activeCreature == "golem" then restoreAppearance(); return end
        restoreAppearance()
        appearanceSystem.activeCreature = "golem"
        creatures.golem()
    end)
    makeButton(userPage, "Вернуть обычный вид", 23, restoreAppearance)

    plr.CharacterAdded:Connect(function()
        task.wait(0.6)
        if appearanceSystem.activeCreature and creatures[appearanceSystem.activeCreature] then
            appearanceSystem.saved = {}
            appearanceSystem.extraParts = {}
            creatures[appearanceSystem.activeCreature]()
        end
    end)

    makeSection(userPage, "Движение", 30)
    makeInput(userPage, "Скорость", 31, "16", function(v)
        local h = getHum(); if h and tonumber(v) then h.WalkSpeed = tonumber(v) end
    end)
    makeInput(userPage, "Прыжок", 32, "50", function(v)
        local h = getHum(); if h and tonumber(v) then h.JumpPower = tonumber(v) end
    end)
    makeToggle(userPage, "Бесконечный прыжок", 33, function(on) infiniteJump = on end)

    local spinning = false
    local spinSpeed = 180
    makeToggle(userPage, "Спин по Y", 34, function(on) spinning = on end)
    makeInput(userPage, "Скорость спина (°/сек)", 35, "180", function(v)
        if tonumber(v) then spinSpeed = tonumber(v) end
    end)
    RunService.RenderStepped:Connect(function(dt)
        if not spinning then return end
        local c = plr.Character; if not c or not c.PrimaryPart then return end
        c:PivotTo(c:GetPivot() * CFrame.Angles(0, math.rad(spinSpeed)*dt, 0))
    end)

    local backWalk = false
    makeToggle(userPage, "Идти спиной (Shift Lock)", 36, function(on)
        backWalk = on
        local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.AutoRotate = not on end
    end)
    RunService.RenderStepped:Connect(function()
        if not backWalk then return end
        local c = plr.Character; if not c then return end
        local hum = c:FindFirstChildOfClass("Humanoid"); if not hum then return end
        local root = c:FindFirstChild("HumanoidRootPart"); if not root then return end
        if hum.AutoRotate then hum.AutoRotate = false end
        local mv = hum.MoveDirection
        if mv.Magnitude < 0.1 then return end
        local look = CFrame.lookAt(root.Position, root.Position - mv)
        root.CFrame = CFrame.new(root.Position) * look.Rotation
    end)
    plr.CharacterAdded:Connect(function()
        task.wait(0.5)
        local h = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
        if h and not backWalk then h.AutoRotate = true end
    end)
end

local infiniteJump = false
UIS.JumpRequest:Connect(function()
    if infiniteJump then
        local h = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

--=============================================================
--  VISUAL
--=============================================================
local visualPage = addTab("visual", "visual", 2)
do
    local function resetLighting()
        Lighting.Brightness = 2; Lighting.FogEnd = 100000; Lighting.FogStart = 0
        Lighting.FogColor = Color3.fromRGB(192,192,192); Lighting.ClockTime = 14
    end
    local function clearWeather()
        for _, n in ipairs({"WeatherRain","WeatherSnow","WeatherStars"}) do
            local o = workspace:FindFirstChild(n); if o then o:Destroy() end
        end
    end

    makeSection(visualPage, "Погода", 1)
    local function setRain(on)
        clearWeather()
        if not on then resetLighting(); return end
        Lighting.FogEnd = 400; Lighting.FogColor = Color3.fromRGB(90,90,100); Lighting.Brightness = 1
        local rain = Instance.new("Part")
        rain.Name = "WeatherRain"; rain.Size = Vector3.new(2000,1,2000); rain.Transparency = 1
        rain.CanCollide = false; rain.Anchored = true; rain.Parent = workspace
        local em = Instance.new("ParticleEmitter")
        em.Texture = "rbxassetid://241876428"; em.Rate = 1000
        em.Lifetime = NumberRange.new(0.6,1)
        em.Speed = NumberRange.new(80,120)
        em.SpreadAngle = Vector2.new(5,5)
        em.Size = NumberSequence.new(0.6); em.Transparency = NumberSequence.new(0.4)
        em.Parent = rain
        local conn; conn = RunService.Heartbeat:Connect(function()
            if not rain.Parent then conn:Disconnect(); return end
            local c = plr.Character
            if c and c.PrimaryPart then rain.CFrame = CFrame.new(c.PrimaryPart.Position + Vector3.new(0,60,0)) end
        end)
    end
    makeToggle(visualPage, "Дождь", 2, setRain)

    local function setSnow(on)
        clearWeather()
        if not on then resetLighting(); return end
        Lighting.FogEnd = 300; Lighting.FogColor = Color3.fromRGB(240,240,255); Lighting.Brightness = 2
        local snow = Instance.new("Part")
        snow.Name = "WeatherSnow"; snow.Size = Vector3.new(2000,1,2000); snow.Transparency = 1
        snow.CanCollide = false; snow.Anchored = true; snow.Parent = workspace
        local em = Instance.new("ParticleEmitter")
        em.Texture = "rbxassetid://241876428"; em.Rate = 500
        em.Lifetime = NumberRange.new(2,4)
        em.Speed = NumberRange.new(5,15)
        em.SpreadAngle = Vector2.new(20,20)
        em.Size = NumberSequence.new(0.4)
        em.Color = ColorSequence.new(Color3.fromRGB(255,255,255))
        em.Parent = snow
        local conn; conn = RunService.Heartbeat:Connect(function()
            if not snow.Parent then conn:Disconnect(); return end
            local c = plr.Character
            if c and c.PrimaryPart then snow.CFrame = CFrame.new(c.PrimaryPart.Position + Vector3.new(0,50,0)) end
        end)
    end
    makeToggle(visualPage, "Снег", 3, setSnow)

    local lightningOn = false
    makeToggle(visualPage, "Гроза", 4, function(on) lightningOn = on end)
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
    makeToggle(visualPage, "Солнечно", 5, function(on)
        if on then resetLighting(); Lighting.Brightness = 4; Lighting.ClockTime = 12 end
    end)
    makeToggle(visualPage, "Метель", 6, function(on)
        clearWeather()
        if not on then resetLighting(); return end
        Lighting.FogEnd = 50; Lighting.FogStart = 0
        Lighting.FogColor = Color3.fromRGB(220,220,230); Lighting.Brightness = 1.5
    end)
    makeToggle(visualPage, "Ночь", 7, function(on)
        if on then
            Lighting.ClockTime = 0; Lighting.Brightness = 0.5
            Lighting.FogEnd = 500; Lighting.FogColor = Color3.fromRGB(20,20,40)
        else resetLighting() end
    end)

    makeSection(visualPage, "Освещение", 10)
    makeInput(visualPage, "Brightness", 11, "2", function(v)
        if tonumber(v) then Lighting.Brightness = tonumber(v) end
    end)
    makeInput(visualPage, "ClockTime", 12, "14", function(v)
        if tonumber(v) then Lighting.ClockTime = tonumber(v) end
    end)
    makeToggle(visualPage, "Ночное зрение", 13, function(on)
        if on then
            Lighting.OutdoorAmbient = Color3.fromRGB(200,200,200)
            Lighting.Ambient = Color3.fromRGB(200,200,200)
        else
            Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
            Lighting.Ambient = Color3.fromRGB(0,0,0)
        end
    end)

    makeSection(visualPage, "Цветовые фильтры", 20)
    local filters = {
        {name = "Красный", color = Color3.fromRGB(255,100,100), contrast = 0.2, saturation = 0.5},
        {name = "Синий",   color = Color3.fromRGB(100,150,255), contrast = 0.2, saturation = 0.5},
        {name = "Зелёный", color = Color3.fromRGB(100,255,150), contrast = 0.2, saturation = 0.5},
        {name = "ЧБ",      color = Color3.fromRGB(200,200,200), contrast = 0.3, saturation = -1},
        {name = "Сепия",   color = Color3.fromRGB(220,180,120), contrast = 0.2, saturation = 0.3},
        {name = "Неон",    color = Color3.fromRGB(150,100,255), contrast = 0.5, saturation = 0.8},
    }
    local currentFilter
    local filterRow = new("Frame", {Size = UDim2.new(1,-16,0,26), BackgroundTransparency = 1, LayoutOrder = 21}, visualPage)
    new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0,4),
        SortOrder = Enum.SortOrder.LayoutOrder}, filterRow)
    for i, f in ipairs(filters) do
        local b = new("TextButton", {
            Size = UDim2.fromOffset(50,24), BackgroundColor3 = f.color,
            Text = f.name, TextColor3 = Color3.new(1,1,1),
            Font = Enum.Font.GothamBold, TextSize = 10, LayoutOrder = i,
        }, filterRow)
        corner(b, 4)
        b.MouseButton1Click:Connect(function()
            if currentFilter then currentFilter:Destroy() end
            local c = Instance.new("ColorCorrectionEffect")
            c.TintColor = f.color; c.Contrast = f.contrast; c.Saturation = f.saturation
            c.Parent = Lighting; currentFilter = c
        end)
    end
    makeButton(visualPage, "Убрать фильтр", 22, function()
        if currentFilter then currentFilter:Destroy(); currentFilter = nil end
    end)

    makeSection(visualPage, "Эффекты экрана", 30)
    makeToggle(visualPage, "Bloom", 31, function(on)
        local e = Lighting:FindFirstChildOfClass("BloomEffect")
        if on and not e then
            local b = Instance.new("BloomEffect")
            b.Intensity = 0.8; b.Size = 24; b.Threshold = 0.8; b.Parent = Lighting
        elseif not on and e then e:Destroy() end
    end)
    makeToggle(visualPage, "Blur", 32, function(on)
        local e = Lighting:FindFirstChildOfClass("BlurEffect")
        if on and not e then
            local b = Instance.new("BlurEffect"); b.Size = 12; b.Parent = Lighting
        elseif not on and e then e:Destroy() end
    end)

    makeSection(visualPage, "Ауры", 40)
    local activeEmitters = {}
    local function makeAura(name, color, size)
        local c = plr.Character; if not c or not c.PrimaryPart then return end
        if activeEmitters[name] then activeEmitters[name]:Destroy(); activeEmitters[name] = nil; return end
        local pe = Instance.new("ParticleEmitter")
        pe.Name = name; pe.Texture = "rbxassetid://241876428"
        pe.Rate = 80; pe.Lifetime = NumberRange.new(0.5,1.5)
        pe.Speed = NumberRange.new(0,2)
        pe.SpreadAngle = Vector2.new(180,180)
        pe.Size = NumberSequence.new(size or 0.5)
        pe.Color = ColorSequence.new(color)
        pe.Transparency = NumberSequence.new(0.3)
        pe.Parent = c.PrimaryPart
        activeEmitters[name] = pe
    end
    makeButton(visualPage, "Огонь", 41, function() makeAura("Fire", Color3.fromRGB(255,100,0), 0.8) end)
    makeButton(visualPage, "Лёд", 42, function() makeAura("Ice", Color3.fromRGB(100,200,255), 0.6) end)
    makeButton(visualPage, "Молния", 43, function() makeAura("Light", Color3.fromRGB(255,255,150), 0.5) end)
    makeButton(visualPage, "Смерть", 44, function() makeAura("Death", Color3.fromRGB(50,0,50), 0.7) end)
    makeButton(visualPage, "Убрать все", 45, function()
        for _, pe in pairs(activeEmitters) do if pe then pe:Destroy() end end
        activeEmitters = {}
    end)

    makeSection(visualPage, "FOV", 50)
    makeInput(visualPage, "FOV", 51, "70", function(v)
        if tonumber(v) then camera.FieldOfView = tonumber(v) end
    end)
end

--=============================================================
--  ESP
--=============================================================
local espPage = addTab("esp", "esp", 3)
do
    local highlights, nickGuis, hpGuis = {}, {}, {}
    local espEnabled = false
    local showNick, showHP = false, false
    local espColor = Color3.fromRGB(0,200,255)

    local function getChar(p)
        local c = p.Character
        if c and c:FindFirstChild("HumanoidRootPart") then return c end
    end
    local function clearAll()
        for _, h in pairs(highlights) do if h then h:Destroy() end end
        for _, g in pairs(nickGuis) do if g then g:Destroy() end end
        for _, g in pairs(hpGuis) do if g then g:Destroy() end end
        highlights, nickGuis, hpGuis = {}, {}, {}
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
        if head and showNick and not nickGuis[p] then
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

    makeToggle(espPage, "ESP (Highlight)", 1, function(on)
        espEnabled = on
        if on then for _,p in ipairs(Players:GetPlayers()) do if p ~= plr then buildFor(p) end end
        else clearAll() end
    end)
    makeToggle(espPage, "Ник", 2, function(on) showNick = on; for _,p in ipairs(Players:GetPlayers()) do if p ~= plr then buildFor(p) end end end)
    makeToggle(espPage, "HP-бар", 3, function(on) showHP = on; for _,p in ipairs(Players:GetPlayers()) do if p ~= plr then buildFor(p) end end end)

    makeSection(espPage, "Цвет", 10)
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
--  FLY
--=============================================================
local flyPage = addTab("fly", "fly", 4)
do
    local flying = false
    local flySpeed = 50
    local bodyVel, bodyGyro
    local keys = {W=false,A=false,S=false,D=false,Space=false,Ctrl=false}

    UIS.InputBegan:Connect(function(i, gp)
        if gp then return end
        local k = i.KeyCode
        if k == Enum.KeyCode.W then keys.W = true
        elseif k == Enum.KeyCode.A then keys.A = true
        elseif k == Enum.KeyCode.S then keys.S = true
        elseif k == Enum.KeyCode.D then keys.D = true
        elseif k == Enum.KeyCode.Space then keys.Space = true
        elseif k == Enum.KeyCode.LeftControl then keys.Ctrl = true end
    end)
    UIS.InputEnded:Connect(function(i)
        local k = i.KeyCode
        if k == Enum.KeyCode.W then keys.W = false
        elseif k == Enum.KeyCode.A then keys.A = false
        elseif k == Enum.KeyCode.S then keys.S = false
        elseif k == Enum.KeyCode.D then keys.D = false
        elseif k == Enum.KeyCode.Space then keys.Space = false
        elseif k == Enum.KeyCode.LeftControl then keys.Ctrl = false end
    end)

    local function startFly()
        local c = plr.Character; if not c then return end
        local hrp = c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = true end
        hrp.Anchored = false
        bodyVel = Instance.new("BodyVelocity")
        bodyVel.MaxForce = Vector3.new(1e5,1e5,1e5)
        bodyVel.Velocity = Vector3.zero
        bodyVel.Parent = hrp
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(1e5,1e5,1e5)
        bodyGyro.P = 1000; bodyGyro.D = 100
        bodyGyro.Parent = hrp
        RunService.Heartbeat:Connect(function()
            if not flying then
                if bodyVel then bodyVel:Destroy(); bodyVel = nil end
                if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
                if hum then hum.PlatformStand = false end
                return
            end
            if not bodyVel or not bodyVel.Parent then return end
            local camCF = camera.CFrame
            local move = Vector3.zero
            if keys.W then move = move + camCF.LookVector end
            if keys.S then move = move - camCF.LookVector end
            if keys.A then move = move - camCF.RightVector end
            if keys.D then move = move + camCF.RightVector end
            if keys.Space then move = move + Vector3.new(0,1,0) end
            if keys.Ctrl then move = move - Vector3.new(0,1,0) end
            if move.Magnitude > 0 then move = move.Unit end
            bodyVel.Velocity = move * flySpeed
            bodyGyro.CFrame = camCF
        end)
    end
    local function stopFly()
        flying = false
        if bodyVel then bodyVel:Destroy(); bodyVel = nil end
        if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
        local c = plr.Character
        if c then
            local hum = c:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
        end
    end

    makeSection(flyPage, "Fly", 1)
    makeInput(flyPage, "Скорость", 2, "50", function(v)
        if tonumber(v) then flySpeed = tonumber(v) end
    end)
    makeToggle(flyPage, "Fly вкл/выкл", 3, function(on)
        flying = on
        if on then startFly() else stopFly() end
    end)
end

--=============================================================
--  TELEPORT
--=============================================================
local tpPage = addTab("tp", "tp", 5)
do
    makeSection(tpPage, "Телепорт к игроку", 1)
    local playerList = new("ScrollingFrame", {
        Size = UDim2.new(1,-16,0,120), BackgroundColor3 = Color3.fromRGB(25,25,25),
        BackgroundTransparency = 0.4, BorderSizePixel = 0, ScrollBarThickness = 4,
        LayoutOrder = 2, CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, tpPage)
    corner(playerList, 6)
    new("UIListLayout", {Padding = UDim.new(0,4), SortOrder = Enum.SortOrder.LayoutOrder}, playerList)
    new("UIPadding", {PaddingTop = UDim.new(0,4), PaddingLeft = UDim.new(0,4), PaddingRight = UDim.new(0,4)}, playerList)

    local function refreshPlayers()
        for _, c in ipairs(playerList:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p == plr then continue end
            local b = new("TextButton", {
                Size = UDim2.new(1,-4,0,24), BackgroundColor3 = Color3.fromRGB(45,45,45),
                Text = p.Name, TextColor3 = Color3.fromRGB(220,220,220),
                Font = Enum.Font.Gotham, TextSize = 13, AutoButtonColor = false,
            }, playerList)
            corner(b, 4)
            b.MouseButton1Click:Connect(function()
                local c = plr.Character; if not c or not c.PrimaryPart then return end
                local t = p.Character
                if t and t:FindFirstChild("HumanoidRootPart") then
                    c:PivotTo(t.HumanoidRootPart.CFrame * CFrame.new(0,0,3))
                end
            end)
        end
    end
    refreshPlayers()
    Players.PlayerAdded:Connect(refreshPlayers)
    Players.PlayerRemoving:Connect(function() task.wait(0.1); refreshPlayers() end)
    makeButton(tpPage, "Обновить список", 3, refreshPlayers)

    makeSection(tpPage, "Координаты", 10)
    local cx, cy, cz = 0, 0, 0
    makeInput(tpPage, "X", 11, "0", function(v) cx = tonumber(v) or 0 end)
    makeInput(tpPage, "Y", 12, "0", function(v) cy = tonumber(v) or 0 end)
    makeInput(tpPage, "Z", 13, "0", function(v) cz = tonumber(v) or 0 end)
    makeButton(tpPage, "Телепорт", 14, function()
        local c = plr.Character; if not c or not c.PrimaryPart then return end
        c:PivotTo(CFrame.new(cx, cy, cz))
    end)

    makeSection(tpPage, "Сохранение позиции", 20)
    local savedPos = nil
    makeButton(tpPage, "Сохранить", 21, function()
        local c = plr.Character; if not c or not c.PrimaryPart then return end
        savedPos = c.PrimaryPart.Position
    end)
    makeButton(tpPage, "Вернуться", 22, function()
        if not savedPos then return end
        local c = plr.Character; if not c or not c.PrimaryPart then return end
        c:PivotTo(CFrame.new(savedPos + Vector3.new(0,3,0)))
    end)
end

--=============================================================
--  AIM
--=============================================================
local aimPage = addTab("aim", "aim", 6)
do
    local aimEnabled = false
    local aimTarget = nil
    makeSection(aimPage, "Игроки на сервере", 1)
    local aimList = new("ScrollingFrame", {
        Size = UDim2.new(1,-16,0,160), BackgroundColor3 = Color3.fromRGB(25,25,25),
        BackgroundTransparency = 0.4, BorderSizePixel = 0, ScrollBarThickness = 4,
        LayoutOrder = 2, CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, aimPage)
    corner(aimList, 6)
    new("UIListLayout", {Padding = UDim.new(0,4), SortOrder = Enum.SortOrder.LayoutOrder}, aimList)
    new("UIPadding", {PaddingTop = UDim.new(0,4), PaddingLeft = UDim.new(0,4), PaddingRight = UDim.new(0,4)}, aimList)
    local selectedLabel = new("TextLabel", {Size = UDim2.new(1,-16,0,20), BackgroundTransparency = 1,
        Text = "Выбрано: —", TextColor3 = Color3.fromRGB(200,200,200),
        Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 3}, aimPage)

    local function refreshAimList()
        for _, c in ipairs(aimList:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p == plr then continue end
            local b = new("TextButton", {
                Size = UDim2.new(1,-4,0,24), BackgroundColor3 = Color3.fromRGB(45,45,45),
                Text = p.Name, TextColor3 = Color3.fromRGB(220,220,220),
                Font = Enum.Font.Gotham, TextSize = 13, AutoButtonColor = false,
            }, aimList)
            corner(b, 4)
            b.MouseButton1Click:Connect(function()
                aimTarget = p
                selectedLabel.Text = "Выбрано: " .. p.Name
            end)
        end
    end
    refreshAimList()
    Players.PlayerAdded:Connect(refreshAimList)
    Players.PlayerRemoving:Connect(function() task.wait(0.1); refreshAimList() end)
    makeButton(aimPage, "Обновить", 4, refreshAimList)
    makeToggle(aimPage, "Aim вкл/выкл", 5, function(on) aimEnabled = on end)
    RunService.RenderStepped:Connect(function()
        if not aimEnabled or not aimTarget then return end
        local char = aimTarget.Character
        if not char then return end
        local head = char:FindFirstChild("Head")
        if not head then return end
        camera.CFrame = CFrame.lookAt(camera.CFrame.Position, head.Position)
    end)
end

--=============================================================
--  MISC
--=============================================================
local miscPage = addTab("misc", "misc", 7)
do
    makeSection(miscPage, "Чат", 1)
    local chatMsg = "Привет!"
    makeInput(miscPage, "Текст", 2, "Привет!", function(v) chatMsg = v end)
    makeButton(miscPage, "Отправить", 3, function()
        local ev = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
        if ev then
            local say = ev:FindFirstChild("SayMessageRequest")
            if say then say:FireServer(chatMsg, "All") end
        end
    end)

    makeSection(miscPage, "Rejoin", 10)
    makeButton(miscPage, "Переподключиться", 11, function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, plr)
    end)

    makeSection(miscPage, "Информация", 20)
    local infoLabel = new("TextLabel", {
        Size = UDim2.new(1,-16,0,80), BackgroundTransparency = 1,
        Text = "", TextColor3 = Color3.fromRGB(200,200,200),
        Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true, LayoutOrder = 21,
    }, miscPage)
    makeButton(miscPage, "Обновить инфо", 22, function()
        local players = #Players:GetPlayers()
        local ping = math.floor(plr:GetNetworkPing() * 1000)
        infoLabel.Text = string.format(
            "Игроков: %d\nPing: %d ms\nPlaceId: %d\nJobId: %s",
            players, ping, game.PlaceId, tostring(game.JobId):sub(1, 20).."…"
        )
    end)

    makeSection(miscPage, "Прочее", 30)
    makeButton(miscPage, "Сброс персонажа", 31, function()
        local h = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
        if h then h.Health = 0 end
    end)
    makeToggle(miscPage, "Увеличить хитбокс", 32, function(on)
        local c = plr.Character; if not c then return end
        local hrp = c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        if on then
            hrp.Size = Vector3.new(10,10,10)
            hrp.Transparency = 0.7
        else
            hrp.Size = Vector3.new(2,2,1)
            hrp.Transparency = 1
        end
    end)
end

--=============================================================
--  СТАРТ
--=============================================================
switchTab("user")

toggle.MouseButton1Click:Connect(function()
    if frame.Visible then
        TweenService:Create(frame, TweenInfo.new(0.15), {Size = UDim2.fromOffset(660,0)}):Play()
        task.wait(0.15)
        frame.Visible = false
        frame.Size = UDim2.fromOffset(660,460)
    else
        frame.Visible = true
        frame.Size = UDim2.fromOffset(660,0)
        TweenService:Create(frame, TweenInfo.new(0.2), {Size = UDim2.fromOffset(660,460)}):Play()
    end
end)

print("[MyUI v10] loaded | icon:", ICON_ID)
