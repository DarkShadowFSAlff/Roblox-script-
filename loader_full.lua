local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local pgui = player:WaitForChild("PlayerGui")

if pgui:FindFirstChild("CustomHubUI") then
    pgui.CustomHubUI:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomHubUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = pgui

-- Frame Utama Menu
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 240, 0, 210)
mainFrame.Position = UDim2.new(0.5, -120, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(60, 60, 70)
mainStroke.Thickness = 1.5
mainStroke.Parent = mainFrame

-- Top Bar
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 30)
topBar.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 10)
topCorner.Parent = topBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0.5, 0, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚡ DELTA HUB"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 11
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topBar

-- Tombol Kontrol Atas (Minimize Tab & Minimize Menu Penuh)
local btnHolder = Instance.new("Frame")
btnHolder.Size = UDim2.new(0, 65, 1, 0)
btnHolder.Position = UDim2.new(1, -70, 0, 0)
btnHolder.BackgroundTransparency = 1
btnHolder.Parent = topBar

local layoutBtns = Instance.new("UIListLayout")
layoutBtns.FillDirection = Enum.FillDirection.Horizontal
layoutBtns.HorizontalAlignment = Enum.HorizontalAlignment.Right
layoutBtns.VerticalAlignment = Enum.VerticalAlignment.Center
layoutBtns.Padding = UDim.new(0, 4)
layoutBtns.Parent = btnHolder

-- Tombol Minimize Tab (Menyembunyikan bar tab atas, menyisakan fungsi tab aktif saja)
local minimizeTabBtn = Instance.new("TextButton")
minimizeTabBtn.Size = UDim2.new(0, 22, 0, 22)
minimizeTabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
minimizeTabBtn.Text = "➖"
minimizeTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeTabBtn.TextSize = 10
minimizeTabBtn.Font = Enum.Font.SourceSansBold
minimizeTabBtn.Parent = btnHolder

local mTabCorner = Instance.new("UICorner")
mTabCorner.CornerRadius = UDim.new(0, 6)
mTabCorner.Parent = minimizeTabBtn

-- Tombol Minimize Penuh (Menjadi bentuk icon kotak melayang ala Delta)
local minimizeFullBtn = Instance.new("TextButton")
minimizeFullBtn.Size = UDim2.new(0, 22, 0, 22)
minimizeFullBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
minimizeFullBtn.Text = "❌"
minimizeFullBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeFullBtn.TextSize = 9
minimizeFullBtn.Font = Enum.Font.SourceSansBold
minimizeFullBtn.Parent = btnHolder

local mFullCorner = Instance.new("UICorner")
mFullCorner.CornerRadius = UDim.new(0, 6)
mFullCorner.Parent = minimizeFullBtn

-- Tab Bar
local tabBar = Instance.new("Frame")
tabBar.Name = "TabBar"
tabBar.Size = UDim2.new(1, -12, 0, 26)
tabBar.Position = UDim2.new(0, 6, 0, 34)
tabBar.BackgroundTransparency = 1
tabBar.Parent = mainFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 4)
tabLayout.Parent = tabBar

-- Container Konten Tab (Posisinya dinamis menyesuaikan minimize tab)
local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(1, -12, 1, -68)
container.Position = UDim2.new(0, 6, 0, 64)
container.BackgroundTransparency = 1
container.Parent = mainFrame

-- Floating Icon (Bentuk kotak saat menu di-minimize penuh)
local floatIcon = Instance.new("TextButton")
floatIcon.Name = "FloatingIcon"
floatIcon.Size = UDim2.new(0, 42, 0, 42)
floatIcon.Position = UDim2.new(0.05, 0, 0.2, 0)
floatIcon.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
floatIcon.Text = "⚡"
floatIcon.TextColor3 = Color3.fromRGB(0, 170, 255)
floatIcon.TextSize = 20
floatIcon.Font = Enum.Font.SourceSansBold
floatIcon.Visible = false
floatIcon.Parent = screenGui

local floatCorner = Instance.new("UICorner")
floatCorner.CornerRadius = UDim.new(0, 10)
floatCorner.Parent = floatIcon

