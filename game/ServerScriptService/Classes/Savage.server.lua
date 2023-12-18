local TweenService = game:GetService("TweenService")
local effects = require(game.ServerStorage.effects)
local ClassData = require(game.ServerStorage.ClassData)
local remotes = game.ReplicatedStorage:WaitForChild("remotes")
local VfXRemotes = remotes:WaitForChild("vfx")
local combat = remotes:WaitForChild("COMBAT")
local SP2 = remotes:WaitForChild("SPECIAL2")
local SP1 = remotes:WaitForChild("SPECIAL1")
local SP3 = remotes:WaitForChild("SPECIAL3")
local guardbreak = remotes:WaitForChild("GB")
local dash = remotes:WaitForChild("dash")
local hitbox = require(game.ServerStorage.hitbox)
local hithandler = require(game.ServerStorage.HitHandler)
local maxcombo = 4

local function ChangeStuff(hum, def)
	if def then
		local mod = 0
		local cripple = false
		for i, v in pairs(hum.Parent:GetChildren()) do
			if v.Name == "Effect" and v:GetAttribute("Type") == "Slow" then
				mod += v.Value
			elseif v.Name == "Effect" and v:GetAttribute("Type") == "Cripple" then
				cripple = true
			end
		end
		hum.WalkSpeed = ClassData.WalkSpeeds[script.Name] - mod
		if cripple then
			hum.JumpPower = 0
			hum.JumpHeight = 0
		else 
			hum.JumpPower = 50.14500427246094
			hum.JumpHeight = 7.20009183883667
		end

		for i, v in pairs(hum.Parent:GetChildren()) do
			if v.Name == "Effect" and v:GetAttribute("Type") == "Sleep" then
				hum.WalkSpeed = 0
				hum.JumpPower = 0
				hum.JumpHeight = 0
			end
		end
	else
		hum.WalkSpeed = 0
		hum.JumpPower = 0
		hum.JumpHeight = 0
	end
end

local function ChangeCombo(char:Instance)
	local current = char:GetAttribute("Combo")
	if current < maxcombo then
		char:SetAttribute("Combo", current+1)
	else
		char:SetAttribute("Combo", 1)
	end
end

local function ResetCombo(char:Instance, old:IntValue)
	if old == maxcombo then return end
	task.delay(0.5, function()
		local current = char:GetAttribute("Combo")
		if current-1 == old then
			char:SetAttribute("Combo", 1)
		end
	end)
end

