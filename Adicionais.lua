local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

getgenv().ScriptAtivoRRR = true 

local Shoot = ReplicatedStorage:WaitForChild("ShootRE")
local Tackle = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tackle")

-- GOLS E TPs
local GOL_AZUL = { TraveEsq = Vector3.new(-2202, -12, 1006), TraveDir = Vector3.new(-2203, -12, 1049) }
local GOL_VERMELHO = { TraveEsq = Vector3.new(-2907, -12, 1049), TraveDir = Vector3.new(-2908, -12, 1007) }
local GOAL_TP_RED = Vector3.new(-2848, -25, 1030)
local GOAL_TP_BLUE = Vector3.new(-2261, -25, 1030)

local function getChar() return player.Character or player.CharacterAdded:Wait() end
local function getHRP() return getChar():WaitForChild("HumanoidRootPart") end
local function getBall() return workspace:FindFirstChild("Ball") end

local function dispararBola(forca, direcao)
    if not getgenv().ScriptAtivoRRR then return end
    local hrp = getHRP()
    local configs = getgenv().RRR_Configs
    local opt1 = configs.States["PowerOption1"] or false
    local opt2 = configs.States["PowerOption2"] or false
    Shoot:FireServer(forca, direcao, direcao, hrp.Position, opt1, opt2)
end

-- ==========================================
-- AUTO STEAL (POSIÇÃO EXATA DA BOLA)
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
            con:Disconnect() 
        end
    end)

    task.spawn(function()
        for i = 1, 100 do
            if not getgenv().ScriptAtivoRRR or pegou then break end
            Tackle:FireServer()
            task.wait(0.02)
        end
    end)

    local start = tick()
    while getgenv().ScriptAtivoRRR and not pegou and (tick() - start < 3) do
        -- Teleporta exatamente para a posição da bola (X, Y, Z)
        -- Sem cálculos extras, apenas o CFrame da bola
        hrp.CFrame = ball.CFrame
        hrp.AssemblyLinearVelocity = Vector3.zero 
        task.wait()
    end
    if con then con:Disconnect() end
end

-- ==========================================
-- AUTO GOL
-- ==========================================
local function executarAutoGoal()
    local hrp = getHRP()
    local gol = (player.Team.Name == "Red") and GOL_AZUL or GOL_VERMELHO
    local lado = math.random(1,2)
    local off = (lado == 1) and (math.random(15,30)/100) or (math.random(70,85)/100)
    local alvo = gol.TraveEsq:Lerp(gol.TraveDir, off)
    
    local forca = tonumber(getgenv().RRR_Configs.Keys["PowerValue"]) or 230
    local dir = (Vector3.new(alvo.X, -14, alvo.Z) - hrp.Position).Unit + Vector3.new(0, 0.05, 0)
    
    for i = 1, 4 do dispararBola(forca, dir) task.wait() end
end

-- ==========================================
-- INPUTS
-- ==========================================
UIS.InputBegan:Connect(function(input, gpe)
    if input.KeyCode == Enum.KeyCode.P then getgenv().ScriptAtivoRRR = false return end
    if gpe or not getgenv().ScriptAtivoRRR then return end
    
    local c = getgenv().RRR_Configs
    
    if c.States["KeySteal"] and input.KeyCode == Enum.KeyCode[c.Keys["KeySteal"]:upper()] then
        executarAutoSteal()
    end
    
    if c.States["KeyAutoGoal"] and input.KeyCode == Enum.KeyCode[c.Keys["KeyAutoGoal"]:upper()] then
        task.spawn(function()
            local b = getBall()
            if not b then return end
            getHRP().CFrame = b.CFrame
            Tackle:FireServer()
            task.wait(0.1)
            getHRP().CFrame = CFrame.new((player.Team.Name == "Red" and GOAL_TP_BLUE or GOAL_TP_RED))
            task.wait(0.4)
            executarAutoGoal()
        end)
    end
end)

-- POWER SHOT (SYNC COM A UI)
CAS:BindActionAtPriority("M2ChuteForte", function(_, state)
    local configs = getgenv().RRR_Configs
    if not getgenv().ScriptAtivoRRR or not configs.States["PowerShotState"] then 
        return Enum.ContextActionResult.Pass 
    end
    
    if state == Enum.UserInputState.Begin then
        segurandoM2 = true tempoM2 = tick()
    elseif state == Enum.UserInputState.End and segurandoM2 then
        segurandoM2 = false
        local hold = tonumber(configs.Keys["HoldValue"]) or 0.5
        if (tick() - tempoM2) >= hold then
            local pwr = tonumber(configs.Keys["PowerValue"]) or 230
            local dir = (camera.CFrame.LookVector * 1000 + Vector3.new(0, 0.14, 0)).Unit
            for i = 1, 4 do dispararBola(pwr, dir) task.wait() end 
        end
    end
    return Enum.ContextActionResult.Pass
end, false, 3000, Enum.UserInputType.MouseButton2)

-- LOOP STATUS
task.spawn(function()
    while task.wait(0.5) do
        if not getgenv().ScriptAtivoRRR then break end
        local h = getChar():FindFirstChild("Humanoid")
        local c = getgenv().RRR_Configs
        if c.States["KeyTackle"] and h then h.WalkSpeed = 40 h.JumpPower = 63 end
        player:SetAttribute("Flow", c.States["Flow"])
        player:SetAttribute("Metavision", c.States["Meta"])
    end
end)
