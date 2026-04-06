local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Remotes do Jogo (Ajuste os nomes se necessário)
local ShootRE = ReplicatedStorage:WaitForChild("ShootRE", 5)
local TackleRE = ReplicatedStorage:FindFirstChild("Tackle", true) or ReplicatedStorage:FindFirstChild("TackleRE", true)

-- // Verificação de Chat
local function IsTyping()
    return UIS:GetFocusedTextBox() ~= nil
end

-- // 1. LÓGICA DE CHUTE (Auto Goal)
local function executarAutoGoal()
    local cfg = getgenv().RRR_Config.Misc.AutoGoal
    if not cfg.Enabled then return end
    
    local ball = workspace:FindFirstChild("Ball")
    if not ball or ball:GetAttribute("State") ~= LocalPlayer.Name then return end
    
    -- Procura o Gol (Geralmente uma Part chamada Goal ou dentro de um Model)
    local goal = workspace:FindFirstChild("Goal", true) 
    if goal and ShootRE then
        local pwr = tonumber(getgenv().RRR_Config.Misc.PowerShot.Power) or 230
        -- Ângulo de 0.14 como solicitado
        local direcao = (goal.Position - ball.Position).Unit + Vector3.new(0, 0.14, 0)
        
        ShootRE:FireServer(
            pwr, 
            direcao, 
            direcao, 
            LocalPlayer.Character.HumanoidRootPart.Position, 
            getgenv().RRR_Config.Misc.PowerShot.Effect, 
            getgenv().RRR_Config.Misc.PowerShot.Effect2
        )
    end
end

-- // 2. LÓGICA DE ROUBO (Auto Steal com trava de Magnitude)
local function executarAutoSteal()
    local cfg = getgenv().RRR_Config.Misc.AutoSteal
    if not cfg.Enabled then return end
    
    local ball = workspace:FindFirstChild("Ball")
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not ball or not hrp or ball:GetAttribute("State") == LocalPlayer.Name then return end
    
    local distance = (ball.Position - hrp.Position).Magnitude
    local oldPos = hrp.CFrame
    
    -- REGRA: Só dá o "Dash" (TP) se a distância for maior que 10
    if distance > 10 then
        hrp.CFrame = CFrame.new(ball.Position.X, ball.Position.Y + 2.1, ball.Position.Z)
        hrp.Velocity = Vector3.zero
        
        if TackleRE then TackleRE:FireServer() end
        
        task.wait(0.1) -- Tempo curto para o server registrar o roubo
        hrp.CFrame = oldPos -- Volta pra posição original (TP Back)
    else
        -- Se estiver perto (menor que 10), apenas tenta o tackle sem dash/TP
        if TackleRE then TackleRE:FireServer() end
    end
end

-- // 3. FAKE FLOW & METAVISION (Efeitos Visuais)
local ColorGrading = Instance.new("ColorCorrectionEffect", Lighting)
local BlueSky = Instance.new("BloomEffect", Lighting)
ColorGrading.Enabled = false
BlueSky.Enabled = false

RunService.Heartbeat:Connect(function()
    local cfg = getgenv().RRR_Config.Player
    if not cfg then return end

    -- Fake Flow (Efeito de Saturação e Bloom)
    if cfg.FakeFlow then
        ColorGrading.Enabled = true
        ColorGrading.Saturation = 1.5
        ColorGrading.Contrast = 0.5
    elseif not cfg.FakeMetavision then
        ColorGrading.Enabled = false
    end

    -- Fake Metavision (Efeito Azulado e FOV)
    if cfg.FakeMetavision then
        ColorGrading.Enabled = true
        ColorGrading.TintColor = Color3.fromRGB(150, 180, 255)
        workspace.CurrentCamera.FieldOfView = 110
    else
        if not cfg.FakeFlow then ColorGrading.Enabled = false end
        ColorGrading.TintColor = Color3.fromRGB(255, 255, 255)
    end
end)

-- // 4. DETECÇÃO DE BOTÕES (BINDS)
UIS.InputBegan:Connect(function(input, processed)
    if processed or IsTyping() then return end
    
    local cfg = getgenv().RRR_Config
    
    -- Bind Auto Goal
    if input.KeyCode.Name == cfg.Misc.AutoGoal.Key then
        executarAutoGoal()
    end
    
    -- Bind Auto Steal
    if input.KeyCode.Name == cfg.Misc.AutoSteal.Key then
        executarAutoSteal()
    end
    
    -- Bind Cancel Cutscene (Exemplo: Deleta câmeras locais de replay)
    if input.KeyCode.Name == cfg.Player.CancelCutscene.Key then
        local cam = workspace.CurrentCamera
        if cam:FindFirstChild("CutsceneCamera") or #cam:GetChildren() > 0 then
            cam:ClearAllChildren()
            warn("Cutscene Cancelada!")
        end
    end
end)

-- Botão de Pânico (P) - Limpa tudo
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.P then
        ColorGrading:Destroy()
        BlueSky:Destroy()
        getgenv().RRR_Config = nil
        if CoreGui:FindFirstChild("RRR_Hub") then CoreGui.RRR_Hub:Destroy() end
        warn("RRR HUB Encerrado.")
    end
end)

print("--- RRR HUB: Comandos.lua Rodando ---")
