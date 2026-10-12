--[[
    SL HUB V1 — Street Life Remastered. Solo asistencia (camara) + radar.
    Sin hooks, sin CoreGui/gethui, sin prints. Textos neutros desde el codigo.
]]

--// Servicios
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

--// Anti re-ejecución
if _G.__SL_STOP then pcall(_G.__SL_STOP) end
local dead = false
_G.__SL_STOP = function() dead = true end
if _G.__SL_CONNS then
    for _, c in ipairs(_G.__SL_CONNS) do pcall(function() c:Disconnect() end) end
end
_G.__SL_CONNS = {}
local function SCONN(c) table.insert(_G.__SL_CONNS, c) return c end
if _G.__SL_GUI then pcall(function() _G.__SL_GUI:Destroy() end) _G.__SL_GUI = nil end

--// Settings
local settings = {
    aimEnabled = false, aimAuto = false, smoothing = 25, fovRadius = 140,
    showFov = true, targetPart = "Head", aimMaxDistance = 500, aimDeadzone = 6,
    stickyTarget = true,
    espEnabled = false, espNames = true, espDistance = true, espHealthBar = true,
    espBox = true, espTracer = true, skeleton = true,
    espTool = false, espPaint = false,
    tracerOrigin = "Bottom", maxDistance = 1500,
    magicEnabled = false, magicPrediction = 0.12,
    silentEnabled = false, silentFov = 200, silentHitChance = 100,
    uiToggleKey = Enum.KeyCode.RightShift,
}
local stickyPart, stickyModel, stickyName = nil, nil, ""
local lastAimPart = nil

--// Estilo
local ACCENT = Color3.fromRGB(0, 242, 255)
local COLOR_BG = Color3.fromRGB(10, 10, 16)
local COLOR_CARD = Color3.fromRGB(17, 17, 27)
local COLOR_CARD2 = Color3.fromRGB(22, 22, 34)
local COLOR_TEXT = Color3.fromRGB(245, 245, 250)
local COLOR_SUBTEXT = Color3.fromRGB(150, 150, 170)
local FONT_MAIN = Enum.Font.GothamMedium
local FONT_BOLD = Enum.Font.GothamBold
local FONT_TITLE = Enum.Font.FredokaOne

local function tween(obj, info, props)
    pcall(function()
        TweenService:Create(obj, info or TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
    end)
end
local function corner(obj, r)
    local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, r or 8) c.Parent = obj return c
end
local function stroke(obj, col, t)
    local s = Instance.new("UIStroke") s.Color = col s.Thickness = t or 1 s.Transparency = 0 s.Parent = obj return s
end
local function myRoot()
    local c = localPlayer.Character return c and c:FindFirstChild("HumanoidRootPart")
end
local function myHum()
    local c = localPlayer.Character return c and c:FindFirstChildOfClass("Humanoid")
end

--// GUI raíz (nombre aleatorio neutro)
local function rndName()
    local s = ""
    for i = 1, 10 do s = s .. string.char(math.random(97, 122)) end
    return "ui_" .. s
end
if _G.__SL_SILOLD then
    pcall(function() hookmetamethod(game, "__namecall", _G.__SL_SILOLD) end)
    _G.__SL_SILOLD = nil
end
for _, v in ipairs(localPlayer.PlayerGui:GetChildren()) do
    pcall(function()
        if v:GetAttribute("SL1") then v:Destroy() end
    end)
end
local gui = Instance.new("ScreenGui")
gui.Name = rndName()
gui:SetAttribute("SL1", true)
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = localPlayer:WaitForChild("PlayerGui")
_G.__SL_GUI = gui

--// Panel
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 520, 0, 380)
mainFrame.Position = UDim2.new(0.5, -260, 0.5, -190)
mainFrame.BackgroundColor3 = COLOR_BG
mainFrame.Visible = false
mainFrame.Parent = gui
corner(mainFrame, 12) stroke(mainFrame, Color3.fromRGB(38, 38, 55), 1.2)

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 48) topBar.BackgroundTransparency = 1 topBar.Parent = mainFrame
local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(0, 220, 0, 28) titleLbl.Position = UDim2.new(0, 16, 0, 6)
titleLbl.BackgroundTransparency = 1 titleLbl.Font = FONT_BOLD titleLbl.TextSize = 17
titleLbl.TextXAlignment = Enum.TextXAlignment.Left titleLbl.TextColor3 = COLOR_TEXT
titleLbl.Text = "Calle v1.0" titleLbl.Parent = topBar
local descLbl = Instance.new("TextLabel")
descLbl.Size = UDim2.new(0, 300, 0, 16) descLbl.Position = UDim2.new(0, 16, 0, 30)
descLbl.BackgroundTransparency = 1 descLbl.Font = FONT_MAIN descLbl.TextSize = 11
descLbl.TextXAlignment = Enum.TextXAlignment.Left descLbl.TextColor3 = COLOR_SUBTEXT
descLbl.Text = "Asistencia + radar." descLbl.Parent = topBar
local hideBtn = Instance.new("TextButton")
hideBtn.Size = UDim2.new(0, 32, 0, 32) hideBtn.Position = UDim2.new(1, -44, 0, 8)
hideBtn.BackgroundColor3 = COLOR_CARD2 hideBtn.Font = FONT_BOLD hideBtn.TextSize = 14
hideBtn.TextColor3 = COLOR_TEXT hideBtn.Text = "-" hideBtn.Parent = topBar corner(hideBtn, 8)

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -24, 1, -60) scroll.Position = UDim2.new(0, 12, 0, 54)
scroll.BackgroundTransparency = 1 scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = ACCENT scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new(0, 0, 0, 0) scroll.Parent = mainFrame
local scrollLay = Instance.new("UIListLayout")
scrollLay.Padding = UDim.new(0, 10) scrollLay.SortOrder = Enum.SortOrder.LayoutOrder scrollLay.Parent = scroll