local floatStroke = Instance.new("UIStroke")
floatStroke.Color = Color3.fromRGB(0, 170, 255)
floatStroke.Thickness = 2
floatStroke.Parent = floatIcon

-- Smooth Dragging untuk Seluruh Sisi Frame
local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        local endPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        TweenService:Create(frame, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = endPos}):Play()
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
end

makeDraggable(mainFrame)
makeDraggable(floatIcon)

-- Tab Management
local tabs = {}
local tabButtons = {}

local function createTab(name, order)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0.23, 0, 1, 0)
    tabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    tabBtn.Text = name
    tabBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
    tabBtn.TextSize = 10
    tabBtn.Font = Enum.Font.SourceSansBold
    tabBtn.LayoutOrder = order
    tabBtn.Parent = tabBar

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = tabBtn

    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.ScrollBarThickness = 2
    tabContent.Visible = false
    tabContent.Parent = container

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentLayout.Padding = UDim.new(0, 6)
    contentLayout.Parent = tabContent

    tabs[name] = tabContent
    tabButtons[name] = tabBtn

    tabBtn.MouseButton1Click:Connect(function()
        for tName, tFrame in pairs(tabs) do
            tFrame.Visible = (tName == name)
            tabButtons[tName].BackgroundColor3 = (tName == name) and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(35, 35, 45)
            tabButtons[tName].TextColor3 = (tName == name) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 190)
        end
    end)

    return tabContent
end

local wpTab = createTab("📍 Wp", 1)
local perfTab = createTab("⚡ Perf", 2)
local spdTab = createTab("🚀 Spd", 3)
local gameTab = createTab("🎮 Game", 4)

tabs["📍 Wp"].Visible = true
tabButtons["📍 Wp"].BackgroundColor3 = Color3.fromRGB(0, 120, 215)

-- LOGIKA MINIMIZE TAB (Menyembunyikan pilihan tab atas, menyisakan fungsi tab aktif saja dengan smooth)
local isTabMinimized = false

minimizeTabBtn.MouseButton1Click:Connect(function()
    isTabMinimized = not isTabMinimized
    
    local targetSize = isTabMinimized and UDim2.new(0, 240, 0, 150) or UDim2.new(0, 240, 0, 210)
    local targetContainerSize = isTabMinimized and UDim2.new(1, -12, 1, -38) or UDim2.new(1, -12, 1, -68)
    local targetContainerPos = isTabMinimized and UDim2.new(0, 6, 0, 34) or UDim2.new(0, 6, 0, 64)
    
    TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize}):Play()
    TweenService:Create(container, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetContainerSize, Position = targetContainerPos}):Play()
    
    tabBar.Visible = not isTabMinimized
    minimizeTabBtn.Text = isTabMinimized and "➕" or "➖"
end)

-- LOGIKA MINIMIZE PENUH MENJADI FLOATING ICON (Gaya Delta)
minimizeFullBtn.MouseButton1Click:Connect(function()
    TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    task.wait(0.2)
    mainFrame.Visible = false
    floatIcon.Visible = true
end)

floatIcon.MouseButton1Click:Connect(function()
    floatIcon.Visible = false
    mainFrame.Visible = true
    local targetSize = isTabMinimized and UDim2.new(0, 240, 0, 150) or UDim2.new(0, 240, 0, 210)
    TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = targetSize}):Play()
end)

-- LOAD MODUL LUAR DARI GITHUB
local baseURL = "https://raw.githubusercontent.com/DarkShadowFSAlff/Roblox-script-/main/"

local function loadModule(fileName)
    local success, res = pcall(function()
        return loadstring(game:HttpGet(baseURL .. fileName))()
    end)
    if not success then warn("Gagal memuat modul: " .. fileName) end
    return res
end

local WaypointMod = loadModule("waypoint.lua")
local PerformanceMod = loadModule("performance.lua")
local SpeedMod = loadModule("speed.lua")
local GameMod = loadModule("game_doors.lua")

if WaypointMod then WaypointMod.Init(wpTab, player) end
if PerformanceMod then PerformanceMod.Init(perfTab, Lighting, Players, player) end
if SpeedMod then SpeedMod.Init(spdTab, player, RunService) end
if GameMod then GameMod.Init(gameTab, player) end
