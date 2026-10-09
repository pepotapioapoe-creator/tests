-- SL_RECON3 (solo Real): formato del remote Fire. Vivo, con arma, disparar mirando variado.
local RS = game:GetService("ReplicatedStorage")
if type(hookmetamethod) ~= "function" or type(getnamecallmethod) ~= "function" then
    print("[firelog] necesita Real (hooks)")
    return
end
if _G.__SL_OLDNC then
    pcall(function() hookmetamethod(game, "__namecall", _G.__SL_OLDNC) end)
    _G.__SL_OLDNC = nil
end
local gf = RS:WaitForChild("Modules", 10):WaitForChild("GunFramework", 10):WaitForChild("Remotes", 10)
local fireRemote = gf and gf:WaitForChild("Fire", 10)
if fireRemote then
print("[firelog] listo: dispara y pasa la salida")
local cam = workspace.CurrentCamera
local count = 0
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
    elseif t == "buffer" then
        return "buffer len=" .. tostring(buffer.len(v))
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
local old
old = hookmetamethod(game, "__namecall", function(self, ...)
    if self == fireRemote and getnamecallmethod() == "FireServer" then
        count = count + 1
        if count <= 10 then
            local args = {...}
            local parts = {}
            for i, a in ipairs(args) do
                parts[#parts + 1] = "[" .. i .. "]" .. short(a)
            end
            local cf = cam and cam.CFrame
            local look = cf and string.format("look(%.2f,%.2f,%.2f)", cf.LookVector.X, cf.LookVector.Y, cf.LookVector.Z) or "?"
            print(string.format("[firelog %d] nargs=%d :: %s | %s", count, #args, table.concat(parts, " "), look))
        end
    end
    return old(self, ...)
end)
_G.__SL_OLDNC = old
else
    print("[firelog] no se encontro Fire")
end
