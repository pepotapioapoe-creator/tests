- BLOX_RECON3 v2 (solo Real): registra ShootWeapon. NO toca movimiento ni nada mas.
-- Primero REENTRA al juego (para sacar el hook anterior y recuperar movimiento).
-- Vivo, con arma, disparar y pasar lineas [shootlog].
local RS = game:GetService("ReplicatedStorage")
if _G.__BLOX_OLDNC then
    pcall(function() hookmetamethod(game, "__namecall", _G.__BLOX_OLDNC) end)
    _G.__BLOX_OLDNC = nil
end
local inv = RS:WaitForChild("NetworkRemotes", 10):WaitForChild("Inventory", 10)
local shootRemote = inv and inv:WaitForChild("ShootWeapon", 10)
local meleeRemote = inv and inv:FindFirstChild("MeleeAttack")
if not shootRemote then
    print("[shootlog] no se encontro ShootWeapon")
    return
end
print("[shootlog] enganchado a ShootWeapon, dispara y pasa la salida")
local function short(v, depth)
    depth = depth or 0
    local t = typeof(v)
    if t == "Vector3" then
        return string.format("V3(%.1f,%.1f,%.1f)", v.X, v.Y, v.Z)
    elseif t == "CFrame" then
        local p = v.Position
        return string.format("CF(%.1f,%.1f,%.1f)", p.X, p.Y, p.Z)
    elseif t == "Instance" then
        return v.ClassName .. ":" .. v.Name
    elseif t == "number" then
        return string.format("%.3f", v)
    elseif t == "string" then
        return string.format("%q", tostring(v):sub(1, 60))
    elseif t == "boolean" then
        return tostring(v)
    elseif t == "table" then
        if depth > 0 then return "{...}" end
        local n, ks = 0, {}
        for k, vv in pairs(v) do
            n = n + 1
            if #ks < 10 then ks[#ks + 1] = tostring(k) .. "=" .. short(vv, depth + 1) end
        end
        return "{" .. n .. ": " .. table.concat(ks, ",") .. "}"
    else
        return t
    end
end
local count = 0
local old
old = hookmetamethod(game, "__namecall", function(self, ...)
    if self == shootRemote or self == meleeRemote then
        local method = getnamecallmethod()
        if method == "FireServer" then
            count = count + 1
            if count <= 12 then
                local args = {...}
                local parts = {}
                for i, a in ipairs(args) do
                    parts[#parts + 1] = "[" .. i .. "]" .. short(a)
                end
                print(string.format("[shootlog %d] nargs=%d :: %s", count, #args, table.concat(parts, " ")))
            end
        end
    end
    return old(self, ...)
end)
_G.__BLOX_OLDNC = old

