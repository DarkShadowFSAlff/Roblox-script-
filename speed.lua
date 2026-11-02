local SpeedModule = {}

function SpeedModule.Init(tab, player, RunService)
	-- UI
	local speedLabel = Instance.new("TextLabel")
	speedLabel.Size = UDim2.new(0.9, 0, 0, 20)
	speedLabel.BackgroundTransparency = 1
	speedLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
	speedLabel.TextSize = 11
	speedLabel.Font = Enum.Font.SourceSansBold
	speedLabel.Text = "--- Kecepatan & Anti-Bounce Tembok ---"
	speedLabel.LayoutOrder = 1
	speedLabel.Parent = tab

	local speedBox = Instance.new("TextBox")
	speedBox.Size = UDim2.new(0.9, 0, 0, 28)
	speedBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	speedBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 130)
	speedBox.PlaceholderText = "Masukkan Angka (Contoh: 50 / 300)"
	speedBox.Text = ""
	speedBox.TextSize = 11
	speedBox.Font = Enum.Font.SourceSans
	speedBox.ClearTextOnFocus = false
	speedBox.LayoutOrder = 2
	speedBox.Parent = tab

	local speedBtn = Instance.new("TextButton")
	speedBtn.Size = UDim2.new(0.9, 0, 0, 30)
	speedBtn.BackgroundColor3 = Color3.fromRGB(130, 0, 180)
	speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	speedBtn.TextSize = 11
	speedBtn.Font = Enum.Font.SourceSansBold
	speedBtn.Text = "Aktifkan Speed Presisi"
	speedBtn.LayoutOrder = 3
	speedBtn.Parent = tab

	local fixBtn = Instance.new("TextButton")
	fixBtn.Size = UDim2.new(0.9, 0, 0, 30)
	fixBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	fixBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	fixBtn.TextSize = 11
	fixBtn.Font = Enum.Font.SourceSansBold
	fixBtn.Text = "Fix Posisi / Reset Nyangkut"
	fixBtn.LayoutOrder = 4
	fixBtn.Parent = tab

	-- State
	local activeSpeedConnection = nil
	local characterConnection = nil
	local targetCustomSpeed = 16
	local isActive = false

	local function stopSpeed()
		if activeSpeedConnection then
			activeSpeedConnection:Disconnect()
			activeSpeedConnection = nil
		end
		isActive = false

		local char = player.Character
		if char then
			local humanoid = char:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.WalkSpeed = 16
			end
		end

		speedBtn.Text = "Aktifkan Speed Presisi"
		speedBtn.BackgroundColor3 = Color3.fromRGB(130, 0, 180)
	end

	local function startSpeed(speed)
		stopSpeed() -- pastikan bersih dulu

		targetCustomSpeed = speed
		isActive = true

		activeSpeedConnection = RunService.Heartbeat:Connect(function(dt)
			local char = player.Character
			if not char then return end

			local humanoid = char:FindFirstChildOfClass("Humanoid")
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not humanoid or not hrp or humanoid.Health <= 0 then return end

			-- Batasi WalkSpeed normal (agar tidak terlalu ekstrem)
			humanoid.WalkSpeed = math.clamp(targetCustomSpeed, 16, 120)

			-- Mode super speed (CFrame) hanya jika > 120
			if targetCustomSpeed > 120 and humanoid.MoveDirection.Magnitude > 0.1 then
				local moveDir = humanoid.MoveDirection.Unit

				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = {char}
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams.IgnoreWater = true

				-- Deteksi tembok di depan
				local rayDistance = math.clamp(targetCustomSpeed * dt * 1.2, 3, 8)
				local raycastResult = workspace:Raycast(hrp.Position, moveDir * rayDistance, raycastParams)

				if raycastResult then
					-- Ada tembok → hentikan gerakan horizontal (anti bounce)
					local vel = hrp.AssemblyLinearVelocity
					hrp.AssemblyLinearVelocity = Vector3.new(0, vel.Y, 0)
				else
					-- Tidak ada tembok → gerak maju dengan CFrame
					local speedMultiplier = 0.9 -- bisa disesuaikan (0.7 \~ 1.1)
					local increment = moveDir * (targetCustomSpeed * dt * speedMultiplier)
					hrp.CFrame = hrp.CFrame + increment
				end
			end
		end)

		speedBtn.Text = "Speed Aktif (" .. targetCustomSpeed .. ")"
		speedBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 40)
	end

	-- Tombol Aktifkan
	speedBtn.MouseButton1Click:Connect(function()
		local inputSpeed = tonumber(speedBox.Text)

		if not inputSpeed or inputSpeed <= 0 then
			speedBox.PlaceholderText = "Masukkan angka yang valid!"
			speedBox.Text = ""
			return
		end

		if isActive and targetCustomSpeed == inputSpeed then
			-- Klik lagi = matikan
			stopSpeed()
		else
			startSpeed(inputSpeed)
		end
	end)

	-- Tombol Fix / Reset
	fixBtn.MouseButton1Click:Connect(function()
		local char = player.Character
		if not char then return end

		local hrp = char:FindFirstChild("HumanoidRootPart")
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if not hrp or not humanoid then return end

		stopSpeed()

		-- Reset velocity
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.AssemblyAngularVelocity = Vector3.zero

		-- Naikkan sedikit biar tidak nyangkut di tanah/tembok
		hrp.CFrame = hrp.CFrame + Vector3.new(0, 4, 0)

		speedBox.Text = ""
		fixBtn.Text = "Berhasil Direset!"
		task.delay(1.2, function()
			if fixBtn and fixBtn.Parent then
				fixBtn.Text = "Fix Posisi / Reset Nyangkut"
			end
		end)
	end)

	-- Auto stop saat karakter mati / respawn
	characterConnection = player.CharacterAdded:Connect(function()
		stopSpeed()
	end)

	-- Cleanup jika module di-destroy (opsional tapi bagus)
	tab.AncestryChanged:Connect(function(_, parent)
		if not parent then
			stopSpeed()
			if characterConnection then
				characterConnection:Disconnect()
			end
		end
	end)
end

return SpeedModule
