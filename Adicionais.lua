-- ==========================================
-- SERVICES
-- ==========================================
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ==========================================
-- CONFIG & BASE
-- ==========================================
repeat task.wait() until getgenv().RRR_Config and getgenv().RRR_Config.Misc and getgenv().RRR_Config.Player

local function getCfg() return getgenv().RRR_Config end
local function getChar() return player.Character or player.CharacterAdded:Wait() end
local function getHRP() return player.Character and player.Character:FindFirstChild("HumanoidRootPart") end
local function getBall() return workspace:FindFirstChild("Ball") end

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
-- PLAYER ATTRIBUTES (SYCHRONIZED)
-- ==========================================
local function updatePlayerAttributes()
    local cfg = getCfg()
    -- Conforme sua tabela: FakeFlow e FakeMetavision são booleanos diretos
    player:SetAttribute("Flow", cfg.Player.FakeFlow)
    player:SetAttribute("Metavision", cfg.Player.FakeMetavision)
end

-- ==========================================
-- CANCEL CUTSCENE (FULL RESET)
-- ==========================================
local function cancelCutscene()
    local cfg = getCfg()
    if cfg.Player.CancelCutscene.Enabled ~= true then return end

    local char = getChar()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")

    camera.CameraType = Enum.CameraType.Custom
    camera.CameraSubject = hum

    if hum then
        hum.WalkSpeed = 40
        hum.JumpPower = 60
    end
    if hrp then
        hrp.Anchored = false
    end

    player:SetAttribute("CanShoot", true)
    player:SetAttribute("IsCasting", false)

    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            local p_hum = p.Character:FindFirstChildOfClass("Humanoid")
            if p_hum then
                for _, anim in pairs(p_hum:GetPlayingAnimationTracks()) do anim:Stop() end
            end
        end
    end
end

-- ==========================================
-- AUTO STEAL & AUTO GOAL
-- ==========================================
local function autoSteal()
    local cfg = getCfg()
    if cfg.Misc.AutoSteal.Enabled ~= true then return end
    local hrp, ball = getHRP(), getBall()
    if not (hrp and ball) then return end
    
    local state = ball:GetAttribute("State")
    if state == player.Name or state == "UNTOUCHABLE" then return end

    local oldPos, startTime, deuTackle = hrp.CFrame, tick(), false
    while ball and ball.Parent and (tick() - startTime < 1.2) do
        if ball:GetAttribute("State") == "UNTOUCHABLE" then deuTackle = true break end
        if ball:GetAttribute("State") == player.Name then break end
        tpSeguro(ball.Position + (ball.AssemblyLinearVelocity * 0.15) + Vector3.new(0,2,0))
        Tackle:FireServer()
        task.wait(0.03)
    end
    if deuTackle then task.wait(0.05) tpSeguro(oldPos.Position) end
end

local function chuteEntreTraves()
    local cfg = getCfg()
    local hrp = getHRP()
    if not hrp then return end
    
    local forca = tonumber(cfg.Misc.PowerShot.Power) or 230
    local targets = (player.Team and player.Team.Name == "Red") and {TRAVE_BLUE_1, TRAVE_BLUE_2} or {TRAVE_RED_1, TRAVE_RED_2}
    
    local centro = (targets[1] + targets[2]) / 2
    local lado = (targets[2] - targets[1]).Unit
    local dot = (hrp.Position - centro):Dot(lado)
    local alvoFinal = (dot > 0) and targets[1] or targets[2]

    local dir = (alvoFinal - hrp.Position).Unit
    dir = (dir + Vector3.new(0, 0.131, 0)).Unit -- Direção original mantida

    Shoot:FireServer(forca, dir, dir, hrp.Position, true, true)
end

local function autoGoal()
    local cfg = getCfg()
    if cfg.Misc.AutoGoal.Enabled ~= true then return end
    local hrp, ball = getHRP(), getBall()
    if not (hrp and ball) then return end

    local startTime, conseguiu = tick(), false
    while ball and ball.Parent and (tick() - startTime < 1.2) do
        if ball:GetAttribute("State") == "UNTOUCHABLE" then conseguiu = true break end
        tpSeguro(ball.Position + Vector3.new(0, 2, 0))
        Tackle:FireServer()
        task.wait(0.03)
    end

    if conseguiu then
        tpSeguro((player.Team.Name == "Red") and GOAL_TP_BLUE or GOAL_TP_RED)
        task.wait(1)
        chuteEntreTraves()
    end
end

-- ==========================================
-- POWER SHOT LOGIC
-- ==========================================
local isHolding, holdStart = false, 0

local function performPowerShot()
    local cfg = getCfg()
    local hrp = getHRP()
    if not hrp then return end

    local forca = tonumber(cfg.Misc.PowerShot.Power) or 230
    -- Conforme sua tabela: Effect e Effect2 são booleanos diretos
    local eff = cfg.Misc.PowerShot.Effect
    local eff2 = cfg.Misc.PowerShot.Effect2
    
    local camDir = camera.CFrame.LookVector
    local dir = (camDir * 310000 + (camDir + Vector3.new(0,0.14,0)) * 10000000).Unit
    
    for i = 1, 4 do 
        Shoot:FireServer(forca, dir, dir, hrp.Position, eff, eff2) 
        task.wait(0.01) 
    end
end

local function startPower()
    if getCfg().Misc.PowerShot.Enabled == true then 
        isHolding = true 
        holdStart = tick() 
    end
end

local function endPower()
    if not isHolding then return end
    isHolding = false
    local duration = tick() - holdStart
    local needed = tonumber(getCfg().Misc.PowerShot.HoldTime) or 0.47
    
    if duration >= needed then 
        performPowerShot() 
    end
end

-- ==========================================
-- INPUTS
-- ==========================================
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local cfg = getCfg()
    local key = input.KeyCode.Name
    
    if key == tostring(cfg.Misc.AutoSteal.Key) then autoSteal()
    elseif key == tostring(cfg.Misc.AutoGoal.Key) then autoGoal()
    elseif key == tostring(cfg.Player.CancelCutscene.Key) then cancelCutscene()
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then startPower() end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then endPower() end
end)

-- Mobile Support
if UIS.TouchEnabled then
    task.spawn(function()
        local frame = player:WaitForChild("PlayerGui"):WaitForChild("MobileSupport", 15):WaitForChild("Frame")
        local cfg = getCfg()
        local function fBtn(k, d) return frame:FindFirstChild(tostring(k)) or frame:FindFirstChild(d) end
        
        local sB = fBtn(cfg.Misc.AutoSteal.Key, "StealButton")
        local gB = fBtn(cfg.Misc.AutoGoal.Key, "GoalButton")
        local cB = fBtn(cfg.Player.CancelCutscene.Key, "CancelButton")
        local shB = fBtn("Shoot", "ShootButton")

        if sB then sB.MouseButton1Click:Connect(autoSteal) end
        if gB then gB.MouseButton1Click:Connect(autoGoal) end
        if cB then cB.MouseButton1Click:Connect(cancelCutscene) end
        if shB then shB.MouseButton1Down:Connect(startPower) shB.MouseButton1Up:Connect(endPower) end
    end)
end

task.spawn(function() while task.wait(0.5) do updatePlayerAttributes() end end)
print(">> SCRIPT FULL: CONFIGURAÇÃO SINCRONIZADA COM A TABELA ✅")
