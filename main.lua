-- 1. Carrega a Interface
loadstring(game:HttpGet("https://raw.githubusercontent.com/orytsukz-creator/MonkysHub/refs/heads/main/HubRRR.lua"))()

-- 2. Espera a UI carregar as tabelas globais (IMPORTANTE!)
repeat task.wait() until getgenv().RRR_Configs and getgenv().RRR_Configs.Keys

-- 3. Carrega o script com as funções (Adicionais.lua)
loadstring(game:HttpGet("https://raw.githubusercontent.com/orytsukz-creator/MonkysHub/refs/heads/main/Adicionais.lua"))()
