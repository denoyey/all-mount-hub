-- local function disableLogs()
-- 	_G.originalPrint = print
-- 	_G.originalWarn = warn
-- 	_G.originalError = error
-- 	print = function(...) end
-- 	warn = function(...) end
-- 	error = function(...) end
-- end
-- disableLogs()


local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
	Name = "All Mount Hub",
	Icon = 4483362458,
	LoadingTitle = "All Mount Hub",
	LoadingSubtitle = "by WhoAmI",
	ShowText = "All Mount Hub v1.0",
	Theme = "Amethyst",
	ToggleUIKeybind = "Q",
	DisableRayfieldPrompts = true,
	DisableBuildWarnings = true,
	ConfigurationSaving = {
		Enabled = false,
		FolderName = nil,
		FileName = "AllMountHub"
	},
	Discord = {
		Enabled = true,
		Invite = "https://discord.gg/whoami?",
		RememberJoins = true
	},
	KeySystem = true,
	KeySettings = {
		Title = "All Mount Hub",
		Subtitle = "Key System",
		Note = "Required Key System..",
		FileName = "AMHKey",
		SaveKey = false,
		GrabKeyFromSite = false,
		Key = {"test"}
	}
})

local function notif(title, text)
	Rayfield:Notify({
		Title = title,
		Content = text,
		Duration = 5,
		Image = 4483362458
	})
end
notif("WHOAMI?", "Enjoy this ny script.")



local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local defaultSpeed, defaultJump, defaultFlySpeed = 16, 50, 60
local bodyVelocity, antiKBConnection, flySpeed = nil, nil, defaultFlySpeed
local states = {
	noclip = false,
	antiFall = false,
	antiRagdoll = false,
	infJump = false,
	fly = false,
	antiKB = false,
	esp = false,
	godMode = false,
	autoHeal = false
}
local function setHumanoidStates(enable)
	if hum then
		pcall(function()
			hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, enable)
			hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, enable)
			hum:SetStateEnabled(Enum.HumanoidStateType.Physics, enable)
		end)
	end
end
local function updateCharacterEffects(c)
	char = c
	hum = c:WaitForChild("Humanoid")
	if states.antiRagdoll then setHumanoidStates(false) end
	if antiKBConnection then antiKBConnection:Disconnect() end
	if states.antiKB then
		local root = char:WaitForChild("HumanoidRootPart")
		antiKBConnection = root:GetPropertyChangedSignal("Velocity"):Connect(function()
			if states.antiKB then root.Velocity = Vector3.zero end
		end)
	end
end
lp.CharacterAdded:Connect(updateCharacterEffects)
RunService.Stepped:Connect(function()
	if states.noclip and lp.Character then
		for _, part in ipairs(lp.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)
RunService.Heartbeat:Connect(function()
	if not hum or not char then return end
	if states.godMode then
		hum.Health = hum.MaxHealth
		pcall(function()
			hum:ChangeState(Enum.HumanoidStateType.Seated, false)
			hum:ChangeState(Enum.HumanoidStateType.Ragdoll, false)
		end)
	end
	if states.autoHeal and hum.Health < hum.MaxHealth then
		hum.Health = math.min(hum.Health + 1, hum.MaxHealth)
	end
	if states.antiFall and char:FindFirstChild("HumanoidRootPart") then
		if char.HumanoidRootPart.Velocity.Y < -100 then
			char.HumanoidRootPart.Velocity = Vector3.new(0, -50, 0)
		end
	end
	if states.fly and char:FindFirstChild("HumanoidRootPart") then
		if not bodyVelocity then
			bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Velocity = Vector3.zero
			bodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 1e6
			bodyVelocity.Parent = char.HumanoidRootPart
		end
		local move = Vector3.zero
		if UIS:IsKeyDown(Enum.KeyCode.W) then move += Vector3.new(0, 0, -1) end
		if UIS:IsKeyDown(Enum.KeyCode.S) then move += Vector3.new(0, 0, 1) end
		if UIS:IsKeyDown(Enum.KeyCode.A) then move += Vector3.new(-1, 0, 0) end
		if UIS:IsKeyDown(Enum.KeyCode.D) then move += Vector3.new(1, 0, 0) end
		if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
		if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move += Vector3.new(0, -1, 0) end
		bodyVelocity.Velocity = move.Magnitude > 0 and workspace.CurrentCamera.CFrame:VectorToWorldSpace(move.Unit) * flySpeed or Vector3.zero
	elseif bodyVelocity then
		bodyVelocity:Destroy()
		bodyVelocity = nil
	end
end)
UIS.JumpRequest:Connect(function()
	if states.infJump and hum then
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)
local function enableESP()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= lp and player.Character and not player.Character:FindFirstChild("ESP_Name") then
			local tag = Instance.new("BillboardGui", player.Character)
			tag.Name = "ESP_Name"
			tag.Size = UDim2.new(0, 100, 0, 20)
			tag.AlwaysOnTop = true
			tag.Adornee = player.Character:WaitForChild("Head")
			tag.StudsOffset = Vector3.new(0, 2, 0)
			local text = Instance.new("TextLabel", tag)
			text.Size = UDim2.new(1, 0, 1, 0)
			text.Text = player.Name
			text.BackgroundTransparency = 1
			text.TextColor3 = Color3.fromRGB(255, 255, 255)
			text.TextStrokeTransparency = 0.5
			text.Font = Enum.Font.SourceSansBold
			text.TextScaled = true
		end
	end
end
local function disableESP()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= lp and player.Character then
			local esp = player.Character:FindFirstChild("ESP_Name")
			if esp then esp:Destroy() end
		end
	end
end
local function forcePush()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= lp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local theirHRP = player.Character.HumanoidRootPart
			local yourHRP = char:FindFirstChild("HumanoidRootPart")
			if yourHRP then
				local direction = (theirHRP.Position - yourHRP.Position).Unit
				theirHRP.Velocity = direction * 100
			end
		end
	end
end
UIS.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.F then
		forcePush()
	end
end)
local function getAllPlayerNames(excludeLocal)
	local names = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if not excludeLocal or player ~= lp then
			table.insert(names, player.Name)
		end
	end
	return names
end
local ui = {}



-- TAB INFO

local TabInfo = Window:CreateTab("Info")
TabInfo:CreateSection("Script Information")

TabInfo:CreateSection("Update")
TabInfo:CreateButton({
    Name = "Check for Updates",
    Callback = function()
        notif("Update", "No new updates.")
    end
})

TabInfo:CreateSection("Script Info")
TabInfo:CreateParagraph({
    Title = "ALL MOUNT HUB",
    Content = "v1.0 - by WhoAmI",
})

TabInfo:CreateParagraph({
    Title = "CHANGELOG",
    Content = [[
v1.0 – Initial release:  
• Fly / NoClip  
• God Mode, Auto Heal  
• Anti Ragdoll, Anti Fall, Anti KB  
• ESP Name  
• Teleport to player & position  
• Infinite Jump  
• Slider for Speed, Jump, FlySpeed  
• UI & Rayfield design  
]]
})

