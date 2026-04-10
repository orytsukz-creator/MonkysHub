-- ==========================================
-- SERVICES
-- ==========================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ==========================================
-- CONFIG & BASE FUNCTIONS
-- ==========================================

repeat task.wait() until getgenv().RRR_Config and getgenv().RRR_Config.Misc

local function getCfg()
    return getgenv().RRR_Config
end

local function getChar()
    return player.Character or player.CharacterAdded:Wait()
end

local function getHRP()
    local char = player.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getBall()
    return workspace:FindFirstChild("Ball")
end

local function tpSeguro(pos)
    local hrp = getHRP()
    if not hrp then return end
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    hrp.CFrame = CFrame.new(pos)
end

-- ==========================================
-- REMOTES & POSITIONS
-- ==========================================

local Shoot = ReplicatedStorage:WaitForChild("ShootRE")
local Tackle = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tackle")

local TRAVE_RED_1, TRAVE_RED_2 = Vector3.new(-2907, -25, 1010), Vector3.new(-2907, -25, 1047)
local TRAVE_BLUE_1, TRAVE_BLUE_2 = Vector3.new(-2202, -25, 1010), Vector3.new(-2202, -25, 1047)
local GOAL_TP_RED, GOAL_TP_BLUE = Vector3.new(-2848, -25, 1030), Vector3.new(-2261, -25, 1030)

-- ==========================================
-- CORE FUNCTIONS (STEAL & GOAL)
-- ==========================================

local function autoSteal()
    local cfg = getCfg()
    if cfg.Misc.AutoSteal.Enabled ~= true then return end

    local hrp = getHRP()
    local ball = getBall()
    if not (hrp and ball) then return end

    local stateInicial = ball:GetAttribute("State")
    if stateInicial == player.Name or stateInicial == "UNTOUCHABLE" then return end

    local oldPos = hrp.CFrame
    local startTime = tick()
    local deuTackle = false

    while ball and ball.Parent do
        if tick() - startTime > 1.2 then break end
        if ball:GetAttribute("State") == "UNTOUCHABLE" then deuTackle = true; break end
        if ball:GetAttribute("State") == player.Name then break end

        -- Predição de movimento da bola
        tpSeguro(ball.Position + (ball.AssemblyLinearVelocity * 0.15) + Vector3.new(0,2,0))
        Tackle:FireServer()
        task.wait(0.03)
    end

    if deuTackle then
        task.wait(0.05)
        tpSeguro(oldPos.Position)
    end
end

local function chuteEntreTraves()
    local cfg = getCfg()
    local hrp = getHRP()
    if not hrp then return end
    
    local forca = tonumber(cfg.Misc.PowerShot.Power) or 230
    local alvo1, alvo2 = (player.Team and player.Team.Name == "Red") and {TRAVE_BLUE_1, TRAVE_BLUE_2} or {TRAVE_RED_1, TRAVE_RED_2}
    
    local centro = (alvo1[1] + alvo1[2]) / 2
    local lado = (alvo1[2] - alvo1[1]).Unit
    local dot = (hrp.Position - centro):Dot(lado)
    local alvoFinal = (dot > 0) and alvo1[1] or alvo1[2]

    local dir = (alvoFinal - hrp.Position).Unit
    dir = (dir + Vector3.new(0, 0.131, 0)).Unit

    Shoot:FireServer(forca, dir, dir, hrp.Position, true, true)
end

local function autoGoal()
    local cfg = getCfg()
    if cfg.Misc.AutoGoal.Enabled ~= true then return end

    local hrp = getHRP()
    local ball = getBall()
    if not (hrp and ball) then return end

    local startTime = tick()
    local conseguiuPegar = false

    while ball and ball.Parent and (tick() - startTime < 1.2) do
        if ball:GetAttribute("State") == "UNTOUCHABLE" then conseguiuPegar = true; break end
        tpSeguro(ball.Position + Vector3.new(0, 2, 0))
        Tackle:FireServer()
        task.wait(0.03)
    end

    if conseguiuPegar then
        local goalPos = (player.Team and player.Team.Name == "Red") and GOAL_TP_BLUE or GOAL_TP_RED
        tpSeguro(goalPos)
        task.wait(1)
        chuteEntreTraves()
    end
end

-- ==========================================
-- POWER SHOT LOGIC
-- ==========================================

local isHolding = false
local startTime = 0

local function performPowerShot()
    local cfg = getCfg()
    local hrp = getHRP()
    if not hrp then return end
    
    local forca = tonumber(cfg.Misc.PowerShot.Power) or 230
    local camDir = camera.CFrame.LookVector
    local dir = (camDir * 310000 + (camDir + Vector3.new(0,0.14,0)) * 10000000).Unit
    
    for i = 1, 4 do
        Shoot:FireServer(forca, dir, dir, hrp.Position, true, true)
        task.wait(0.02)
    end
end

local function startPower()
    if getCfg().Misc.PowerShot.Enabled == true then
        isHolding = true
        startTime = tick()
    end
end

local function endPower()
    if not isHolding then return end
    isHolding = false
    
    local duration = tick() - startTime
    local required = tonumber(getCfg().Misc.PowerShot.HoldTime) or 0.45

    if duration >= required then
        performPowerShot()
    end
end

-- ==========================================
-- INPUTS (PC)
-- ==========================================

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local cfg = getCfg()

    if input.KeyCode.Name == tostring(cfg.Misc.AutoSteal.Key) then
        autoSteal()
    elseif input.KeyCode.Name == tostring(cfg.Misc.AutoGoal.Key) then
        autoGoal()
    end

    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        startPower()
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        endPower()
    end
end)

-- ==========================================
-- MOBILE ADAPTATIVO
-- ==========================================

task.spawn(function()
    local playerGui = player:WaitForChild("PlayerGui")
    local mobileSupport = playerGui:WaitForChild("MobileSupport", 15)
    if not mobileSupport then return end
    local frame = mobileSupport:WaitForChild("Frame")

    local cfg = getCfg()

    -- Função para localizar botão pelo Nome da Key ou Nome Padrão
    local function findButton(key, default)
        return frame:FindFirstChild(tostring(key)) or frame:FindFirstChild(default)
    end

    local stealBtn = findButton(cfg.Misc.AutoSteal.Key, "StealButton")
    local goalBtn = findButton(cfg.Misc.AutoGoal.Key, "GoalButton")
    local shootBtn = findButton("Shoot", "ShootButton")

    if stealBtn then
        stealBtn.MouseButton1Click:Connect(autoSteal)
    end

    if goalBtn then
        goalBtn.MouseButton1Click:Connect(autoGoal)
    end

    if shootBtn then
        shootBtn.MouseButton1Down:Connect(startPower)
        shootBtn.MouseButton1Up:Connect(endPower)
    end
end)

print(">> SCRIPT COMPLETO E SINCRONIZADO 🔥")