do
    local dragging, ds, sp
    local function begin(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true ds = input.Position sp = mainFrame.Position
        end
    end
    local function move(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - ds
            mainFrame.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end
    local function fin(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end
    SCONN(topBar.InputBegan:Connect(begin))
    SCONN(UserInputService.InputChanged:Connect(move))
    SCONN(UserInputService.InputEnded:Connect(fin))
    hideBtn.MouseButton1Click:Connect(function() mainFrame.Visible = false end)
end

--// Componentes
local toggleStates = {}
local cardCount = 0
local function createCard(titleText)
    cardCount = cardCount + 1
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -12, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = COLOR_CARD card.Parent = scroll
    card.LayoutOrder = cardCount
    corner(card, 10) stroke(card, Color3.fromRGB(32, 32, 48), 1)
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 14) pad.PaddingRight = UDim.new(0, 14)
    pad.PaddingTop = UDim.new(0, 12) pad.PaddingBottom = UDim.new(0, 14) pad.Parent = card
    local layCard = Instance.new("UIListLayout")
    layCard.Padding = UDim.new(0, 6) layCard.SortOrder = Enum.SortOrder.LayoutOrder layCard.Parent = card
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 20) title.BackgroundTransparency = 1
    title.Font = FONT_BOLD title.TextSize = 12 title.TextColor3 = COLOR_TEXT
    title.TextXAlignment = Enum.TextXAlignment.Left title.Text = titleText:upper() title.Parent = card
    title.LayoutOrder = 1
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 26, 0, 3)
    bar.BackgroundColor3 = ACCENT bar.Parent = card corner(bar, 99)
    bar.LayoutOrder = 2
    local box = Instance.new("Frame")
    box.Size = UDim2.new(1, 0, 0, 0)
    box.AutomaticSize = Enum.AutomaticSize.Y
    box.BackgroundTransparency = 1 box.Parent = card
    box.LayoutOrder = 3
    local lay = Instance.new("UIListLayout")
    lay.Padding = UDim.new(0, 8) lay.SortOrder = Enum.SortOrder.LayoutOrder lay.Parent = box
    return box
end

local function createToggle(parent, text, callback, key, default)
    default = default or false
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, 0, 0, 30) row.BackgroundTransparency = 1 row.Text = "" row.Parent = parent
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -58, 1, 0) lbl.BackgroundTransparency = 1
    lbl.Font = FONT_MAIN lbl.TextSize = 12 lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = default and COLOR_TEXT or COLOR_SUBTEXT lbl.Text = text lbl.Parent = row
    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 42, 0, 22) track.Position = UDim2.new(1, -42, 0.5, -11)
    track.BackgroundColor3 = default and ACCENT or Color3.fromRGB(30, 30, 44) track.Parent = row corner(track, 99)
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16) knob.Position = default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255) knob.Parent = track corner(knob, 99)
    local state = default
    local function set(v, silent)
        state = v
        lbl.TextColor3 = state and COLOR_TEXT or COLOR_SUBTEXT
        tween(track, TweenInfo.new(0.2), {BackgroundColor3 = state and ACCENT or Color3.fromRGB(30, 30, 44)})
        tween(knob, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)})
        if not silent then pcall(callback, state) end
    end
    if key then toggleStates[key] = {Set = function(v) set(v) end, Get = function() return state end} end
    row.MouseButton1Click:Connect(function() set(not state) end)
    if default then pcall(callback, true) end
    return {Set = set}
end

local function createSlider(parent, titlePrefix, defaultVal, minVal, maxVal, callback)
    local box = Instance.new("Frame")
    box.Size = UDim2.new(1, 0, 0, 46) box.BackgroundTransparency = 1 box.Parent = parent
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 18) label.BackgroundTransparency = 1
    label.Font = FONT_MAIN label.TextSize = 12 label.TextColor3 = COLOR_SUBTEXT
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = titlePrefix .. ":  " .. tostring(defaultVal) label.Parent = box
    local valBadge = Instance.new("TextLabel")
    valBadge.Size = UDim2.new(0, 52, 0, 18) valBadge.Position = UDim2.new(1, -52, 0, 0)
    valBadge.BackgroundColor3 = COLOR_CARD2 valBadge.Font = FONT_BOLD valBadge.TextSize = 11
    valBadge.TextColor3 = ACCENT valBadge.Text = tostring(defaultVal) valBadge.Parent = box corner(valBadge, 6)
    local bar = Instance.new("TextButton")
    bar.Size = UDim2.new(1, 0, 0, 8) bar.Position = UDim2.new(0, 0, 0, 28)
    bar.BackgroundColor3 = Color3.fromRGB(28, 28, 42) bar.Text = "" bar.AutoButtonColor = false bar.Parent = box corner(bar, 99)
    local fill = Instance.new("Frame")
    local p0 = (defaultVal - minVal) / math.max(1, (maxVal - minVal))
    fill.Size = UDim2.new(p0, 0, 1, 0) fill.BackgroundColor3 = ACCENT fill.Parent = bar corner(fill, 99)
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14) knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(p0, 0, 0.5, 0) knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255) knob.Parent = bar corner(knob, 99)
    local dragging = false
    local function apply(xPos)
        local bp, bs = bar.AbsolutePosition.X, math.max(1, bar.AbsoluteSize.X)
        local c = math.clamp((xPos - bp) / bs, 0, 1)
        local val = math.floor(minVal + c * (maxVal - minVal))
        fill.Size = UDim2.new(c, 0, 1, 0) knob.Position = UDim2.new(c, 0, 0.5, 0)
        label.Text = titlePrefix .. ":  " .. tostring(val) valBadge.Text = tostring(val)
        pcall(callback, val)
    end
    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true apply(i.Position.X)
        end
    end)
    SCONN(UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end))
    SCONN(UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then apply(i.Position.X) end
    end))