combat.OnServerEvent:Connect(function(player)
	if player:GetAttribute("Class") ~= "Savage" then return end
	local char = player.Character
	local hum = char:FindFirstChild("Humanoid")
	local animator = hum.Animator
	local rootpart = hum.RootPart
	
	if char:GetAttribute("Attacking") then
		for i = 1, 7, 1 do
			if not char:GetAttribute("Attacking") then break end
			task.wait(0.03)
		end
	end

	local combo = char:GetAttribute("Combo")
	local attacking = char:GetAttribute("Attacking")
	local stun = char:GetAttribute("Stunned")
	local blocking = char:GetAttribute("Blocking")
	local sleeping = char:GetAttribute("Sleeping")

	if attacking or stun or blocking or sleeping then return end
	char:SetAttribute("Attacking", true)

	local animations = game.ReplicatedStorage.Anim
	local track = animator:LoadAnimation(animations.Savage[combo])
	local box
	if combo == 1 then
		box = hitbox.Create(Vector3.new(5.633, 2.355, 4.389), rootpart, CFrame.new(-0.201, 0.375, -2.388) * CFrame.fromEulerAnglesXYZ(0,math.rad(21.07),math.rad(-39.189)))
	elseif combo == 2 then
		box = hitbox.Create(Vector3.new(5.633, 2.355, 4.51), rootpart, CFrame.new(0.385, -0.122, -2.889))
	elseif combo == 3 then
		box = hitbox.Create(Vector3.new(6.634, 2.035, 4.386), rootpart, CFrame.new(0.227, -0.257, -2.475) * CFrame.fromEulerAnglesXYZ(0,0,math.rad(21.132)))
	elseif combo == 4 then
		box = hitbox.Create(Vector3.new(5.56, 4.517, 3.72), rootpart, CFrame.new(0.092, -0.544, -2.86))
	end

	task.delay(0.4, function()
		ResetCombo(char, combo)
		box:Stop()

		if combo == maxcombo then
			hum.WalkSpeed = 3
			task.wait(0.5)
		end
		ChangeStuff(hum, true)
		char:SetAttribute("Attacking", false)
		hum.AutoRotate = true
	end)

	box.Touched:Connect(function(hit, victim)
		if victim == hum  then return end
		if victim then
			if victim:FindFirstChild("Animator") and not victim.Parent:GetAttribute("Blocking") and not victim.Parent:GetAttribute("SuperArmour") then
				if combo == 1 or combo == 3 then
					local e = victim.Animator:LoadAnimation(animations.hit.hit1)
					e:Play()
				elseif combo == 2 then
					local e = victim.Animator:LoadAnimation(animations.hit.hit2)
					e:Play()
				else
					local e = victim.Animator:LoadAnimation(animations.hit.hitspecial)
					e:Play()
				end
			end
			if combo == maxcombo then
				hithandler.hit(victim, 7, 0.75, rootpart.CFrame.lookVector*100, false, char, nil, "Slash", nil, nil, nil, 0.2)
				return
			end
			hithandler.hit(victim, 6, 0.55, rootpart.CFrame.lookVector*10, false, char, nil, "Slash", nil, nil, nil, 0.2)
		end
	end)

	ChangeStuff(hum)
	ChangeCombo(char)
	hum.AutoRotate = false
	track:Play()
	if combo == 2 or combo == 3 then
		task.wait(0.1)
	elseif combo == 4 then
		task.wait(0.2)
	else 
		task.wait(0.15)
	end
	if char:GetAttribute("Combo") == 4 then
		dash:FireClient(player, 20, 0.1)
	else
		dash:FireClient(player, 15, 0.1)
	end
	box:Start()
end)

local guardbreakcd = {}
guardbreak.OnServerEvent:Connect(function(player)
	if player:GetAttribute("Class") ~= "Savage" then return end
	local char = player.Character
	local hum = char:FindFirstChild("Humanoid")
	local animator = hum.Animator
	local rootpart = hum.RootPart
	
	if char:GetAttribute("Attacking") then
		for i = 1, 10, 1 do
			if not char:GetAttribute("Attacking") then break end
			task.wait(0.03)
		end
	end

	local attacking = char:GetAttribute("Attacking")
	local stun = char:GetAttribute("Stunned")
	local blocking = char:GetAttribute("Blocking")
	local sleeping = char:GetAttribute("Sleeping")
	local cooldowntime = 8  -- COOLDOWNTIME LES GOOOOOOO!!!

	if attacking or stun or blocking or table.find(guardbreakcd, char.Name) or sleeping then return end
	hum.AutoRotate = false
	table.insert(guardbreakcd, char.Name); task.delay(cooldowntime, function() table.remove(guardbreakcd, table.find(guardbreakcd, char.Name)) end) 
	ClassData.Cooldown(player, "GB", cooldowntime)
	char:SetAttribute("Attacking", true)
	ChangeStuff(hum)
	local track = animator:LoadAnimation(game.ReplicatedStorage.Anim.Savage.Guardbreak)
	track:Play()
	effects.guardbreak(char.Head, 1)
	for i = 1, 10, 1 do
		task.wait(0.05)
		if char:GetAttribute("Stunned") then break end
		if i == 8 then
			dash:FireClient(player, 25, 0.1)
		end
	end
	local alreadyhit
	if not char:GetAttribute("Stunned") then
		local box = hitbox.Create(Vector3.new(8.404, 2.848, 4.7), rootpart, CFrame.new(0.172, 0.359, -2.5) * CFrame.fromEulerAnglesXYZ(0,0,math.rad(15.019)))
		local connection
		connection = box.Touched:Connect(function(hit, victim)
			if victim == hum  then return end
			if victim then
				alreadyhit = victim
				local animator2 = victim:FindFirstChild("Animator")
				if animator2 and not victim.Parent:GetAttribute("Blocking") and not victim.Parent:GetAttribute("SuperArmour") then
					local e = animator2:LoadAnimation(game.ReplicatedStorage.Anim.hit.hitspecial)
					e:Play()
				end
				local kb = rootpart.CFrame.lookVector * 75
				hithandler.hit(victim, 12, 0.75, kb, true, char, nil, "Slash")
			end
		end)
		box:Start()
		task.wait(0.25)
		box:Stop()
	end
	if alreadyhit then
		track:Stop()
		char:SetAttribute("Attacking", false)
		ChangeStuff(hum, true)
		hum.AutoRotate = true
	else
		task.wait(0.5)
		track:Stop()
		char:SetAttribute("Attacking", false)
		ChangeStuff(hum, true)
		hum.AutoRotate = true
	end
end)

