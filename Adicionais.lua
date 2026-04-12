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

-- Traves Fixas
local TRAVE_RED_L = Vector3.new(-2907, -8, 1010)
local TRAVE_RED_R = Vector3.new(-2907, -8, 1047)
local TRAVE_BLUE_L = Vector3.new(-2201, -8, 1010)
local TRAVE_BLUE_R = Vector3.new(-2201, -8, 1047)

-- Gerenciador de Estado (Anti-Spam)
local Ativo = { Steal = false, Goal = false, Shot = false }

local function tpSeguro(pos)
    local hrp = getHRP()
    if not hrp then return end
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    hrp.CFrame = pos -- Usa CFrame completo para manter a rotação
end

-- ==========================================
-- REMOTES
-- ==========================================
local Shoot = ReplicatedStorage:WaitForChild("ShootRE")
local Tackle = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tackle")

-- ==========================================
-- ABA PLAYER
-- ==========================================
local function updatePlayerAttributes()
    local cfg = getCfg()
    player:SetAttribute("Flow", cfg.Player.FakeFlow)
    player:SetAttribute("Metavision", cfg.Player.FakeMetavision)
end

local function cancelCutscene()
    local cfg = getCfg()
    if cfg.Player.CancelCutscene.Enabled ~= true then return end
    local char = getChar()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")

    camera.CameraType = Enum.CameraType.Custom
    camera.CameraSubject = hum
    if hum then hum.WalkSpeed = 40 hum.JumpPower = 60 end
    if hrp then hrp.Anchored = false end

    player:SetAttribute("CanShoot", true)
    player:SetAttribute("IsCasting", false)

    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            local p_hum = p.Character:FindFirstChildOfClass("Humanoid")
            if p_hum then for _, anim in pairs(p_hum:GetPlayingAnimationTracks()) do anim:Stop() end end
        end
    end
end

-- ==========================================
-- LÓGICA DE CHUTE (AUTO GOL DINÂMICO)
-- ==========================================
local function realizarChuteAutoGol()
    local hrp = getHRP()
    if not hrp then return end

    local sorteio = math.random()
    if sorteio > 0.3 and sorteio < 0.7 then
        sorteio = (sorteio < 0.5) and 0.15 or 0.85
    end

    local alvoFinal
    if player.Team and player.Team.Name == "Red" then
        alvoFinal = TRAVE_BLUE_L:Lerp(TRAVE_BLUE_R, math.clamp(sorteio, 0.1, 0.9))
    else
        alvoFinal = TRAVE_RED_L:Lerp(TRAVE_RED_R, math.clamp(sorteio, 0.1, 0.9))
    end

    local distancia = (alvoFinal - hrp.Position).Magnitude
    local alturaDinamica = 0.1 
    if distancia < 100 then
        local bonus = (1 - (distancia / 100)) * 0.05
        alturaDinamica = math.clamp(0.1 + bonus, 0.1, 0.15)
    end

    local direcaoHorizontal = Vector3.new(alvoFinal.X - hrp.Position.X, 0, alvoFinal.Z - hrp.Position.Z).Unit
    local dirBase = Vector3.new(direcaoHorizontal.X, alturaDinamica, direcaoHorizontal.Z).Unit
    local impulsoBruto = dirBase * 3.5
    local dirImpulso = Vector3.new(impulsoBruto.X, impulsoBruto.Y / 3.5, impulsoBruto.Z)

    Shoot:FireServer(230, dirBase, dirImpulso, hrp.Position, true, true)
end

-- ==========================================
-- ABA MISC
-- ==========================================
local function autoSteal()
    local cfg = getCfg()
    if cfg.Misc.AutoSteal.Enabled ~= true or Ativo.Steal then return end
    local hrp, ball = getHRP(), getBall()
    if not (hrp and ball) then return end
    
    local state = ball:GetAttribute("State")
    if state == player.Name or state == "UNTOUCHABLE" then return end

    Ativo.Steal = true
    local oldPos = hrp.CFrame -- SALVA A POSIÇÃO ANTES DE IR
    local startTime = tick()

    while ball and ball.Parent and (tick() - startTime < 1.2) do
        if ball:GetAttribute("State") == "UNTOUCHABLE" or ball:GetAttribute("State") == player.Name then break end
        tpSeguro(CFrame.new(ball.Position + (ball.AssemblyLinearVelocity * 0.15) + Vector3.new(0,2,0)))
        Tackle:FireServer()
        task.wait(0.03)
    end

    task.wait(0.05)
    tpSeguro(oldPos) -- VOLTA PARA A POSIÇÃO ORIGINAL
    Ativo.Steal = false
end

local function autoGoal()
    local cfg = getCfg()
    if cfg.Misc.AutoGoal.Enabled ~= true or Ativo.Goal then return end
    
    Ativo.Goal = true
    realizarChuteAutoGol() -- Chute direto sem TP, conforme solicitado
    task.wait(0.5) -- Pequeno delay para evitar spam do chute
    Ativo.Goal = false
end

local function performPowerShot()
    local cfg = getCfg()
    local hrp = getHRP()
    if not hrp or Ativo.Shot then return end

    Ativo.Shot = true
    local forca = tonumber(cfg.Misc.PowerShot.Power) or 230
    local eff, eff2 = cfg.Misc.PowerShot.Effect, cfg.Misc.PowerShot.Effect2
    
    local camDir = camera.CFrame.LookVector
    local dirBase = (camDir + Vector3.new(0, 0.131, 0)).Unit
    local dirImpulso = dirBase * 1.2 -- Magnitude de velocidade

    Shoot:FireServer(forca, dirBase, dirImpulso, hrp.Position, eff, eff2)
    task.wait(0.3)
    Ativo.Shot = false
end

-- ==========================================
-- INPUTS
-- ==========================================
local isHolding, holdStart = false, 0

local function startPower()
    if getCfg().Misc.PowerShot.Enabled == true then isHolding, holdStart = true, tick() end
end

local function endPower()
    if not isHolding then return end
    isHolding = false
    local duration = tick() - holdStart
    local needed = tonumber(getCfg().Misc.PowerShot.HoldTime) or 0.47
    
    if duration >= needed then 
        task.wait(0.01) -- DELAY DE .01s SOLICITADO
        performPowerShot() 
    end
end

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local cfg = getCfg()
    local key = input.KeyCode.Name
    
    if key == tostring(cfg.Misc.AutoSteal.Key) then task.spawn(autoSteal)
    elseif key == tostring(cfg.Misc.AutoGoal.Key) then task.spawn(autoGoal)
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
        local shB = fBtn("Shoot", "ShootButton")

        if sB then sB.MouseButton1Click:Connect(function() task.spawn(autoSteal) end) end
        if gB then gB.MouseButton1Click:Connect(function() task.spawn(autoGoal) end) end
        if shB then shB.MouseButton1Down:Connect(startPower) shB.MouseButton1Up:Connect(endPower) end
    end)
end

task.spawn(function() while task.wait(0.5) do updatePlayerAttributes() end end)
print(">> SCRIPT TOTALMENTE CORRIGIDO: STEAL, GOAL E POWER SHOT ✅")
