-- SL_RECON2: como disparan las armas. Vivo, con arma en mano. Dispara un poco antes/durante.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer
print("--- arma equipada ---")
local ch = lp.Character
if ch then
    for _, t in ipairs(ch:GetChildren()) do
        if t:IsA("Tool") then
            print("TOOL:", t.Name)
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
print("--- mochila ---")
local bp = lp:FindFirstChild("Backpack")
if bp then
    for _, t in ipairs(bp:GetChildren()) do
        if t:IsA("Tool") then print("TOOL mochila:", t.Name) end
    end
end
print("--- remotes de disparo (scan) ---")
local keys = {"shoot", "fire", "gun", "weapon", "bullet", "damage", "hit", "ray", "projectil", "ammo", "reload", "trigger"}
local n = 0
for _, d in ipairs(game:GetDescendants()) do
    if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
        local nl = d.Name:lower()
        for _, k in ipairs(keys) do
            if nl:find(k, 1, true) then
                n = n + 1
                if n <= 30 then
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
                break
            end
        end
    end
end
print("matches:", n)
print("FIN SL_RECON2")