TabInfo:CreateParagraph({
    Title = "IMPORTANT NOTE",
    Content = [[
This script is made for educational & entertainment purposes.  
Using it in public games may lead to a ban.  
Use responsibly and at your own risk.
]]
})



-- TAB ALL MOUNT

local MountTab = Window:CreateTab("All Mount")
MountTab:CreateSection("All Mount in here.")

MountTab:CreateSection("Print Current Position")
MountTab:CreateButton({
	Name = "My Coordinates (F9 to view)",
	Callback = function()
		local myChar = lp.Character or lp.CharacterAdded:Wait()
		local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
		if myHRP then
			local pos = myHRP.Position
			warn(string.format("My Position: Vector3.new(%.2f, %.2f, %.2f)", pos.X, pos.Y, pos.Z))
		end
	end
})

-- MOUNT ATIN
local checkpointPositions = {
	Vector3.new(16.34, 54.88, -1082.45),
	Vector3.new(-184.30, 127.80, 409.54),
	Vector3.new(-164.85, 229.41, 653.01),
	Vector3.new(-37.85, 406.24, 615.72),
	Vector3.new(130.61, 650.22, 613.45),
	Vector3.new(-246.56, 665.40, 734.58),
	Vector3.new(-684.35, 640.47, 867.51),
	Vector3.new(-658.26, 688.16, 1458.51),
    Vector3.new(-507.94, 902.60, 1868.30),
    Vector3.new(60.75, 949.57, 2088.30),
    Vector3.new(52.09, 981.22, 2450.13),
    Vector3.new(72.80, 1096.64, 2457.60),
    Vector3.new(262.64, 1269.81, 2037.60),
    Vector3.new(-419.25, 1301.84, 2394.52),
    Vector3.new(-773.56, 1313.62, 2665.07),
    Vector3.new(-836.55, 1474.96, 2625.56),
    Vector3.new(-467.87, 1465.41, 2769.58),
    Vector3.new(-467.14, 1537.15, 2836.61),
    Vector3.new(-385.27, 1639.99, 2794.67),
    Vector3.new(-207.88, 1665.45, 2749.39),
    Vector3.new(-232.91, 1741.74, 2791.76),
    Vector3.new(-424.22, 1740.21, 2798.65),
    Vector3.new(-424.07, 1712.12, 3420.85),
    Vector3.new(70.83, 1718.37, 3427.13),
    Vector3.new(436.02, 1720.26, 3430.67),
    Vector3.new(803, 2146, 3908),
}
local checkpointList = {}
for i, pos in ipairs(checkpointPositions) do
	if i == 1 then
		checkpointList["Basecamp"] = pos
	else
		checkpointList["Checkpoint " .. i] = pos
	end
end
local selectedCheckpoint = nil
local checkpointDropdown
local function getCheckpointNames()
	local names = {}
	for name in pairs(checkpointList) do
		table.insert(names, name)
	end
	table.sort(names, function(a, b)
		local numA = tonumber(string.match(a, "%d+")) or 0
		local numB = tonumber(string.match(b, "%d+")) or 0
		return numA < numB
	end)
	return names
end
local function teleportTo(position)
	local char = lp.Character or lp.CharacterAdded:Wait()
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then return false end
	local oldHealth = humanoid.Health
	humanoid.MaxHealth = math.huge
	humanoid.Health = math.huge
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
	local flying = true
	local runService = game:GetService("RunService")
	local floatThread = task.spawn(function()
		while flying do
			runService.Heartbeat:Wait()
			hrp.Velocity = Vector3.zero
			hrp.Anchored = false
		end
	end)
	hrp.CFrame = CFrame.new(position + Vector3.new(0, 5, 0))
	flying = false
	task.delay(0.5, function()
		if humanoid then
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
			humanoid.MaxHealth = oldHealth
			if humanoid.Health > oldHealth then
				humanoid.Health = oldHealth
			end
		end
	end)
	return true
end

