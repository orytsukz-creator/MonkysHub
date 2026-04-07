-- // comandos.lua (REVISADO: DETECÇÃO AUTOMÁTICA MOBILE/PC)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- // 1. DEPENDÊNCIAS
local Shoot = ReplicatedStorage:WaitForChild("ShootRE", 20)
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 20)
local Tackle = Remotes:WaitForChild("Tackle", 10)

-- Aguarda a Hub carregar
repeat task.wait(0.5) until getgenv().RRR_Config and getgenv().RRR_Config.Misc

-- // 2. VARIÁVEIS DE AMBIENTE
local disparoPendente = false
local function getCfg() return getgenv().RRR_Config end
local function getHRP() return player.Character and player.Character:FindFirstChild("HumanoidRootPart") end
local function getBall() return workspace:FindFirstChild("Ball") end

-- Função de Teleporte Seguro
local function tpSeguro(pos)
    local hrp = getHRP()
    if hrp then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.CFrame = CFrame.new(pos)
    end
end

-- // 3. LÓGICA DE DETECÇÃO DE PLATAFORMA (MOBILE SUPPORT)
local function checkBind(input, category, keyName)
    local cfg = getCfg()
    if not (cfg and cfg[category] and cfg[category][keyName] and cfg[category][keyName].Enabled) then 
        return false 
    end

    local bindSalvo = tostring(cfg[category][keyName].Key):upper()
    
    -- DETECÇÃO: Se for MOBILE (Touch ativo e sem Teclado)
    local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

    if isMobile then
        -- Tenta localizar a GUI MobileSupport do Jogo
        local MobileSupport = player.PlayerGui:FindFirstChild("MobileSupport")
        if MobileSupport then
            -- Verifica se o toque do usuário acertou um botão dentro da MobileSupport
            local objects = player.PlayerGui:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
            for _, obj in pairs(objects) do
                -- Se o nome do botão bater com o Bind salvo (ex: "Button1")
                if obj:IsA("GuiButton") and obj.Name:upper() == bindSalvo then
                    return true
                end
            end
        end
    else
        -- LÓGICA PARA PC (Teclado)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            return input.KeyCode.Name:upper() == bindSalvo
        end
    end

    return false
end

-- // 4. FUNÇÕES DE COMBATE
local function executarAutoSteal()
    local hrp, ball = getHRP(), getBall()
    if not (hrp and ball and Tackle) then return end
    if ball:GetAttribute("State") == player.Name then return end

    local distancia = (hrp.Position - ball.Position).Magnitude
    if distancia > 10 then
        local oldPos = hrp.CFrame
        Tackle:FireServer()
        local start = tick()
        while ball and (tick() - start < 1.0) do
            if ball:GetAttribute("State") == player.Name then break end
            tpSeguro(ball.Position + Vector3.new(0, 2, 0))
            task.wait(0.03)
        end
        task.wait(0.05)
        tpSeguro(oldPos.Position)
    else
        Tackle:FireServer()
    end
end

local function executarChuteForte()
    local hrp, cfg = getHRP(), getCfg()
    if not (hrp and cfg and Shoot) then return end
    local pwr = tonumber(cfg.Misc.PowerShot.Power) or 230
    local dir = (camera.CFrame.LookVector * 310000 + (camera.CFrame.LookVector + Vector3.new(0, 0.14, 0)) * 10000000).Unit
    Shoot:FireServer(pwr, dir, dir, hrp.Position, cfg.Misc.PowerShot.Effect, cfg.Misc.PowerShot.Effect2)
end

-- // 5. CONEXÕES DE INPUT
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if checkBind(input, "Misc", "AutoSteal") then
        executarAutoSteal()
    end
end)

-- Lógica do PowerShot (Segurar botão)
local pStart = 0
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if checkBind(input, "Misc", "PowerShot") or (not UIS.TouchEnabled and input.UserInputType == Enum.UserInputType.MouseButton2) then
        pStart = tick()
    end
end)

UIS.InputEnded:Connect(function(input)
    if checkBind(input, "Misc", "PowerShot") or (not UIS.TouchEnabled and input.UserInputType == Enum.UserInputType.MouseButton2) then
        local cfg = getCfg()
        if cfg and cfg.Misc.PowerShot.Enabled then
            local holdReq = tonumber(cfg.Misc.PowerShot.HoldTime) or 0.47
            if (tick() - pStart) >= holdReq and not disparoPendente then
                disparoPendente = true
                executarChuteForte()
                task.wait(0.1)
                disparoPendente = false
            end
        end
    end
end)

-- // 6. LOOP DE ATRIBUTOS
task.spawn(function()
    while task.wait(1) do
        local cfg = getCfg()
        if cfg and cfg.Player then
            pcall(function()
                player:SetAttribute("Flow", cfg.Player.FakeFlow)
                player:SetAttribute("Metavision", cfg.Player.FakeMetavision)
            end)
        end
    end
end)

print(">> [RRR] SISTEMA HÍBRIDO (PC/MOBILE) ATIVADO!")