local alreadyhit = {}
local function touch(box:Instance, hum:Humanoid)
	box.Touched:Connect(function(hit, victim)
		if victim == hum or table.find(alreadyhit[hum.Parent.Name], victim) then return end
		if victim then
			local animator2 = victim:FindFirstChild("Animator")
			if animator2 and not victim.Parent:GetAttribute("Blocking") and not victim.Parent:GetAttribute("SuperArmour") then
				local e = animator2:LoadAnimation(game.ReplicatedStorage.Anim.hit.hitspecial)
				e:Play()
			end
			local kb = hum.RootPart.CFrame.lookVector * 40
			local blocked = hithandler.hit(victim, 12, 1, kb, false, hum.Parent, nil, "Slash", nil, nil, nil, 0.25)
			if blocked == nil then table.insert(alreadyhit[hum.Parent.Name], victim) end
		end
	end)
end

local SP1cd = {}
SP1.OnServerEvent:Connect(function(player)
	if player:GetAttribute("Class") ~= "Savage" then return end
	local char = player.Character
	local hum = char:FindFirstChild("Humanoid")
	local animator = hum.Animator
	local rootpart = hum.RootPart

	if char:GetAttribute("Attacking") then
		for i = 1, 10, 1 do
			if not char:GetAttribute("Attacking") then break end
			task.wait(0.03)
		end
	end
	
	local attacking = char:GetAttribute("Attacking")
	local stun = char:GetAttribute("Stunned")
	local blocking = char:GetAttribute("Blocking")
	local sleeping = char:GetAttribute("Sleeping")
	local cooldowntime = 12
	
	if attacking or stun or blocking or table.find(SP1cd, player) or sleeping then return end
	table.insert(SP1cd, player); task.delay(cooldowntime, function() table.remove(SP1cd, table.find(SP1cd, player)) end)
	ClassData.Cooldown(player, "AB1", cooldowntime)
	char:SetAttribute("Attacking", true)
	ChangeStuff(hum)
	local track = animator:LoadAnimation(game.ReplicatedStorage.Anim.Savage.SP1)
	track:Play()
	for i = 1, 8, 1 do
		task.wait(0.05)
		if char:GetAttribute("Stunned") then break end
		if i == 2 then hum.AutoRotate = false end
		if i == 7 then
			dash:FireClient(player, 60, 0.4)
		end
	end
	if not char:GetAttribute("Stunned") then
		game.ReplicatedStorage.remotes.vfx.medicvfx:FireAllClients(rootpart, Color3.fromRGB(255,255,255), true)
		char:SetAttribute("SuperArmour", true)
		effects.superarmour(char, 0.45)
		alreadyhit[player.Name] = {}
		local starting = rootpart.CFrame * CFrame.new(-0.306, -0.206, -6.3)
		local box = hitbox.Create(Vector3.new(4.043, 3.702, 10), starting)
		touch(box, hum, {})
		box:Start()
		task.wait(0.14)
		box:Stop()
		starting *= CFrame.new(0,0,-10)
		local box = hitbox.Create(Vector3.new(4.043, 3.702, 10), starting)
		touch(box, hum)
		box:Start()
		task.wait(0.14)
		box:Stop()
		starting *= CFrame.new(0,0,-10)
		local box = hitbox.Create(Vector3.new(4.043, 3.702, 10), starting)
		touch(box, hum)
		box:Start()
		task.wait(0.14)
		box:Stop()
	end
	char:SetAttribute("SuperArmour", false)
	if #alreadyhit[player.Name] > 0 then
		task.wait(0.2)
		track:Stop()
		char:SetAttribute("Attacking", false)
		ChangeStuff(hum, true)
		hum.AutoRotate = true
	else
		task.wait(0.7)
		track:Stop()
		char:SetAttribute("Attacking", false)
		ChangeStuff(hum, true)
		hum.AutoRotate = true
	end
end)