MountTab:CreateSection("Mount Atin")
MountTab:CreateButton({
	Name = "Auto Summit",
	Callback = function()
		local char = lp.Character or lp.CharacterAdded:Wait()
		local hrp = char:WaitForChild("HumanoidRootPart")
		local flying = true
		task.spawn(function()
			while flying do
				task.wait()
				hrp.Velocity = Vector3.zero
				hrp.Anchored = false
			end
		end)
		local function getTPPoint(name)
			local obj = workspace:FindFirstChild(name)
			if obj then
				if obj:IsA("BasePart") then
					return obj.CFrame + Vector3.new(0, 5, 0)
				elseif obj:IsA("Model") then
					local cf = obj:GetBoundingBox()
					return cf + Vector3.new(0, 5, 0)
				end
			end
			return nil
		end
		task.spawn(function()
			local pos26 = getTPPoint("Pos26")
			if pos26 then
				hrp.CFrame = pos26
				task.wait(2)
			end
			local summitCoord = Vector3.new(803, 2146, 3908)
			hrp.CFrame = CFrame.new(summitCoord)
			flying = false
		end)
	end,
})
MountTab:CreateButton({
	Name = "Auto DarkEvil",
	Callback = function()
		local Players = game:GetService("Players")
		local TextChatService = game:GetService("TextChatService")
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local StarterGui = game:GetService("StarterGui")
		local UIS = game:GetService("UserInputService")
		local function chat(msg)
			local m = tostring(msg or ""):lower()
			local general = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
			local oldChat = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
			if general then
				pcall(function() general:SendAsync(m) end)
			elseif oldChat and oldChat:FindFirstChild("SayMessageRequest") then
				pcall(function() oldChat.SayMessageRequest:FireServer(m, "All") end)
			else
				pcall(function()
					StarterGui:SetCore("ChatMakeSystemMessage", {Text = m, Color = Color3.fromRGB(255, 255, 255)})
				end)
			end
		end
		local function adjustPrompt(prompt)
			if prompt:IsA("ProximityPrompt") then
				pcall(function()
					prompt.HoldDuration = 0
					prompt.KeyboardKeyCode = Enum.KeyCode.E
				end)
			end
		end
		local function interactAtRadius(radius, timeout)
			local char = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
			local hrp = char:WaitForChild("HumanoidRootPart")
			local t0 = tick()
			local firedAny = false
			while tick() - t0 < (timeout or 4) do
				for _, prompt in ipairs(workspace:GetDescendants()) do
					if prompt:IsA("ProximityPrompt") and prompt.Enabled then
						local parent = prompt.Parent
						local part = parent:IsA("BasePart") and parent or parent:FindFirstChildWhichIsA("BasePart", true)
						if part and (part.Position - hrp.Position).Magnitude <= (radius or 50) then
							adjustPrompt(prompt)
							for attempt = 1, 4 do
								pcall(function() fireproximityprompt(prompt) end)
								task.wait(0.1)
							end
							firedAny = true
						end
					end
				end
				if firedAny then break end
				task.wait(0.1)
			end
			return firedAny
		end
		local function step(pos, messages, delayPerChat)
			local char = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
			local hrp = char:WaitForChild("HumanoidRootPart")
			hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
			if messages then
				for _, msg in ipairs(messages) do
					chat(msg)
					task.wait((delayPerChat or 2) + math.random() * 0.8) 
				end
			end
		end
		local lp = Players.LocalPlayer
		local char = lp.Character or lp.CharacterAdded:Wait()
		local hrp = char:WaitForChild("HumanoidRootPart")
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if not hrp or not humanoid then return end
		local oldHealth = humanoid.Health
		humanoid.MaxHealth = math.huge
		humanoid.Health = math.huge
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
		step(Vector3.new(-454.08, -41.91, -594.20), {"omatsurimambo"}, 2)
		task.wait(2)
		step(Vector3.new(190.06, 37.87, -815.01), {
			"sang hyang jagad",
			"kawula nyuwun pangayoman",
			"kawula nyuwun pitedah",
			"mugi tansah pinaringan rahayu",
		}, 2)
		interactAtRadius(50, 4)
		task.wait(2)
		step(Vector3.new(-205.26, 84.96, -49.81), {
			"ompu mulajadi nabolon",
			"tuanku na bolon",
			"pasu-pasu ma hami",
			"jaga ma hami di tano on di langit on",
		}, 2)
		interactAtRadius(50, 4)
		task.wait(2)
        humanoid.PlatformStand = true
		step(Vector3.new(128.38, -60.92, -1590.00), {
			"hai sangiyang lahat",
			"datang handiai kami",
			"bawalah pasahat penyembuhan",
			"jaga uluh lew tatangka betang lewu ntuhan",
		}, 2)
		interactAtRadius(50, 4)
        humanoid.PlatformStand = false
		task.wait(2)
		step(Vector3.new(-159.03, 16.71, -1115.91), {
			"om bhuta kala",
			"ring kaja kangin",
			"rauh ring caru",
			"sampun ngamuk sampun ngamangsuh",
		}, 2)
		interactAtRadius(50, 4)
		task.wait(2)
		step(Vector3.new(258.00, -55.36, -173.46), {
			"wor nubu mambram",
			"ai rofam ro",
			"mamfwar nubu mansard",
			"nafan kor rofam",
		}, 2)
		interactAtRadius(50, 4)
		task.wait(1)
        step(Vector3.new(-440.10, -42.30, -602.51), {""}, 2)
        interactAtRadius(50, 4)
        task.wait(2)
        step(Vector3.new(-454.02, -42.30, -609.42), {""}, 2)
        interactAtRadius(50, 4)
        task.wait(2)
        step(Vector3.new(-467.60, -42.30, -603.04), {""}, 2)
        interactAtRadius(50, 4)
        task.wait(2)
        step(Vector3.new(-467.44, -42.30, -586.53), {""}, 2)
        interactAtRadius(50, 4)
        task.wait(2)
        step(Vector3.new(-446.02, -42.30, -580.51), {""}, 2)
        interactAtRadius(50, 4)
        task.wait(2)
        step(Vector3.new(-454.08, -41.91, -594.20), {""}, 2)
        interactAtRadius(50, 4)
        task.wait(1)
		task.delay(0.5, function()
			if humanoid then
				humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
				humanoid.MaxHealth = oldHealth
				if humanoid.Health > oldHealth then
					humanoid.Health = oldHealth
				end
			end
		end)
	end,
})
checkpointDropdown = MountTab:CreateDropdown({
	Name = "Select Checkpoint",
	Options = getCheckpointNames(),
	CurrentOption = nil,
	MultiSelection = false,
	Callback = function(option)
		selectedCheckpoint = typeof(option) == "table" and option[1] or option
	end,
})
MountTab:CreateButton({
	Name = "Go to Checkpoint",
	Callback = function()
		if not selectedCheckpoint then
			return notif("Select a Checkpoint", "Please choose a checkpoint first.")
		end
		local destination = checkpointList[selectedCheckpoint]
		if destination then
			local success = teleportTo(destination)
			if success then
				notif("Teleported", "You have been teleported to " .. selectedCheckpoint)
			else
				notif("Error", "HumanoidRootPart not found.")
			end
		else
			notif("Error", "Checkpoint not found in list.")
		end
	end,
})


-- MOUNT DAUN
local checkpointPositions = {
	Vector3.new(-6.56, 13.44, -8.49),
	Vector3.new(-622.57, 249.81, -383.80),
	Vector3.new(-1202.65, 261.14, -487.39),
	Vector3.new(-1352.48, 522.31, -894.88),
	Vector3.new(-1679.87, 824.93, -1328.14),
	Vector3.new(-3083.63, 1730.87, -2642.92),
}
local checkpointList = {}
for i, pos in ipairs(checkpointPositions) do
	if i == 1 then
		checkpointList["Basecamp"] = pos
	else
		checkpointList["Checkpoint " .. (i - 1)] = pos
	end
end
local selectedCheckpoint = nil
local checkpointDropdown
local function getCheckpointNames()
	local names = {}
	for name in pairs(checkpointList) do
		table.insert(names, name)
	end
	table.sort(names, function(a, b)
		local numA = tonumber(string.match(a, "%d+")) or 0
		local numB = tonumber(string.match(b, "%d+")) or 0
		return numA < numB
	end)
	return names
end
local function teleportTo(position)
	local char = lp.Character or lp.CharacterAdded:Wait()
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then return false end
	local oldHealth = humanoid.Health
	humanoid.MaxHealth = math.huge
	humanoid.Health = math.huge
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
	local flying = true
	local runService = game:GetService("RunService")
	local floatThread = task.spawn(function()
		while flying do
			runService.Heartbeat:Wait()
			hrp.Velocity = Vector3.zero
			hrp.Anchored = false
		end
	end)
	hrp.CFrame = CFrame.new(position + Vector3.new(0, 5, 0))
	flying = false
	task.delay(0.5, function()
		if humanoid then
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
			humanoid.MaxHealth = oldHealth
			if humanoid.Health > oldHealth then
				humanoid.Health = oldHealth
			end
		end
	end)
	return true
