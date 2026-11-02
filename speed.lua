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
		stopSpeed()

		targetCustomSpeed = speed
		isActive = true

		activeSpeedConnection = RunService.Heartbeat:Connect(function(dt)
			local char = player.Character
			if not char then return end

			local humanoid = char:FindFirstChildOfClass("Humanoid")
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not humanoid or not hrp or humanoid.Health <= 0 then return end

			-- WalkSpeed normal (aman)
			humanoid.WalkSpeed = math.clamp(targetCustomSpeed, 16, 100)

			-- Super speed mode (pakai velocity, bukan CFrame)
			if targetCustomSpeed > 100 and humanoid.MoveDirection.Magnitude > 0.05 then
				local moveDir = humanoid.MoveDirection.Unit
				local currentVel = hrp.AssemblyLinearVelocity
				local desiredSpeed = targetCustomSpeed

				-- ======================
				-- RAYCAST PREDIKTIF + MULTI RAY
				-- ======================
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = {char}
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams.IgnoreWater = true

				-- Jarak ray menyesuaikan kecepatan (penting!)
				local lookAhead = math.clamp(desiredSpeed * dt * 1.8, 2.5, 12)

				local function cast(offset)
					local origin = hrp.Position + offset
					return workspace:Raycast(origin, moveDir * lookAhead, raycastParams)
				end

				-- 3 ray: tengah, kiri, kanan
				local hitCenter = cast(Vector3.zero)
				local hitLeft   = cast(hrp.CFrame.RightVector * -1.2)
				local hitRight  = cast(hrp.CFrame.RightVector * 1.2)

				local wallHit = hitCenter or hitLeft or hitRight

				if wallHit then
					-- Ada tembok → SLIDE di dinding (bukan stop total, bukan bounce aneh)
					local normal = wallHit.Normal
					-- Hapus komponen velocity yang menembus tembok
					local vel = currentVel
					local intoWall = vel:Dot(normal)
					if intoWall < 0 then
						vel = vel - normal * intoWall
					end
					-- Tetap izinkan gerak sepanjang dinding sesuai arah joystick
					local slideDir = moveDir - normal * moveDir:Dot(normal)
					if slideDir.Magnitude > 0.05 then
						slideDir = slideDir.Unit
						vel = Vector3.new(slideDir.X * desiredSpeed * 0.85, vel.Y, slideDir.Z * desiredSpeed * 0.85)
					else
						vel = Vector3.new(0, vel.Y, 0)
					end
					hrp.AssemblyLinearVelocity = vel
				else
					-- Tidak ada tembok → pakai velocity penuh
					hrp.AssemblyLinearVelocity = Vector3.new(
						moveDir.X * desiredSpeed,
						currentVel.Y,
						moveDir.Z * desiredSpeed
					)
				end

				-- ======================
				-- KOREKSI JIKA SUDAH SEDIKIT MENEMBUS
				-- ======================
				local checkParams = RaycastParams.new()
				checkParams.FilterDescendantsInstances = {char}
				checkParams.FilterType = Enum.RaycastFilterType.Exclude

				local insideCheck = workspace:Raycast(hrp.Position, moveDir * 1.1, checkParams)
				if insideCheck and insideCheck.Distance < 1.3 then
					-- Dorong keluar sedikit dari tembok
					hrp.CFrame = hrp.CFrame + insideCheck.Normal * (1.3 - insideCheck.Distance)
				end
			end
		end)

		speedBtn.Text = "Speed Aktif (" .. targetCustomSpeed .. ")"
		speedBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 40)
	end

	-- Tombol Aktifkan / Matikan
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

	-- Tombol Fix
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

	-- Auto stop saat respawn
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
