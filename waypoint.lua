local WaypointModule = {}

function WaypointModule.Init(tab, player, HttpService)
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
    nameBox.Parent = tab

    local addBtn = Instance.new("TextButton")
    addBtn.Size = UDim2.new(0.9, 0, 0, 30)
    addBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 220)
    addBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    addBtn.TextSize = 11
    addBtn.Font = Enum.Font.SourceSansBold
    addBtn.Text = "+ Simpan Posisi Ini"
    addBtn.LayoutOrder = 2
    addBtn.Parent = tab

    local function renderList()
        for _, child in ipairs(tab:GetChildren()) do
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
            itemFrame.Parent = tab

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
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
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
                renderList()
            end)
        end
    end

    addBtn.MouseButton1Click:Connect(function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local pos = char.HumanoidRootPart.Position
            local customName = nameBox.Text
            if customName == "" or customName == nil then
                customName = "Lokasi " .. (#savedWaypoints + 1)
            end
            table.insert(savedWaypoints, {Name = customName, X = pos.X, Y = pos.Y, Z = pos.Z})
            saveToFile()
            renderList()
            nameBox.Text = ""
        end
    end)

    renderList()
end

return WaypointModule