end
MountTab:CreateSection("Mount Daun")
MountTab:CreateButton({
	Name = "Auto Summit",
	Callback = function()
		local char = lp.Character or lp.CharacterAdded:Wait()
		local hrp = char:WaitForChild("HumanoidRootPart")
		local flying = true
		task.spawn(function()
			while flying do
				task.wait()
				hrp.Velocity = Vector3.zero
				hrp.Anchored = false
			end
		end)
		local function getTPPoint(name)
			local obj = workspace:FindFirstChild(name)
			if obj then
				if obj:IsA("BasePart") then
					return obj.CFrame + Vector3.new(0, 5, 0)
				elseif obj:IsA("Model") then
					local cf = obj:GetBoundingBox()
					return cf + Vector3.new(0, 5, 0)
				end
			end
			return nil
		end
		task.spawn(function()
			local pos26 = getTPPoint("Checkpoint 5")
			if pos26 then
				hrp.CFrame = pos26
				task.wait(2.5)
			end
			local summitCoord = Vector3.new(-3083.63, 1730.87, -2642.92)
			hrp.CFrame = CFrame.new(summitCoord)
			flying = false
		end)
	end,
})
checkpointDropdown = MountTab:CreateDropdown({
	Name = "Select Checkpoint",
	Options = getCheckpointNames(),
	CurrentOption = nil,
	MultiSelection = false,
	Callback = function(option)
		selectedCheckpoint = typeof(option) == "table" and option[1] or option
	end,
})
MountTab:CreateButton({
	Name = "Go to Checkpoint",
	Callback = function()
		if not selectedCheckpoint then
			return notif("Select a Checkpoint", "Please choose a checkpoint first.")
		end
		local destination = checkpointList[selectedCheckpoint]
		if destination then
			local success = teleportTo(destination)
			if success then
				notif("Teleported", "You have been teleported to " .. selectedCheckpoint)
			else
				notif("Error", "HumanoidRootPart not found.")
			end
		else
			notif("Error", "Checkpoint not found in list.")
		end
	end,
})


-- MOUNT YNTKTS
local checkpointPositions = {
	Vector3.new(-664.72, 58.22, -442.34),
	Vector3.new(-46.24, 42.22, -554.55),
	Vector3.new(833.55, 66.22, -427.35),
	Vector3.new(1013.90, 70.84, -109.28),
	Vector3.new(2089.07, 70.22, -146.97),
	Vector3.new(2330.55, 62.44, -139.08),
	Vector3.new(2548.66, 42.09, -414.55),
	Vector3.new(2682.99, 86.30, -334.83),
	Vector3.new(2713.42, 158.42, -363.13),
	Vector3.new(3036.69, 154.22, -365.26),
	Vector3.new(3227.04, -5.63, -338.17),
	Vector3.new(3668.05, 22.36, -219.92),
	Vector3.new(3724.57, 90.22, -247.05),
	Vector3.new(4005.08, 64.36, -315.79),
	Vector3.new(4443.74, 83.15, -310.08),
}
local checkpointList = {}
for i, pos in ipairs(checkpointPositions) do
	if i == 1 then
		checkpointList["Basecamp"] = pos
	else
		checkpointList["Checkpoint " .. i] = pos
	end
end
local selectedCheckpoint = nil
local checkpointDropdown
local function getCheckpointNames()
	local names = {}
	for name in pairs(checkpointList) do
		table.insert(names, name)
	end
	table.sort(names, function(a, b)
		local numA = tonumber(string.match(a, "%d+")) or 0
		local numB = tonumber(string.match(b, "%d+")) or 0
		return numA < numB
	end)
	return names
end
local function teleportTo(position)
	local char = lp.Character or lp.CharacterAdded:Wait()
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then return false end
	local oldHealth = humanoid.Health
	humanoid.MaxHealth = math.huge
	humanoid.Health = math.huge
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
	local flying = true
	local runService = game:GetService("RunService")
	local floatThread = task.spawn(function()
		while flying do
			runService.Heartbeat:Wait()
			hrp.Velocity = Vector3.zero
			hrp.Anchored = false
		end
	end)
	hrp.CFrame = CFrame.new(position + Vector3.new(0, 5, 0))
	flying = false
	task.delay(0.5, function()
		if humanoid then
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
			humanoid.MaxHealth = oldHealth
			if humanoid.Health > oldHealth then
				humanoid.Health = oldHealth
			end
		end
	end)
	return true
end
MountTab:CreateSection("Mount YNTKTS")
MountTab:CreateButton({
	Name = "Auto Summit",
	Callback = function()
		local char = lp.Character or lp.CharacterAdded:Wait()
		local hrp = char:WaitForChild("HumanoidRootPart")
		local flying = true
		task.spawn(function()
			while flying do
				task.wait()
				hrp.Velocity = Vector3.zero
				hrp.Anchored = false
			end
		end)
		local checkpointPositions = {
			Vector3.new(-664.72, 58.22, -442.34),
			Vector3.new(-46.24, 42.22, -554.55),
			Vector3.new(833.55, 66.22, -427.35),
			Vector3.new(1013.90, 70.84, -109.28),
			Vector3.new(2089.07, 70.22, -146.97),
			Vector3.new(2330.55, 62.44, -139.08),
			Vector3.new(2548.66, 42.09, -414.55),
			Vector3.new(2682.99, 86.30, -334.83),
			Vector3.new(2713.42, 158.42, -363.13),
			Vector3.new(3036.69, 154.22, -365.26),
			Vector3.new(3227.04, -5.63, -338.17),
			Vector3.new(3668.05, 22.36, -219.92),
			Vector3.new(3724.57, 90.22, -247.05),
			Vector3.new(4005.08, 64.36, -315.79),
			Vector3.new(4443.74, 83.15, -310.08),
		}
		task.spawn(function()
			for i, pos in ipairs(checkpointPositions) do
				hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
				task.wait(2.5)
			end
			flying = false
		end)
	end,
})
checkpointDropdown = MountTab:CreateDropdown({
	Name = "Select Checkpoint",
	Options = getCheckpointNames(),
	CurrentOption = nil,
	MultiSelection = false,
	Callback = function(option)
		selectedCheckpoint = typeof(option) == "table" and option[1] or option
	end,
})
MountTab:CreateButton({
	Name = "Go to Checkpoint",
	Callback = function()
		if not selectedCheckpoint then
			return notif("Select a Checkpoint", "Please choose a checkpoint first.")
		end
		local destination = checkpointList[selectedCheckpoint]
		if destination then
			local success = teleportTo(destination)
			if success then
				notif("Teleported", "You have been teleported to " .. selectedCheckpoint)
			else
				notif("Error", "HumanoidRootPart not found.")
			end
		else
			notif("Error", "Checkpoint not found in list.")
		end
	end,
})


-- MOUNT RUNIA
local checkpointPositions = {
	Vector3.new(701.02, 184.71, -675.74),
	Vector3.new(505.28, 244.56, -370.00),
	Vector3.new(517.95, 460.51, -269.17),
	Vector3.new(522.51, 468.71, -53.90),
	Vector3.new(321.85, 332.71, -83.01),
	Vector3.new(140.48, 496.51, 671.81),
	Vector3.new(-46.47, 637.52, 810.89),
	Vector3.new(-212.03, 931.41, 422.62),
	Vector3.new(-554.04, 960.65, -174.14),
}
local checkpointList = {}
for i, pos in ipairs(checkpointPositions) do
	if i == 1 then
		checkpointList["Basecamp"] = pos
	else
		checkpointList["Checkpoint " .. i] = pos
	end
end
local selectedCheckpoint = nil
local checkpointDropdown
local function getCheckpointNames()
	local names = {}
	for name in pairs(checkpointList) do
		table.insert(names, name)
	end
	table.sort(names, function(a, b)
		local numA = tonumber(string.match(a, "%d+")) or 0
		local numB = tonumber(string.match(b, "%d+")) or 0
		return numA < numB
	end)
	return names