end

local function createDropdown(parent, title, list, default, callback)
    local idx = 1
    for i, v in ipairs(list) do if v == default then idx = i break end end
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 32) row.BackgroundTransparency = 1 row.Parent = parent
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 170, 1, 0) lbl.BackgroundTransparency = 1
    lbl.Font = FONT_MAIN lbl.TextSize = 12 lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = COLOR_SUBTEXT lbl.Text = title lbl.Parent = row
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 170, 0, 28) b.Position = UDim2.new(1, -170, 0.5, -14)
    b.BackgroundColor3 = COLOR_CARD2 b.Font = FONT_BOLD b.TextSize = 11
    b.TextColor3 = ACCENT b.Text = list[idx] b.Parent = row corner(b, 7)
    stroke(b, Color3.fromRGB(45, 45, 65), 1)
    pcall(callback, list[idx])
    b.MouseButton1Click:Connect(function()
        idx = idx + 1 if idx > #list then idx = 1 end
        b.Text = list[idx] pcall(callback, list[idx])
    end)
    return b
end

local function createButton(parent, text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 34) b.Font = FONT_BOLD b.TextSize = 12
    b.TextColor3 = COLOR_TEXT b.BackgroundColor3 = COLOR_CARD2
    b.Text = text b.Parent = parent corner(b, 8)
    stroke(b, Color3.fromRGB(40, 40, 60), 1)
    b.MouseButton1Click:Connect(function() pcall(callback) end)
    return b
end

--// Sigilo (silent aim por hook al remote Fire, solo Real). FOV propio.
local silentHooked = false
local fireRemoteCached = nil
local function getFireRemote()
    if fireRemoteCached and fireRemoteCached.Parent then return fireRemoteCached end
    local ok, r = pcall(function()
        return game:GetService("ReplicatedStorage"):WaitForChild("Modules", 5)
            :WaitForChild("GunFramework", 5):WaitForChild("Remotes", 5):WaitForChild("Fire", 5)
    end)
    if ok and r then fireRemoteCached = r return r end
    return nil
end
local function pickSilentTarget()
    if dead then return nil end
    if math.random(100) > (settings.silentHitChance or 100) then return nil end
    local lr = myRoot()
    if not lr then return nil end
    local ml = nil
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        local vs = camera.ViewportSize
        ml = Vector2.new(vs.X / 2, vs.Y / 2)
    else
        ml = UserInputService:GetMouseLocation()
    end
    local best, bestD = nil, settings.silentFov or 200
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localPlayer and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local tp = p.Character:FindFirstChild(settings.targetPart)
                    or p.Character:FindFirstChild("Head")
                if tp then
                    local dp = (lr.Position - tp.Position).Magnitude
                    if dp >= 4 and dp <= (settings.aimMaxDistance or 500) then
                        local sp, on = camera:WorldToViewportPoint(tp.Position)
                        if on then
                            local d = (Vector2.new(sp.X, sp.Y) - ml).Magnitude
                            if d <= (settings.silentFov or 200) and d < bestD then
                                bestD = d best = tp
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end
local function setSilentHook(on)
    if on == silentHooked then return end
    if on then
        local fr = getFireRemote()
        if not fr or type(hookmetamethod) ~= "function" then return end
        local hookFn = function(self, ...)
            if not dead and settings.silentEnabled and self == fr and getnamecallmethod() == "FireServer" then
                local okP, tgt = pcall(pickSilentTarget)
                if okP and tgt and tgt.Parent then
                    local args = {...}
                    if typeof(args[2]) == "Vector3" and typeof(args[3]) == "Vector3" then
                        local org = args[2]
                        local aim = tgt.Position + (tgt.Velocity * (settings.magicPrediction or 0.12))
                        if (aim - org).Magnitude > 0.5 then
                            return _G.__SL_SILOLD(self, args[1], org, (aim - org).Unit)
                        end
                    end
                end
            end
            return _G.__SL_SILOLD(self, ...)
        end
        if type(newcclosure) == "function" then
            local okC, cc = pcall(newcclosure, hookFn)
            if okC then hookFn = cc end
        end
        local okH, old = pcall(hookmetamethod, game, "__namecall", hookFn)
        if okH and old then
            _G.__SL_SILOLD = old
            silentHooked = true
        end
    else
        if _G.__SL_SILOLD then
            pcall(hookmetamethod, game, "__namecall", _G.__SL_SILOLD)
            _G.__SL_SILOLD = nil
        end
        silentHooked = false
    end
end

