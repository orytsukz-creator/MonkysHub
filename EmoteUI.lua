local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Tabela de IDs (Incluindo a Exclusiva)
local emotes = {
    {nome = "Rin Cutscene", id = "121090548140901", exclusivo = true}, -- EXCLUSIVO
    {nome = "Think", id = "99006875625158"}, {nome = "Think2", id = "119765570214121"},
    {nome = "Victory", id = "103421847601450"}, {nome = "My Dream", id = "116152016189256"},
    {nome = "Nice To Meet You", id = "94736990737189"}, {nome = "Prodigy", id = "89404477602877"},
    {nome = "Jackpoint", id = "81196531443865"}, {nome = "Honored One", id = "130265558158027"},
    {nome = "Executed", id = "72672037473914"}, {nome = "Duality2", id = "78704181592689"},
    {nome = "Strongest", id = "75792602056927"}, {nome = "Ice King", id = "105910359170022"},
    {nome = "Bad Time", id = "78570002249522"}, {nome = "Bird Brain", id = "72082681471851"},
    {nome = "Death Aura", id = "85857795820883"}, {nome = "Half Cold Half", id = "97895427608945"},
    {nome = "Egotistic Win", id = "98603428583779"}, {nome = "Blue Rose", id = "136148459656688"},
    {nome = "Keyblade Master", id = "109606947558561"}, {nome = "Demon King", id = "78380706895512"},
    {nome = "Demon Wings", id = "89845967157258"}, {nome = "Soda Pop", id = "111004175847659"},
    {nome = "I'll Crush You", id = "103416634616367"}, {nome = "Arise", id = "85857795820883"},
    {nome = "Candy Eater", id = "72817927510621"}, {nome = "FireWorks", id = "121761885959239"},
    {nome = "Gang Dance", id = "121761885959239"}, {nome = "Menacing", id = "123801827585367"},
    {nome = "Funeral For Living", id = "136870874987904"}, {nome = "Watch Tower", id = "131484246085027"},
    {nome = "Give You Up", id = "78169849689636"}, {nome = "Camaleon", id = "84763822681010"},
    {nome = "Take L", id = "131449237110149"}, {nome = "Griddy", id = "117269191029399"},
    {nome = "Duality", id = "122077724933224"}, {nome = "Jump Style", id = "125926744085888"},
    {nome = "Skeleton", id = "78570002249522"}, {nome = "Menacing2", id = "95289103286896"},
    {nome = "Pride of Japan", id = "84557915621928"}, {nome = "Strongest2", id = "75792602056927"},
    {nome = "Cute Dance", id = "114838799237262"}, {nome = "Disgusting", id = "97895427608945"},
    {nome = "Cute", id = "123764969253629"}
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EmoteHub_Final"
ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 440)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -220)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Barra de Pesquisa
local SearchBar = Instance.new("TextBox")
SearchBar.Size = UDim2.new(1, -20, 0, 35)
SearchBar.Position = UDim2.new(0, 10, 0, 50)
SearchBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SearchBar.Text = ""
SearchBar.PlaceholderText = "Pesquisar emote..."
SearchBar.TextColor3 = Color3.new(1,1,1)
SearchBar.Font = Enum.Font.Gotham
SearchBar.TextSize = 14
SearchBar.Parent = MainFrame

local SBCorner = Instance.new("UICorner")
SBCorner.CornerRadius = UDim.new(0, 6)
SBCorner.Parent = SearchBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "EMOTE SEARCHER"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -110)
Scroll.Position = UDim2.new(0, 10, 0, 100)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 2
Scroll.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 5)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Scroll

--- LÓGICA DE ANIMAÇÃO ---

local activeTrack = nil
local activeId = nil
local isExclusivo = false

local function StopEmote()
    if activeTrack then
        activeTrack:Stop()
        activeTrack = nil
        activeId = nil
        isExclusivo = false
    end
end

local function PlayEmote(id, exclusivo)
    -- Se clicar no mesmo que já está tocando, ele para (Toggle)
    if activeId == id then
        StopEmote()
        return
    end

    StopEmote()
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. id
    activeTrack = humanoid:LoadAnimation(anim)
    activeTrack:Play()
    activeId = id
    isExclusivo = exclusivo or false
end

-- Detectar Pulo (Ignora se for exclusivo)
local jumpConn = humanoid.StateChanged:Connect(function(_, newState)
    if (newState == Enum.HumanoidStateType.Jumping or newState == Enum.HumanoidStateType.Freefall) then
        if not isExclusivo then
            StopEmote()
        end
    end
end)

--- GERAR LISTA ---
local buttons = {}

for i, data in pairs(emotes) do
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -5, 0, 40)
    Container.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Container.LayoutOrder = i + 100
    Container.Parent = Scroll
    
    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 6)
    cCorner.Parent = Container

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -50, 1, 0)
    Btn.Position = UDim2.new(0, 10, 0, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = data.nome
    Btn.TextColor3 = (data.exclusivo and Color3.fromRGB(255, 100, 100)) or Color3.fromRGB(220, 220, 220)
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 13
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.Parent = Container

    local FavBtn = Instance.new("TextButton")
    FavBtn.Size = UDim2.new(0, 30, 0, 30)
    FavBtn.Position = UDim2.new(1, -35, 0, 5)
    FavBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    FavBtn.Text = "★"
    FavBtn.TextColor3 = Color3.fromRGB(80, 80, 80)
    FavBtn.Font = Enum.Font.GothamBold
    FavBtn.Parent = Container
    Instance.new("UICorner", FavBtn).CornerRadius = UDim.new(1, 0)

    local isFav = false
    FavBtn.MouseButton1Click:Connect(function()
        isFav = not isFav
        Container.LayoutOrder = isFav and 1 or (i + 100)
        FavBtn.TextColor3 = isFav and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(80, 80, 80)
    end)

    Btn.MouseButton1Click:Connect(function()
        PlayEmote(data.id, data.exclusivo)
    end)

    buttons[data.nome:lower()] = Container
end

-- Lógica de Pesquisa
SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
    local text = SearchBar.Text:lower()
    for nome, frame in pairs(buttons) do
        frame.Visible = nome:find(text) ~= nil
    end
    Scroll.CanvasPosition = Vector2.new(0,0)
end)

--- CONTROLES ---
local ConnectionV = UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.V then MainFrame.Visible = not MainFrame.Visible end
end)

local ConnectionJ = UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.J then
        StopEmote()
        ConnectionV:Disconnect()
        jumpConn:Disconnect()
        ScreenGui:Destroy()
    end
end)

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y)
end)
