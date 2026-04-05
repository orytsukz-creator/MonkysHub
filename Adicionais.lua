local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

getgenv().ScriptAtivoRRR = true 

local Tackle = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tackle")

local function getChar() return player.Character or player.CharacterAdded:Wait() end
local function getHRP() return getChar():WaitForChild("HumanoidRootPart") end
local function getBall() return workspace:FindFirstChild("Ball") end

-- ==========================================
-- AUTO STEAL (SEM DASH + TP BACK)
-- ==========================================
local function executarAutoSteal()
    if not getgenv().ScriptAtivoRRR then return end
    local ball = getBall()
    local hrp = getHRP()
    
    if not ball or ball:GetAttribute("State") == player.Name then return end

    local posOriginal = hrp.CFrame
    local pegou = false
    local tempoMaximo = 3 -- 3 segundos de tentativa

    -- Detecta se pegou a bola
    local con; con = ball:GetAttributeChangedSignal("State"):Connect(function()
        if ball:GetAttribute("State") == player.Name then 
            pegou = true 
        end
    end)

    -- Início do Processo
    local start = tick()
    
    -- Loop de TP e Tackle
    while getgenv().ScriptAtivoRRR and not pegou and (tick() - start < tempoMaximo) do
        -- TELEPORTE SECO (Exatamente na bola, sem cálculos de dash)
        hrp.CFrame = CFrame.new(ball.Position.X, ball.Position.Y + 2.1, ball.Position.Z)
        
        -- MUITO IMPORTANTE: Zera a velocidade para MATAR o dash
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        
        -- Spam de Tackle
        Tackle:FireServer()
        
        task.wait() -- Roda na frequência do servidor
    end

    -- TP BACK (Executa se pegou a bola OU se deu timeout de 3s)
    if con then con:Disconnect() end
    hrp.CFrame = posOriginal
    hrp.AssemblyLinearVelocity = Vector3.zero -- Garante que você não chegue no TP Back com impulso
end

-- ==========================================
-- INPUTS
-- ==========================================
UIS.InputBegan:Connect(function(input, gpe)
    if gpe or not getgenv().ScriptAtivoRRR then return end
    
    local configs = getgenv().RRR_Configs
    local key = configs.Keys["KeySteal"]
    
    if key and key ~= "" and input.KeyCode == Enum.KeyCode[key:upper()] then
        executarAutoSteal()
    end
end)

-- Loop de Atributos (Meta/Flow)
task.spawn(function()
    while task.wait(0.5) do
        if not getgenv().ScriptAtivoRRR then break end
        local c = getgenv().RRR_Configs
        if c.States["Meta"] ~= nil then player:SetAttribute("Metavision", c.States["Meta"]) end
        if c.States["Flow"] ~= nil then player:SetAttribute("Flow", c.States["Flow"]) end
    end
end)