--// Contenido
local c1 = createCard("Asistencia")
createToggle(c1, "Asistencia", function(v) settings.aimEnabled = v end, "aim")
createToggle(c1, "Auto", function(v) settings.aimAuto = v end)
createToggle(c1, "Fijar blanco", function(v) settings.stickyTarget = v end, nil, true)
createDropdown(c1, "Punto", {"Head", "HumanoidRootPart", "UpperTorso"}, "Head", function(v) settings.targetPart = v end)
createSlider(c1, "Vista", settings.fovRadius, 40, 400, function(v) settings.fovRadius = v end)
createSlider(c1, "Suave", settings.smoothing, 1, 100, function(v) settings.smoothing = v end)
createSlider(c1, "Margen", settings.aimDeadzone, 0, 30, function(v) settings.aimDeadzone = v end)
createSlider(c1, "Alcance", settings.aimMaxDistance, 50, 2000, function(v) settings.aimMaxDistance = v end)
createToggle(c1, "Ver círculo", function(v) settings.showFov = v end, nil, true)
createToggle(c1, "Balas curvas", function(v) settings.magicEnabled = v end)
createSlider(c1, "Predicción", 12, 0, 50, function(v) settings.magicPrediction = v / 100 end)
local tSilent
tSilent = createToggle(c1, "Sigilo", function(v)
    settings.silentEnabled = v
    setSilentHook(v)
    if v and not silentHooked then
        settings.silentEnabled = false
        tSilent.Set(false)
    end
end)
createSlider(c1, "FOV Sigilo", settings.silentFov, 40, 500, function(v) settings.silentFov = v end)
createSlider(c1, "Chance", settings.silentHitChance, 0, 100, function(v) settings.silentHitChance = v end)

local c2 = createCard("Radar")
createToggle(c2, "Radar", function(v) settings.espEnabled = v end, "esp")
createToggle(c2, "Nombres", function(v) settings.espNames = v end, nil, true)
createToggle(c2, "Distancia", function(v) settings.espDistance = v end, nil, true)
createToggle(c2, "Vida", function(v) settings.espHealthBar = v end, nil, true)
createToggle(c2, "Caja", function(v) settings.espBox = v end, nil, true)
createToggle(c2, "Líneas", function(v) settings.espTracer = v end, nil, true)
createToggle(c2, "Esqueleto", function(v) settings.skeleton = v end, nil, true)
createToggle(c2, "Arma equipada", function(v) settings.espTool = v end)
createToggle(c2, "Pintar cuerpo", function(v) settings.espPaint = v end)
createDropdown(c2, "Origen", {"Bottom", "Center"}, "Bottom", function(v) settings.tracerOrigin = v end)
createSlider(c2, "Lejos", settings.maxDistance, 100, 5000, function(v) settings.maxDistance = v end)

local c3 = createCard("Ajustes")
createDropdown(c3, "Tecla menú", {"RightShift", "Insert", "P", "L"}, "RightShift", function(v)
    settings.uiToggleKey = Enum.KeyCode[v]
end)
createButton(c3, "Quitar menú", function()
    if _G.__SL_STOP then pcall(_G.__SL_STOP) end
    pcall(function() gui:Destroy() end)
end)

--// FOV + estados
local fovFrame = Instance.new("Frame")
fovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
fovFrame.BackgroundTransparency = 1 fovFrame.Visible = false fovFrame.Parent = gui
local fovStroke = stroke(fovFrame, ACCENT, 1.6)
corner(fovFrame, 999)
local silFov = Instance.new("Frame")
silFov.AnchorPoint = Vector2.new(0.5, 0.5)
silFov.BackgroundTransparency = 1 silFov.Visible = false silFov.Parent = gui
local silStroke = stroke(silFov, Color3.fromRGB(255, 255, 255), 1)
silStroke.Transparency = 0.4
corner(silFov, 999)
local aimStatus = Instance.new("TextLabel")
aimStatus.Size = UDim2.new(0, 340, 0, 18) aimStatus.Position = UDim2.new(0, 10, 0, 10)
aimStatus.BackgroundTransparency = 1 aimStatus.Font = FONT_MAIN aimStatus.TextSize = 12
aimStatus.TextColor3 = COLOR_SUBTEXT aimStatus.TextStrokeTransparency = 0.5
aimStatus.Text = "" aimStatus.Parent = gui
local espStatus = Instance.new("TextLabel")
espStatus.Size = UDim2.new(0, 380, 0, 18) espStatus.Position = UDim2.new(0, 10, 0, 30)
espStatus.BackgroundTransparency = 1 espStatus.Font = FONT_MAIN espStatus.TextSize = 11
espStatus.TextColor3 = COLOR_SUBTEXT espStatus.TextStrokeTransparency = 0.5
espStatus.Text = "" espStatus.Parent = gui

