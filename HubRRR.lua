--- UPDATE V1
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

-- FUNÇÃO DE DISPARO (USA AS OPÇÕES TRUE/FALSE DA UI)
local function dispararBola(forca, direcao)
    if not getgenv().ScriptAtivoRRR then return end
    local configs = getgenv().RRR_Configs
    local opt1 = configs.States["PowerOption1"] or false
    local opt2 = configs.States["PowerOption2"] or false
    
    Shoot:FireServer(forca, direcao, direcao, getHRP().Position, opt1, opt2)
end

-- ==========================================
-- AUTO STEAL (AJUSTADO PARA O PÉ DO JOGADOR)
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
        for i = 1, 150 do -- Mais agressivo
            if not getgenv().ScriptAtivoRRR or pegou then break end
            Tackle:FireServer()
            task.wait(0.01)
        end
    end)

    local start = tick()
    while getgenv().ScriptAtivoRRR and not pegou and (tick() - start < 3) do
        -- OFFSET DE ALTURA: O HumanoidRootPart fica a ~3 studs do chão. 
        -- Colocamos o HRP 2 studs ACIMA da bola para o pé tocar nela.
        local ballPos = ball.Position
        hrp.CFrame = CFrame.new(ballPos.X, ballPos.Y + 2.2, ballPos.Z) 
        hrp.AssemblyLinearVelocity = Vector3.zero 
        task.wait()
    end
    if con then con:Disconnect() end
end

-- ==========================================
-- POWER SHOT (M2 E MOBILE)
-- ==========================================
local function acionarChuteForte()
    local configs = getgenv().RRR_Configs
    local pwr = tonumber(configs.Keys["PowerValue"]) or 230
    -- Direção baseada na câmera com leve elevação
    local dir = (camera.CFrame.LookVector * 1000 + Vector3.new(0, 0.15, 0)).Unit
    
    for i = 1, 4 do 
        dispararBola(pwr, dir) 
        task.wait() 
    end
end

-- Lógica de segurar (PC)
CAS:BindActionAtPriority("M2ChuteForte", function(_, state)
    local configs = getgenv().RRR_Configs
    if not getgenv().ScriptAtivoRRR or not configs.States["PowerShotState"] then return Enum.ContextActionResult.Pass end
    
    if state == Enum.UserInputState.Begin then
        segurandoM2 = true tempoM2 = tick()
    elseif state == Enum.UserInputState.End and segurandoM2 then
        segurandoM2 = false
        local hold = tonumber(configs.Keys["HoldValue"]) or 0.5
        if (tick() - tempoM2) >= hold then acionarChuteForte() end
    end
    return Enum.ContextActionResult.Pass
end, false, 3000, Enum.UserInputType.MouseButton2)

-- Lógica para o Botão de Chute (Mobile)
task.spawn(function()
    local mobileGui = player:WaitForChild("PlayerGui"):WaitForChild("MobileSupport", 10)
    local shootBtn = mobileGui:WaitForChild("Frame"):WaitForChild("ShootButton")
    
    if shootBtn then
        local startHold = 0
        shootBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                startHold = tick()
            end
        end)
        shootBtn.InputEnded:Connect(function(input)
            local configs = getgenv().RRR_Configs
            if getgenv().ScriptAtivoRRR and configs.States["PowerShotState"] then
                local hold = tonumber(configs.Keys["HoldValue"]) or 0.5
                if (tick() - startHold) >= hold then
                    acionarChuteForte()
                end
            end
        end)
    end
end)

-- ==========================================
-- INPUTS GERAIS (STEAL / GOAL / P)
-- ==========================================
UIS.InputBegan:Connect(function(input, gpe)
    if input.KeyCode == Enum.KeyCode.P then getgenv().ScriptAtivoRRR = false return end
    if gpe or not getgenv().ScriptAtivoRRR then return end
    
    local c = getgenv().RRR_Configs
    if c.States["KeySteal"] and input.KeyCode == Enum.KeyCode[c.Keys["KeySteal"]:upper()] then executarAutoSteal() end
    
    if c.States["KeyAutoGoal"] and input.KeyCode == Enum.KeyCode[c.Keys["KeyAutoGoal"]:upper()] then
        task.spawn(function()
            local b = getBall()
            if not b then return end
            getHRP().CFrame = b.CFrame * CFrame.new(0, 2, 0)
            Tackle:FireServer()
            task.wait(0.1)
            getHRP().CFrame = CFrame.new((player.Team.Name == "Red" and GOAL_TP_BLUE or GOAL_TP_RED))
            task.wait(0.4)
            -- Função de chute de gol automática (aciona o dispararBola)
            local configs = getgenv().RRR_Configs
            local pwr = tonumber(configs.Keys["PowerValue"]) or 230
            acionarChuteForte() 
        end)
    end
end)

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
