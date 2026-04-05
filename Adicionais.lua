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
-- AUTO STEAL (DASH > 10 VELOCIDADE)
-- ==========================================
local function executarAutoSteal()
    if not getgenv().ScriptAtivoRRR then return end
    local ball = getBall()
    local hrp = getHRP()
    if not ball or ball:GetAttribute("State") == player.Name then return end

    local pegou = false
    local con; con = ball:GetAttributeChangedSignal("State"):Connect(function()
        if ball:GetAttribute("State") == player.Name then pegou = true con:Disconnect() end
    end)

    task.spawn(function()
        for i = 1, 100 do
            if not getgenv().ScriptAtivoRRR or pegou then break end
            Tackle:FireServer()
            task.wait(0.01)
        end
    end)

    local start = tick()
    while getgenv().ScriptAtivoRRR and not pegou and (tick() - start < 3) do
        local ballVel = ball.AssemblyLinearVelocity
        local ballSpeed = ballVel.Magnitude
        local targetPos = ball.Position

        -- LÓGICA DO DASH: Só ativa se a bola estiver com movimento > 10
        if ballSpeed > 10 then
            -- Antecipa o movimento da bola para o Dash
            targetPos = ball.Position + (ballVel * 0.12)
        end

        -- Teleporte Estável (Pé na bola, sem capotar)
        hrp.Velocity = Vector3.zero
        hrp.RotVelocity = Vector3.zero
        hrp.CFrame = CFrame.new(targetPos.X, targetPos.Y + 2.2, targetPos.Z)
        
        task.wait()
    end
    if con then con:Disconnect() end
end

-- ==========================================
-- POWER SHOT (M2)
-- ==========================================
local segurandoM2 = false
local tempoM2 = 0

local function dispararForte()
    local configs = getgenv().RRR_Configs
    local pwr = tonumber(configs.Keys["PowerValue"]) or 230
    local opt1 = configs.States["PowerOption1"] or false
    local opt2 = configs.States["PowerOption2"] or false
    local dir = (camera.CFrame.LookVector * 1000 + Vector3.new(0, 0.15, 0)).Unit

    for i = 1, 4 do
        Shoot:FireServer(pwr, dir, dir, getHRP().Position, opt1, opt2)
        task.wait()
    end
end

CAS:BindActionAtPriority("M2ChuteForte", function(_, state)
    local configs = getgenv().RRR_Configs
    if not getgenv().ScriptAtivoRRR or not configs.States["PowerShotState"] then 
        return Enum.ContextActionResult.Pass 
    end
    
    if state == Enum.UserInputState.Begin then
        segurandoM2 = true
        tempoM2 = tick()
    elseif state == Enum.UserInputState.End and segurandoM2 then
        segurandoM2 = false
        local hold = tonumber(configs.Keys["HoldValue"]) or 0.5
        if (tick() - tempoM2) >= hold then
            dispararForte()
        end
    end
    return Enum.ContextActionResult.Pass
end, false, 3000, Enum.UserInputType.MouseButton2)

-- ==========================================
-- INPUTS E LOOPS
-- ==========================================
UIS.InputBegan:Connect(function(input, gpe)
    if input.KeyCode == Enum.KeyCode.P then getgenv().ScriptAtivoRRR = false return end
    if gpe or not getgenv().ScriptAtivoRRR then return end
    
    local c = getgenv().RRR_Configs
    if c.States["KeySteal"] and input.KeyCode == Enum.KeyCode[c.Keys["KeySteal"]:upper()] then 
        executarAutoSteal() 
    end
end)

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
