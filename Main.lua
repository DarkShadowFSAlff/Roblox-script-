-- Layanan Dasar
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
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

screenGui.Archivable = true
screenGui.AncestryChanged:Connect(function(_, parent)
    if not parent then
        task.wait(0.5)
        if screenGui and screenGui.Parent == nil then
            screenGui.Parent = targetParent
        end
    end
end)

-- Tombol Minimize Kotak Kecil di Tengah Atas
local minIcon = Instance.new("TextButton")
minIcon.Size = UDim2.new(0, 45, 0, 45)
minIcon.Position = UDim2.new(0.5, -22, 0, 10)
minIcon.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
minIcon.BorderColor3 = Color3.fromRGB(60, 60, 60)
minIcon.BorderSizePixel = 1
minIcon.TextColor3 = Color3.fromRGB(0, 170, 255)
minIcon.TextSize = 20
minIcon.Font = Enum.Font.SourceSansBold
minIcon.Text = "📌"
minIcon.Active = true
minIcon.Draggable = true
minIcon.Visible = false
minIcon.Parent = screenGui

-- Panel Utama Multi-Tab
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 210, 0, 340)
frame.Position = UDim2.new(0.5, -105, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderColor3 = Color3.fromRGB(50, 50, 50)
frame.BorderSizePixel = 1
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 26)
header.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
header.BorderSizePixel = 0
header.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.4, 0, 1, 0)
title.Position = UDim2.new(0.04, 0, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(220, 220, 220)
title.TextSize = 11
title.Font = Enum.Font.SourceSansBold
title.Text = "Ultimate Menu"
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 22, 0, 22)
minBtn.Position = UDim2.new(0.5, -23, 0, 2)
minBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.TextSize = 10
minBtn.Font = Enum.Font.SourceSansBold
minBtn.Text = "-"
minBtn.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 22, 0, 22)
closeBtn.Position = UDim2.new(0.5, 1, 0, 2)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 10
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.Text = "X"
closeBtn.Parent = header

-- --- NAVIGASI TAB ---
local tabHeader = Instance.new("Frame")
tabHeader.Size = UDim2.new(1, 0, 0, 30)
tabHeader.Position = UDim2.new(0, 0, 0, 26)
tabHeader.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
tabHeader.BorderSizePixel = 0
tabHeader.Parent = frame

local tab1Btn = Instance.new("TextButton")
tab1Btn.Size = UDim2.new(0.33, 0, 1, 0)
tab1Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
tab1Btn.TextColor3 = Color3.fromRGB(0, 170, 255)
tab1Btn.TextSize = 11
tab1Btn.Font = Enum.Font.SourceSansBold
tab1Btn.Text = "📍 Waypoint"
tab1Btn.Parent = tabHeader

local tab2Btn = Instance.new("TextButton")
tab2Btn.Size = UDim2.new(0.33, 0, 1, 0)
tab2Btn.Position = UDim2.new(0.33, 0, 0, 0)
tab2Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
tab2Btn.TextColor3 = Color3.fromRGB(150, 150, 150)
tab2Btn.TextSize = 11
tab2Btn.Font = Enum.Font.SourceSansBold
tab2Btn.Text = "⚡ Performa"
tab2Btn.Parent = tabHeader

local tab3Btn = Instance.new("TextButton")
tab3Btn.Size = UDim2.new(0.34, 0, 1, 0)
tab3Btn.Position = UDim2.new(0.66, 0, 0, 0)
tab3Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
tab3Btn.TextColor3 = Color3.fromRGB(150, 150, 150)
tab3Btn.TextSize = 11
tab3Btn.Font = Enum.Font.SourceSansBold
tab3Btn.Text = "🚀 Fitur Lain"
tab3Btn.Parent = tabHeader

local pageContainer = Instance.new("Frame")
pageContainer.Size = UDim2.new(1, 0, 1, -56)
pageContainer.Position = UDim2.new(0, 0, 0, 56)
pageContainer.BackgroundTransparency = 1
pageContainer.Parent = frame

local pages = {}
for i = 1, 3 do
    local scrolling = Instance.new("ScrollingFrame")
    scrolling.Size = UDim2.new(1, 0, 1, 0)
    scrolling.BackgroundTransparency = 1
    scrolling.BorderSizePixel = 0
    scrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrolling.ScrollBarThickness = 2
    scrolling.Visible = (i == 1)
    scrolling.Parent = pageContainer

    local list = Instance.new("UIListLayout")
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 6)
    list.Parent = scrolling

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)
    pad.Parent = scrolling

    pages[i] = scrolling
