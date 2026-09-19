-- CLICKCLIP: clickea una estructura y la atraviesas. N = modo click, X = limpiar.
-- Funciona con cualquier estructura (muros, puertas, modelos raros): apaga su colision.
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer
if _G.__NC_STOP then pcall(_G.__NC_STOP) end
local dead = false
_G.__NC_STOP = function() dead = true end
if _G.__NC_CONNS then
    for _, c in ipairs(_G.__NC_CONNS) do pcall(function() c:Disconnect() end) end
end
_G.__NC_CONNS = {}
local function NCONN(c) table.insert(_G.__NC_CONNS, c) return c end

local phased = {}
local phaseMode = false
local wholeModel = true

local gui = Instance.new("ScreenGui")
gui.Name = "nc_" .. tostring(math.random(100000, 999999))
gui:SetAttribute("NC1", true)
gui.ResetOnSpawn = false
gui.Parent = lp:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 180, 0, 118)
panel.Position = UDim2.new(0, 10, 0, 80)
panel.BackgroundColor3 = Color3.fromRGB(13, 13, 22)
panel.Parent = gui
local pc = Instance.new("UICorner") pc.CornerRadius = UDim.new(0, 8) pc.Parent = panel
local pst = Instance.new("UIStroke") pst.Color = Color3.fromRGB(60, 60, 80) pst.Thickness = 1 pst.Parent = panel
local function lbl(txt, y, size)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -16, 0, size or 18) l.Position = UDim2.new(0, 8, 0, y)
    l.BackgroundTransparency = 1 l.Font = Enum.Font.GothamMedium l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left l.TextColor3 = Color3.fromRGB(200, 200, 215)
    l.Text = txt l.Parent = panel
    return l
end
lbl("Atravesar [N]", 6, 18)
local modeBtn = Instance.new("TextButton")
modeBtn.Size = UDim2.new(1, -16, 0, 26) modeBtn.Position = UDim2.new(0, 8, 0, 28)
modeBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 34) modeBtn.Font = Enum.Font.GothamBold
modeBtn.TextSize = 12 modeBtn.TextColor3 = Color3.fromRGB(0, 242, 255)
modeBtn.Text = "Modo: Modelo" modeBtn.Parent = panel
local mc = Instance.new("UICorner") mc.CornerRadius = UDim.new(0, 6) mc.Parent = modeBtn
local countLbl = lbl("Fases: 0 (X limpia)", 58, 18)
local hintLbl = lbl("click en pared", 78, 16)
hintLbl.TextColor3 = Color3.fromRGB(120, 120, 140)

local function refresh()
    local n = 0
    for _ in pairs(phased) do n = n + 1 end
    countLbl.Text = "Fases: " .. n .. " (X limpia)"
    modeBtn.Text = phaseMode and ((wholeModel and "Modelo" or "Pieza") .. " *CLICK*") or ("Modo: " .. (wholeModel and "Modelo" or "Pieza"))
    pst.Color = phaseMode and Color3.fromRGB(0, 242, 255) or Color3.fromRGB(60, 60, 80)
end
modeBtn.MouseButton1Click:Connect(function()
    wholeModel = not wholeModel
    refresh()
end)
local function noCollide(inst)
    pcall(function()
        if inst:IsA("BasePart") then
            inst.CanCollide = false
            inst.CanTouch = false
        elseif inst:IsA("Model") then
            for _, d in ipairs(inst:GetDescendants()) do
                if d:IsA("BasePart") then d.CanCollide = false d.CanTouch = false end
            end
        end
    end)
end
local mouse = lp:GetMouse()
NCONN(mouse.Button1Down:Connect(function()
    if dead or not phaseMode then return end
    local t = mouse.Target
    if not t then return end
    local target = t
    if wholeModel then
        local m = t
        local ups = 0
        while m and not m:IsA("Model") and ups < 6 do m = m.Parent ups = ups + 1 end
        if m and m:IsA("Model") then target = m end
    end
    phased[target] = true
    noCollide(target)
    refresh()
end))
NCONN(UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.N then
        phaseMode = not phaseMode
        refresh()
    elseif inp.KeyCode == Enum.KeyCode.X then
        table.clear(phased)
        refresh()
    end
end))
task.spawn(function()
    while not dead do
        task.wait(0.3)
        for inst, _ in pairs(phased) do
            if inst and inst.Parent then
                noCollide(inst)
            else
                phased[inst] = nil
            end
        end
        refresh()
    end
end)
refresh()
