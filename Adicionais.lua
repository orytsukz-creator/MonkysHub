-- // comandos.lua FINAL COMPLETO

-- // SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- // REMOTES
local Shoot = ReplicatedStorage:WaitForChild("ShootRE", 20)
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 20)
local Tackle = Remotes:WaitForChild("Tackle", 10)

-- // WAIT CONFIG
repeat task.wait(0.5) until getgenv().RRR_Config and getgenv().RRR_Config.Misc

-- // BASE
local function getCfg() return getgenv().RRR_Config end
local function getHRP() return player.Character and player.Character:FindFirstChild("HumanoidRootPart") end
local function getBall() return workspace:FindFirstChild("Ball") end

local function tpSeguro(pos)
    local hrp = getHRP()
    if hrp then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.CFrame = CFrame.new(pos)
    end
end

-- // CHECK BIND (PC + MOBILE)
local function checkBind(input, category, keyName)
    local cfg = getCfg()
    if not (cfg and cfg[category] and cfg[category][keyName] and cfg[category][keyName].Enabled) then 
        return false 
    end

    local bindSalvo = tostring(cfg[category][keyName].Key):upper()
    local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

    if isMobile then
        local MobileSupport = player.PlayerGui:FindFirstChild("MobileSupport")
        if MobileSupport then
            local objects = player.PlayerGui:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
            for _, obj in pairs(objects) do
                if obj:IsA("GuiButton") and obj.Name:upper() == bindSalvo then
                    return true
                end
            end
        end
    else
        if input.UserInputType == Enum.UserInputType.Keyboard then
            return input.KeyCode.Name:upper() == bindSalvo
        end
    end

    return false
end

-- // AUTO STEAL
local function executarAutoSteal()
    local hrp, ball = getHRP(), getBall()
    if not (hrp and ball and Tackle) then return end

    local oldPos = hrp.CFrame

    local vel = ball.AssemblyLinearVelocity.Magnitude
    local isFast = vel > 25

    local predictedPos = ball.Position + (ball.AssemblyLinearVelocity * 0.15)

    tpSeguro(predictedPos + Vector3.new(0, 2, 0))

    for i = 1, 50 do
        Tackle:FireServer()
    end

    if isFast then
        local start = tick()
        while ball and (tick() - start < 0.4) do
            local newPred = ball.Position + (ball.AssemblyLinearVelocity * 0.15)
            tpSeguro(newPred + Vector3.new(0, 2, 0))
            task.wait()
        end
    end

    task.wait(0.05)

    local state = ball:GetAttribute("State")
    if state == "UNTOUCHABLE" or state == player.Name then
        tpSeguro(oldPos.Position)
    end
end

-- // AUTO GOAL
local function executarAutoGoal()
    local hrp, ball = getHRP(), getBall()
    local cfg = getCfg()

    if not (hrp and ball and Shoot and cfg) then return end
    if ball:GetAttribute("State") ~= player.Name then return end

    local goalPos = Vector3.new(0, 5, -180)

    local dir = (goalPos - hrp.Position).Unit
    local dist = (hrp.Position - goalPos).Magnitude

    local power = 230

    Shoot:FireServer(
        power,
        dir,
        dir,
        hrp.Position,
        cfg.Misc.PowerShot.Effect,
        cfg.Misc.PowerShot.Effect2
    )
end

-- // POWERSHOT (HOLD + 4x)
local holding = false
local holdStart = 0

local function startHold()
    local cfg = getCfg()
    if not (cfg and cfg.Misc.PowerShot.Enabled) then return end

    holding = true
    holdStart = tick()
end

local function endHold()
    local cfg = getCfg()
    if not (holding and cfg and cfg.Misc.PowerShot.Enabled) then return end

    local held = tick() - holdStart
    holding = false

    local holdReq = tonumber(cfg.Misc.PowerShot.HoldTime) or 0.47
    if held < holdReq then return end

    local hrp = getHRP()
    if not hrp then return end

    local pwr = tonumber(cfg.Misc.PowerShot.Power) or 230
    local dir = (camera.CFrame.LookVector * 310000 + (camera.CFrame.LookVector + Vector3.new(0, 0.14, 0)) * 10000000).Unit

    -- DISPARA 4x
    for i = 1, 4 do
        Shoot:FireServer(
            pwr,
            dir,
            dir,
            hrp.Position,
            cfg.Misc.PowerShot.Effect,
            cfg.Misc.PowerShot.Effect2
        )
        task.wait(0.03)
    end
end

-- // INPUTS
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end

    if checkBind(input, "Misc", "AutoSteal") then
        executarAutoSteal()
    end

    if checkBind(input, "Misc", "AutoGoal") then
        executarAutoGoal()
    end

    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        startHold()
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        endHold()
    end
end)

-- MOBILE SHOOT BUTTON
task.spawn(function()
    task.wait(2)

    local ms = player.PlayerGui:FindFirstChild("MobileSupport")
    local frame = ms and ms:FindFirstChild("Frame")
    local btn = frame and frame:FindFirstChild("ShootButton")

    if btn then
        btn.MouseButton1Down:Connect(startHold)
        btn.MouseButton1Up:Connect(endHold)
    end
end)

-- LOOP ATTRIBUTES
task.spawn(function()
    while task.wait(1) do
        local cfg = getCfg()
        if cfg and cfg.Player then
            pcall(function()
                player:SetAttribute("Flow", cfg.Player.FakeFlow)
                player:SetAttribute("Metavision", cfg.Player.FakeMetavision)
            end)
        end
    end
end)

print(">> [RRR] SISTEMA FINAL ATIVO!")
