-- BLOX_RECON: como dispara este juego. Vivo, con arma en mano, cerca de otros.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer
print("jugadores:", #Players:GetPlayers())
local ch = lp.Character
print("mi character:", ch and ch.Name or "NIL")
if ch then
    local hum = ch:FindFirstChildOfClass("Humanoid")
    print("humanoide:", hum and ("SI vida=" .. math.floor(hum.Health)) or "NO")
    local parts = {}
    for _, d in ipairs(ch:GetDescendants()) do
        if d:IsA("BasePart") then parts[#parts + 1] = d.Name end
    end
    print("piezas (" .. #parts .. "):", table.concat(parts, ",", 1, math.min(20, #parts)))
end
print("--- tools (arma en mano + mochila) ---")
local function dumpTools(cont, tag)
    if not cont then return end
    for _, t in ipairs(cont:GetChildren()) do
        if t:IsA("Tool") then
            print("TOOL [" .. tag .. "]:", t.Name)
            for _, v in ipairs(t:GetDescendants()) do
                if v:IsA("ValueBase") then
                    print("  val:", v.Name, "=", tostring(v.Value))
                elseif v:IsA("ModuleScript") then
                    print("  modulo:", v.Name)
                elseif v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                    print("  remote:", v.Name, v.ClassName)
                end
            end
        end
    end
end
dumpTools(ch, "mano")
dumpTools(lp:FindFirstChild("Backpack"), "mochila")
print("--- ReplicatedStorage top ---")
for _, c in ipairs(RS:GetChildren()) do
    print("rs:", c.Name, "|", c.ClassName)
end
print("--- remotes (todos, 40) ---")
local n = 0
for _, d in ipairs(game:GetDescendants()) do
    if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
        n = n + 1
        if n <= 40 then
            local path = d.Name
            local par = d.Parent
            local ups = 0
            while par and par ~= game and ups < 4 do
                path = par.Name .. "/" .. path
                par = par.Parent
                ups = ups + 1
            end
            print(n .. ".", d.ClassName, path)
        end
    end
end
print("FIN BLOX_RECON")
