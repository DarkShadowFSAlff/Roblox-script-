local SpeedModule = {}

function SpeedModule.Init(tab, player, RunService)
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(0.9, 0, 0, 20)
    speedLabel.BackgroundTransparency = 1
    speedLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
    speedLabel.TextSize = 11
    speedLabel.Font = Enum.Font.SourceSansBold
    speedLabel.Text = "--- Kustom Kecepatan & Anti-Noclip ---"
    speedLabel.LayoutOrder = 1
    speedLabel.Parent = tab

    local speedBox = Instance.new("TextBox")
    speedBox.Size = UDim2.new(0.9, 0, 0, 28)
    speedBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 130)
    speedBox.PlaceholderText = "Masukkan Angka (Contoh: 50 / 80)"
    speedBox.Text = ""
    speedBox.TextSize = 11
    speedBox.Font = Enum.Font.SourceSans
    speedBox.LayoutOrder = 2
    speedBox.Parent = tab

    local speedBtn = Instance.new("TextButton")
    speedBtn.Size = UDim2.new(0.9, 0, 0, 30)
    speedBtn.BackgroundColor3 = Color3.fromRGB(130, 0, 180)
    speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedBtn.TextSize = 11
    speedBtn.Font = Enum.Font.SourceSansBold
    speedBtn.Text = "🚀 Aktifkan Speed Kustom"
    speedBtn.LayoutOrder = 3
    speedBtn.Parent = tab

    -- Tombol Solusi Fix Noclip / Unstuck Darurat
    local fixBtn = Instance.new("TextButton")
    fixBtn.Size = UDim2.new(0.9, 0, 0, 30)
    fixBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    fixBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    fixBtn.TextSize = 11
    fixBtn.Font = Enum.Font.SourceSansBold
    fixBtn.Text = "🛠️ Fix Diri / Unstuck (Anti-Noclip)"
    fixBtn.LayoutOrder = 4
    fixBtn.Parent = tab

    local activeSpeedConnection = nil
    local targetCustomSpeed = 16

    speedBtn.MouseButton1Click:Connect(function()
        local inputSpeed = tonumber(speedBox.Text)
        if inputSpeed then
            targetCustomSpeed = inputSpeed
            if activeSpeedConnection then
                activeSpeedConnection:Disconnect()
            end
            
            activeSpeedConnection = RunService.RenderStepped:Connect(function()
                local char = player.Character
                if char then
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.WalkSpeed = targetCustomSpeed
                    end
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    -- Batasi dorongan vektor agar tidak terlempar menembus tembok (noclip)
                    if hrp and humanoid.MoveDirection.Magnitude > 0 then
                        if targetCustomSpeed > 100 then
                            -- Pengaman ekstra untuk kecepatan sangat tinggi agar tidak tembus dinding
                            hrp.CFrame = hrp.CFrame + (humanoid.MoveDirection * math.min(targetCustomSpeed / 40, 2))
                        end
                    end
                end
            end)
            
            speedBtn.Text = "🚀 Speed Aktif (" .. targetCustomSpeed .. ")"
            speedBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 40)
        end
    end)

    -- Logika Tombol Fix Darurat Saat Nyangkut / Noclip
    fixBtn.MouseButton1Click:Connect(function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            
            -- Reset kecepatan normal sementara dan angkat sedikit ke atas agar keluar dari lantai/tembok
            if humanoid then
                humanoid.WalkSpeed = 16
            end
            
            -- Geser sedikit ke atas dan hentikan momentum fizikal agar tidak jatuh ke void
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            hrp.CFrame = hrp.CFrame + Vector3.new(0, 4, 0)
            
            fixBtn.Text = "🛠️ Berhasil Direset!"
            task.wait(1)
            fixBtn.Text = "🛠️ Fix Diri / Unstuck (Anti-Noclip)"
        end
    end)
end

return SpeedModule
