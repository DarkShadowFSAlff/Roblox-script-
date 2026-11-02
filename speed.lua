--!strict
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local SpeedModule = {}

-- ============================================================
-- KONFIGURASI (ubah di sini)
-- ============================================================
local CONFIG = {
	DEFAULT_WALKSPEED     = 16,
	MIN_SPEED             = 16,
	MAX_SPEED             = 150,

	-- Deteksi dinding
	WALL_CHECK_DISTANCE   = 2.0,
	WALL_STRONG_DISTANCE  = 1.3,

	-- Kekuatan dorongan (jauh lebih kecil dari versi awal)
	WALL_PUSH_NORMAL      = 0.35,
	WALL_PUSH_STRONG      = 0.70,
	WALL_PUSH_MULTIPLIER  = 25,   -- sebelumnya 50 (terlalu keras → stutter)

	-- Filter raycast
	WALL_RAYCAST_COUNT    = 8,
	WALL_MIN_VELOCITY     = 3,
	WALL_MAX_PUSH_MAG     = 1.0,

	-- Verifikasi WalkSpeed (anti-override dari sistem lain)
	WALKSPEED_VERIFY_INTERVAL = 0.3,

	-- Jika true: speed hack menimpa WalkSpeed = 0 dari game (mis. saat hiding)
	-- Jika false: menghormati game saat game "mengunci" kecepatan ke 0
	FORCE_THROUGH_GAME_LOCKS = false,
}

-- ============================================================
-- UTIL
-- ============================================================
local function safeCall(fn, ...)
	local ok, err = pcall(fn, ...)
	if not ok then
		warn("[SpeedModule]", tostring(err))
	end
	return ok
end

local function getParts(player)
	local char = player.Character
	if not char then return nil end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not humanoid or not hrp then return nil end
	if humanoid.Health <= 0 then return nil end
	return char, humanoid, hrp
end

local function buildCharacterFilter(onlyChar)
	local list = { onlyChar }
	for _, plr in ipairs(Players:GetPlayers()) do
		local c = plr.Character
		if c and c ~= onlyChar then
			table.insert(list, c)
		end
	end
	return list
end

