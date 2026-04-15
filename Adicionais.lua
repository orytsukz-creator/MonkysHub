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

local POS_CHUTE_RED  = Vector3.new(-2835, -25, 1033)
local POS_CHUTE_BLUE = Vector3.new(-2260, -25, 1047)

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

local function tpGolInimigo()
    local hrp = getHRP()
    if not hrp then return end

    local destino

    if player.Team and player.Team.Name == "Red" then
        -- Red chuta no Azul
        destino = POS_CHUTE_BLUE
    else
        -- Blue chuta no Red
        destino = POS_CHUTE_RED
    end

    tpSeguro(CFrame.new(destino))
end

-- ==========================================
-- AUTO GOL DINÂMICO (LONGE .15 | PERTO .07)
-- ==========================================
local function realizarChuteAutoGol()
    local hrp = getHRP()
    if not hrp then return end

    -- Sorteio de Canto: 0.22 (Esquerda) e 0.78 (Direita)
    -- Ajustado para evitar o poste em distâncias longas
    local sorteio = math.random()
    if sorteio > 0.35 and sorteio < 0.65 then
        sorteio = (sorteio < 0.5) and 0.22 or 0.78
    end

    local alvoFinal
    if player.Team and player.Team.Name == "Red" then
        alvoFinal = TRAVE_BLUE_L:Lerp(TRAVE_BLUE_R, math.clamp(sorteio, 0.22, 0.78))
    else
        alvoFinal = TRAVE_RED_L:Lerp(TRAVE_RED_R, math.clamp(sorteio, 0.22, 0.78))
    end

    local distancia = (alvoFinal - hrp.Position).Magnitude
    
    -- LÓGICA DINÂMICA (LIMITES: 0.07 - 0.15)
    local alturaMin = 0.07 -- Perto
    local alturaMax = 0.3 -- Longe (400 studs)
    local distanciaLimite = 800

    local progresso = math.clamp(distancia / distanciaLimite, 0, 1)
    local alturaDinamica = alturaMin + (progresso * (alturaMax - alturaMin))

    -- Direção Horizontal
    local direcaoHorizontal = Vector3.new(alvoFinal.X - hrp.Position.X, 0, alvoFinal.Z - hrp.Position.Z).Unit
    
    -- Direção Base com o Y dinâmico aplicado
    local dirBase = Vector3.new(direcaoHorizontal.X, alturaDinamica, direcaoHorizontal.Z).Unit
    
    -- Impulso: 3.5x no Horizontal e Y neutralizado (dividido por 3.5)
    local impulsoBruto = dirBase * 3.5
    local dirImpulso = Vector3.new(impulsoBruto.X, impulsoBruto.Y / 3.5, impulsoBruto.Z)

    Shoot:FireServer(230, dirBase, dirImpulso, hrp.Position, true, true)
    
    -- Debug para conferir se a altura está batendo com a distância
    -- print(string.format("Dist: %.1f | Altura: %.3f", distancia, alturaDinamica))
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

local function oldAutoGoal()

    local ball = getBall()
    local hrp = getHRP()

    if not (ball and hrp) then
        return
    end

    local pegou = false
    local start = tick()

    while ball and ball.Parent and tick() - start < 3 do

        local state = ball:GetAttribute("State")

        -- PEGOU = TP IMEDIATO
        if state == "UNTOUCHABLE" or state == player.Name then
            pegou = true
            break
        end

        -- vai na bola
        hrp.CFrame = CFrame.new(
            ball.Position +
            (ball.AssemblyLinearVelocity * 0.145) +
            Vector3.new(0,2,0)
        )

        Tackle:FireServer()

        task.wait(0.03)
    end

    if not pegou then
        return
    end

    -- TELEPORTA PRO GOL INIMIGO NA HORA
    tpGolInimigo()
	hrp = getHRP()
	hrp.Anchored = true
	task.wait(1)

    hrp = getHRP()
    if not hrp then return end

    local alvo

    if player.Team and player.Team.Name == "Red" then
        alvo = (TRAVE_BLUE_L + TRAVE_BLUE_R) / 2
    else
        alvo = (TRAVE_RED_L + TRAVE_RED_R) / 2
    end

    local dir = (alvo - hrp.Position).Unit
    local dirBase = Vector3.new(dir.X, 0.10, dir.Z).Unit
    local dirImpulso = dirBase * 1.8

	hrp.Anchored = false
    Shoot:FireServer(
        230,
        dirBase,
        dirImpulso,
        hrp.Position,
        true,
        true
    )
