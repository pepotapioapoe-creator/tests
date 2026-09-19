-- HOOKTEST: verifica hooks FUNCIONALES del executor. Solo consola, no toca el juego.
local function rep(name, ok, extra)
    print(string.format("[hooktest] %-18s %s %s", name, ok and "PASS" or "FAIL", extra or ""))
end
local function wrap(f)
    if type(newcclosure) == "function" then
        local ok, c = pcall(newcclosure, f)
        if ok then return c end
    end
    return f
end
-- 1. hookfunction: hookear dummy, verificar que pega, restaurar
do
    local ok, msg = false, "no existe"
    if type(hookfunction) == "function" then
        local function dummy() return "orig" end
        local old
        local okH = pcall(function()
            old = hookfunction(dummy, wrap(function() return "hooked" end))
        end)
        if okH and type(old) == "function" then
            local okC, res = pcall(dummy)
            pcall(hookfunction, dummy, old)
            if okC and res == "hooked" then ok, msg = true, "" end
            if not ok then msg = "devolvio: " .. tostring(res) end
        else
            msg = "pcall fallo"
        end
    end
    rep("hookfunction", ok, msg)
end
-- 2. hookmetamethod: hookear __index de game con passthrough, leer PlaceId, restaurar
do
    local ok, msg = false, "no existe"
    if type(hookmetamethod) == "function" then
        local orig
        local okH = pcall(function()
            orig = hookmetamethod(game, "__index", wrap(function(...) return orig(...) end))
        end)
        if okH and orig then
            local okR, pid = pcall(function() return game.PlaceId end)
            local okU = pcall(function() hookmetamethod(game, "__index", orig) end)
            if okR and pid and pid ~= 0 and okU then ok, msg = true, "" end
            if not ok then msg = "passthrough fallo" end
        else
            msg = "pcall fallo"
        end
    end
    rep("hookmetamethod", ok, msg)
end
-- 3. funciones relacionadas (solo existencia + prueba rapida)
do
    rep("newcclosure", type(newcclosure) == "function")
    rep("getrawmetatable", type(getrawmetatable) == "function")
    if type(getrawmetatable) == "function" then
        local ok, mt = pcall(getrawmetatable, game)
        rep("getrawmetatable(game)", ok and type(mt) == "table")
    end
    rep("getnamecallmethod", type(getnamecallmethod) == "function")
    rep("checkcaller", type(checkcaller) == "function")
    rep("restorefunction", type(restorefunction) == "function")
    rep("gethui", type(gethui) == "function")
end
print("[hooktest] FIN")