-- ============================================================
-- MODULE
-- ============================================================
function SpeedModule.Init(tab, player, RunService)
	if not RunService:IsClient() then
		warn("[SpeedModule] Hanya bisa dijalankan di client")
		return
	end

	-- ===============================
	-- UI
	-- ===============================
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

	-- ===============================
	-- STATE
	-- ===============================
	local heartbeatConn  = nil
	local verifyThread   = nil
	local charConn       = nil
	local treeConn       = nil

	local targetCustomSpeed = CONFIG.DEFAULT_WALKSPEED
	local originalWalkSpeed = CONFIG.DEFAULT_WALKSPEED
	local hasCapturedOriginal = false
	local isActive = false

	-- Cache arah raycast (dihitung sekali)
	local directions = table.create(CONFIG.WALL_RAYCAST_COUNT)
	for i = 0, CONFIG.WALL_RAYCAST_COUNT - 1 do
		local angle = (i / CONFIG.WALL_RAYCAST_COUNT) * math.pi * 2
		directions[i + 1] = Vector3.new(math.cos(angle), 0, math.sin(angle))
	end

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.RespectCanCollide = true

	-- ===============================
	-- CORE: push dinding
	-- ===============================
	local function computeWallPush(hrp, char)
		rayParams.FilterDescendantsInstances = buildCharacterFilter(char)

		local totalPush = Vector3.zero
		local closestDist = CONFIG.WALL_CHECK_DISTANCE
		local origin = hrp.Position

		for _, dir in ipairs(directions) do
			local result = Workspace:Raycast(origin, dir * CONFIG.WALL_CHECK_DISTANCE, rayParams)
			if result then
				local n = result.Normal
				-- Abaikan lantai / plafon (normal hampir vertikal)
				if math.abs(n.Y) < 0.7 then
					local horiz = Vector3.new(n.X, 0, n.Z)
					local mag = horiz.Magnitude
					if mag > 0.01 then
						horiz = horiz / mag
						local dist = result.Distance
						if dist < closestDist then
							closestDist = dist
						end
						local force = (CONFIG.WALL_CHECK_DISTANCE - dist) / CONFIG.WALL_CHECK_DISTANCE
						totalPush = totalPush + horiz * force
					end
				end
			end
		end

		return totalPush, closestDist
	end

	local function applyAntiBounce(hrp, humanoid, dt)
		local vel = hrp.AssemblyLinearVelocity
		local horizVel = Vector3.new(vel.X, 0, vel.Z)

		-- Hanya aktif saat bergerak cukup cepat (mencegah dorongan saat idle)
		if horizVel.Magnitude < CONFIG.WALL_MIN_VELOCITY then
			return
		end

		local pushDir, closestDist = computeWallPush(hrp, player.Character)
		local mag = pushDir.Magnitude
		if mag < 0.01 then return end  -- PENTING: hindari .Unit pada vektor ~0

		if mag > CONFIG.WALL_MAX_PUSH_MAG then
			pushDir = pushDir / mag * CONFIG.WALL_MAX_PUSH_MAG
		end
		pushDir = pushDir.Unit

		local isStrong = closestDist < CONFIG.WALL_STRONG_DISTANCE
		local pushPower = isStrong and CONFIG.WALL_PUSH_STRONG or CONFIG.WALL_PUSH_NORMAL

		-- Jika sedang bergerak searah dorongan, kurangi dorongan samping
		-- (biar lebih mudah lewat pintu)
		local moveDir = humanoid.MoveDirection
		if moveDir.Magnitude > 0.1 then
			local alignment = math.abs(pushDir:Dot(moveDir))
			pushPower = pushPower * (1 - alignment * 0.5)
		end

		hrp.CFrame = hrp.CFrame + pushDir * (pushPower * dt * CONFIG.WALL_PUSH_MULTIPLIER)
	end

	-- ===============================
	-- CORE: start/stop speed
	-- ===============================
	local function stopSpeed()
		if heartbeatConn then
			heartbeatConn:Disconnect()
			heartbeatConn = nil
		end
		if verifyThread then
			pcall(task.cancel, verifyThread)
			verifyThread = nil
		end
		isActive = false

		local _, humanoid = getParts(player)
		if humanoid and hasCapturedOriginal then
			safeCall(function()
				humanoid.WalkSpeed = originalWalkSpeed
			end)
			hasCapturedOriginal = false
		end

		safeCall(function()
			if speedBtn.Parent then
				speedBtn.Text = "Aktifkan Speed Presisi"
				speedBtn.BackgroundColor3 = Color3.fromRGB(130, 0, 180)
			end
		end)
	end

	local function startSpeed(speed)
		stopSpeed()

		local _, humanoid = getParts(player)
		if not humanoid then return end

		-- Simpan WalkSpeed asli HANYA sekali per sesi aktif
		originalWalkSpeed = humanoid.WalkSpeed
		hasCapturedOriginal = true

		targetCustomSpeed = math.clamp(speed, CONFIG.MIN_SPEED, CONFIG.MAX_SPEED)
		isActive = true

		safeCall(function()
			humanoid.WalkSpeed = targetCustomSpeed
		end)

		-- Heartbeat: set WalkSpeed + anti-bounce
		heartbeatConn = RunService.Heartbeat:Connect(function(dt)
			local c, h, hrp = getParts(player)
			if not c or not h or not hrp then return end

			-- Deteksi jika game mengubah WalkSpeed dari luar
			if h.WalkSpeed ~= targetCustomSpeed then
				if h.WalkSpeed == 0 and not CONFIG.FORCE_THROUGH_GAME_LOCKS then
					-- Game mengunci (hiding/cutscene) → hormati, jangan paksa
				else
					h.WalkSpeed = targetCustomSpeed
				end
			end

			safeCall(applyAntiBounce, hrp, h, dt)
		end)

		-- Verifikasi berkala (jika ada sistem lain yang mengubah tanpa lewat Heartbeat)
		verifyThread = task.spawn(function()
			while isActive do
				task.wait(CONFIG.WALKSPEED_VERIFY_INTERVAL)
				if not isActive then break end
				local _, h = getParts(player)
				if h and h.WalkSpeed ~= targetCustomSpeed and h.WalkSpeed ~= 0 then
					safeCall(function()
						h.WalkSpeed = targetCustomSpeed
					end)
				end
			end
		end)

		safeCall(function()
			if speedBtn.Parent then
				speedBtn.Text = "Speed Aktif (" .. targetCustomSpeed .. ")"
				speedBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 40)
			end
		end)
	end

	-- ===============================
	-- UI EVENTS
	-- ===============================
	speedBtn.MouseButton1Click:Connect(function()
		local inputSpeed = tonumber(speedBox.Text)

		if not inputSpeed or inputSpeed <= 0 then
			speedBox.PlaceholderText = "Masukkan angka yang valid!"
			return
		end
		if inputSpeed < CONFIG.MIN_SPEED then
			speedBox.PlaceholderText = "Minimal " .. CONFIG.MIN_SPEED
			return
		end
		if inputSpeed > CONFIG.MAX_SPEED then
			speedBox.PlaceholderText = "Maksimal " .. CONFIG.MAX_SPEED
			return
		end

		if isActive and math.abs(targetCustomSpeed - inputSpeed) < 0.1 then
			stopSpeed()
		else
			startSpeed(inputSpeed)
		end
	end)

	fixBtn.MouseButton1Click:Connect(function()
		local char, _, hrp = getParts(player)
		if not hrp then return end

		stopSpeed()

		safeCall(function()
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.AssemblyAngularVelocity = Vector3.zero

			local checkParams = RaycastParams.new()
			checkParams.FilterType = Enum.RaycastFilterType.Exclude
			checkParams.FilterDescendantsInstances = { char }
			checkParams.RespectCanCollide = true

			-- Cari langit-langit di atas (agar tidak tembus)
			local upRes = Workspace:Raycast(hrp.Position, Vector3.new(0, 8, 0), checkParams)
			local lift = upRes and math.max(upRes.Distance - 0.5, 1) or 4

			-- Cari lantai di bawah posisi tujuan
			local targetPos = hrp.Position + Vector3.new(0, lift, 0)
			local downRes = Workspace:Raycast(targetPos, Vector3.new(0, -(lift + 2), 0), checkParams)
			if downRes then
				targetPos = downRes.Position + Vector3.new(0, 3, 0)
			end

			-- Offset posisi, pertahankan rotasi
			hrp.CFrame = hrp.CFrame + (targetPos - hrp.Position)

			speedBox.Text = ""
			if fixBtn.Parent then
				fixBtn.Text = "Berhasil Direset!"
				task.delay(1.2, function()
					if fixBtn.Parent then
						fixBtn.Text = "Fix Posisi / Reset Nyangkut"
					end
				end)
			end
		end)
	end)

	-- ===============================
	-- CLEANUP
	-- ===============================
	local function cleanup()
		stopSpeed()
		if charConn then
			charConn:Disconnect()
			charConn = nil
		end
		if treeConn then
			treeConn:Disconnect()
			treeConn = nil
		end
	end

	charConn = player.CharacterAdded:Connect(function()
		stopSpeed()
	end)

	treeConn = tab.AncestryChanged:Connect(function(_, parent)
		if not parent then
			cleanup()
		end
	end)

	return { cleanup = cleanup, stop = stopSpeed }
end

return SpeedModule