end

local function switchTab(tabIndex)
    for i, page in ipairs(pages) do
        page.Visible = (i == tabIndex)
    end
    tab1Btn.TextColor3 = (tabIndex == 1) and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(150, 150, 150)
    tab1Btn.BackgroundColor3 = (tabIndex == 1) and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(20, 20, 20)
    
    tab2Btn.TextColor3 = (tabIndex == 2) and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(150, 150, 150)
    tab2Btn.BackgroundColor3 = (tabIndex == 2) and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(20, 20, 20)
    
    tab3Btn.TextColor3 = (tabIndex == 3) and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(150, 150, 150)
    tab3Btn.BackgroundColor3 = (tabIndex == 3) and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(20, 20, 20)
end

tab1Btn.MouseButton1Click:Connect(function() switchTab(1) end)
tab2Btn.MouseButton1Click:Connect(function() switchTab(2) end)
tab3Btn.MouseButton1Click:Connect(function() switchTab(3) end)


-- --- TAB 1: WAYPOINT PERMANEN ---
local tab1 = pages[1]
local fileName = "Waypoint_Game_" .. game.PlaceId .. ".json"

local savedWaypoints = {}
if writefile and readfile and pcall(function() return readfile(fileName) end) then
    local success, decoded = pcall(function()
        return HttpService:JSONDecode(readfile(fileName))
    end)
    if success and decoded then
        savedWaypoints = decoded
    end
end

local function saveToFile()
    if writefile then
        pcall(function()
            writefile(fileName, HttpService:JSONEncode(savedWaypoints))
        end)
    end
end

local nameBox = Instance.new("TextBox")
nameBox.Size = UDim2.new(0.9, 0, 0, 28)
nameBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
nameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
nameBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 130)
nameBox.PlaceholderText = "Ketik nama waypoint..."
nameBox.Text = ""
nameBox.TextSize = 11
nameBox.Font = Enum.Font.SourceSans
nameBox.LayoutOrder = 1
nameBox.Parent = tab1

local addBtn = Instance.new("TextButton")
addBtn.Size = UDim2.new(0.9, 0, 0, 30)
addBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 220)
addBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
addBtn.TextSize = 11
addBtn.Font = Enum.Font.SourceSansBold
addBtn.Text = "+ Simpan Posisi Ini"
addBtn.LayoutOrder = 2
addBtn.Parent = tab1

local function renderWaypointList()
    for _, child in ipairs(tab1:GetChildren()) do
        if child:IsA("Frame") and child.Name == "WpItem" then
            child:Destroy()
        end
    end

    for index, wp in ipairs(savedWaypoints) do
        local itemFrame = Instance.new("Frame")
        itemFrame.Name = "WpItem"
        itemFrame.Size = UDim2.new(0.9, 0, 0, 26)
        itemFrame.BackgroundTransparency = 1
        itemFrame.LayoutOrder = 10 + index
        itemFrame.Parent = tab1

        local tpBtn = Instance.new("TextButton")
        tpBtn.Size = UDim2.new(0.78, 0, 1, 0)
        tpBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        tpBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
        tpBtn.TextSize = 11
        tpBtn.Font = Enum.Font.SourceSans
        tpBtn.Text = "📌 " .. wp.Name
        tpBtn.TextXAlignment = Enum.TextXAlignment.Left
        tpBtn.Parent = itemFrame

        local tpPadding = Instance.new("UIPadding")
        tpPadding.PaddingLeft = UDim.new(0, 6)
        tpPadding.Parent = tpBtn

        tpBtn.MouseButton1Click:Connect(function()
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local hrp = character.HumanoidRootPart
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                local cf = CFrame.new(wp.X, wp.Y, wp.Z)
                for i = 1, 4 do
                    hrp.CFrame = cf
                    task.wait()
                end
            end
        end)

        local delBtn = Instance.new("TextButton")
        delBtn.Size = UDim2.new(0.18, 0, 1, 0)
        delBtn.Position = UDim2.new(0.82, 0, 0, 0)
        delBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
        delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        delBtn.TextSize = 10
        delBtn.Font = Enum.Font.SourceSansBold
        delBtn.Text = "Del"
        delBtn.Parent = itemFrame

        delBtn.MouseButton1Click:Connect(function()
            table.remove(savedWaypoints, index)
            saveToFile()
            renderWaypointList()
        end)
    end
end

