local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

getgenv().ScriptAtivoRRR = true 

local Shoot = ReplicatedStorage:WaitForChild("ShootRE")
local Tackle = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tackle")

local function getChar() return player.Character or player.CharacterAdded:Wait() end
local function getHRP() return getChar():WaitForChild("HumanoidRootPart") end
local function getBall() return workspace:FindFirstChild("Ball") end

-- ==========================================
-- AUTO STEAL (DIRETO NA BOLA - SEM DASH)
-- ==========================================
local function executarAutoSteal()
    if not getgenv().ScriptAtivoRRR then return end
    local ball = getBall()
    local hrp = getHRP()
    if not ball or ball:GetAttribute("State") == player.Name then return end

    local pegou = false
    local con; con = ball:GetAttributeChangedSignal("State"):Connect(function()
        if ball:GetAttribute("State") == player.Name then 
            pegou = true 
            if con then con:Disconnect() end 
        end
    end)

    -- Spam de Tackle (Roubo)
    task.spawn(function()
        while getgenv().ScriptAtivoRRR and not pegou do
            Tackle:FireServer()
            task.wait(0.01)
        end
    end)

    -- Teleporte Estável (Colado na bola)
    local start = tick()
    while getgenv().ScriptAtivoRRR and not pegou and (tick() - start < 3) do
        -- Vai exatamente na posição da bola (Y + 2.2 para ficar em pé)
        hrp.CFrame = CFrame.new(ball.Position.X, ball.Position.Y + 2.2, ball.Position.Z)
        
        -- Trava física para não capotar ou sair voando
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        
        task.wait()
    end
    if con then con:Disconnect() end
end

-- ==========================================
-- LÓGICA DO CHUTE (POWER SHOT)
-- ==========================================
local function dispararChuteForte()
    local configs = getgenv().RRR_Configs
    if not configs.States["PowerShotState"] then return end
    
    local forca = tonumber(configs.Keys["PowerValue"]) or 230
    local opt1 = configs.States["PowerOption1"] or false
    local opt2 = configs.States["PowerOption2"] or false
    
    -- Direção baseada para onde a câmera aponta
    local look = camera.CFrame.LookVector
    local direcao = (look * 1000 + Vector3.new(0, 0.15, 0)).Unit

    -- Dispara o remote de chute
    Shoot:FireServer(forca, direcao, direcao, getHRP().Position, opt1, opt2)
end

-- Bind do Mouse 2 (Segura e solta)
local segurandoM2 = false
local tempoInicio = 0

CAS:BindActionAtPriority("ChuteM2", function(_, state)
    if not getgenv().ScriptAtivoRRR then return Enum.ContextActionResult.Pass end
    
    if state == Enum.UserInputState.Begin then
        segurandoM2 = true
        tempoInicio = tick()
    elseif state == Enum.UserInputState.End and segurandoM2 then
        segurandoM2 = false
        local holdNecessario = tonumber(getgenv().RRR_Configs.Keys["HoldValue"]) or 0.5
        
        -- Só chuta se segurou pelo tempo definido na UI
        if (tick() - tempoInicio) >= holdNecessario then
            dispararChuteForte()
        end
    end
    return Enum.ContextActionResult.Pass
end, false, 3000, Enum.UserInputType.MouseButton2)

-- ==========================================
-- LOOP DE BUFFS E STATUS (OUTROS BOTÕES)
-- ==========================================
task.spawn(function()
    while task.wait(0.3) do
        if not getgenv().ScriptAtivoRRR then break end
        local char = getChar()
        local hum = char:FindFirstChild("Humanoid")
        local configs = getgenv().RRR_Configs
        
        -- Spam Tackle (Se o botão estiver ON)
        if configs.States["KeyTackle"] then
            Tackle:FireServer()
            if hum then 
                hum.WalkSpeed = 40 
                hum.JumpPower = 63
            end
        end

        -- Atributos (Metavision / Flow)
        player:SetAttribute("Metavision", configs.States["Meta"])
        player:SetAttribute("Flow", configs.States["Flow"])
        
        -- Cancel Animation (Se configurado)
        if configs.States["KeyCancelAnim"] then
            -- Lógica simples de resetar animação se necessário
        end
    end
end)

-- ==========================================
-- INPUTS DE TECLADO
-- ==========================================
UIS.InputBegan:Connect(function(input, gpe)
    if gpe or not getgenv().ScriptAtivoRRR then return end
    
    local configs = getgenv().RRR_Configs
    local teclaSteal = configs.Keys["KeySteal"]
    
    -- Auto Steal
    if teclaSteal and teclaSteal ~= "" and input.KeyCode == Enum.KeyCode[teclaSteal:upper()] then
        executarAutoSteal()
    end
    
    -- Desativar Script (Tecla P)
    if input.KeyCode == Enum.KeyCode.P then
        getgenv().ScriptAtivoRRR = false
        print("Script RRR Desativado")
    end
end)
