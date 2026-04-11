-- ==========================================
-- SERVICES
-- ==========================================
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")

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
-- PLAYER ATTRIBUTES & ACTIONS
-- ==========================================
local function updatePlayerAttributes()
    local cfg = getCfg()
    player:SetAttribute("Flow", cfg.Player.FakeFlow.Enabled)
    player:SetAttribute("Metavision", cfg.Player.FakeMetavision.Enabled)
end

local function cancelCutscene()
    local cfg = getCfg()
    if cfg.Player.CancelCutscene.Enabled ~= true then return end

    camera.CameraType = Enum.CameraType.Custom
    camera.CameraSubject = getChar():WaitForChild("Humanoid")

    local hum = getChar():FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = 40
        hum.JumpPower = 60
    end

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
    if ball:GetAttribute("State") == player.Name or ball:GetAttribute("State") == "UNTOUCHABLE" then return end

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
        -- Chute entre traves
        local targets = (player.Team.Name == "Red") and {TRAVE_BLUE_1, TRAVE_BLUE_2} or {TRAVE_RED_1, TRAVE_RED_2}
        local forca = tonumber(cfg.Misc.PowerShot.Power) or 230
        local dir = ((targets[1] + targets[2])/2 - getHRP().Position).Unit
        Shoot:FireServer(forca, dir + Vector3.new(0,0.13,0), dir, getHRP().Position, true, true)
    end
end

-- ==========================================
-- POWER SHOT LOGIC
-- ==========================================
local isHolding, holdStart = false, 0
local function performPowerShot()
    local cfg = getCfg()
    local forca = tonumber(cfg.Misc.PowerShot.Power) or 230
    local dir = (camera.CFrame.LookVector * 310000 + (camera.CFrame.LookVector + Vector3.new(0,0.14,0)) * 10000000).Unit
    for i = 1, 4 do Shoot:FireServer(forca, dir, dir, getHRP().Position, true, true) task.wait(0.02) end
end

-- ==========================================
-- INPUTS PC
-- ==========================================
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local cfg = getCfg()
    local key = input.KeyCode.Name
    if key == tostring(cfg.Misc.AutoSteal.Key) then autoSteal()
    elseif key == tostring(cfg.Misc.AutoGoal.Key) then autoGoal()
    elseif key == tostring(cfg.Player.CancelCutscene.Key) then cancelCutscene()
    elseif key == tostring(cfg.Player.FakeFlow.Key) then cfg.Player.FakeFlow.Enabled = not cfg.Player.FakeFlow.Enabled updatePlayerAttributes()
    elseif key == tostring(cfg.Player.FakeMetavision.Key) then cfg.Player.FakeMetavision.Enabled = not cfg.Player.FakeMetavision.Enabled updatePlayerAttributes()
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        if cfg.Misc.PowerShot.Enabled then isHolding, holdStart = true, tick() end
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and isHolding then
        isHolding = false
        if (tick() - holdStart) >= (tonumber(getCfg().Misc.PowerShot.HoldTime) or 0.45) then performPowerShot() end
    end
end)

-- ==========================================
-- MOBILE (DENTRO DA VERIFICAÇÃO DE TOQUE)
-- ==========================================
if UIS.TouchEnabled then -- SÓ RODA SE FOR MOBILE/TABLET
    task.spawn(function()
        local playerGui = player:WaitForChild("PlayerGui")
        local frame = playerGui:WaitForChild("MobileSupport", 15):WaitForChild("Frame")
        local cfg = getCfg()

        local function findBtn(key, default) return frame:FindFirstChild(tostring(key)) or frame:FindFirstChild(default) end
        
        local stealBtn = findBtn(cfg.Misc.AutoSteal.Key, "StealButton")
        local goalBtn = findBtn(cfg.Misc.AutoGoal.Key, "GoalButton")
        local cancelBtn = findBtn(cfg.Player.CancelCutscene.Key, "CancelButton")
        local flowBtn = findBtn(cfg.Player.FakeFlow.Key, "FlowButton")
        local mvBtn = findBtn(cfg.Player.FakeMetavision.Key, "MVButton")
        local shootBtn = findBtn("Shoot", "ShootButton")

        if stealBtn then stealBtn.MouseButton1Click:Connect(autoSteal) end
        if goalBtn then goalBtn.MouseButton1Click:Connect(autoGoal) end
        if cancelBtn then cancelBtn.MouseButton1Click:Connect(cancelCutscene) end
        if flowBtn then flowBtn.MouseButton1Click:Connect(function() cfg.Player.FakeFlow.Enabled = not cfg.Player.FakeFlow.Enabled updatePlayerAttributes() end) end
        if mvBtn then mvBtn.MouseButton1Click:Connect(function() cfg.Player.FakeMetavision.Enabled = not cfg.Player.FakeMetavision.Enabled updatePlayerAttributes() end) end
        if shootBtn then
            shootBtn.MouseButton1Down:Connect(function() if cfg.Misc.PowerShot.Enabled then isHolding, holdStart = true, tick() end end)
            shootBtn.MouseButton1Up:Connect(function() if isHolding then isHolding = false if (tick()-holdStart) >= (tonumber(cfg.Misc.PowerShot.HoldTime) or 0.45) then performPowerShot() end end end)
        end
    end)
end

task.spawn(function() while task.wait(0.5) do updatePlayerAttributes() end end)
print(">> SCRIPT FULL OPTIMIZED: PC/MOBILE SYNC ✅")
