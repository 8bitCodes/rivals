local aimbot = {
    Enabled = true, Key = Enum.UserInputType.MouseButton2, Smoothing = 0, Offset = {0, 0},
    TeamCheck = false, AliveCheck = true, VisibilityCheck = false, Players = true,
    PlayerPart = 'Head', FriendlyPlayers = {'name1', 'name2'}, FOV = 200,
    FOVCircleColor = Color3.fromRGB(255, 255, 255), ShowFOV = true,
    CustomParts = {Instance.new('Part', workspace)}
}

local UIS, Players, RS = game:GetService("UserInputService"), game:GetService("Players"), game:GetService("RunService")
local plr, mouse, keypressed = Players.LocalPlayer, Players.LocalPlayer:GetMouse(), false
local fovcircle = Drawing.new("Circle") do fovcircle.Filled, fovcircle.Thickness = false, 1 end

aimbot.GetClosestPart = function()
    local parts, target = {}, nil
    for _, v in ipairs(aimbot.CustomParts) do if v:IsA("BasePart") then table.insert(parts, v) end end
    if aimbot.Players then
        for _, v in ipairs(Players:GetPlayers()) do
            if not table.find(aimbot.FriendlyPlayers, v.Name) and v ~= plr then
                local char, hum = v.Character, v.Character and v.Character:FindFirstChildWhichIsA("Humanoid")
                if aimbot.AliveCheck and (not hum or hum.Health < 1) or aimbot.TeamCheck and v.TeamColor == plr.TeamColor then continue end
                local part = char and char:FindFirstChild(aimbot.PlayerPart)
                if part and aimbot.VisibilityCheck then
                    local params = RaycastParams.new()
                    params.FilterType, params.IgnoreWater, params.FilterDescendantsInstances = Enum.RaycastFilterType.Blacklist, true, {part.Parent, plr.Character}
                    if workspace:Raycast(workspace.CurrentCamera.CFrame.p, part.Position - workspace.Camera.CFrame.p, params) then continue end
                end
                if part then table.insert(parts, part) end
            end
        end
    end
    for _, v in ipairs(parts) do
        local pos, dist = workspace.CurrentCamera:WorldToScreenPoint(v.Position), (Vector2.new(mouse.X, mouse.Y) - Vector2.new(workspace.CurrentCamera:WorldToScreenPoint(v.Position).X, workspace.CurrentCamera:WorldToScreenPoint(v.Position).Y)).Magnitude
        if dist <= aimbot.FOV and pos.Z > 0 and (not target or dist < target.Distance) then target = {Part = v, Position = pos, Distance = dist} end
    end
    return target
end

aimbot.Aim = function(x, y) 
    -- Move the mouse directly to the target position (snappy behavior)
    mousemoverel((x - mouse.X) * 0.2, (y - mouse.Y) * 0.2)  -- Adjust the multiplier for snappiness
end

UIS.InputBegan:Connect(function(input) if input.KeyCode == aimbot.Key or input.UserInputType == aimbot.Key then keypressed = true end end)
UIS.InputEnded:Connect(function(input) if input.KeyCode == aimbot.Key or input.UserInputType == aimbot.Key then keypressed = false end end)

RS.RenderStepped:Connect(function()
    local camFOV = workspace.CurrentCamera.FieldOfView
    local scaleFactor = 70 / camFOV -- Default FOV (70) used as a reference.
    fovcircle.Visible, fovcircle.Color = aimbot.ShowFOV, aimbot.FOVCircleColor
    fovcircle.Radius = aimbot.FOV * scaleFactor
    fovcircle.Position = Vector2.new(mouse.X + aimbot.Offset[1], mouse.Y + 35 + aimbot.Offset[2])
end)

RS.RenderStepped:Connect(function()
    if aimbot.Enabled and keypressed then
        local part = aimbot.GetClosestPart()
        if part then aimbot.Aim(part.Position.X, part.Position.Y) end
    end
end)

return aimbot
