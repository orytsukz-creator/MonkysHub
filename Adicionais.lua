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
    hrp.CFrame = pos
end

-- ==========================================
-- REMOTES
-- ==========================================
local Shoot = ReplicatedStorage:WaitForChild("ShootRE")
local Tackle = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tackle")

-- ==========================================
-- PLAYER ATTRIBUTES
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
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")

    -- Reset de atributos e ancoragem
    player:SetAttribute("CanShoot", true)
    player:SetAttribute("IsCasting", false)
    if hrp then hrp.Anchored = false end
    if hum then hum.WalkSpeed = 40 hum.JumpPower = 60 end

    -- LOOP DE RESET DA CÂMERA (5 VEZES)
    task.spawn(function()
        for i = 1, 5 do
            camera.CameraType = Enum.CameraType.Scriptable
            task.wait(0.01)
            camera.CameraSubject = hum
            camera.CameraType = Enum.CameraType.Custom
            if hrp then
                camera.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 10, 12), hrp.Position)
            end
            task.wait(0.05) -- Intervalo entre as tentativas de "quebra"
        end
    end)

    -- Para todas as animações
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChildOfClass("Humanoid") then
            for _, anim in pairs(p.Character:FindFirstChildOfClass("Humanoid"):GetPlayingAnimationTracks()) do 
                anim:Stop(0) 
            end
        end
    end
end

-- ==========================================
-- AUTO GOL DINÂMICO (LONGE .23 | PERTO .07)
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
    
    -- LÓGICA DINÂMICA REESCRITA:
    -- Perto (0 studs): 0.07
    -- Longe (300 studs): 0.23
    local alturaMin = 0.07
    local alturaMax = 0.23
    local distanciaLimite = 300

    -- Calcula o progresso de 0 a 1 baseado na distância (máximo 300)
    local progresso = math.clamp(distancia / distanciaLimite, 0, 1)
    
    -- Interpolação linear entre 0.07 e 0.23
    local alturaDinamica = alturaMin + (progresso * (alturaMax - alturaMin))

    local direcaoHorizontal = Vector3.new(alvoFinal.X - hrp.Position.X, 0, alvoFinal.Z - hrp.Position.Z).Unit
    local dirBase = Vector3.new(direcaoHorizontal.X, alturaDinamica, direcaoHorizontal.Z).Unit
    
    -- Matemática de Impulso: 3.5x no horizontal e neutraliza o Y para 1x
    local impulsoBruto = dirBase * 3.5
    local dirImpulso = Vector3.new(impulsoBruto.X, impulsoBruto.Y / 3.5, impulsoBruto.Z)

    Shoot:FireServer(230, dirBase, dirImpulso, hrp.Position, true, true)
    
    -- Debug opcional no console para você ver a altura aplicada
    -- print(string.format("Dist: %.1f | Y: %.3f", distancia, alturaDinamica))
end

-- ==========================================
-- ABA MISC (STEAL COM RETORNO)
-- ==========================================
local function autoSteal()
    local cfg = getCfg()
    if cfg.Misc.AutoSteal.Enabled ~= true or Ativo.Steal then return end
    local hrp, ball = getHRP(), getBall()
    if not (hrp and ball) then return end
    
    Ativo.Steal = true
    local oldPos = hrp.CFrame
    local startTime = tick()

    while ball and ball.Parent and (tick() - startTime < 1.2) do
        local state = ball:GetAttribute("State")
        if state == "UNTOUCHABLE" or state == player.Name then break end
        
        tpSeguro(CFrame.new(ball.Position + (ball.AssemblyLinearVelocity * 0.15) + Vector3.new(0,2,0)))
        Tackle:FireServer()
        task.wait(0.03)
    end

    task.wait(0.1)
    tpSeguro(oldPos)
    Ativo.Steal = false
end

local function autoGoal()
    local cfg = getCfg()
    if cfg.Misc.AutoGoal.Enabled ~= true or Ativo.Goal then return end
    Ativo.Goal = true
    realizarChuteAutoGol()
    task.wait(0.5)
    Ativo.Goal = false
end

local function performPowerShot()
    local cfg = getCfg()
    local hrp = getHRP()
    if not hrp or Ativo.Shot then return end

    Ativo.Shot = true
    local forca = tonumber(cfg.Misc.PowerShot.Power) or 230
    local camDir = camera.CFrame.LookVector
    local dirBase = (camDir + Vector3.new(0, 0.131, 0)).Unit
    local dirImpulso = dirBase * 1.2

    Shoot:FireServer(forca, dirBase, dirImpulso, hrp.Position, cfg.Misc.PowerShot.Effect, cfg.Misc.PowerShot.Effect2)
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
    if (tick() - holdStart) >= (tonumber(getCfg().Misc.PowerShot.HoldTime) or 0.47) then 
        task.wait(0.01)
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

-- ==========================================
-- MOBILE SUPPORT
-- ==========================================
if UIS.TouchEnabled then
    task.spawn(function()
        local mobileGui = player:WaitForChild("PlayerGui"):WaitForChild("MobileSupport", 15)
        local frame = mobileGui:WaitForChild("Frame")
        local cfg = getCfg()
        
        local stealBtn = frame:FindFirstChild(tostring(cfg.Misc.AutoSteal.Key))
        local goalBtn = frame:FindFirstChild(tostring(cfg.Misc.AutoGoal.Key))
        local cancelBtn = frame:FindFirstChild(tostring(cfg.Player.CancelCutscene.Key))
        local shootBtn = frame:FindFirstChild("Shoot") or frame:FindFirstChild("ShootButton")

        if stealBtn then stealBtn.MouseButton1Click:Connect(function() task.spawn(autoSteal) end) end
        if goalBtn then goalBtn.MouseButton1Click:Connect(function() task.spawn(autoGoal) end) end
        if cancelBtn then cancelBtn.MouseButton1Click:Connect(cancelCutscene) end
        if shootBtn then 
            shootBtn.MouseButton1Down:Connect(startPower) 
            shootBtn.MouseButton1Up:Connect(endPower) 
        end
    end)
end

task.spawn(function() while task.wait(0.5) do updatePlayerAttributes() end end)
print(">> Script Atualizado: Y (.07 a .23) ✅")
