--!nonstrict
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local SpeedModule = {}

local CONFIG = {
	DEFAULT_WALKSPEED       = 16,
	MIN_SPEED               = 16,
	MAX_SPEED               = 40,

	ACCELERATION            = 0.85,
	DECELERATION            = 2.0,

	RESET_COOLDOWN          = 0.2,
	VERIFY_INTERVAL         = 0.8,

	WALL_PUSH_ENABLED       = true,
	WALL_CHECK_DISTANCE     = 1.8,
	WALL_PUSH_FORCE         = 20,
	WALL_MIN_MOVE_DOT       = 0.65,

	TRY_NETWORK_OWNERSHIP   = false,   -- Matikan dulu biar gak error
	PROTECT_WALKSPEED       = true,
	FORCE_THROUGH_GAME_LOCKS = false,
}

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
	if not humanoid or not hrp or humanoid.Health <= 0 then return nil end
	return char, humanoid, hrp
end

local function buildCharacterFilter(onlyChar)
	local list = { onlyChar }
	for _, plr in ipairs(Players:GetPlayers()) do
		local c = plr.Character
		if c and c \~= onlyChar then
			table.insert(list, c)
		end
	end
	return list
end

function SpeedModule.Init(tab, player, RunService)
	if not tab or not player or not RunService then
		warn("[SpeedModule] Parameter kurang!")
		return
	end

	-- ===================== UI =====================
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
	speedBox.PlaceholderText = "Angka (Rekomendasi: 28-35)"
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

	-- ===================== State =====================
	local heartbeatConn  = nil
	local verifyThread   = nil
	local charConn       = nil
	local treeConn       = nil
	local walkspeedConn  = nil

	local targetSpeed    = CONFIG.DEFAULT_WALKSPEED
	local currentSpeed   = CONFIG.DEFAULT_WALKSPEED
	local lastResetTime  = 0
	local isActive       = false

	local directions = {}
	for i = 0, 7 do
		local a = (i / 8) * math.pi * 2
		directions[#directions + 1] = Vector3.new(math.cos(a), 0, math.sin(a))
	end

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.RespectCanCollide = true

	local pushAttachment, pushVelocity

	local function cleanupPushPhysics()
		if pushVelocity then safeCall(function() pushVelocity:Destroy() end) end
		if pushAttachment then safeCall(function() pushAttachment:Destroy() end) end
		pushVelocity = nil
		pushAttachment = nil
	end

	local function setupPushPhysics(hrp)
		cleanupPushPhysics()
		pushAttachment = Instance.new("Attachment")
		pushAttachment.Parent = hrp

		pushVelocity = Instance.new("LinearVelocity")
		pushVelocity.Attachment0 = pushAttachment
		pushVelocity.MaxForce = 0
		pushVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
		pushVelocity.PrimaryTangentAxis = Vector3.new(1, 0, 0)
		pushVelocity.SecondaryTangentAxis = Vector3.new(0, 0, 1)
		pushVelocity.PlaneVelocity = Vector2.new(0, 0)
		pushVelocity.Parent = hrp
	end

	local function protectWalkSpeed(humanoid)
		if not CONFIG.PROTECT_WALKSPEED then return end
		if walkspeedConn then walkspeedConn:Disconnect() end

		walkspeedConn = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
			if not isActive then return end
			local now = os.clock()
			if humanoid.WalkSpeed \~= currentSpeed and now - lastResetTime > CONFIG.RESET_COOLDOWN then
				lastResetTime = now
				safeCall(function()
					humanoid.WalkSpeed = currentSpeed
				end)
			end
		end)
	end

	local function applyWallPush(hrp, humanoid)
		if not CONFIG.WALL_PUSH_ENABLED or not pushVelocity then return end

		local moveDir = humanoid.MoveDirection
		if moveDir.Magnitude < 0.1 then
			pushVelocity.MaxForce = 0
			return
		end

		local look = hrp.CFrame.LookVector
		local horizLook = Vector3.new(look.X, 0, look.Z)
		if horizLook.Magnitude < 0.01 then
			pushVelocity.MaxForce = 0
			return
		end
		horizLook = horizLook.Unit

		if moveDir:Dot(horizLook) < CONFIG.WALL_MIN_MOVE_DOT then
			pushVelocity.MaxForce = 0
			return
		end

		rayParams.FilterDescendantsInstances = buildCharacterFilter(player.Character)

		local totalPush = Vector3.zero
		local origin = hrp.Position

		for _, dir in ipairs(directions) do
			local result = Workspace:Raycast(origin, dir * CONFIG.WALL_CHECK_DISTANCE, rayParams)
			if result then
				local n = result.Normal
				if math.abs(n.Y) < 0.72 then
					local h = Vector3.new(n.X, 0, n.Z)
					if h.Magnitude > 0.01 then
						local force = (CONFIG.WALL_CHECK_DISTANCE - result.Distance) / CONFIG.WALL_CHECK_DISTANCE
						totalPush = totalPush + h.Unit * force
					end
				end
			end
		end

		if totalPush.Magnitude < 0.04 then
			pushVelocity.MaxForce = 0
			return
		end

		local pushDir = totalPush.Unit
		local strength = math.clamp(totalPush.Magnitude, 0.2, 1.3)
		local pushVel = pushDir * (CONFIG.WALL_PUSH_FORCE * strength * 0.09)

		pushVelocity.PlaneVelocity = Vector2.new(pushVel.X, pushVel.Z)
		pushVelocity.MaxForce = CONFIG.WALL_PUSH_FORCE * 6
	end

	local function stopSpeed()
		if heartbeatConn then heartbeatConn:Disconnect() heartbeatConn = nil end
		if verifyThread then pcall(task.cancel, verifyThread) verifyThread = nil end
		if walkspeedConn then walkspeedConn:Disconnect() walkspeedConn = nil end

		isActive = false
		cleanupPushPhysics()

		local _, humanoid = getParts(player)
		if humanoid then
			safeCall(function() humanoid.WalkSpeed = CONFIG.DEFAULT_WALKSPEED end)
		end

		safeCall(function()
			if speedBtn and speedBtn.Parent then
				speedBtn.Text = "Aktifkan Speed Presisi"
				speedBtn.BackgroundColor3 = Color3.fromRGB(130, 0, 180)
			end
		end)
	end

	local function startSpeed(speed)
		stopSpeed()

		local _, humanoid, hrp = getParts(player)
		if not humanoid or not hrp then return end

		targetSpeed = math.clamp(speed, CONFIG.MIN_SPEED, CONFIG.MAX_SPEED)
		currentSpeed = humanoid.WalkSpeed
		isActive = true
		lastResetTime = 0

		setupPushPhysics(hrp)
		protectWalkSpeed(humanoid)

		heartbeatConn = RunService.Heartbeat:Connect(function(dt)
			local c, h, root = getParts(player)
			if not c or not h or not root then return end

			local now = os.clock()

			-- Smooth speed
			local diff = targetSpeed - currentSpeed
			if math.abs(diff) > 0.4 then
				local step = (diff > 0) and CONFIG.ACCELERATION * (dt * 60) or -CONFIG.DECELERATION * (dt * 60)
				currentSpeed = currentSpeed + math.clamp(step, -math.abs(diff), math.abs(diff))
			else
				currentSpeed = targetSpeed
			end

			local serverSpeed = h.WalkSpeed
			if serverSpeed == 0 and not CONFIG.FORCE_THROUGH_GAME_LOCKS then
				currentSpeed = 0
			else
				if serverSpeed \~= currentSpeed then
					if now - lastResetTime > CONFIG.RESET_COOLDOWN then
						lastResetTime = now
						safeCall(function() h.WalkSpeed = currentSpeed end)
					end
				else
					safeCall(function() h.WalkSpeed = currentSpeed end)
				end
			end

			safeCall(applyWallPush, root, h)
		end)

		verifyThread = task.spawn(function()
			while isActive do
				task.wait(CONFIG.VERIFY_INTERVAL)
				if not isActive then break end
				local _, h = getParts(player)
				if h and h.WalkSpeed \~= 0 and math.abs(h.WalkSpeed - currentSpeed) > 0.5 then
					safeCall(function() h.WalkSpeed = currentSpeed end)
				end
			end
		end)

		safeCall(function()
			if speedBtn and speedBtn.Parent then
				speedBtn.Text = "Speed Aktif (" .. targetSpeed .. ")"
				speedBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 40)
			end
		end)
	end

	-- ===================== Events =====================
	speedBtn.MouseButton1Click:Connect(function()
		local v = tonumber(speedBox.Text)
		if not v or v <= 0 then
			speedBox.PlaceholderText = "Angka tidak valid!"
			return
		end
		if v < CONFIG.MIN_SPEED or v > CONFIG.MAX_SPEED then
			speedBox.PlaceholderText = "Range " .. CONFIG.MIN_SPEED .. "-" .. CONFIG.MAX_SPEED
			return
		end
		if isActive and math.abs(targetSpeed - v) < 0.1 then
			stopSpeed()
		else
			startSpeed(v)
		end
	end)

	fixBtn.MouseButton1Click:Connect(function()
		local char, _, hrp = getParts(player)
		if not hrp then return end
		stopSpeed()

		safeCall(function()
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.AssemblyAngularVelocity = Vector3.zero

			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = {char}
			params.RespectCanCollide = true

			local up = Workspace:Raycast(hrp.Position, Vector3.new(0, 8, 0), params)
			local lift = up and math.max(up.Distance - 0.5, 1.2) or 4
			local target = hrp.Position + Vector3.new(0, lift, 0)
			local down = Workspace:Raycast(target, Vector3.new(0, -(lift + 2), 0), params)
			if down then
				target = down.Position + Vector3.new(0, 3, 0)
			end
			hrp.CFrame = hrp.CFrame + (target - hrp.Position)

			speedBox.Text = ""
			if fixBtn and fixBtn.Parent then
				fixBtn.Text = "Berhasil Direset!"
				task.delay(1.2, function()
					if fixBtn and fixBtn.Parent then
						fixBtn.Text = "Fix Posisi / Reset Nyangkut"
					end
				end)
			end
		end)
	end)

	charConn = player.CharacterAdded:Connect(function()
		stopSpeed()
	end)

	treeConn = tab.AncestryChanged:Connect(function(_, parent)
		if not parent then
			stopSpeed()
			if charConn then charConn:Disconnect() end
			if treeConn then treeConn:Disconnect() end
		end
	end)

	print("[SpeedModule] UI berhasil dibuat") -- biar tau di console
	return { stop = stopSpeed }
end

return SpeedModule
