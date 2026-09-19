-- BLOX_RECON3 (solo executor CON hooks, ej. Real): registra que manda ShootWeapon al disparar.
-- Ejecutar vivo con arma, disparar varias veces al aire y a alguien, pasar la salida.
-- No modifica nada: solo mira y restaura al re-ejecutar.
if _G.__BLOX_OLDNC then
    pcall(function() hookmetamethod(game, "__namecall", _G.__BLOX_OLDNC) end)
    _G.__BLOX_OLDNC = nil
end
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
            if #ks < 8 then ks[#ks + 1] = tostring(k) .. "=" .. short(vv, depth + 1) end
        end
        return "{" .. n .. ": " .. table.concat(ks, ",") .. "}"
    else
        return t
    end
end
local count = 0
local old
old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "FireServer" and typeof(self) == "Instance" and self:IsA("RemoteEvent") then
        local path = self.Name
        local par = self.Parent
        local ups = 0
        while par and par ~= game and ups < 3 do
            path = par.Name .. "/" .. path
            par = par.Parent
            ups = ups + 1
        end
        if path:find("ShootWeapon") or path:find("MeleeAttack") or path:find("ThrowGrenade") then
            count = count + 1
            if count <= 12 then
                local args = {...}
                local parts = {}
                for i, a in ipairs(args) do
                    parts[#parts + 1] = "[" .. i .. "]" .. short(a)
                end
                print(string.format("[shootlog %d] %s nargs=%d :: %s", count, path, #args, table.concat(parts, " ")))
            end
        end
    end
    return old(self, ...)
end))
_G.__BLOX_OLDNC = old
print("[shootlog] listo: dispara varias veces y pasa la salida")
