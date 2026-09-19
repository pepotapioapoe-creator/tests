-- RUSTCLIP: atraviesa TODAS las construcciones de jugadores. N = prender/apagar.
-- Cubre muros, puertas, pisos y lo que construyan despues (re-escanea solo).
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer
if _G.__RC_STOP then pcall(_G.__RC_STOP) end
local dead = false
_G.__RC_STOP = function() dead = true end
if _G.__RC_CONNS then
    for _, c in ipairs(_G.__RC_CONNS) do pcall(function() c:Disconnect() end) end
end
_G.__RC_CONNS = {}
local function RCONN(c) table.insert(_G.__RC_CONNS, c) return c end

local enabled = false
local count = 0
local structRoot = nil

local gui = Instance.new("ScreenGui")
gui.Name = "rc_" .. tostring(math.random(100000, 999999))
gui:SetAttribute("RC1", true)
gui.ResetOnSpawn = false
gui.Parent = lp:WaitForChild("PlayerGui")

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 170, 0, 40) btn.Position = UDim2.new(0, 10, 0, 80)
btn.BackgroundColor3 = Color3.fromRGB(13, 13, 22) btn.Font = Enum.Font.GothamBold
btn.TextSize = 13 btn.TextColor3 = Color3.fromRGB(150, 150, 170)
btn.Text = "Muros: OFF [N]" btn.Parent = gui
local bc = Instance.new("UICorner") bc.CornerRadius = UDim.new(0, 8) bc.Parent = btn
local bs = Instance.new("UIStroke") bs.Color = Color3.fromRGB(60, 60, 80) bs.Thickness = 1 bs.Parent = btn
local info = Instance.new("TextLabel")
info.Size = UDim2.new(0, 170, 0, 18) info.Position = UDim2.new(0, 10, 0, 124)
info.BackgroundTransparency = 1 info.Font = Enum.Font.GothamMedium info.TextSize = 11
info.TextXAlignment = Enum.TextXAlignment.Left info.TextColor3 = Color3.fromRGB(120, 120, 140)
info.Text = "fases: 0" info.Parent = gui

local function refresh()
    btn.Text = enabled and "Muros: ON [N]" or "Muros: OFF [N]"
    btn.TextColor3 = enabled and Color3.fromRGB(0, 242, 255) or Color3.fromRGB(150, 150, 170)
    bs.Color = enabled and Color3.fromRGB(0, 242, 255) or Color3.fromRGB(60, 60, 80)
    info.Text = "fases: " .. count
end
local function phaseAll()
    count = 0
    structRoot = workspace:FindFirstChild("PlayerBuiltStructures")
    if not structRoot then return end
    for _, d in ipairs(structRoot:GetDescendants()) do
        if d:IsA("BasePart") then
            pcall(function()
                d.CanCollide = false
                d.CanTouch = false
            end)
            count = count + 1
        end
    end
end
local function toggle()
    enabled = not enabled
    if enabled then phaseAll() end
    refresh()
end
btn.MouseButton1Click:Connect(toggle)
RCONN(UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.N then toggle() end
end))
RCONN(workspace.DescendantAdded:Connect(function(inst)
    if dead or not enabled then return end
    if not structRoot or not inst:IsDescendantOf(structRoot) then return end
    task.wait(0.2)
    if dead or not enabled then return end
    pcall(function()
        if inst:IsA("BasePart") then
            inst.CanCollide = false
            inst.CanTouch = false
        end
    end)
end))
task.spawn(function()
    while not dead do
        task.wait(0.5)
        if enabled then phaseAll() end
        refresh()
    end
end)
refresh()
