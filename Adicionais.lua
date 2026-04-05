local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Remotes
local Shoot = ReplicatedStorage:WaitForChild("ShootRE")
local Tackle = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tackle")

-- Variáveis de Controle
local ultimoChute = 0
local COOLDOWN_TIME = 0.3 -- Cooldown de 0.3s para sincronia
local segurando, tempoInicio = false, 0

-- Mobile Setup
local MobileFrame = player:WaitForChild("PlayerGui"):WaitForChild("MobileSupport"):WaitForChild("Frame")
local ShootBtn = MobileFrame:WaitForChild("ShootButton")
local TackleBtn = MobileFrame:WaitForChild("TackleButton")
local TalentBtn = MobileFrame:WaitForChild("TalentButton")

-- Funções Base
local function getHRP() return player.Character:WaitForChild("HumanoidRootPart") end
local function getBall() return workspace:FindFirstChild("Ball") end

-- ==========================================
-- LÓGICA DO POWER SHOT (MELHORADA)
-- ==========================================
local function chutePower()
    -- Verifica se já passou o tempo de cooldown
    if tick() - ultimoChute < COOLDOWN_TIME then return end
    ultimoChute = tick()
    
    local hrp = getHRP()
    -- Puxa os valores da UI ou usa padrões se estiverem vazios
    local forcaUI = tonumber(getgenv().RRR_Configs.Keys["PowerValue"]) or 230
    
    local dir = (camera.CFrame.LookVector * 310000 + (camera.CFrame.LookVector + Vector3.new(0,.14,0)) * 10000000).Unit
    Shoot:FireServer(forcaUI, dir, dir, hrp.Position, true, true)
end

local function startHold()
    if not getgenv().RRR_Configs.States["PowerValue"] then return end
    segurando = true
    tempoInicio = tick()
end

local function endHold()
    if not segurando then return end
    segurando = false
    
    local duracao = tick() - tempoInicio
    -- Pega o Hold Time da UI (ex: 0.47)
    local holdNecessario = tonumber(getgenv().RRR_Configs.Keys["HoldValue"]) or 0.47
    
    if duracao >= holdNecessario then
        -- Dispara 4 vezes para garantir o Power Shot (conforme seu pedido)
        for i = 1, 4 do 
            chutePower() 
            task.wait(0.01) 
        end
    end
end

-- ==========================================
-- AUTO GOL (SISTEMA QUE HAVIA PARADO)
-- ==========================================
local function executarAutoGol()
    if not getgenv().RRR_Configs.States["KeyAutoGoal"] then return end
    
    local ball = getBall()
    if not ball then return end
    
    local hrp = getHRP()
    -- Teleporta pra bola e dá tackle pra pegar
    hrp.CFrame = CFrame.new(ball.Position + Vector3.new(0, 2, 0))
    Tackle:FireServer()
    
    task.wait(0.3) -- Tempo para o servidor processar a posse
    
    -- Lógica de chute pro gol inimigo
    local alvoTP = (player.Team.Name == "Red") and Vector3.new(-2261, -25, 1030) or Vector3.new(-2848, -25, 1030)
    hrp.CFrame = CFrame.new(alvoTP)
    
    task.wait(0.5)
    chutePower() -- Usa a função de chute definida acima
end

-- ==========================================
-- BINDS E INPUTS
-- ==========================================

-- PC (M2 para PowerShot / Teclas para o resto)
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then startHold() end
    
    -- Auto Gol Tecla
    local keyGoal = getgenv().RRR_Configs.Keys["KeyAutoGoal"]
    if keyGoal ~= "" and input.KeyCode == Enum.KeyCode[keyGoal:upper()] then
        executarAutoGol()
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then endHold() end
end)

-- MOBILE (Mapeamento total)
ShootBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then startHold() end end)
ShootBtn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then endHold() end end)

TalentBtn.MouseButton1Click:Connect(executarAutoGol)

TackleBtn.MouseButton1Click:Connect(function()
    if getgenv().RRR_Configs.States["KeySteal"] then
        -- Coloque aqui sua função de AutoSteal (executarAutoTackle)
        executarAutoTackle() 
    end
end)

-- LOOP ATRIBUTOS
task.spawn(function()
    while true do
        if getgenv().RRR_Configs.States["Flow"] then player:SetAttribute("Flow", true) end
        if getgenv().RRR_Configs.States["Meta"] then player:SetAttribute("Metavision", true) end
        task.wait(10)
    end
end)

print("Adicionais Carregados: PowerShot e AutoGol corrigidos!")
