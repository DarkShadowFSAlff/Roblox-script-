-- Layanan Dasar
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
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

-- Panel Utama
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 180, 0, 280)
frame.Position = UDim2.new(0.5, -90, 0, 10)
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
title.Text = "Menu Pro"
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

local container = Instance.new("ScrollingFrame")
container.Size = UDim2.new(1, 0, 1, -26)
container.Position = UDim2.new(0, 0, 0, 26)
container.BackgroundTransparency = 1
container.BorderSizePixel = 0
container.CanvasSize = UDim2.new(0, 0, 0, 0)
container.AutomaticCanvasSize = Enum.AutomaticSize.Y
container.ScrollBarThickness = 2
container.Parent = frame

local uiList = Instance.new("UIListLayout")
uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Padding = UDim.new(0, 5)
uiList.Parent = container

local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingTop = UDim.new(0, 6)
uiPadding.PaddingBottom = UDim.new(0, 6)
uiPadding.Parent = container

-- --- WAYPOINT SYSTEM ---
local addBtn = Instance.new("TextButton")
addBtn.Size = UDim2.new(0.9, 0, 0, 28)
addBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 220)
addBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
addBtn.TextSize = 11
addBtn.Font = Enum.Font.SourceSansBold
addBtn.Text = "+ Simpan Posisi"
addBtn.LayoutOrder = 1
addBtn.Parent = container

local divider1 = Instance.new("Frame")
divider1.Size = UDim2.new(0.9, 0, 0, 1)
divider1.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
divider1.BorderSizePixel = 0
divider1.LayoutOrder = 2
divider1.Parent = container

local function addWaypointItem(name, cframe)
    local itemFrame = Instance.new("Frame")
    itemFrame.Size = UDim2.new(0.9, 0, 0, 26)
    itemFrame.BackgroundTransparency = 1
    itemFrame.LayoutOrder = 3
    itemFrame.Parent = container

    local tpBtn = Instance.new("TextButton")
    tpBtn.Size = UDim2.new(0.78, 0, 1, 0)
    tpBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    tpBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
    tpBtn.TextSize = 11
    tpBtn.Font = Enum.Font.SourceSans
    tpBtn.Text = "📌 " .. name
    tpBtn.TextXAlignment = Enum.TextXAlignment.Left
    tpBtn.Parent = itemFrame

    local tpPadding = Instance.new("UIPadding")
    tpPadding.PaddingLeft = UDim.new(0, 6)
    tpPadding.Parent = tpBtn

    -- FIX TELEPORT MELEDAK & KEMBALI KE AWAL (Anti-Rubberband & Velocity Reset)
    tpBtn.MouseButton1Click:Connect(function()
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local hrp = character.HumanoidRootPart
            
            -- Matikan kecepatan fisik sementara agar tidak "meledak" atau mental
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            
            -- Eksekusi Teleportasi CFrame
            hrp.CFrame = cframe
            
            -- Reset ulang kecepatan setelah teleport agar stabil
            task.defer(function()
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end)
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
        itemFrame:Destroy()
    end)
end

-- Tombol Simpan dengan Prompt Nama Custom yang Aman untuk HP
addBtn.MouseButton1Click:Connect(function()
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local count = #container:GetChildren() - 3
        local defaultName = "Lokasi " .. (count + 1)
        
        -- Memunculkan Prompt Bawaan Roblox untuk Input Nama Custom
        pcall(function()
            local promptResult = StarterGui:SetCore("Promptář", {
                Title = "Nama Waypoint",
                Text = "Masukkan nama untuk lokasi ini:",
                PlaceholderText = defaultName,
                Callback = function(text)
                    if text and text ~= "" then
                        addWaypointItem(text, character.HumanoidRootPart.CFrame)
                    else
                        addWaypointItem(defaultName, character.HumanoidRootPart.CFrame)
                    end
                end
            })
        end)
        
        -- Fallback jika Prompt tidak muncul di beberapa game/executor
        -- Langsung buat dengan nama default berurutan
        addWaypointItem(defaultName, character.HumanoidRootPart.CFrame)
    end
end)

local divider2 = Instance.new("Frame")
divider2.Size = UDim2.new(0.9, 0, 0, 1)
divider2.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
divider2.BorderSizePixel = 0
divider2.LayoutOrder = 4
divider2.Parent = container

-- --- FPS & LIGHTING OPTIMIZER ---
local fpsHeader = Instance.new("TextLabel")
fpsHeader.Size = UDim2.new(0.9, 0, 0, 20)
fpsHeader.BackgroundTransparency = 1
fpsHeader.TextColor3 = Color3.fromRGB(0, 170, 255)
fpsHeader.TextSize = 11
fpsHeader.Font = Enum.Font.SourceSansBold
fpsHeader.Text = "--- Optimasi Grafik ---"
fpsHeader.LayoutOrder = 5
fpsHeader.Parent = container

local boostBtn = Instance.new("TextButton")
boostBtn.Size = UDim2.new(0.9, 0, 0, 28)
boostBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 40)
boostBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
boostBtn.TextSize = 11
boostBtn.Font = Enum.Font.SourceSansBold
boostBtn.Text = "⚡ Aktifkan Anti-Lag / Low FX"
boostBtn.LayoutOrder = 6
boostBtn.Parent = container

boostBtn.MouseButton1Click:Connect(function()
    Lighting.GlobalShadows = false
    Lighting.Brightness = 1
    if Lighting:FindFirstChildOfClass("Sky") then
        Lighting:FindFirstChildOfClass("Sky"):Destroy()
    end
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.SmoothPlastic
            obj.CastShadow = false
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
            obj.Enabled = false
        end
    end
    
    boostBtn.Text = "⚡ Mode Ringan Aktif!"
    boostBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
end)

-- Minimize / Restore
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
