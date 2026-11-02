local baseURL = "https://raw.githubusercontent.com/DarkShadowFSAlff/Roblox-script-/main/"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local pgui = player:WaitForChild("PlayerGui")

-- Hapus UI lama jika ada
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

-- Top Bar (Header)
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
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

-- Tombol Control Atas (Compact & Close)
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

local compactBtn = Instance.new("TextButton")
compactBtn.Size = UDim2.new(0, 22, 0, 22)
compactBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
compactBtn.Text = "➖"
compactBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
compactBtn.TextSize = 10
compactBtn.Font = Enum.Font.SourceSansBold
compactBtn.Parent = btnHolder

local compactCorner = Instance.new("UICorner")
compactCorner.CornerRadius = UDim.new(0, 6)
compactCorner.Parent = compactBtn

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 22, 0, 22)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
closeBtn.Text = "❌"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 9
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.Parent = btnHolder

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

-- Tab Navigation Bar
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

-- Container Konten Tab
local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(1, -12, 1, -68)
container.Position = UDim2.new(0, 6, 0, 64)
container.BackgroundTransparency = 1
container.Parent = mainFrame

-- Tombol Floating Widget (Minimize Semua Menu Jadi Kotak Kecil)
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

-- LOGIKA SMOOTH DRAGGING (Bisa Digeser Dari Seluruh Sisi/Bintang Sisi Frame)
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
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

makeDraggable(mainFrame)
makeDraggable(floatIcon)

-- TAB MANAGEMENT & PENGATURAN MODUL
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

-- Aktifkan Tab Pertama Default
tabs["📍 Wp"].Visible = true
tabButtons["📍 Wp"].BackgroundColor3 = Color3.fromRGB(0, 120, 215)

-- LOGIKA MINIMIZE (COMPACT MODE vs FLOATING ICON)
local isCompact = false

compactBtn.MouseButton1Click:Connect(function()
    isCompact = not isCompact
    
    local targetSize = isCompact and UDim2.new(0, 240, 0, 62) or UDim2.new(0, 240, 0, 210)
    TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize}):Play()
    
    container.Visible = not isCompact
    compactBtn.Text = isCompact and "➕" or "➖"
end)

closeBtn.MouseButton1Click:Connect(function()
    -- Smooth transition menyembunyikan menu utama menjadi Icon Kotak Melayang
    TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    task.wait(0.2)
    mainFrame.Visible = false
    floatIcon.Visible = true
end)

floatIcon.MouseButton1Click:Connect(function()
    floatIcon.Visible = false
    mainFrame.Visible = true
    local targetSize = isCompact and UDim2.new(0, 240, 0, 62) or UDim2.new(0, 240, 0, 210)
    TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = targetSize}):Play()
end)

-- PANGGIL MODUL LUAR (SESUAIKAN REPO GITHUB)
local baseURL = "https://raw.githubusercontent.com/DarkShadowFSAlff/Roblox-script-/main/"

local function loadModule(fileName)
    local success, res = pcall(function()
        return loadstring(game:HttpGet(baseURL .. fileName))()
    end)
    if not success then
        warn("Gagal memuat modul: " .. fileName)
    end
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
frame.Parent = screenGui

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 26)
header.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
header.Parent = frame

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 22, 0, 22)
minBtn.Position = UDim2.new(0.5, -23, 0, 2)
minBtn.Text = "-"
minBtn.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 22, 0, 22)
closeBtn.Position = UDim2.new(0.5, 1, 0, 2)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
closeBtn.Text = "X"
closeBtn.Parent = header

local tabHeader = Instance.new("Frame")
tabHeader.Size = UDim2.new(1, 0, 0, 30)
tabHeader.Position = UDim2.new(0, 0, 0, 26)
tabHeader.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
tabHeader.Parent = frame

local tab1Btn = Instance.new("TextButton", tabHeader)
tab1Btn.Size = UDim2.new(0.33, 0, 1, 0)
tab1Btn.Text = "📍 Waypoint"
local tab2Btn = Instance.new("TextButton", tabHeader)
tab2Btn.Size = UDim2.new(0.33, 0, 1, 0)
tab2Btn.Position = UDim2.new(0.33, 0, 0, 0)
tab2Btn.Text = "⚡ Performa"
local tab3Btn = Instance.new("TextButton", tabHeader)
tab3Btn.Size = UDim2.new(0.34, 0, 1, 0)
tab3Btn.Position = UDim2.new(0.66, 0, 0, 0)
tab3Btn.Text = "🚀 Speed"

local pageContainer = Instance.new("Frame", frame)
pageContainer.Size = UDim2.new(1, 0, 1, -56)
pageContainer.Position = UDim2.new(0, 0, 0, 56)
pageContainer.BackgroundTransparency = 1

local pages = {}
for i = 1, 3 do
    local scrolling = Instance.new("ScrollingFrame", pageContainer)
    scrolling.Size = UDim2.new(1, 0, 1, 0)
    scrolling.BackgroundTransparency = 1
    scrolling.Visible = (i == 1)
    scrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local list = Instance.new("UIListLayout", scrolling)
    pages[i] = scrolling
end

tab1Btn.MouseButton1Click:Connect(function()
    pages[1].Visible, pages[2].Visible, pages[3].Visible = true, false, false
end)
tab2Btn.MouseButton1Click:Connect(function()
    pages[1].Visible, pages[2].Visible, pages[3].Visible = false, true, false
end)
tab3Btn.MouseButton1Click:Connect(function()
    pages[1].Visible, pages[2].Visible, pages[3].Visible = false, false, true
end)

-- Download & Inisialisasi Modul dari GitHub
task.spawn(function()
    local successWp, wpMod = pcall(function()
        return loadstring(game:HttpGet(baseURL .. "waypoint.lua"))()
    end)
    if successWp and wpMod then
        wpMod.Init(pages[1], player, HttpService)
    else
        warn("Gagal memuat waypoint.lua")
    end

    local successPerf, perfMod = pcall(function()
        return loadstring(game:HttpGet(baseURL .. "performance.lua"))()
    end)
    if successPerf and perfMod then
        perfMod.Init(pages[2], Lighting, Players, player)
    else
        warn("Gagal memuat performance.lua")
    end

    local successSpd, speedMod = pcall(function()
        return loadstring(game:HttpGet(baseURL .. "speed.lua"))()
    end)
    if successSpd and speedMod then
        speedMod.Init(pages[3], player, RunService)
    else
        warn("Gagal memuat speed.lua")
    end
end)

minBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
    minIcon.Visible = true
end)
minIcon.MouseButton1Click:Connect(function()
    frame.Visible = true
    minIcon.Visible = false
end)
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)