end
local function teleportTo(position)
	local char = lp.Character or lp.CharacterAdded:Wait()
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then return false end
	local oldHealth = humanoid.Health
	humanoid.MaxHealth = math.huge
	humanoid.Health = math.huge
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
	local flying = true
	local runService = game:GetService("RunService")
	local floatThread = task.spawn(function()
		while flying do
			runService.Heartbeat:Wait()
			hrp.Velocity = Vector3.zero
			hrp.Anchored = false
		end
	end)
	hrp.CFrame = CFrame.new(position + Vector3.new(0, 5, 0))
	flying = false
	task.delay(0.5, function()
		if humanoid then
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
			humanoid.MaxHealth = oldHealth
			if humanoid.Health > oldHealth then
				humanoid.Health = oldHealth
			end
		end
	end)
	return true
end
MountTab:CreateSection("Mount Runia")
MountTab:CreateButton({
	Name = "Auto Summit",
	Callback = function()
		local char = lp.Character or lp.CharacterAdded:Wait()
		local hrp = char:WaitForChild("HumanoidRootPart")
		local flying = true
		task.spawn(function()
			while flying do
				task.wait()
				hrp.Velocity = Vector3.zero
				hrp.Anchored = false
			end
		end)
		local checkpointPositions = {
			Vector3.new(701.02, 184.71, -675.74),
			Vector3.new(505.28, 244.56, -370.00),
			Vector3.new(517.95, 460.51, -269.17),
			Vector3.new(522.51, 468.71, -53.90),
			Vector3.new(321.85, 332.71, -83.01),
			Vector3.new(140.48, 496.51, 671.81),
			Vector3.new(-46.47, 637.52, 810.89),
			Vector3.new(-212.03, 931.41, 422.62),
			Vector3.new(-554.04, 960.65, -174.14),
		}
		task.spawn(function()
			for i, pos in ipairs(checkpointPositions) do
				hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
				task.wait(2.5)
			end
			flying = false
		end)
	end,
})
checkpointDropdown = MountTab:CreateDropdown({
	Name = "Select Checkpoint",
	Options = getCheckpointNames(),
	CurrentOption = nil,
	MultiSelection = false,
	Callback = function(option)
		selectedCheckpoint = typeof(option) == "table" and option[1] or option
	end,
})
MountTab:CreateButton({
	Name = "Go to Checkpoint",
	Callback = function()
		if not selectedCheckpoint then
			return notif("Select a Checkpoint", "Please choose a checkpoint first.")
		end
		local destination = checkpointList[selectedCheckpoint]
		if destination then
			local success = teleportTo(destination)
			if success then
				notif("Teleported", "You have been teleported to " .. selectedCheckpoint)
			else
				notif("Error", "HumanoidRootPart not found.")
			end
		else
			notif("Error", "Checkpoint not found in list.")
		end
	end,
})


-- MOUNT SUMBING
local checkpointPositions = {
	Vector3.new(-332.71, 4.71, 29.92),
	Vector3.new(-225.41, 440.71, 2142.53),
	Vector3.new(-428.63, 848.71, 3204.49),
	Vector3.new(43.77, 1268.71, 4043.35),
	Vector3.new(-1142.68, 1552.71, 4901.33),
	Vector3.new(-885.24, 1966.47, 5441.23),
}
local checkpointList = {}
for i, pos in ipairs(checkpointPositions) do
	if i == 1 then
		checkpointList["Basecamp"] = pos
	else
		checkpointList["Checkpoint " .. (i - 1)] = pos
	end
end
local selectedCheckpoint = nil
local checkpointDropdown
local function getCheckpointNames()
	local names = {}
	for name in pairs(checkpointList) do
		table.insert(names, name)
	end
	table.sort(names, function(a, b)
		local numA = tonumber(string.match(a, "%d+")) or 0
		local numB = tonumber(string.match(b, "%d+")) or 0
		return numA < numB
	end)
	return names
end
local function teleportTo(position)
	local char = lp.Character or lp.CharacterAdded:Wait()
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then return false end
	local oldHealth = humanoid.Health
	humanoid.MaxHealth = math.huge
	humanoid.Health = math.huge
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
	local flying = true
	local runService = game:GetService("RunService")
	local floatThread = task.spawn(function()
		while flying do
			runService.Heartbeat:Wait()
			hrp.Velocity = Vector3.zero
			hrp.Anchored = false
		end
	end)
	hrp.CFrame = CFrame.new(position + Vector3.new(0, 5, 0))
	flying = false
	task.delay(0.5, function()
		if humanoid then
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
			humanoid.MaxHealth = oldHealth
			if humanoid.Health > oldHealth then
				humanoid.Health = oldHealth
			end
		end
	end)
	return true
end
MountTab:CreateSection("Mount Sumbing")
MountTab:CreateButton({
	Name = "Auto Summit",
	Callback = function()
		local char = lp.Character or lp.CharacterAdded:Wait()
		local hrp = char:WaitForChild("HumanoidRootPart")
		local flying = true
		task.spawn(function()
			while flying do
				task.wait()
				hrp.Velocity = Vector3.zero
				hrp.Anchored = false
			end
		end)
		local checkpointPositions = {
			Vector3.new(-225.41, 440.71, 2142.53),
			Vector3.new(-428.63, 848.71, 3204.49),
			Vector3.new(43.77, 1268.71, 4043.35),
			Vector3.new(-1142.68, 1552.71, 4901.33),
			Vector3.new(-885.24, 1966.47, 5441.23),
		}
		task.spawn(function()
			for i, pos in ipairs(checkpointPositions) do
				hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
				task.wait(2.5)
			end
			flying = false
		end)
	end,
})
checkpointDropdown = MountTab:CreateDropdown({
	Name = "Select Checkpoint",
	Options = getCheckpointNames(),
	CurrentOption = nil,
	MultiSelection = false,
	Callback = function(option)
		selectedCheckpoint = typeof(option) == "table" and option[1] or option
	end,
})
MountTab:CreateButton({
	Name = "Go to Checkpoint",
	Callback = function()
		if not selectedCheckpoint then
			return notif("Select a Checkpoint", "Please choose a checkpoint first.")
		end
		local destination = checkpointList[selectedCheckpoint]
		if destination then
			local success = teleportTo(destination)
			if success then
				notif("Teleported", "You have been teleported to " .. selectedCheckpoint)
			else
				notif("Error", "HumanoidRootPart not found.")
			end
		else
			notif("Error", "Checkpoint not found in list.")
		end
	end,
})


-- MOUNT YAHAYUK
local checkpointPositions = {
	Vector3.new(-958.02, 168.891, 876.13),
	Vector3.new(-422.20, 248.63, 746.90),
	Vector3.new(-346.05, 387.97, 517.40),
}
local checkpointList = {}
for i, pos in ipairs(checkpointPositions) do
	if i == 1 then
		checkpointList["Basecamp"] = pos
	else
		checkpointList["Checkpoint " .. (i - 1)] = pos
	end
