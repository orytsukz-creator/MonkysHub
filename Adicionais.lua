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
    local char = getChar()
    return char:WaitForChild("HumanoidRootPart")
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
-- REMOTES & POSITIONS
-- ==========================================

local Shoot = ReplicatedStorage:WaitForChild("ShootRE")
local Tackle = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tackle")

local TRAVE_RED_1, TRAVE_RED_2 = Vector3.new(-2907, -25, 1010), Vector3.new(-2907, -25, 1047)
local TRAVE_BLUE_1, TRAVE_BLUE_2 = Vector3.new(-2202, -25, 1010), Vector3.new(-2202, -25, 1047)
local GOAL_TP_RED, GOAL_TP_BLUE = Vector3.new(-2848, -25, 1030), Vector3.new(-2261, -25, 1030)

-- ==========================================
-- CORE FUNCTIONS
-- ==========================================

local function autoSteal()
    local cfg = getCfg()
    if not cfg.Misc.AutoSteal.Enabled then return end

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
    
    -- Puxa a força da interface (PowerShot.Power) ou usa 230 como padrão
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
    if not cfg.Misc.AutoGoal.Enabled then return end

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
-- POWERSHOT LOGIC (FIX POWER VAL)
-- ==========================================

local segurando = false
local tempo = 0

local function shootMobileSafe()
    local cfg = getCfg()
    local hrp = getHRP()
    
    -- PEGA O VALOR DA INTERFACE AQUI:
    local forca = tonumber(cfg.Misc.PowerShot.Power) or 230
    
    local camDir = camera.CFrame.LookVector
    local dir = (camDir * 310000 + (camDir + Vector3.new(0,0.14,0)) * 10000000).Unit
    
    Shoot:FireServer(forca, dir, dir, hrp.Position, true, true)
end

local function startHold()
    local cfg = getCfg()
    if not (cfg.Misc.PowerShot and cfg.Misc.PowerShot.Enabled) then return end
    segurando = true
    tempo = tick()
end

local function endHold()
    if not segurando then return end
    local cfg = getCfg()
    local hold = tonumber(cfg.Misc.PowerShot.HoldTime) or 0.47

    if tick() - tempo >= hold then
        for i = 1, 4 do
            shootMobileSafe()
            task.wait(0.03)
        end
    end
    segurando = false
end

-- ==========================================
-- INPUTS PC & MOBILE BINDINGS
-- ==========================================

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local cfg = getCfg()
    if input.KeyCode.Name == tostring(cfg.Misc.AutoSteal.Key) then autoSteal() end
    if input.KeyCode.Name == tostring(cfg.Misc.AutoGoal.Key) then autoGoal() end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then startHold() end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then endHold() end
end)

task.spawn(function()
    local playerGui = player:WaitForChild("PlayerGui")
    local mobileSupport = playerGui:WaitForChild("MobileSupport", 15)
    if not mobileSupport then return end
    local frame = mobileSupport:WaitForChild("Frame")

    local shootBtn = frame:FindFirstChild("ShootButton")
    local stealBtn = frame:FindFirstChild("StealButton")
    local goalBtn = frame:FindFirstChild("GoalButton")

    if shootBtn then
        shootBtn.MouseButton1Down:Connect(startHold)
        shootBtn.MouseButton1Up:Connect(endHold)
    end
    if stealBtn then stealBtn.MouseButton1Click:Connect(autoSteal) end
    if goalBtn then goalBtn.MouseButton1Click:Connect(autoGoal) end
end)

print(">> SCRIPT COMPLETO: FORÇA E ATIVAÇÃO SINCRONIZADOS ✅")
