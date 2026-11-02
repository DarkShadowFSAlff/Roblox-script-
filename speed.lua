local SpeedModule = {}

function SpeedModule.Init(tab, player, RunService)
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
	speedBox.PlaceholderText = "Masukkan Angka (Rekomendasi: 45-65)"
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

	local activeSpeedConnection = nil
	local characterConnection = nil
	local targetCustomSpeed = 16
	local isActive = false

	-- ======================
	-- PENGATURAN (bisa diubah)
	-- ======================
	local CHECK_DISTANCE = 2.35       -- Jarak deteksi dinding
	local NORMAL_PUSH = 1.35          -- Dorongan biasa
	local STRONG_PUSH = 2.4           -- Dorongan saat hampir nembus
	local MAX_SPEED = 75

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
		stopSpeed()

		targetCustomSpeed = math.clamp(speed, 16, MAX_SPEED)
		isActive = true

		activeSpeedConnection = RunService.Heartbeat:Connect(function(dt)
			local char = player.Character
			if not char then return end

			local humanoid = char:FindFirstChildOfClass("Humanoid")
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not humanoid or not hrp or humanoid.Health <= 0 then return end

			-- Set kecepatan
			humanoid.WalkSpeed = targetCustomSpeed

			-- Arah gerak pemain
			local moveDir = humanoid.MoveDirection
			local isMoving = moveDir.Magnitude > 0.1

			local params = RaycastParams.new()
			params.FilterDescendantsInstances = {char}
			params.FilterType = Enum.RaycastFilterType.Exclude

			-- Hanya cek arah horizontal (hindari masalah saat nunduk)
			local directions = {
				Vector3.new(1, 0, 0),
				Vector3.new(-1, 0, 0),
				Vector3.new(0, 0, 1),
				Vector3.new(0, 0, -1),
				Vector3.new(0.707, 0, 0.707),
				Vector3.new(-0.707, 0, 0.707),
				Vector3.new(0.707, 0, -0.707),
				Vector3.new(-0.707, 0, -0.707),
			}

			local totalPush = Vector3.zero
			local closestDist = CHECK_DISTANCE

			for _, dir in ipairs(directions) do
				local result = workspace:Raycast(hrp.Position, dir * CHECK_DISTANCE, params)
				if result then
					local dist = result.Distance
					if dist < closestDist then
						closestDist = dist
					end

					-- Hanya dorong horizontal
					local normal = Vector3.new(result.Normal.X, 0, result.Normal.Z).Unit
					local force = (CHECK_DISTANCE - dist) / CHECK_DISTANCE
					totalPush = totalPush + (normal * force)
				end
			end

			if totalPush.Magnitude > 0 then
				totalPush = totalPush.Unit

				-- Kalau sangat dekat (hampir nembus) → dorong lebih kuat
				local pushPower = (closestDist < 1.35) and STRONG_PUSH or NORMAL_PUSH

				-- Kalau sedang jalan maju, kurangi dorongan samping supaya lebih gampang lewat pintu
				if isMoving then
					local forward = moveDir
					local sideFactor = 1 - math.abs(totalPush:Dot(forward)) * 0.55
					pushPower = pushPower * math.clamp(sideFactor, 0.45, 1)
				end

				hrp.CFrame = hrp.CFrame + totalPush * pushPower * dt * 50
			end
		end)

		speedBtn.Text = "Speed Aktif (" .. targetCustomSpeed .. ")"
		speedBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 40)
	end

	speedBtn.MouseButton1Click:Connect(function()
		local inputSpeed = tonumber(speedBox.Text)

		if not inputSpeed or inputSpeed <= 0 then
			speedBox.PlaceholderText = "Masukkan angka yang valid!"
			speedBox.Text = ""
			return
		end

		if isActive and math.abs(targetCustomSpeed - inputSpeed) < 0.1 then
			stopSpeed()
		else
			startSpeed(inputSpeed)
		end
	end)

	fixBtn.MouseButton1Click:Connect(function()
		local char = player.Character
		if not char then return end

		local hrp = char:FindFirstChild("HumanoidRootPart")
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if not hrp or not humanoid then return end

		stopSpeed()

		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.AssemblyAngularVelocity = Vector3.zero
		hrp.CFrame = hrp.CFrame + Vector3.new(0, 4, 0)

		speedBox.Text = ""
		fixBtn.Text = "Berhasil Direset!"
		task.delay(1.2, function()
			if fixBtn and fixBtn.Parent then
				fixBtn.Text = "Fix Posisi / Reset Nyangkut"
			end
		end)
	end)

	characterConnection = player.CharacterAdded:Connect(function()
		stopSpeed()
	end)

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
