local PerformanceModule = {}

function PerformanceModule.Init(tab, Lighting, Players, player)
    local boostBtn1 = Instance.new("TextButton")
    boostBtn1.Size = UDim2.new(0.9, 0, 0, 30)
    boostBtn1.BackgroundColor3 = Color3.fromRGB(40, 140, 40)
    boostBtn1.TextColor3 = Color3.fromRGB(255, 255, 255)
    boostBtn1.TextSize = 11
    boostBtn1.Font = Enum.Font.SourceSansBold
    boostBtn1.Text = "⚡ Low FX Auto (Anti-Reset Ruangan)"
    boostBtn1.LayoutOrder = 1
    boostBtn1.Parent = tab

    local autoOptimizeConn = nil

    boostBtn1.MouseButton1Click:Connect(function()
        Lighting.GlobalShadows = false
        Lighting.Brightness = 1
        if Lighting:FindFirstChildOfClass("Sky") then
            Lighting:FindFirstChildOfClass("Sky"):Destroy()
        end

        local function optimizeInstance(obj)
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.CastShadow = false
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                obj.Enabled = false
            end
        end

        -- Bersihkan yang sudah ada di map saat ini
        for _, obj in ipairs(workspace:GetDescendants()) do
            optimizeInstance(obj)
        end

        -- Otomatis bersihkan ruangan baru yang muncul (cocok untuk game Doors)
        if not autoOptimizeConn then
            autoOptimizeConn = workspace.DescendantAdded:Connect(function(obj)
                optimizeInstance(obj)
            end)
        end

        boostBtn1.Text = "⚡ Low FX Aktif Permanen!"
    end)

    local boostBtn2 = Instance.new("TextButton")
    boostBtn2.Size = UDim2.new(0.9, 0, 0, 30)
    boostBtn2.BackgroundColor3 = Color3.fromRGB(180, 100, 0)
    boostBtn2.TextColor3 = Color3.fromRGB(255, 255, 255)
    boostBtn2.TextSize = 11
    boostBtn2.Font = Enum.Font.SourceSansBold
    boostBtn2.Text = "🧹 Hapus Texture & Decal Berat"
    boostBtn2.LayoutOrder = 2
    boostBtn2.Parent = tab

    boostBtn2.MouseButton1Click:Connect(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Texture") or obj:IsA("Decal") then
                obj:Destroy()
            elseif obj:IsA("MeshPart") then
                obj.TextureID = ""
            end
        end
        boostBtn2.Text = "🧹 Texture Dibersihkan!"
    end)

    local boostBtn3 = Instance.new("TextButton")
    boostBtn3.Size = UDim2.new(0.9, 0, 0, 30)
    boostBtn3.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    boostBtn3.TextColor3 = Color3.fromRGB(255, 255, 255)
    boostBtn3.TextSize = 11
    boostBtn3.Font = Enum.Font.SourceSansBold
    boostBtn3.Text = "📉 Matikan PostProcessing / Blur"
    boostBtn3.LayoutOrder = 3
    boostBtn3.Parent = tab

    boostBtn3.MouseButton1Click:Connect(function()
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end)
        for _, postEff in ipairs(Lighting:GetChildren()) do
            if postEff:IsA("PostEffect") or postEff:IsA("Atmosphere") or postEff:IsA("DepthOfFieldEffect") then
                postEff:Destroy()
            end
        end
        boostBtn3.Text = "📉 Efek Visual Dimatikan!"
    end)
end

return PerformanceModule
