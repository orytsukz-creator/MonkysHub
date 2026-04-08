-- ==========================================
-- SERVICES
-- ==========================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ==========================================
-- CONFIG
-- ==========================================

repeat task.wait() until getgenv().RRR_Config and getgenv().RRR_Config.Misc

local function getCfg()
    return getgenv().RRR_Config
end

-- ==========================================
-- REMOTES
-- ==========================================

local Shoot = ReplicatedStorage:WaitForChild("ShootRE")
local Tackle = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tackle")

-- ==========================================
-- POSIÇÕES
-- ==========================================

local TRAVE_RED_1, TRAVE_RED_2 = Vector3.new(-2907, -25, 1010), Vector3.new(-2907, -25, 1047)
local TRAVE_BLUE_1, TRAVE_BLUE_2 = Vector3.new(-2202, -25, 1010), Vector3.new(-2202, -25, 1047)

local GOAL_TP_RED, GOAL_TP_BLUE = Vector3.new(-2848, -25, 1030), Vector3.new(-2261, -25, 1030)

-- ==========================================
-- BASE
-- ==========================================

local function getChar()
    return player.Character or player.CharacterAdded:Wait()
end

local function getHRP()
    return getChar():WaitForChild("HumanoidRootPart")
end

local function getBall()
    return workspace:FindFirstChild("Ball")
end

local function tpSeguro(pos)
    local hrp = getHRP()
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    hrp.CFrame = CFrame.new(pos)
end

-- ==========================================
-- MOBILE UI (DIRETO)
-- ==========================================

local MobileFrame = player:WaitForChild("PlayerGui")
    :WaitForChild("MobileSupport")
    :WaitForChild("Frame")

local function getButton(name)
    return MobileFrame:FindFirstChild(name)
end

-- ==========================================
-- AUTO STEAL
-- ==========================================

local function autoSteal()
    local hrp = getHRP()
    local ball = getBall()
    if not (hrp and ball) then return end

    local stateInicial = ball:GetAttribute("State")
    if stateInicial == player.Name then return end
    if stateInicial == "UNTOUCHABLE" then return end

    local oldPos = hrp.CFrame
    local startTime = tick()
    local deuTackle = false

    local function getPred()
        return ball.Position + (ball.AssemblyLinearVelocity * 0.15)
    end

    while ball and ball.Parent do
        if tick() - startTime > 1.2 then break end

        local stateAtual = ball:GetAttribute("State")

        if stateAtual == "UNTOUCHABLE" then
            deuTackle = true
            break
        end

        if stateAtual == player.Name then break end

        tpSeguro(getPred() + Vector3.new(0,2,0))
        Tackle:FireServer()

        task.wait(0.03)
    end

    if deuTackle then
        task.wait(0.05)
        tpSeguro(oldPos.Position)
    end
end

-- ==========================================
-- CHUTE ENTRE TRAVES (Y 0.131)
-- ==========================================

local function chuteEntreTraves()
    local hrp = getHRP()

    local alvo1, alvo2
    if player.Team and player.Team.Name == "Red" then
        alvo1, alvo2 = TRAVE_BLUE_1, TRAVE_BLUE_2
    else
        alvo1, alvo2 = TRAVE_RED_1, TRAVE_RED_2
    end

    local centro = (alvo1 + alvo2) / 2
    local lado = (alvo2 - alvo1).Unit
    local dot = (hrp.Position - centro):Dot(lado)

    local alvoFinal = (dot > 0) and alvo1 or alvo2

    local dir = (alvoFinal - hrp.Position).Unit
    dir = (dir + Vector3.new(0, 0.131, 0)).Unit

    Shoot:FireServer(230, dir, dir, hrp.Position, true, true)
end

-- ==========================================
-- AUTO GOAL COMBO
-- ==========================================

local function autoGoal()
    local hrp = getHRP()
    local ball = getBall()
    if not (hrp and ball) then return end

    local stateInicial = ball:GetAttribute("State")
    if stateInicial == player.Name then return end
    if stateInicial == "UNTOUCHABLE" then return end

    local startTime = tick()
    local conseguiu = false

    local function getPred()
        return ball.Position + (ball.AssemblyLinearVelocity * 0.15)
    end

    while ball and ball.Parent do
        if tick() - startTime > 1.2 then break end

        if ball:GetAttribute("State") == "UNTOUCHABLE" then
            conseguiu = true
            break
        end

        tpSeguro(getPred() + Vector3.new(0,2,0))
        Tackle:FireServer()

        task.wait(0.03)
    end

    if not conseguiu then return end

    task.wait(0.05)

    local goalPos = (player.Team and player.Team.Name == "Red")
        and GOAL_TP_BLUE or GOAL_TP_RED

    tpSeguro(goalPos)

    task.wait(0.1)
    chuteEntreTraves()
end

-- ==========================================
-- POWERSHOT (FIX MOBILE REAL)
-- ==========================================

local segurando = false
local tempo = 0

local function getShootDirection()
    local hrp = getHRP()

    local camDir = camera.CFrame.LookVector

    if camDir.Magnitude < 0.1 then
        camDir = hrp.CFrame.LookVector
    end

    local dir = (
        camDir * 310000 +
        (camDir + Vector3.new(0,0.14,0)) * 10000000
    ).Unit

    return dir
end

local function shootMobileSafe()
    local hrp = getHRP()
    local dir = getShootDirection()

    Shoot:FireServer(230, dir, dir, hrp.Position, true, true)
end

local function startHold()
    local cfg = getCfg()
    if not (cfg.Misc.PowerShot and cfg.Misc.PowerShot.Enabled) then return end

    segurando = true
    tempo = tick()
end

local function endHold()
    local cfg = getCfg()
    if not segurando then return end

    local hold = tonumber(cfg.Misc.PowerShot.HoldTime) or 0.47

    if tick() - tempo >= hold then
        task.delay(0.01, function()
            for i = 1,4 do
                shootMobileSafe()
                task.wait(0.03)
            end
        end)
    end

    segurando = false
end

-- ==========================================
-- INPUT PC
-- ==========================================

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    local cfg = getCfg()

    if input.KeyCode.Name == tostring(cfg.Misc.AutoSteal.Key) then
        autoSteal()
    end

    if input.KeyCode.Name == tostring(cfg.Misc.AutoGoal.Key) then
        autoGoal()
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

-- ==========================================
-- MOBILE (FINAL FIX)
-- ==========================================

task.spawn(function()
    local cfg = getCfg()

    local shootBtn = getButton("ShootButton")
    if shootBtn then
        shootBtn.MouseButton1Down:Connect(startHold)
        shootBtn.MouseButton1Up:Connect(endHold)
    end

    local stealBtn = getButton(cfg.Misc.AutoSteal.Key)
    if stealBtn then
        stealBtn.MouseButton1Click:Connect(autoSteal)
    end

    local goalBtn = getButton(cfg.Misc.AutoGoal.Key)
    if goalBtn then
        goalBtn.MouseButton1Click:Connect(autoGoal)
    end
end)

print(">> SCRIPT FINAL MOBILE + PC FUNCIONANDO 🔥")
