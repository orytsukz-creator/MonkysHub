local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- // DEBUG: Verifica se a UI existe
if not getgenv().RRR_Config then
    warn("⚠️ ERRO: A Interface (UI) não foi carregada antes dos comandos!")
else
    print("✅ Comandos detectaram a UI com sucesso.")
end

local function getCfg()
    return getgenv().RRR_Config
end

-- Remotes
local Shoot = ReplicatedStorage:WaitForChild("ShootRE")
local Tackle = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tackle")

-- // LOOP DE VERIFICAÇÃO (Vê se a UI está mandando os dados)
task.spawn(function()
    local lastStateGoal = false
    while task.wait(0.5) do
        local cfg = getCfg()
        if cfg then
            -- Printa no console se o estado mudar (só pra você testar)
            if cfg.Misc.AutoGoal.Enabled ~= lastStateGoal then
                lastStateGoal = cfg.Misc.AutoGoal.Enabled
                print("🔄 Sincronia: AutoGoal agora está " .. (lastStateGoal and "ON" or "OFF"))
            end
            
            -- Atributos de Flow/Meta
            if cfg.Player.FakeFlow then player:SetAttribute("Flow", true) end
            if cfg.Player.FakeMetavision then player:SetAttribute("Metavision", true) end
        end
    end
end)

-- // INPUTS
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local cfg = getCfg()
    if not cfg then return end

    -- Verifica se a tecla apertada é a que está na UI
    local keySteal = cfg.Misc.AutoSteal.Key:upper()
    local keyGoal = cfg.Misc.AutoGoal.Key:upper()

    if input.KeyCode == Enum.KeyCode[keySteal] and cfg.Misc.AutoSteal.Enabled then
        print("🚀 Executando Auto Steal...")
        -- (Lógica do tackle aqui...)
    end

    if input.KeyCode == Enum.KeyCode[keyGoal] and cfg.Misc.AutoGoal.Enabled then
        print("🚀 Executando Auto Goal...")
        -- (Lógica do gol aqui...)
    end
end)

print("RRR DEBUG: Comandos carregados. Cheque o F9 para ver as mensagens de sincronia.")