--// Botón flotante + aim táctil
local floatBtn = Instance.new("TextButton")
floatBtn.Size = UDim2.new(0, 84, 0, 40) floatBtn.Position = UDim2.new(0, 30, 0, 120)
floatBtn.BackgroundColor3 = COLOR_CARD floatBtn.Font = FONT_TITLE floatBtn.TextSize = 14
floatBtn.TextColor3 = Color3.fromRGB(255, 255, 255) floatBtn.Text = "SL" floatBtn.Parent = gui corner(floatBtn, 12)
floatBtn.MouseButton1Click:Connect(function() mainFrame.Visible = not mainFrame.Visible end)
local isTouch = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local aimBtn = Instance.new("TextButton")
aimBtn.Size = UDim2.new(0, 64, 0, 64) aimBtn.Position = UDim2.new(1, -90, 0.5, -32)
aimBtn.BackgroundColor3 = COLOR_CARD aimBtn.Font = FONT_BOLD aimBtn.TextSize = 13
aimBtn.TextColor3 = ACCENT aimBtn.Text = "FIJ" aimBtn.Visible = false aimBtn.Parent = gui
corner(aimBtn, 999) stroke(aimBtn, ACCENT, 2)
local aimingMobile = false
aimBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
        aimingMobile = true aimBtn.BackgroundColor3 = ACCENT aimBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    end
end)
aimBtn.InputEnded:Connect(function()
    aimingMobile = false aimBtn.BackgroundColor3 = COLOR_CARD aimBtn.TextColor3 = ACCENT
end)

SCONN(UserInputService.InputBegan:Connect(function(inp, gp)
    if dead then return end
    if inp.UserInputType == Enum.UserInputType.MouseButton2 then _G.__SL_AIMPC = true end
    if gp then return end
    if inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode == settings.uiToggleKey then
        mainFrame.Visible = not mainFrame.Visible
    end
end))
SCONN(UserInputService.InputEnded:Connect(function(inp)
    if dead then return end
    if inp.UserInputType == Enum.UserInputType.MouseButton2 then _G.__SL_AIMPC = false end
end))

--// ESP (nombres + caja + líneas + esqueleto)
local espData = {}
local espCharOf = {}
local function safeDestroy(inst)
    pcall(function()
        if inst and typeof(inst) == "Instance" then
            local cn = inst.ClassName
            if cn == "Model" or cn == "Humanoid" or cn == "HumanoidRootPart" then return end
            if Players:GetPlayerFromCharacter(inst) then return end
            inst:Destroy()
        end
    end)
end
local function clearESP(key)
    local o = espData[key]
    if o then
        safeDestroy(o.bb) safeDestroy(o.line) safeDestroy(o.box) safeDestroy(o.hl)
        if o.sk then for _, f in ipairs(o.sk) do safeDestroy(f) end end
        if o.skj then for _, f in ipairs(o.skj) do safeDestroy(f) end end
        espData[key] = nil
    end
end
local SK_R15 = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "UpperArmLeft"}, {"UpperArmLeft", "LowerArmLeft"}, {"LowerArmLeft", "HandLeft"},
    {"UpperTorso", "UpperArmRight"}, {"UpperArmRight", "LowerArmRight"}, {"LowerArmRight", "HandRight"},
    {"LowerTorso", "UpperLegLeft"}, {"UpperLegLeft", "LowerLegLeft"}, {"LowerLegLeft", "FootLeft"},
    {"LowerTorso", "UpperLegRight"}, {"UpperLegRight", "LowerLegRight"}, {"LowerLegRight", "FootRight"},
}
local SK_R6 = {
    {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"},
}
local function skSeg(objs, i)
    local f = objs.sk[i]
    if not f then
        f = Instance.new("Frame")
        f.AnchorPoint = Vector2.new(0.5, 0.5) f.BorderSizePixel = 0
        f.BackgroundColor3 = ACCENT f.Visible = false f.Parent = gui
        objs.sk[i] = f
    end
    return f
end
local function drawSeg(f, ax, ay, bx, by, col)
    local dx, dy = bx - ax, by - ay
    local len = math.sqrt(dx * dx + dy * dy)
    if len < 1 then f.Visible = false return end
    f.Size = UDim2.new(0, 1, 0, len)
    f.Position = UDim2.new(0, (ax + bx) / 2, 0, (ay + by) / 2)
    f.Rotation = math.deg(math.atan2(dy, dx)) - 90
    f.BackgroundColor3 = col f.BackgroundTransparency = 0.1 f.Visible = true
end
local function skDot(objs, i)
    objs.skj = objs.skj or {}
    local f = objs.skj[i]
    if not f then
        f = Instance.new("Frame")
        f.AnchorPoint = Vector2.new(0.5, 0.5) f.BorderSizePixel = 0
        f.Size = UDim2.new(0, 3, 0, 3)
        f.BackgroundColor3 = ACCENT f.Visible = false f.Parent = gui
        corner(f, 999)
        objs.skj[i] = f
    end
    return f
end
local function hideSk(objs)
    if objs.sk then for _, f in ipairs(objs.sk) do f.Visible = false end end
    if objs.skj then for _, f in ipairs(objs.skj) do f.Visible = false end end
end
local function buildESP(key, char)
    clearESP(key)
    local objs = {}
    objs.sk = {} objs.skj = {}
    -- pintura del cuerpo (Highlight sutil, anti-fugas con atributo)
    local hl = Instance.new("Highlight")
    hl.FillTransparency = 0.75 hl.OutlineTransparency = 0
    hl.FillColor = ACCENT hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl:SetAttribute("SL1", true)
    hl.Adornee = char hl.Parent = char objs.hl = hl
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, 170, 0, 40) bb.StudsOffset = Vector3.new(0, 2.8, 0) bb.AlwaysOnTop = true
    bb:SetAttribute("SL1", true)
    bb.Adornee = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    bb.Parent = char
    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, 0, 0, 16) name.BackgroundTransparency = 1
    name.Font = FONT_BOLD name.TextSize = 12 name.TextColor3 = Color3.fromRGB(255, 255, 255)
    name.TextStrokeTransparency = 0.4 name.Parent = bb objs.name = name
    local hpBg = Instance.new("Frame")
    hpBg.Size = UDim2.new(1, -40, 0, 5) hpBg.Position = UDim2.new(0, 20, 0, 20)
    hpBg.BackgroundColor3 = Color3.fromRGB(25, 25, 35) hpBg.Parent = bb corner(hpBg, 99) objs.hpBg = hpBg
    local hpFill = Instance.new("Frame")
    hpFill.Size = UDim2.new(1, 0, 1, 0) hpFill.Parent = hpBg corner(hpFill, 99) objs.hpFill = hpFill
    objs.bb = bb
    espCharOf[key] = char
    local line = Instance.new("Frame")
    line.AnchorPoint = Vector2.new(0.5, 0.5) line.BorderSizePixel = 0 line.Visible = false line.Parent = gui objs.line = line
    local box = Instance.new("Frame")
    box.BackgroundTransparency = 1 box.Visible = false box.Parent = gui objs.box = box
    local bs = stroke(box, ACCENT, 1.2) objs.boxStroke = bs
    espData[key] = objs
