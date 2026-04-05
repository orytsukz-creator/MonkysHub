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

-- FUNÇÃO DE CHUTE (POWER SHOT)
local function executarChute(forca)
    if not getgenv().ScriptAtivoRRR then return end
    local hrp = getHRP()
    local configs = getgenv().RRR_Configs
    
    -- Puxa as opções True/False da UI
    local opt1 = configs.States["PowerOption1"] or false
    local opt2 = configs.States["PowerOption2"] or false
    local direcao = (camera.CFrame.LookVector * 1000 + Vector3.new(0, 0.15, 0)).Unit

    for i = 1, 4 do
        Shoot:FireServer(forca, direcao, direcao, hrp.Position, opt1, opt2)
        task.wait()
    end
end

-- ==========================================
-- AUTO STEAL (ESTÁVEL - NO PÉ)
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
        -- Mantém o player em pé (Y + 2.2) para o pé tocar na bola
        hrp.Velocity = Vector3.zero
        hrp.RotVelocity = Vector3.zero
        hrp.CFrame = CFrame.new(ball.Position.X, ball.Position.Y + 2.2, ball.Position.Z)
        task.wait()
    end
    if con then con:Disconnect() end
end

-- ==========================================
-- BIND DO M2 (POWER SHOT PC)
-- ==========================================
local segurandoM2 = false
local tempoM2 = 0

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
        local holdNecessario = tonumber(configs.Keys["HoldValue"]) or 0.5
        if (tick() - tempoM2) >= holdNecessario then
            local forca = tonumber(configs.Keys["PowerValue"]) or 230
            executarChute(forca)
        end
    end
    return Enum.ContextActionResult.Pass
end, false, 3000, Enum.UserInputType.MouseButton2)

-- ==========================================
-- INPUTS (TECLAS E MOBILE)
-- ==========================================
UIS.InputBegan:Connect(function(input, gpe)
    if input.KeyCode == Enum.KeyCode.P then getgenv().ScriptAtivoRRR = false return end
    if gpe or not getgenv().ScriptAtivoRRR then return end
    
    local c = getgenv().RRR_Configs
    if c.States["KeySteal"] and input.KeyCode == Enum.KeyCode[c.Keys["KeySteal"]:upper()] then 
        executarAutoSteal() 
    end
end)

-- LOOP DE BUFFS
task.spawn(function()
    while task.wait(0.5) do
        if not getgenv().ScriptAtivoRRR then break end
        local h = getChar():FindFirstChild("Humanoid")
        local c = getgenv().RRR_Configs
        if c.States["KeyTackle"] and h then 
            h.WalkSpeed = 40 
            h.JumpPower = 63 
        end
        player:SetAttribute("Flow", c.States["Flow"])
        player:SetAttribute("Metavision", c.States["Meta"])
    end
end)
