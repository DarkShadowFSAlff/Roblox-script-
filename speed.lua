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
	speedBox.PlaceholderText = "Masukkan Angka (Contoh: 50 / 160)"
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
	-- PENGATURAN (bisa kamu ubah)
	-- ======================
	local MAX_STEP = 2.8          -- Jarak maksimal per frame (penting untuk FPS rendah)
	local WALL_CHECK_DIST = 2.6   -- Seberapa jauh deteksi dinding
	local REPEL_STRENGTH = 1.8    -- Kekuatan dorong keluar dari dinding
	local SLIDE_FACTOR = 0.92     -- Seberapa kencang slide di dinding

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

			-- Batasi WalkSpeed normal
			humanoid.WalkSpeed = math.clamp(targetCustomSpeed, 16, 90)

			if targetCustomSpeed <= 90 or humanoid.MoveDirection.Magnitude < 0.05 then
				return
			end

			local moveDir = humanoid.MoveDirection.Unit
			local currentVel = hrp.AssemblyLinearVelocity
			local desiredSpeed = targetCustomSpeed

			-- Batasi jarak tempuh per frame (anti overshoot saat FPS rendah)
			local step = math.min(desiredSpeed * dt, MAX_STEP)
			local intendedMove = moveDir * step

			local params = RaycastParams.new()
			params.FilterDescendantsInstances = {char}
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.IgnoreWater = true

			-- ======================
			-- 1. DETEKSI DINDING DI DEPAN (multi ray)
			-- ======================
			local function cast(originOffset, direction, distance)
				return workspace:Raycast(hrp.Position + originOffset, direction * distance, params)
			end

			local hitFront = cast(Vector3.zero, moveDir, step + 1.8)
			local hitFrontL = cast(hrp.CFrame.RightVector * -0.9, moveDir, step + 1.5)
			local hitFrontR = cast(hrp.CFrame.RightVector * 0.9, moveDir, step + 1.5)

			local wallHit = hitFront or hitFrontL or hitFrontR

			-- ======================
			-- 2. WALL REPEL (selalu cek sekeliling)
			-- ======================
			local directions = {
				Vector3.new(1, 0, 0), Vector3.new(-1, 0, 0),
				Vector3.new(0, 0, 1), Vector3.new(0, 0, -1),
				Vector3.new(0.7, 0, 0.7), Vector3.new(-0.7, 0, 0.7),
				Vector3.new(0.7, 0, -0.7), Vector3.new(-0.7, 0, -0.7)
			}

			local repel = Vector3.zero
			for _, dir in ipairs(directions) do
				local result = workspace:Raycast(hrp.Position, dir * WALL_CHECK_DIST, params)
				if result then
					local dist = result.Distance
					if dist < WALL_CHECK_DIST then
						local strength = (WALL_CHECK_DIST - dist) / WALL_CHECK_DIST
						repel = repel + result.Normal * strength
					end
				end
			end

			if repel.Magnitude > 0 then
				repel = repel.Unit * REPEL_STRENGTH
				hrp.CFrame = hrp.CFrame + repel * dt * 60 -- dorong keluar
			end

			-- ======================
			-- 3. GERAKAN UTAMA
			-- ======================
			if wallHit then
				-- Ada dinding di depan → SLIDE
				local normal = wallHit.Normal
				local slideDir = moveDir - normal * moveDir:Dot(normal)

				if slideDir.Magnitude > 0.08 then
					slideDir = slideDir.Unit
					local slideSpeed = desiredSpeed * SLIDE_FACTOR
					hrp.AssemblyLinearVelocity = Vector3.new(
						slideDir.X * slideSpeed,
						currentVel.Y,
						slideDir.Z * slideSpeed
					)
				else
					-- Langsung menghadap dinding → hentikan horizontal
					hrp.AssemblyLinearVelocity = Vector3.new(0, currentVel.Y, 0)
				end
			else
				-- Jalan bebas
				hrp.AssemblyLinearVelocity = Vector3.new(
					moveDir.X * desiredSpeed,
					currentVel.Y,
					moveDir.Z * desiredSpeed
				)
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
		hrp.CFrame = hrp.CFrame + Vector3.new(0, 5, 0)

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
			if characterConnection then characterConnection:Disconnect() end
		end
	end)
end

return SpeedModule