local SP2cd = {}
SP2.OnServerEvent:Connect(function(player)
	if player:GetAttribute("Class") ~= "Savage" then return end
	local char = player.Character
	local hum = char:FindFirstChild("Humanoid")
	local animator = hum.Animator
	local rootpart = hum.RootPart
	
	if char:GetAttribute("Attacking") then
		for i = 1, 10, 1 do
			if not char:GetAttribute("Attacking") then break end
			task.wait(0.03)
		end
	end
	
	local attacking = char:GetAttribute("Attacking")
	local stun = char:GetAttribute("Stunned")
	local blocking = char:GetAttribute("Blocking")
	local sleeping = char:GetAttribute("Sleeping")
	local cooldowntime = 13
	
	if attacking or stun or blocking or table.find(SP2cd, player.Name) or sleeping then return end
	table.insert(SP2cd, player.Name); task.delay(cooldowntime, function() table.remove(SP2cd, table.find(SP2cd, player.Name)) end)
	ClassData.Cooldown(player, "AB2", cooldowntime)
	char:SetAttribute("Attacking", true)
	ChangeStuff(hum)
	hum.AutoRotate = false
	local track = animator:LoadAnimation(game.ReplicatedStorage.Anim.Savage.SP2)
	track:Play()
	track:AdjustSpeed(1.66666666666667)
	for i = 1, 6, 1 do
		task.wait(0.05)
		if char:GetAttribute("Stunned") then break end
		if i == 3 then
			dash:FireClient(player, 15, 0.1)
		end
	end
	local hiit = false
	if not char:GetAttribute("Stunned") then
		local box = hitbox.Create(Vector3.new(5.633, 2.355, 4.389), rootpart, CFrame.new(-0.201, 0.375, -2.388) * CFrame.fromEulerAnglesXYZ(0,math.rad(21.07),math.rad(-39.189)))
		box:Start()
		local connection 
		connection = box.Touched:Connect(function(hit, victim)
			if victim == hum or hiit then return end
			if victim then
				if victim.Parent:GetAttribute("iframes") then return end
				connection:Disconnect()
				local root = victim.RootPart
				victim.AutoRotate = false
				local blocked = hithandler.hit(victim, 2, 0.75, nil, false, char, nil, "Slash", nil, nil, nil, 0.25)
				if blocked ~= true then
					hiit = true
					local animator2 = victim:FindFirstChild("Animator")
					track:Stop()
					local e1 = animator:LoadAnimation(game.ReplicatedStorage.Anim.Savage.SP2_hit)
					e1:Play()
					if animator2 and animator then
						local e2 = animator2:LoadAnimation(game.ReplicatedStorage.Anim.hit.Svg_sp2hit)
						e2:Play()
					end
					char:SetAttribute("iframes", true); victim.Parent:SetAttribute("iframes", true)
					root.CFrame = rootpart.CFrame * CFrame.new(0,0,-5) * CFrame.fromEulerAnglesXYZ(0,math.rad(180), 0)
					task.wait(0.16666667)
					hithandler.hit(victim, 3, 0.4, nil, false, char, true, "Slash", nil, true)
					task.wait(0.28333333)
					hithandler.hit(victim, 3, 0.4, nil, false, char, true, "Slash", nil, true)
					task.wait(0.25)
					hithandler.hit(victim, 3, 0.4, nil, false, char, true, "Slash", nil, true)
					task.wait(0.3833333)
					hithandler.hit(victim, 3, 0.4, rootpart.CFrame.lookVector * 100, false, char, true, "Slash", nil, true)
					task.spawn(effects.dot, victim, 1, 4, "Bleed")
					game.ReplicatedStorage.remotes.vfx.medicvfx:FireAllClients(rootpart, Color3.fromRGB(255,255,255))
					task.wait(0.15)
					victim.AutoRotate = true
					task.wait(0.15)
					char:SetAttribute("Attacking", false)
					ChangeStuff(hum, true)
					hum.AutoRotate = true
					char:SetAttribute("iframes", false)
					if victim.Parent then victim.Parent:SetAttribute("iframes", false) end
				end
			end
		end)
		task.wait(0.25)
		box:Stop()
	end
	if not hiit then
		task.wait(0.6)
		track:Stop()
		char:SetAttribute("Attacking", false)
		ChangeStuff(hum, true)
		hum.AutoRotate = true
	end
end)