addBtn.MouseButton1Click:Connect(function()
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local pos = character.HumanoidRootPart.Position
        local customName = nameBox.Text
        if customName == "" or customName == nil then
            customName = "Lokasi " .. (#savedWaypoints + 1)
        end
        
        table.insert(savedWaypoints, {Name = customName, X = pos.X, Y = pos.Y, Z = pos.Z})
        saveToFile()
        renderWaypointList()
        nameBox.Text = ""
    end
end)

renderWaypointList()


-- --- TAB 2: PERFORMA (OPTIMASI LANJUTAN) ---
local tab2 = pages[2]

local boostBtn1 = Instance.new("TextButton")
boostBtn1.Size = UDim2.new(0.9, 0, 0, 30)
boostBtn1.BackgroundColor3 = Color3.fromRGB(40, 140, 40)
boostBtn1.TextColor3 = Color3.fromRGB(255, 255, 255)
boostBtn1.TextSize = 11
boostBtn1.Font = Enum.Font.SourceSansBold
boostBtn1.Text = "⚡ Low FX & Matikan Shadow"
boostBtn1.LayoutOrder = 1
boostBtn1.Parent = tab2

boostBtn1.MouseButton1Click:Connect(function()
    Lighting.GlobalShadows = false
    Lighting.Brightness = 1
    if Lighting:FindFirstChildOfClass("Sky") then
        Lighting:FindFirstChildOfClass("Sky"):Destroy()
    end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.SmoothPlastic
            obj.CastShadow = false
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Fire") or obj:IsA("Smoke") then
            obj.Enabled = false
        end
    end
    boostBtn1.Text = "⚡ Low FX Aktif!"
end)

local boostBtn2 = Instance.new("TextButton")
boostBtn2.Size = UDim2.new(0.9, 0, 0, 30)
boostBtn2.BackgroundColor3 = Color3.fromRGB(180, 100, 0)
boostBtn2.TextColor3 = Color3.fromRGB(255, 255, 255)
boostBtn2.TextSize = 11
boostBtn2.Font = Enum.Font.SourceSansBold
boostBtn2.Text = "🧹 Hapus Texture & Pet Lain"
boostBtn2.LayoutOrder = 2
boostBtn2.Parent = tab2

boostBtn2.MouseButton1Click:Connect(function()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Texture") or obj:IsA("Decal") then
            obj:Destroy()
        elseif obj:IsA("MeshPart") then
            obj.TextureID = ""
        end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            for _, part in ipairs(p.Character:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    part.Transparency = 1
                end
            end
        end
    end
    boostBtn2.Text = "🧹 RAM Dibersihkan!"
end)


-- --- TAB 3: FITUR LAIN (SPEED HACK) ---
local tab3 = pages[3]

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.9, 0, 0, 20)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
speedLabel.TextSize = 11
speedLabel.Font = Enum.Font.SourceSansBold
speedLabel.Text = "--- Kustom Kecepatan (Speed) ---"
speedLabel.LayoutOrder = 1
speedLabel.Parent = tab3

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0.9, 0, 0, 28)
speedBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 130)
speedBox.PlaceholderText = "Masukkan Angka (Contoh: 25 / 50)"
speedBox.Text = ""
speedBox.TextSize = 11
speedBox.Font = Enum.Font.SourceSans
speedBox.LayoutOrder = 2
speedBox.Parent = tab3

local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(0.9, 0, 0, 30)
speedBtn.BackgroundColor3 = Color3.fromRGB(130, 0, 180)
speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBtn.TextSize = 11
speedBtn.Font = Enum.Font.SourceSansBold
speedBtn.Text = "🚀 Terapkan Speed Kustom"
speedBtn.LayoutOrder = 3
speedBtn.Parent = tab3

speedBtn.MouseButton1Click:Connect(function()
    local customSpeed = tonumber(speedBox.Text)
    if customSpeed then
        RunService.Stepped:Connect(function()
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = customSpeed
            end
        end)
        speedBtn.Text = "🚀 Speed Aktif (" .. customSpeed .. ")"
    end
end)


-- Minimize / Restore Logic
local function toggleMinimize()
    local isMinimized = frame.Visible
    frame.Visible = not isMinimized
    minIcon.Visible = isMinimized
    
    if isMinimized then
        minIcon.Position = frame.Position
    else
        frame.Position = minIcon.Position
    end
end

minBtn.MouseButton1Click:Connect(toggleMinimize)
minIcon.MouseButton1Click:Connect(toggleMinimize)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)