end
local selectedCheckpoint = nil
local checkpointDropdown
local function getCheckpointNames()
	local names = {}
	for name in pairs(checkpointList) do
		table.insert(names, name)
	end
	table.sort(names, function(a, b)
		local numA = tonumber(string.match(a, "%d+")) or 0
		local numB = tonumber(string.match(b, "%d+")) or 0
		return numA < numB
	end)
	return names
end
local function teleportTo(position)
	local char = lp.Character or lp.CharacterAdded:Wait()
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then return false end
	local oldHealth = humanoid.Health
	humanoid.MaxHealth = math.huge
	humanoid.Health = math.huge
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
	local flying = true
	local runService = game:GetService("RunService")
	local floatThread = task.spawn(function()
		while flying do
			runService.Heartbeat:Wait()
			hrp.Velocity = Vector3.zero
			hrp.Anchored = false
		end
	end)
	hrp.CFrame = CFrame.new(position + Vector3.new(0, 5, 0))
	flying = false
	task.delay(0.5, function()
		if humanoid then
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
			humanoid.MaxHealth = oldHealth
			if humanoid.Health > oldHealth then
				humanoid.Health = oldHealth
			end
		end
	end)
	return true
end
MountTab:CreateSection("Mount YAHAYUK (SOON)")
MountTab:CreateButton({
	Name = "Auto Summit",
	Callback = function()
		local char = lp.Character or lp.CharacterAdded:Wait()
		local hrp = char:WaitForChild("HumanoidRootPart")
		local flying = true
		task.spawn(function()
			while flying do
				task.wait()
				hrp.Velocity = Vector3.zero
				hrp.Anchored = false
			end
		end)
		local checkpointPositions = {
			Vector3.new(-422.20, 248.63, 746.90),
			Vector3.new(-346.05, 387.97, 517.40),
		}
		task.spawn(function()
			for i, pos in ipairs(checkpointPositions) do
				hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
				task.wait(2.5)
			end
			flying = false
		end)
	end,
})
checkpointDropdown = MountTab:CreateDropdown({
	Name = "Select Checkpoint",
	Options = getCheckpointNames(),
	CurrentOption = nil,
	MultiSelection = false,
	Callback = function(option)
		selectedCheckpoint = typeof(option) == "table" and option[1] or option
	end,
})
MountTab:CreateButton({
	Name = "Go to Checkpoint",
	Callback = function()
		if not selectedCheckpoint then
			return notif("Select a Checkpoint", "Please choose a checkpoint first.")
		end
		local destination = checkpointList[selectedCheckpoint]
		if destination then
			local success = teleportTo(destination)
			if success then
				notif("Teleported", "You have been teleported to " .. selectedCheckpoint)
			else
				notif("Error", "HumanoidRootPart not found.")
			end
		else
			notif("Error", "Checkpoint not found in list.")
		end
	end,
})


-- MOUNT SIBUATAN
local checkpointPositions = {
	Vector3.new(990.33, 112.51, -695.93),
	Vector3.new(-313.30, 154.73, -325.39),
	Vector3.new(-727.54, 588.71, -123.80),
	Vector3.new(-883.89, 992.51, -205.08),
	Vector3.new(-1636.63, 992.71, -281.15),
	Vector3.new(-1647.88, 994.74, 632.61),
	Vector3.new(-1638.00, 1112.71, 2150.54),
	Vector3.new(-519.56, 1448.71, 3279.35),
	Vector3.new(-707.27, 1892.63, 2384.27),
	Vector3.new(-860.81, 1940.51, 2071.56),
	Vector3.new(-868.07, 2100.71, 1668.74),
	Vector3.new(-900.93, 2340.71, 1441.99),
	Vector3.new(-846.71, 2764.71, 1505.92),
	Vector3.new(-614.76, 3284.71, 1505.92),
}
local checkpointList = {}
for i, pos in ipairs(checkpointPositions) do
	if i == 1 then
		checkpointList["Basecamp"] = pos
	else
		checkpointList["Checkpoint " .. (i - 1)] = pos
	end
end
local selectedCheckpoint = nil
local checkpointDropdown
local function getCheckpointNames()
	local names = {}
	for name in pairs(checkpointList) do
		table.insert(names, name)
	end
	table.sort(names, function(a, b)
		local numA = tonumber(string.match(a, "%d+")) or 0
		local numB = tonumber(string.match(b, "%d+")) or 0
		return numA < numB
	end)
	return names
end
local function teleportTo(position)
	local char = lp.Character or lp.CharacterAdded:Wait()
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then return false end
	local oldHealth = humanoid.Health
	humanoid.MaxHealth = math.huge
	humanoid.Health = math.huge
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
	local flying = true
	local runService = game:GetService("RunService")
	local floatThread = task.spawn(function()
		while flying do
			runService.Heartbeat:Wait()
			hrp.Velocity = Vector3.zero
			hrp.Anchored = false
		end
	end)
	hrp.CFrame = CFrame.new(position + Vector3.new(0, 5, 0))
	flying = false
	task.delay(0.5, function()
		if humanoid then
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
			humanoid.MaxHealth = oldHealth
			if humanoid.Health > oldHealth then
				humanoid.Health = oldHealth
			end
		end
	end)
	return true
end
MountTab:CreateSection("Mount SIBUATAN")
MountTab:CreateButton({
	Name = "Auto Summit",
	Callback = function()
		local char = lp.Character or lp.CharacterAdded:Wait()
		local hrp = char:WaitForChild("HumanoidRootPart")
		local flying = true
		task.spawn(function()
			while flying do
				task.wait()
				hrp.Velocity = Vector3.zero
				hrp.Anchored = false
			end
		end)
		local checkpointPositions = {
			Vector3.new(-422.20, 248.63, 746.90),
			Vector3.new(-346.05, 387.97, 517.40),
		}
		task.spawn(function()
			for i, pos in ipairs(checkpointPositions) do
				hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
				task.wait(2.5)
			end
			flying = false
		end)
	end,
})
checkpointDropdown = MountTab:CreateDropdown({
	Name = "Select Checkpoint",
	Options = getCheckpointNames(),
	CurrentOption = nil,
	MultiSelection = false,
	Callback = function(option)
		selectedCheckpoint = typeof(option) == "table" and option[1] or option
	end,
})
MountTab:CreateButton({
	Name = "Go to Checkpoint",
	Callback = function()
		if not selectedCheckpoint then
			return notif("Select a Checkpoint", "Please choose a checkpoint first.")
		end
		local destination = checkpointList[selectedCheckpoint]
		if destination then
			local success = teleportTo(destination)
			if success then
				notif("Teleported", "You have been teleported to " .. selectedCheckpoint)
			else
				notif("Error", "HumanoidRootPart not found.")
			end
		else
			notif("Error", "Checkpoint not found in list.")
		end
	end,
})