local SP3cd = {}
SP3.OnServerEvent:Connect(function(player)
	if player:GetAttribute("Class") ~= "Savage" then return end
	local char = player.Character
	local hum = char:FindFirstChild("Humanoid")
	local animator = hum.Animator
	local rootpart = hum.RootPart

	if char:GetAttribute("Attacking") then
		for i = 1, 10, 1 do
			if not char:GetAttribute("Attacking") then break end
			task.wait(0.03)
		end
	end

	local attacking = char:GetAttribute("Attacking")
	local stun = char:GetAttribute("Stunned")
	local blocking = char:GetAttribute("Blocking")
	local sleeping = char:GetAttribute("Sleeping")
	local cooldowntime = 13
	if attacking or stun or blocking or table.find(SP3cd, player) or sleeping then return end

	table.insert(SP3cd, player); task.delay(cooldowntime, function() table.remove(SP3cd, table.find(SP3cd, player)) end)
	ClassData.Cooldown(player, "AB3", cooldowntime)
	char:SetAttribute("Attacking", true)
	ChangeStuff(hum)
	effects.guardbreak(char.Head, 0.9)
	local track = animator:LoadAnimation(game.ReplicatedStorage.Anim.Savage.SP3)
	track:Play()
	track:AdjustSpeed(1.2)
	for i = 1, 10, 1 do
		task.wait(0.05)
		if char:GetAttribute("Stunned") then break end
		if i == 5 then
			hum.AutoRotate = false
		end
	end
	track:AdjustSpeed(1)
	if not char:GetAttribute("Stunned") then
		local starting = rootpart.CFrame * CFrame.new(-0.059, 0.348, -2.918)
		local box = hitbox.Create(Vector3.new(5.177, 6.64, 4.8), starting)
		box:Start()
		local alreadyhit = {}
		box.Touched:Connect(function(hit, victim)
			if victim == hum or table.find(alreadyhit, victim) then return end
			if victim then
				table.insert(alreadyhit, victim)
				hithandler.hit(victim, 15, 0.75, rootpart.CFrame.lookVector * 75, false, char, true, "Slash")
				task.wait(0.05)
				if victim.Health < victim.MaxHealth * 10/100 then
					victim.Health = 0
				end
			end
		end)
		task.wait(0.04)
		game.ReplicatedStorage.remotes.vfx.svgvfx:FireAllClients(rootpart)
		task.wait(0.085)
		box:Stop()
		local box = hitbox.Create(Vector3.new(8.159, 7.424, 7.294),starting * CFrame.new(0, 0.357, -6.115))
		box:Start()
		box.Touched:Connect(function(hit, victim)
			if victim == hum or table.find(alreadyhit, victim) then return end
			if victim then
				table.insert(alreadyhit, victim)
				hithandler.hit(victim, 8, 0.45, rootpart.CFrame.lookVector * 50, false, char, true, "Slash")
			end
		end)
		task.wait(0.125)
		box:Stop()
	end
	track:AdjustSpeed(0.875)
	task.wait(0.4)
	track:Stop()
	char:SetAttribute("Attacking", false)
	ChangeStuff(hum, true)
	hum.AutoRotate = true
end)