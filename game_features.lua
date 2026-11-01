local GameFeaturesModule = {}

function GameFeaturesModule.Init(tab, player)
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(0.9, 0, 0, 30)
    infoLabel.BackgroundTransparency = 1
    infoLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    infoLabel.TextSize = 11
    infoLabel.Font = Enum.Font.SourceSansBold
    infoLabel.Text = "--- Fitur Khusus Game Ini ---"
    infoLabel.LayoutOrder = 1
    infoLabel.Parent = tab

    local customBtn = Instance.new("TextButton")
    customBtn.Size = UDim2.new(0.9, 0, 0, 30)
    customBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    customBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    customBtn.TextSize = 11
    customBtn.Font = Enum.Font.SourceSansBold
    customBtn.Text = "✨ Tombol Fitur Khusus"
    customBtn.LayoutOrder = 2
    customBtn.Parent = tab

    customBtn.MouseButton1Click:Connect(function()
        print("Fitur khusus game aktif!")
        customBtn.Text = "✨ Berhasil Ditekan!"
    end)
end

return GameFeaturesModule
