local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remote = ReplicatedStorage:WaitForChild("MainRemotes"):WaitForChild("MainRemoteEvent")

-- Config
local whitelist = {
    ["GigaDuckThunder"] = true,
    ["lolii2242"] = true,
}

local targetName = "mikarajah" -- set to "all" or a specific player like "SomeUser"
local canMulti = true -- set to false to only shoot one target

local function getRevolver()
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    return (char and char:FindFirstChild("[Revolver]")) or (backpack and backpack:FindFirstChild("[Revolver]"))
end

local function shootAll()
    local revolver = getRevolver()
    if not revolver then return end

    if revolver.Parent == LocalPlayer.Backpack then
        LocalPlayer.Character.Humanoid:EquipTool(revolver)
        task.wait(0.2)
    end

    local handle = revolver:FindFirstChild("Handle")
    if not handle then return end

    for _, plr in pairs(Players:GetPlayers()) do
        if
            plr ~= LocalPlayer and
            not whitelist[plr.Name] and
            plr.Character and
            plr.Character:FindFirstChild("HumanoidRootPart")
        then
            if targetName == "all" or plr.Name:lower() == targetName:lower() then
                local origin = handle.Position
                local targetPart = plr.Character.HumanoidRootPart
                local hitPos = targetPart.Position + Vector3.new(0, 1, 0)
                local normal = Vector3.new(0, 1, 0)

                remote:FireServer("ShootGun", handle, origin, hitPos, targetPart, normal)

                if not canMulti then
                    break -- only shoot the first valid target
                end
            end
        end
    end
end

-- Fire when new player joins
Players.PlayerAdded:Connect(function()
    task.wait(1)
    shootAll()
end)

-- Constant check
RunService.Heartbeat:Connect(function()
    shootAll()
end)