-- MOUNT RINJANI
local checkpointPositions = {
	Vector3.new(2688.03, 8956.71, 7560.14),
	Vector3.new(3352.45, 9032.71, 5636.30),
	Vector3.new(3071.70, 9108.71, 4459.96),
	Vector3.new(1872.05, 9552.69, 3489.45),
	Vector3.new(1364.99, 9776.71, 3129.28),
	Vector3.new(1192.10, 10122.16, 2292.78),
	Vector3.new(-103.79, 10820.86, 3016.38),
}
local checkpointList = {}
for i, pos in ipairs(checkpointPositions) do
	if i == 1 then
		checkpointList["Basecamp"] = pos
	else
		checkpointList["Checkpoint " .. (i - 1)] = pos
	end
end
local selectedCheckpoint = nil
local checkpointDropdown
local function getCheckpointNames()
	local names = {}
	for name in pairs(checkpointList) do
		table.insert(names, name)
	end
	table.sort(names, function(a, b)
		local numA = tonumber(string.match(a, "%d+")) or 0
		local numB = tonumber(string.match(b, "%d+")) or 0
		return numA < numB
	end)
	return names
end
local function teleportTo(position)
	local char = lp.Character or lp.CharacterAdded:Wait()
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then return false end
	local oldHealth = humanoid.Health
	humanoid.MaxHealth = math.huge
	humanoid.Health = math.huge
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
	local flying = true
	local runService = game:GetService("RunService")
	local floatThread = task.spawn(function()
		while flying do
			runService.Heartbeat:Wait()
			hrp.Velocity = Vector3.zero
			hrp.Anchored = false
		end
	end)
	hrp.CFrame = CFrame.new(position + Vector3.new(0, 5, 0))
	flying = false
	task.delay(0.5, function()
		if humanoid then
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
			humanoid.MaxHealth = oldHealth
			if humanoid.Health > oldHealth then
				humanoid.Health = oldHealth
			end
		end
	end)
	return true
end
MountTab:CreateSection("Mount RINJANI")
MountTab:CreateButton({
	Name = "Auto Summit",
	Callback = function()
		local char = lp.Character or lp.CharacterAdded:Wait()
		local hrp = char:WaitForChild("HumanoidRootPart")
		local flying = true
		task.spawn(function()
			while flying do
				task.wait()
				hrp.Velocity = Vector3.zero
				hrp.Anchored = false
			end
		end)
		local checkpointPositions = {
			Vector3.new(3352.45, 9032.71, 5636.30),
			Vector3.new(3071.70, 9108.71, 4459.96),
			Vector3.new(1872.05, 9552.69, 3489.45),
			Vector3.new(1364.99, 9776.71, 3129.28),
			Vector3.new(1192.10, 10122.16, 2292.78),
			Vector3.new(-103.79, 10820.86, 3016.38),
		}
		task.spawn(function()
			for i, pos in ipairs(checkpointPositions) do
				hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
				task.wait(2.5)
			end
			flying = false
		end)
	end,
})
checkpointDropdown = MountTab:CreateDropdown({
	Name = "Select Checkpoint",
	Options = getCheckpointNames(),
	CurrentOption = nil,
	MultiSelection = false,
	Callback = function(option)
		selectedCheckpoint = typeof(option) == "table" and option[1] or option
	end,
})
MountTab:CreateButton({
	Name = "Go to Checkpoint",
	Callback = function()
		if not selectedCheckpoint then
			return notif("Select a Checkpoint", "Please choose a checkpoint first.")
		end
		local destination = checkpointList[selectedCheckpoint]
		if destination then
			local success = teleportTo(destination)
			if success then
				notif("Teleported", "You have been teleported to " .. selectedCheckpoint)
			else
				notif("Error", "HumanoidRootPart not found.")
			end
		else
			notif("Error", "Checkpoint not found in list.")
		end
	end,
})


-- TAB PLAYER
local Tab = Window:CreateTab("Player")
Tab:CreateSection("Player Tab: Configure and enable character abilities.")

local function resetAllSettings()
	if not states then return end
	for k in pairs(states) do states[k] = false end
	if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
	if antiKBConnection then antiKBConnection:Disconnect() antiKBConnection = nil end
	if hum then
		hum.WalkSpeed = defaultSpeed
		hum.JumpPower = defaultJump
		setHumanoidStates(true)
	end
	disableESP()
	if ui then
		for key, element in pairs(ui) do
			if element and typeof(element.Set) == "function" then
				if key == "speed" then
					element:Set(defaultSpeed)
				elseif key == "jump" then
					element:Set(defaultJump)
				elseif key == "flySpeed" then
					flySpeed = defaultFlySpeed
					element:Set(defaultFlySpeed)
				else
					element:Set(false)
				end
			end
		end
	end
	notif("Settings Reset", "All values reset.")
end
Tab:CreateSection("Utilities")
Tab:CreateButton({
	Name = "Reset All",
	Callback = function()
		resetAllSettings()
	end
})

Tab:CreateSection("Visual Tools")
ui.esp = Tab:CreateToggle({
	Name = "ESP Name",
	CurrentValue = false,
	Callback = function(v)
		states.esp = v
		if v then enableESP() else disableESP() end
	end
})

Tab:CreateSection("Movement Settings")
ui.speed = Tab:CreateSlider({
	Name = "Walk Speed",
	Range = {16, 200},
	Increment = 1,
	Suffix = "Speed",
	CurrentValue = defaultSpeed,
	Callback = function(v) if hum then hum.WalkSpeed = v end end
})
ui.jump = Tab:CreateSlider({
	Name = "Jump Power",
	Range = {50, 200},
	Increment = 1,
	Suffix = "Power",
	CurrentValue = defaultJump,
	Callback = function(v) if hum then hum.JumpPower = v end end
})
ui.fly = Tab:CreateToggle({
	Name = "Fly Mode",
	CurrentValue = false,
	Callback = function(v) states.fly = v end
})
ui.flySpeed = Tab:CreateSlider({
	Name = "Fly Speed",
	Range = {10, 200},
	Increment = 5,
	Suffix = "Speed",
	CurrentValue = flySpeed,
	Callback = function(v) flySpeed = v end
})

Tab:CreateSection("Movement Abilities")
ui.infJump = Tab:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Callback = function(v) states.infJump = v end})
ui.noclip = Tab:CreateToggle({Name = "NoClip (Wall Pass)", CurrentValue = false, Callback = function(v) states.noclip = v end})

Tab:CreateSection("Protections")
ui.antiFall = Tab:CreateToggle({Name = "Anti Fall Damage", CurrentValue = false, Callback = function(v) states.antiFall = v end})
ui.antiRagdoll = Tab:CreateToggle({
	Name = "Anti-Ragdoll / Stun",
	CurrentValue = false,
	Callback = function(v)
		states.antiRagdoll = v
		setHumanoidStates(not v)
	end
})
ui.antiKB = Tab:CreateToggle({
	Name = "Anti Knockback",
	CurrentValue = false,
	Callback = function(v)
		states.antiKB = v
		if antiKBConnection then
			antiKBConnection:Disconnect()
			antiKBConnection = nil
		end
		if v and char:FindFirstChild("HumanoidRootPart") then
			antiKBConnection = char.HumanoidRootPart:GetPropertyChangedSignal("Velocity"):Connect(function()
				if states.antiKB then
					char.HumanoidRootPart.Velocity = Vector3.zero
				end
			end)
		end
	end
})
ui.godMode = Tab:CreateToggle({Name = "God Mode (Immortal)", CurrentValue = false, Callback = function(v) states.godMode = v end})
ui.autoHeal = Tab:CreateToggle({Name = "Auto Heal", CurrentValue = false, Callback = function(v) states.autoHeal = v end})

