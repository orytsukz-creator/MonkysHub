-- // comandos.lua (VERSÃO FINAL: PC + MOBILE + COOLDOWN SELETIVO)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- // REMOTES E POSIÇÕES
local Shoot = ReplicatedStorage:WaitForChild("ShootRE")
local Tackle = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tackle")
local TRAVE_RED_1, TRAVE_RED_2 = Vector3.new(-2907, -25, 1010), Vector3.new(-2907, -25, 1047)
local TRAVE_BLUE_1, TRAVE_BLUE_2 = Vector3.new(-2202, -25, 1010), Vector3.new(-2202, -25, 1047)
local GOAL_TP_RED, GOAL_TP_BLUE = Vector3.new(-2848, -25, 1030), Vector3.new(-2261, -25, 1030)

-- // VARIÁVEIS DE CONTROLE
local lastMobileTackle = 0
local tackleCooldown = 2
local disparoPendente = false

local function getCfg() return getgenv().RRR_Config end
local function getHRP() return player.Character and player.Character:FindFirstChild("HumanoidRootPart") end
local function getBall() return workspace:FindFirstChild("Ball") end

local function tpSeguro(pos)
    local hrp = getHRP()
    if hrp then
        hrp.AssemblyLinearVelocity, hrp.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
        hrp.CFrame = CFrame.new(pos)
    end
end

-- // LÓGICAS DE EXECUÇÃO
local function executarChuteForte()
    local hrp, cfg = getHRP(), getCfg()
    if not hrp or not cfg then return end
    local dir = (camera.CFrame.LookVector * 310000 + (camera.CFrame.LookVector + Vector3.new(0, 0.14, 0)) * 10000000).Unit
    Shoot:FireServer(tonumber(cfg.Misc.PowerShot.Power) or 230, dir, dir, hrp.Position, cfg.Misc.PowerShot.Effect, cfg.Misc.PowerShot.Effect2)
end

local function executarAutoSteal()
    local hrp, cfg, ball = getHRP(), getCfg(), getBall()
    if not hrp or not cfg or not ball or ball:GetAttribute("State") == player.Name then return end
    
    local oldPos = hrp.CFrame
    Tackle:FireServer()
    local start = tick()
    local pegou = false
    while ball and tick() - start < 1.2 do
        local st = ball:GetAttribute("State")
        if st == "UNTOUCHABLE" or st == player.Name then pegou = true; break end
        tpSeguro(ball.Position + Vector3.new(0, 2, 0))
        task.wait(0.03)
    end
    if pegou then task.wait(0.05); tpSeguro(oldPos.Position) end
end

local function executarAutoGoal()
    local hrp, cfg, ball = getHRP(), getCfg(), getBall()
    if not hrp or not cfg or not ball then return end
    
    tpSeguro(ball.Position + Vector3.new(0, 2, 0))
    Tackle:FireServer()
    task.wait(0.2)
    tpSeguro((player.Team.Name == "Red") and GOAL_TP_BLUE or GOAL_TP_RED)
    task.wait(0.8)
    
    -- Lógica de direção do gol
    local a1, a2 = (player.Team.Name == "Red") and (TRAVE_BLUE_1, TRAVE_BLUE_2) or (TRAVE_RED_1, TRAVE_RED_2)
    local centro = (a1 + a2) / 2
    local alvoFinal = ((hrp.Position - centro):Dot((a2 - a1).Unit) > 0) and a1 or a2
    local delta = alvoFinal - hrp.Position
    local dist = delta.Magnitude
    local altura = (dist < 60) and -1 or (dist * (0.14 + (math.floor((dist-60)/20)*0.01)))
    local dir = (Vector3.new(delta.X, 0, delta.Z).Unit + Vector3.new(0, altura/dist, 0)).Unit
    Shoot:FireServer(tonumber(cfg.Misc.PowerShot.Power) or 230, dir, dir, hrp.Position, cfg.Misc.PowerShot.Effect, cfg.Misc.PowerShot.Effect2)
end

-- // SUPORTE MOBILE (Com Cooldown no Tackle)
task.spawn(function()
    local mobileFrame = player:WaitForChild("PlayerGui"):WaitForChild("MobileSupport", 10):WaitForChild("Frame", 5)
    if mobileFrame then
        -- Botão Tackle (Auto Steal) com Cooldown apenas aqui
        mobileFrame:WaitForChild("TackleButton").MouseButton1Click:Connect(function()
            if tick() - lastMobileTackle >= tackleCooldown then
                executarAutoSteal()
                lastMobileTackle = tick()
            end
        end)
        -- Botão Talent (Auto Goal)
        mobileFrame:WaitForChild("TalentButton").MouseButton1Click:Connect(executarAutoGoal)
        -- Botão Shoot (PowerShot)
        local btnShoot = mobileFrame:WaitForChild("ShootButton")
        local pStart = 0
        btnShoot.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then pStart = tick() end end)
        btnShoot.InputEnded:Connect(function(i)
            local cfg = getCfg()
            if cfg and cfg.Misc.PowerShot.Enabled and (tick() - pStart) >= (tonumber(cfg.Misc.PowerShot.HoldTime) or 0.47) then
                executarChuteForte()
            end
        end)
    end
end)

-- // SUPORTE PC (Sem Cooldown)
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    local cfg = getCfg()
    if not cfg then return end

    if input.KeyCode == Enum.KeyCode[cfg.Misc.AutoSteal.Key:upper()] and cfg.Misc.AutoSteal.Enabled then
        executarAutoSteal()
    elseif input.KeyCode == Enum.KeyCode[cfg.Misc.AutoGoal.Key:upper()] and cfg.Misc.AutoGoal.Enabled then
        executarAutoGoal()
    end
end)

-- SISTEMA M2 (PC)
CAS:BindActionAtPriority("M2Chute", function(_, state)
    local cfg = getCfg()
    if not cfg or not cfg.Misc.PowerShot.Enabled then return Enum.ContextActionResult.Pass end
    static_pStart = static_pStart or 0
    if state == Enum.UserInputState.Begin then static_pStart = tick()
    elseif state == Enum.UserInputState.End then
        if (tick() - static_pStart) >= (tonumber(cfg.Misc.PowerShot.HoldTime) or 0.47) and not disparoPendente then
            disparoPendente = true
            for i=1,4 do executarChuteForte(); task.wait() end
            disparoPendente = false
        end
    end
    return Enum.ContextActionResult.Pass
end, false, 3000, Enum.UserInputType.MouseButton2)

-- LOOP FLOW/META
task.spawn(function()
    while task.wait(0.5) do
        local cfg = getCfg()
        if cfg then
            player:SetAttribute("Flow", cfg.Player.FakeFlow)
            player:SetAttribute("Metavision", cfg.Player.FakeMetavision)
        end
    end
end)

print("✅ comandos.lua: Mobile (com cooldown) e PC carregados!")