end


local function autoGoal()
    local cfg = getCfg()

    if cfg.Misc.AutoGoal.Enabled ~= true or Ativo.Goal then
        return
    end

    Ativo.Goal = true

    local mode = cfg.Misc.AutoGoal.Type or "New"

    if mode == "Old" then
        oldAutoGoal()
    else -- NEW
        realizarChuteAutoGol()
    end

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
task.spawn(function()

	local Teams = game:GetService("Teams")
	local RunService = game:GetService("RunService")
	local player = game.Players.LocalPlayer

	-- limpa antigos
	pcall(function()
		if workspace:FindFirstChild("BlueGoalHB") then
			workspace.BlueGoalHB:Destroy()
		end

		if workspace:FindFirstChild("RedGoalHB") then
			workspace.RedGoalHB:Destroy()
		end
	end)

	--================================================
	-- CRIAR HITBOX
	--================================================

	local function criarHB(nome, p1, p2)
		local center = (p1 + p2) / 2
		center = center - Vector3.new(0,8,0)

		local part = Instance.new("Part")
		part.Name = nome
		part.Anchored = true
		part.CanCollide = false
		part.Transparency = 1
		part.Size = Vector3.new(
			math.abs(p2.X - p1.X),
			120,
			math.abs(p2.Z - p1.Z)
		)
		part.CFrame = CFrame.new(center)
		part.Parent = workspace

		return part
	end

	local blueHB = criarHB(
		"BlueGoalHB",
		Vector3.new(-2295,-25,907),
		Vector3.new(-2201,-25,1150)
	)

	local redHB = criarHB(
		"RedGoalHB",
		Vector3.new(-2815,-25,1149),
		Vector3.new(-2907,-25,907)
	)

	--================================================
	-- TIME REAL PELO POSITION
	--================================================

	local function getRealTeam()
		local pos = tostring(player:GetAttribute("Position") or "")

		if string.find(pos,"Blue") then
			return "Blue"
		elseif string.find(pos,"Red") then
			return "Red"
		end

		return nil
	end

	--================================================
	-- DENTRO DA BOX
	--================================================

	local function inside(v, part)
		local rel = part.CFrame:PointToObjectSpace(v)
		local half = part.Size / 2

		return math.abs(rel.X) <= half.X
		and math.abs(rel.Y) <= half.Y
		and math.abs(rel.Z) <= half.Z
	end

	--================================================
	-- ESTADO
	--================================================

	local changed = false
	local locked = nil

	--================================================
	-- LOOP
	--================================================

	RunService.RenderStepped:Connect(function()

		local cfg = getCfg()
		if not cfg or not cfg.Player then return end

		------------------------------------------------
		-- DESATIVADO
		------------------------------------------------
		if cfg.Player.SkillOnGkBox ~= true then

			if changed then
				local real = getRealTeam()

				if real then
					local t = Teams:FindFirstChild(real)
					if t then
						player.Team = t
					end
				end

				changed = false
				locked = nil
			end

			return
		end

		------------------------------------------------
		-- ATIVADO
		------------------------------------------------

		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		local real = getRealTeam()
		if not real then return end

		local pos = hrp.Position

		local inBlue = inside(pos, blueHB)
		local inRed = inside(pos, redHB)

		------------------------------------------------
		-- JÁ TROCADO
		------------------------------------------------

		if changed then
			if locked and not inside(pos, locked) then

				local t = Teams:FindFirstChild(real)
				if t then
					player.Team = t
				end

				changed = false
				locked = nil
			end

			return
		end

		------------------------------------------------
		-- BLUE ENTROU NO PRÓPRIO GOL
		------------------------------------------------

		if real == "Blue" and inBlue then
			local enemy = Teams:FindFirstChild("Red")

			if enemy then
				player.Team = enemy
				changed = true
				locked = blueHB
			end

		------------------------------------------------
		-- RED ENTROU NO PRÓPRIO GOL
		------------------------------------------------

		elseif real == "Red" and inRed then
			local enemy = Teams:FindFirstChild("Blue")

			if enemy then
				player.Team = enemy
				changed = true
				locked = redHB
			end
		end

	end)

end)

print(">> Script Atualizado: Y (.07 a .23) ✅")
