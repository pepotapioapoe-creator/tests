-- SL_RECON: estructura de cuerpos en Street Life. Vivo, caminando, con otros cerca.
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
print("jugadores:", #Players:GetPlayers())
local ch = lp.Character
print("mi character:", ch and ch.Name or "NIL")
if ch then
    local hum = ch:FindFirstChildOfClass("Humanoid")
    print("humanoide:", hum and ("SI vida=" .. math.floor(hum.Health) .. " rig=" .. tostring(hum.RigType)) or "NO")
    local parts = {}
    for _, d in ipairs(ch:GetDescendants()) do
        if d:IsA("BasePart") then parts[#parts + 1] = d.Name end
    end
    print("mis piezas (" .. #parts .. "):", table.concat(parts, ",", 1, math.min(20, #parts)))
end
local otro = 0
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= lp and p.Character then
        otro = otro + 1
        if otro == 1 then
            local h2 = p.Character:FindFirstChildOfClass("Humanoid")
            print("otro:", p.Name, "| hum:", h2 and "SI" or "NO")
        end
    end
end
print("otros con character:", otro)
print("FIN SL_RECON")