end
local espErr = nil
local function updateESP(plr)
    local char = plr.Character
    if not char or not char.Parent then clearESP(plr) return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not settings.espEnabled or not root then clearESP(plr) return end
    local objs = espData[plr]
    if not objs or espCharOf[plr] ~= char then buildESP(plr, char) objs = espData[plr] if not objs then return end end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local lr = myRoot()
    if not lr then return end
    local dist = math.floor((lr.Position - root.Position).Magnitude)
    local alive = hum ~= nil and hum.Health > 0
    if dist < 4 or dist > settings.maxDistance or not alive then
        objs.bb.Enabled = false objs.line.Visible = false objs.box.Visible = false
        if objs.hl then objs.hl.Enabled = false end
        hideSk(objs)
        return
    end
    local col = ACCENT
    objs.bb.Enabled = true
    -- pintura del cuerpo
    if objs.hl then
        objs.hl.Enabled = settings.espPaint
        if settings.espPaint then
            objs.hl.FillColor = col
            objs.hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        end
    end
    -- arma equipada
    local tool = char:FindFirstChildOfClass("Tool")
    local txt = ""
    if settings.espNames then txt = plr.DisplayName .. " " end
    if settings.espDistance then txt = txt .. "[" .. dist .. "m]" end
    if settings.espTool then
        txt = txt .. (tool and (" | 🔫 " .. tool.Name) or "")
    end
    objs.name.Text = txt ~= "" and txt or plr.Name
    objs.name.Visible = (settings.espNames or settings.espDistance)
    objs.name.TextColor3 = col
    objs.hpBg.Visible = settings.espHealthBar and hum ~= nil
    if hum and settings.espHealthBar then
        local pct = math.clamp(hum.Health / math.max(1, hum.MaxHealth), 0, 1)
        objs.hpFill.Size = UDim2.new(pct, 0, 1, 0)
        objs.hpFill.BackgroundColor3 = Color3.fromHSV(pct * 0.33, 1, 1)
    end
    if settings.espTracer then
        local sp, on = camera:WorldToViewportPoint(root.Position)
        if on then
            local vs = camera.ViewportSize local startV
            if settings.tracerOrigin == "Center" then startV = Vector2.new(vs.X / 2, vs.Y / 2)
            else startV = Vector2.new(vs.X / 2, vs.Y) end
            local endV = Vector2.new(sp.X, sp.Y)
            local d = (endV - startV).Magnitude
            objs.line.Size = UDim2.new(0, 1.25, 0, d)
            objs.line.Position = UDim2.new(0, (startV.X + endV.X) / 2, 0, (startV.Y + endV.Y) / 2)
            objs.line.Rotation = math.deg(math.atan2(endV.Y - startV.Y, endV.X - startV.X)) - 90
            objs.line.BackgroundColor3 = col objs.line.Visible = true
        else objs.line.Visible = false end
    else objs.line.Visible = false end
    if settings.espBox then
        local head = char:FindFirstChild("Head")
        local _, on = camera:WorldToViewportPoint(root.Position)
        if on then
            local top3d = head and (head.Position + Vector3.new(0, 0.6, 0)) or (root.Position + Vector3.new(0, 2.5, 0))
            local hp = camera:WorldToViewportPoint(top3d)
            local lp = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
            local h = math.abs(hp.Y - lp.Y) local w = h * 0.62
            if h > 4 then
                objs.box.Size = UDim2.new(0, w, 0, h)
                objs.box.Position = UDim2.new(0, hp.X - w / 2, 0, hp.Y)
                objs.box.Visible = true objs.boxStroke.Color = col
            else objs.box.Visible = false end
        else objs.box.Visible = false end
    else objs.box.Visible = false end
    if settings.skeleton then
        local pm = {}
        for _, c in ipairs(char:GetDescendants()) do
            if c:IsA("BasePart") and pm[c.Name] == nil then pm[c.Name] = c end
        end
        local segs, dots = {}, {}
        local function dotP(p)
            for _, q in ipairs(dots) do
                if (q - p).Magnitude < 0.05 then return end
            end
            if #dots < 16 then dots[#dots + 1] = p end
        end
        if pm["UpperTorso"] then
            for _, s in ipairs(SK_R15) do
                local a, b = pm[s[1]], pm[s[2]]
                if a and b then
                    segs[#segs + 1] = {a.Position, b.Position}
                    dotP(a.Position) dotP(b.Position)
                end
            end
        else
            local torso, head = pm["Torso"], pm["Head"]
            if torso then
                local cf = torso.CFrame
                local up, rt = cf.UpVector, cf.RightVector
                local sx, sy = torso.Size.X / 2, torso.Size.Y / 2
                local neck = torso.Position + up * sy
                local hipC = torso.Position - up * sy
                local shL = torso.Position - rt * sx + up * (sy * 0.6)
                local shR = torso.Position + rt * sx + up * (sy * 0.6)
                if head then segs[#segs + 1] = {head.Position, neck} dotP(head.Position) end
                dotP(neck) dotP(hipC) dotP(shL) dotP(shR)
                local limbs = {{"Left Arm", shL}, {"Right Arm", shR}, {"Left Leg", hipC}, {"Right Leg", hipC}}
                for _, L in ipairs(limbs) do
                    local p = pm[L[1]]
                    if p then segs[#segs + 1] = {L[2], p.Position} dotP(p.Position) end
                end
            elseif head then
                dotP(head.Position)
            end
        end
        local si = 0
        for _, s in ipairs(segs) do
            local sa, ona = camera:WorldToViewportPoint(s[1])
            local sb, onb = camera:WorldToViewportPoint(s[2])
            si = si + 1
            local f = skSeg(objs, si)
            if ona and onb then drawSeg(f, sa.X, sa.Y, sb.X, sb.Y, col)
            else f.Visible = false end
        end
        for i = si + 1, #objs.sk do objs.sk[i].Visible = false end
        local di = 0
        for _, p in ipairs(dots) do
            local sp, on = camera:WorldToViewportPoint(p)
            di = di + 1
            local d = skDot(objs, di)
            if on then
                d.Position = UDim2.new(0, sp.X, 0, sp.Y)
                d.BackgroundColor3 = col d.Visible = true
            else d.Visible = false end
        end
        for i = di + 1, #(objs.skj or {}) do objs.skj[i].Visible = false end
    else hideSk(objs) end
end
SCONN(Players.PlayerRemoving:Connect(function(plr)
    if not dead then clearESP(plr) espCharOf[plr] = nil end
end))

--// Loop principal
local espFrame = 0
local espDiagLast = 0
SCONN(RunService.RenderStepped:Connect(function(dt)
    if dead then return end
    local freshCam = workspace.CurrentCamera
    if freshCam then camera = freshCam end
    if not camera then return end
    local okLoop, errLoop = pcall(function()
        local ml = nil
        if isTouch then
            local vs = camera.ViewportSize
            ml = Vector2.new(vs.X / 2, vs.Y / 2)
        else
            ml = UserInputService:GetMouseLocation()
        end
        local wantFov = settings.aimEnabled and settings.showFov
        fovFrame.Visible = wantFov
        aimBtn.Visible = settings.aimEnabled and isTouch
        if wantFov then
            fovFrame.Position = UDim2.new(0, ml.X, 0, ml.Y)
            fovFrame.Size = UDim2.new(0, settings.fovRadius * 2, 0, settings.fovRadius * 2)
            fovStroke.Thickness = 1.6
        end
        local wantSil = settings.silentEnabled
        silFov.Visible = wantSil
        if wantSil then
            silFov.Position = UDim2.new(0, ml.X, 0, ml.Y)
            silFov.Size = UDim2.new(0, settings.silentFov * 2, 0, settings.silentFov * 2)
        end
        espFrame = espFrame + 1
        if settings.espEnabled then
            for i, p in ipairs(Players:GetPlayers()) do
                if p ~= localPlayer and (i + espFrame) % 2 == 0 then
                    local okE, errE = pcall(updateESP, p)
                    if not okE and not espErr then espErr = errE end
                end
            end
            local nowE = tick()
            if nowE - espDiagLast > 0.5 then
                espDiagLast = nowE
                if espErr then
                    espStatus.Text = "Radar err: " .. tostring(espErr):sub(1, 90)
                    espStatus.TextColor3 = Color3.fromRGB(255, 110, 120)
                    espErr = nil
                else
                    local nNear, nTot = 0, 0
                    local lrE = myRoot()
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= localPlayer and p.Character then
                            nTot = nTot + 1
                            local rt = p.Character:FindFirstChild("HumanoidRootPart")
                            if rt and lrE and (lrE.Position - rt.Position).Magnitude <= settings.maxDistance then
                                nNear = nNear + 1
                            end
                        end
                    end
                    espStatus.Text = string.format("Radar: %d/%d", nNear, nTot)
                    espStatus.TextColor3 = (nNear > 0) and Color3.fromRGB(80, 255, 130) or Color3.fromRGB(255, 200, 80)
                end
            end
        else
            espStatus.Text = ""
            for k, _ in pairs(espData) do clearESP(k) end
        end
        do
            local aiming = (_G.__SL_AIMPC or aimingMobile) or settings.aimAuto
            if not settings.aimEnabled then
                aimStatus.Text = ""
                stickyPart, stickyModel, stickyName = nil, nil, ""
            elseif not aiming then
                aimStatus.Text = "Listo - mantén click derecho"
                aimStatus.TextColor3 = COLOR_SUBTEXT
                stickyPart, stickyModel, stickyName = nil, nil, ""
            else
                local lr2 = myRoot()
                local bestPart, bestD, bestName = nil, settings.fovRadius, ""
                local bestModel = nil
                local cAlive, cScreen = 0, 0
                local camP = camera.CFrame.Position
                local function consider(model, label)
                    if not model or not model.Parent then return end
                    local humanoid = model:FindFirstChildOfClass("Humanoid")
                    if not (humanoid and humanoid.Health > 0) then return end
                    cAlive = cAlive + 1
                    local tp = model:FindFirstChild(settings.targetPart)
                        or model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
                    if not tp then return end
                    local dp = (lr2.Position - tp.Position).Magnitude
                    if not lr2 or dp < 4 or dp > settings.aimMaxDistance then return end
                    local sp, on = camera:WorldToViewportPoint(tp.Position)
                    if not on then return end
                    cScreen = cScreen + 1
                    local d = (Vector2.new(sp.X, sp.Y) - ml).Magnitude
                    if d <= settings.fovRadius and d < bestD then
                        bestD = d bestPart = tp bestName = label bestModel = model
                    end
                end
                if lr2 and localPlayer.Character then
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= localPlayer and player.Character then
                            consider(player.Character, player.DisplayName)
                        end
                    end
                end
                if settings.stickyTarget and stickyPart and stickyPart.Parent and lr2 then
                    local sAlive = true
                    if stickyModel then
                        if stickyModel.Parent == nil then sAlive = false end
                        local sh = stickyModel:FindFirstChildOfClass("Humanoid")
                        if sh and sh.Health <= 0 then sAlive = false end
                    end
                    if sAlive then
                        local ssp, son = camera:WorldToViewportPoint(stickyPart.Position)
                        if son then
                            local sd = (Vector2.new(ssp.X, ssp.Y) - ml).Magnitude
                            local sdist = (lr2.Position - stickyPart.Position).Magnitude
                            -- sticky fuerte: solo suelta si el blanco salio de pantalla,
                            -- murio, o se paso MUY lejos del alcance
                            if sdist <= (settings.aimMaxDistance or 500) * 2 then
                                bestPart = stickyPart
                                bestD = sd
                                bestName = stickyName
                            else
                                stickyPart, stickyModel, stickyName = nil, nil, ""
                            end
                        else
                            stickyPart, stickyModel, stickyName = nil, nil, ""
                        end
                    else
                        stickyPart, stickyModel, stickyName = nil, nil, ""
                    end
                end
                if bestPart then
                    local isSticky = (stickyPart == bestPart)
                    stickyPart, stickyModel, stickyName = bestPart, bestModel, bestName
                    lastAimPart = bestPart
                    aimStatus.Text = (isSticky and "🔒 " or "● ") .. tostring(bestName)
                    aimStatus.TextColor3 = Color3.fromRGB(80, 255, 130)
                    if bestD > (settings.aimDeadzone or 0) then
                        local alpha = math.clamp(settings.smoothing / 100, 0.05, 1)
                        pcall(function()
                            camera.CFrame = camera.CFrame:Lerp(
                                CFrame.new(camera.CFrame.Position, bestPart.Position), alpha)
                        end)
                    end
                else
                    aimStatus.Text = string.format("● 0 (%d vivos %d pant)", cAlive, cScreen)
                    aimStatus.TextColor3 = Color3.fromRGB(255, 200, 80)
                    lastAimPart = nil
                end
            end
        end
    end)
    if not okLoop then
    end
end))

--// Balas curvas: tus proyectiles doblan hacia el objetivo del aimbot.
local trackedBullets = {}
SCONN(workspace.DescendantAdded:Connect(function(inst)
    if dead then return end
    if not settings.magicEnabled then return end
    if not inst or not inst:IsA("BasePart") then return end
    if inst.Anchored then return end
    local mr = myRoot()
    if not mr then return end
    local model = inst:FindFirstAncestorOfClass("Model")
    if model and (Players:GetPlayerFromCharacter(model) or model == localPlayer.Character) then return end
    local off = inst.Position - mr.Position
    if off.Magnitude < 1 or off.Magnitude > 25 then return end
    local vel = inst.AssemblyLinearVelocity
    if vel.Magnitude < 20 then return end
    if vel.Unit:Dot(off.Unit) < 0.2 then return end
    local count = 0
    for _ in pairs(trackedBullets) do count = count + 1 end
    if count >= 40 then return end
    local tgt = lastAimPart
    local realTgt = (tgt and tgt.Parent) and tgt or nil
    trackedBullets[inst] = {t0 = tick(), target = realTgt}
end))
SCONN(RunService.Heartbeat:Connect(function()
    if dead then return end
    if not settings.magicEnabled then return end
    local now = tick()
    for part, info in pairs(trackedBullets) do
        local tgt = info.target
        if (not part) or (not part.Parent) or (now - info.t0) > 3 then
            trackedBullets[part] = nil
        elseif tgt and tgt.Parent then
            local pred = settings.magicPrediction or 0.12
            local aim = tgt.Position + (tgt.Velocity * pred)
            if (aim - part.Position).Magnitude > 4 then
                local sp = part.AssemblyLinearVelocity.Magnitude
                if sp > 5 then
                    part.AssemblyLinearVelocity = (aim - part.Position).Unit * sp
                    pcall(function() part.CFrame = CFrame.new(part.Position, aim) end)
                end
            end
        end
    end
end))

--// Mostrar
mainFrame.Visible = true
