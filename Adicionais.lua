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
-- AUTO STEAL (COLADO NA BOLA - SEM DASH)
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

    -- Spam de Tackle
    task.spawn(function()
        while getgenv().ScriptAtivoRRR and not pegou do
            Tackle:FireServer()
            task.wait(0.01)
        end
    end)

    -- Teleporte Seco (Em cima da bola)
    local start = tick()
    while getgenv().ScriptAtivoRRR and not pegou and (tick() - start < 3) do
        -- Vai direto na bola sem previsão de movimento (Sem Dash)
        hrp.CFrame = CFrame.new(ball.Position.X, ball.Position.Y + 2.2, ball.Position.Z)
        
        -- Trava física para estabilidade total
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        
        task.wait()
    end
    if con then con:Disconnect() end
end

-- ==========================================
-- POWER SHOT (M2) - CORRIGIDO
-- ==========================================
local segurandoM2 = false
local tempoInicio = 0

local function dispararChuteForte()
    local configs = getgenv().RRR_Configs
    local pwr = tonumber(configs.Keys["PowerValue"]) or 230
    local opt1 = configs.States["PowerOption1"] or false
    local opt2 = configs.States["PowerOption2"] or false
    
    local dir = (camera.CFrame.LookVector * 1000 + Vector3.new(0, 0.15, 0)).Unit
    Shoot:FireServer(pwr, dir, dir, getHRP().Position, opt1, opt2)
end

CAS:BindActionAtPriority("ChuteM2", function(_, state)
    local configs = getgenv().RRR_Configs
    if not getgenv().ScriptAtivoRRR or not configs.States["PowerShotState"] then 
        return Enum.ContextActionResult.Pass 
    end
    
    if state == Enum.UserInputState.Begin then
        segurandoM2 = true
        tempoInicio = tick()
    elseif state == Enum.UserInputState.End and segurandoM2 then
        segurandoM2 = false
        local hold = tonumber(configs.Keys["HoldValue"]) or 0.5
        if (tick() - tempoInicio) >= hold then
            dispararChuteForte()
        end
    end
    return Enum.ContextActionResult.Pass
end, false, 3000, Enum.UserInputType.MouseButton2)

-- ==========================================
-- LOOP DE BUFFS E INPUTS
-- ==========================================
task.spawn(function()
    while task.wait(0.5) do
        if not getgenv().ScriptAtivoRRR then break end
        local c = getgenv().RRR_Configs
        player:SetAttribute("Metavision", c.States["Meta"])
        player:SetAttribute("Flow", c.States["Flow"])
        
        if c.States["KeyTackle"] then
            local hum = getChar():FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = 40 end
        end
    end
end)

UIS.InputBegan:Connect(function(input, gpe)
    if gpe or not getgenv().ScriptAtivoRRR then return end
    local configs = getgenv().RRR_Configs
    local key = configs.Keys["KeySteal"]
    
    if key and key ~= "" and input.KeyCode == Enum.KeyCode[key:upper()] then
        executarAutoSteal()
    end
end)
