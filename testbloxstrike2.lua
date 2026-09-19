-- BLOX_RECON2: arbol de remotes del juego + modulos de armas. Vivo, con arma en mano.
local RS = game:GetService("ReplicatedStorage")
local function dumpTree(root, path, depth, maxN, counter)
    if depth > 4 or counter.n >= maxN then return end
    local kids = root:GetChildren()
    table.sort(kids, function(a, b) return a.Name < b.Name end)
    for _, c in ipairs(kids) do
        if counter.n >= maxN then return end
        counter.n = counter.n + 1
        print(path .. "/" .. c.Name, "|", c.ClassName)
        if c:IsA("Folder") or c:IsA("Model") then
            dumpTree(c, path .. "/" .. c.Name, depth + 1, maxN, counter)
        end
    end
end
print("=== NetworkRemotes ===")
local nr = RS:FindFirstChild("NetworkRemotes")
if nr then dumpTree(nr, "NetworkRemotes", 0, 120, {n = 0}) else print("NO NetworkRemotes") end
print("=== Remotes ===")
local rr = RS:FindFirstChild("Remotes")
if rr then dumpTree(rr, "Remotes", 0, 120, {n = 0}) else print("NO Remotes") end
print("=== carpetas codigo (top) ===")
for _, fname in ipairs({"Controllers", "Classes", "Shared", "Components", "Scripts"}) do
    local f = RS:FindFirstChild(fname)
    if f then
        local names = {}
        for _, c in ipairs(f:GetChildren()) do names[#names + 1] = c.Name end
        table.sort(names)
        print(fname .. ":", table.concat(names, ", ", 1, math.min(30, #names)))
    end
end
print("FIN BLOX_RECON2")
