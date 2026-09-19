-- WALLSPY: clickea la pared y dice de que esta hecha. Vivo, frente a la pared.
local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local mouse = Players.LocalPlayer:GetMouse()
local last = 0
print("WALLSPY listo: clickea la pared")
mouse.Button1Down:Connect(function()
    if tick() - last < 1 then return end
    last = tick()
    local t = mouse.Target
    if not t then print("click al aire") return end
    local path = t.Name
    local par = t.Parent
    local ups = 0
    while par and par ~= workspace and par ~= game and ups < 8 do
        path = par.Name .. "/" .. path
        par = par.Parent
        ups = ups + 1
    end
    print("--- pared:", t.Name, "|", t.ClassName, "---")
    print("ruta:", path)
    print("CanCollide:", tostring(t.CanCollide), "| CanQuery:", tostring(t.CanQuery),
        "| CanTouch:", tostring(t.CanTouch), "| Anchored:", tostring(t.Anchored))
    local okG, gname = pcall(function() return PhysicsService:GetCollisionGroupName(t.CollisionGroupId) end)
    print("CollisionGroup:", tostring(t.CollisionGroupId), okG and ("=" .. tostring(gname)) or "")
    print("tam:", tostring(t.Size), "| transp:", tostring(t.Transparency), "| material:", tostring(t.Material))
    if t.Parent and t.Parent:IsA("Model") then
        print("modelo padre:", t.Parent.Name, "| hijos:", #t.Parent:GetChildren())
    end
end)
