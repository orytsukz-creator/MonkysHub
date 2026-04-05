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
-- AUTO STEAL (TELEPORTE PARADO NA BOLA)
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

    -- Spam de Roubo
    task.spawn(function()
        while getgenv().ScriptAtivoRRR and not pegou do
            Tackle:FireServer()
            task.wait(0.01)
        end
    end)

    -- Teleporte Estrito (Vai na posição exata da bola, sem adicionar velocidade)
    local start = tick()
    while getgenv().ScriptAtivoRRR and not pegou and (tick() - start < 3) do
        -- Posição exata. Sem somar velocidade da bola (Ball.Position puro)
        hrp.CFrame = CFrame.new(ball.Position.X, ball.Position.Y + 2.1, ball.Position.Z)
        
        -- Zera qualquer força que faria o boneco "dashar" ou deslizar
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        
        task.wait()
    end
    if con then con:Disconnect() end
end

-- ==========================================
-- POWER SHOT (M2 CORRIGIDO)
-- ==========================================
local function dispararChuteForte()
    local configs = getgenv().RRR_Configs
    if not configs.States["PowerShotState"] then return end
    
    local pwr = tonumber(configs.Keys["PowerValue"]) or 230
    local opt1 = configs.States["PowerOption1"] or false
    local opt2 = configs.States["PowerOption2"] or false
    
    local look = camera.CFrame.LookVector
    local dir = (look * 1000 + Vector3.new(0, 0.15, 0)).Unit

    Shoot:FireServer(pwr, dir, dir, getHRP().Position, opt1, opt2)
end

local segurandoM2 = false
local tempoM2 = 0

CAS:BindActionAtPriority("M2Shot", function(_, state)
    if state == Enum.UserInputState.Begin then
        segurandoM2 = true
        tempoM2 = tick()
    elseif state == Enum.UserInputState.End and segurandoM2 then
        segurandoM2 = false
        local hold = tonumber(getgenv().RRR_Configs.Keys["HoldValue"]) or 0.5
        if (tick() - tempoM2) >= hold then
            dispararChuteForte()
        end
    end
    return Enum.ContextActionResult.Pass
end, false, 3000, Enum.UserInputType.MouseButton2)

-- ==========================================
-- INPUTS E LOOP DE STATUS
-- ==========================================
UIS.InputBegan:Connect(function(input, gpe)
    if gpe or not getgenv().ScriptAtivoRRR then return end
    local c = getgenv().RRR_Configs
    local k = c.Keys["KeySteal"]
    
    if k and k ~= "" and input.KeyCode == Enum.KeyCode[k:upper()] then
        executarAutoSteal()
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if not getgenv().ScriptAtivoRRR then break end
        local c = getgenv().RRR_Configs
        player:SetAttribute("Metavision", c.States["Meta"])
        player:SetAttribute("Flow", c.States["Flow"])
        
        -- SpamTackle/Speed se o botão da UI estiver ON
        if c.States["KeyTackle"] then
            local h = getChar():FindFirstChild("Humanoid")
            if h then h.WalkSpeed = 40 end
        end
    end
end)
