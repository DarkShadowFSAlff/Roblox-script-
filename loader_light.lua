-- Ganti URL di bawah dengan Link Raw GitHub repository Anda yang sebenarnya
local baseURL = "https://raw.githubusercontent.com/DarkShadowFSAlff/Roblox-script-/main/"

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local targetParent = (gethui and gethui()) or CoreGui or player:WaitForChild("PlayerGui")
if targetParent:FindFirstChild("UltimateToolGui") then
    targetParent.UltimateToolGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UltimateToolGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = targetParent

-- Tombol Minimize
local minIcon = Instance.new("TextButton")
minIcon.Size = UDim2.new(0, 45, 0, 45)
minIcon.Position = UDim2.new(0.5, -22, 0, 10)
minIcon.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
minIcon.TextColor3 = Color3.fromRGB(0, 170, 255)
minIcon.TextSize = 20
minIcon.Text = "📌"
minIcon.Active = true
minIcon.Draggable = true
minIcon.Visible = false
minIcon.Parent = screenGui

-- Panel Utama
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 210, 0, 340)
frame.Position = UDim2.new(0.5, -105, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Active = true
frame.Draggable = true
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

-- 3 Tab Header
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

-- Memuat Modul dari GitHub secara Aman
pcall(function()
    local wpMod = loadstring(game:HttpGet(baseURL .. "waypoint.lua"))()
    wpMod.Init(pages[1], player, HttpService)
end)

pcall(function()
    local perfMod = loadstring(game:HttpGet(baseURL .. "performance.lua"))()
    perfMod.Init(pages[2], Lighting, Players, player)
end)

pcall(function()
    local speedMod = loadstring(game:HttpGet(baseURL .. "speed.lua"))()
    speedMod.Init(pages[3], player, RunService)
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