updateCharacterEffects(lp.Character)
resetAllSettings()



-- TAB SPECTATE
local SpectateTab = Window:CreateTab("Spectate")
SpectateTab:CreateSection("Spectate Tab: View other players in real-time.")
SpectateTab:CreateSection("Spectate Player")
local selectedSpectatePlayer = nil
local isSpectating = false
local spectateDropdown
local function refreshSpectateDropdown()
	if spectateDropdown and typeof(spectateDropdown.SetOptions) == "function" then
		spectateDropdown:SetOptions(getAllPlayerNames(true))
	end
end
spectateDropdown = SpectateTab:CreateDropdown({
	Name = "Select Player",
	Options = getAllPlayerNames(true),
	CurrentOption = nil,
	MultiSelection = false,
	Callback = function(option)
		selectedSpectatePlayer = typeof(option) == "table" and option[1] or option
	end,
})
SpectateTab:CreateButton({
	Name = "Start Spectating",
	Callback = function()
		if not selectedSpectatePlayer then
			return notif("Select Player", "Please choose a player first.")
		end
		local targetPlayer = Players:FindFirstChild(selectedSpectatePlayer)
		if targetPlayer and targetPlayer.Character then
        local targetHumanoid = targetPlayer.Character:FindFirstChild("Humanoid")
        local cam = workspace.CurrentCamera
        if targetHumanoid then
                cam.CameraSubject = targetHumanoid
            elseif targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                -- fallback manual camera tracking
                local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                cam.CameraType = Enum.CameraType.Scriptable
                isSpectating = true
                local conn
                conn = RunService.RenderStepped:Connect(function()
                    if not isSpectating or not hrp or not hrp:IsDescendantOf(workspace) then
                        cam.CameraType = Enum.CameraType.Custom
                        cam.CameraSubject = lp.Character and lp.Character:FindFirstChild("Humanoid")
                        if conn then conn:Disconnect() end
                        return
                    end
                    cam.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 5, 10), hrp.Position)
                end)
            else
                notif("Error", "Target does not have Humanoid or HRP.")
                return
            end
            isSpectating = true
            notif("Spectating", "Now spectating " .. selectedSpectatePlayer)
        else
            notif("Error", "Player not found or character not loaded.")
        end
	end
})
SpectateTab:CreateButton({
	Name = "Stop Spectating",
	Callback = function()
		if isSpectating then
			local myChar = lp.Character or lp.CharacterAdded:Wait()
			local myHumanoid = myChar and myChar:FindFirstChild("Humanoid")
			if myHumanoid then
				workspace.CurrentCamera.CameraSubject = myHumanoid
				notif("Spectate Ended", "You are no longer spectating.")
			else
				notif("Error", "Your humanoid not found.")
			end
			isSpectating = false
			selectedSpectatePlayer = nil
			if spectateDropdown and typeof(spectateDropdown.SetCurrentOption) == "function" then
				spectateDropdown:SetCurrentOption(nil)
			end
			refreshSpectateDropdown()
		else
			notif("Not Spectating", "You're not spectating anyone.")
		end
	end
})
Players.PlayerAdded:Connect(refreshSpectateDropdown)
Players.PlayerRemoving:Connect(function(player)
	if selectedSpectatePlayer == player.Name then
		selectedSpectatePlayer = nil
		isSpectating = false
		workspace.CurrentCamera.CameraSubject = lp.Character and lp.Character:FindFirstChild("Humanoid")
		notif("Spectate Ended", player.Name .. " left the game.")
		if spectateDropdown and typeof(spectateDropdown.SetCurrentOption) == "function" then
			spectateDropdown:SetCurrentOption(nil)
		end
	end
	refreshSpectateDropdown()
end)



-- TAB TELEPORT
TeleportTab = Window:CreateTab("Teleport")
TeleportTab:CreateSection("Teleport Tab: Move to players or saved positions instantly.")
TeleportTab:CreateSection("Teleport to Player")
local selectedPlayer = nil
local playerDropdown
local function getPlayerNames()
	local names = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= lp then
			table.insert(names, player.Name)
		end
	end
	return names
end
local function refreshPlayerDropdown()
	if playerDropdown and typeof(playerDropdown.SetOptions) == "function" then
		playerDropdown:SetOptions(getPlayerNames())
	end
end
playerDropdown = TeleportTab:CreateDropdown({
	Name = "Select Player",
	Options = getPlayerNames(),
	CurrentOption = nil,
	MultiSelection = false,
	Callback = function(option)
		selectedPlayer = typeof(option) == "table" and option[1] or option
	end,
})
TeleportTab:CreateButton({
	Name = "Teleport to Player",
	Callback = function()
		if not selectedPlayer then
			return notif("Select Player", "Please choose a player first.")
		end
		local target = Players:FindFirstChild(selectedPlayer)
		local targetChar = target and target.Character
		local targetHRP = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
		local myChar = lp.Character or lp.CharacterAdded:Wait()
		local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
		if target and targetHRP and myHRP then
			myHRP.CFrame = CFrame.new(targetHRP.Position + Vector3.new(0, 5, 0))
			notif("Success", "Teleported to " .. selectedPlayer)
		else
			notif("Failed", "Player not found or not spawned.")
		end
	end
})
Players.PlayerAdded:Connect(refreshPlayerDropdown)
Players.PlayerRemoving:Connect(function(player)
	refreshPlayerDropdown()
	if selectedPlayer == player.Name then
		selectedPlayer = nil
		notif("Player Left", player.Name .. " has left the game.")
	end
end)
TeleportTab:CreateSection("Quick Save Position")
local savedPosition = nil
TeleportTab:CreateButton({
	Name = "Save Current Position",
	Callback = function()
		local myChar = lp.Character or lp.CharacterAdded:Wait()
		local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
		if myHRP then
			savedPosition = myHRP.Position
			notif("Saved", "Position has been saved.")
		else
			notif("Error", "Failed to get character position.")
		end
	end
})
TeleportTab:CreateButton({
	Name = "Teleport to Saved Position",
	Callback = function()
		if not savedPosition then
			return notif("Error", "No position saved.")
		end
		local myChar = lp.Character or lp.CharacterAdded:Wait()
		local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
		if myHRP then
			myHRP.CFrame = CFrame.new(savedPosition + Vector3.new(0, 5, 0))
			notif("Teleported", "Teleported to saved position.")
		else
			notif("Error", "Failed to teleport.")
		end
	end
})
TeleportTab:CreateButton({
	Name = "Delete Saved Position",
	Callback = function()
		if savedPosition then
			savedPosition = nil
			notif("Deleted", "Saved position has been removed.")
		else
			notif("Error", "No saved position to delete.")
		end
	end
})

