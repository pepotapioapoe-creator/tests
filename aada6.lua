local vim = game:GetService("VirtualInputManager")
local x, y = 500, 400
for i = 1, 50 do
    x = x + 3
    vim:SendMouseMoveEvent(x, y, game, 0)
    task.wait(0.03)
end
