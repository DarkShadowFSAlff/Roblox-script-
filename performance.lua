local PerformanceModule = {}

function PerformanceModule.Init(tab, Lighting, Players, player)
    local boostBtn1 = Instance.new("TextButton")
    boostBtn1.Size = UDim2.new(0.9, 0, 0, 30)
    boostBtn1.BackgroundColor3 = Color3.fromRGB(40, 140, 40)
    boostBtn1.TextColor3 = Color3.fromRGB(255, 255, 255)
    boostBtn1.TextSize = 11
    boostBtn1.Font = Enum.Font.SourceSansBold
    boostBtn1.Text = "⚡ Low FX & Matikan Shadow"
    boostBtn1.LayoutOrder = 1
    boostBtn1.Parent = tab

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
    boostBtn2.Parent = tab

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
end

return PerformanceModule
