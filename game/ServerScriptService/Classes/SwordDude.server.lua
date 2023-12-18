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
	if player:GetAttribute("Class") ~= "SwordDude" then return end
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
	local track = animator:LoadAnimation(animations.SwordDude[combo])
	local box
	if combo == 1 then
		box = hitbox.Create(Vector3.new(7.22, 2, 5.83), rootpart, CFrame.new(-0.4, 0.436, -3.785) * CFrame.fromEulerAnglesXYZ(0,0,math.rad(24.51)))
	elseif combo == 2 then
		box = hitbox.Create(Vector3.new(7.96, 2.52, 5.13), rootpart, CFrame.new(-1.085, 0.658, -4.045) * CFrame.fromEulerAnglesXYZ(0,0,math.rad(-41.9)))
	elseif combo == 3 then
		box = hitbox.Create(Vector3.new(3.31, 1.92, 6.7), rootpart, CFrame.new(0.485, -0.162, -4.355))
	elseif combo == 4 then
		box = hitbox.Create(Vector3.new(2.97, 2.8, 4.6), rootpart, CFrame.new(0.375, -0.722, -3.41) * CFrame.fromEulerAnglesXYZ(0,0,math.rad(-41.9)))
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
				if combo == 1 or combo == 2 then
				else
				end
			end
			if combo == maxcombo then
				hithandler.hit(victim, 5, 0.75, rootpart.CFrame.lookVector*100, false, char, nil, nil, nil, nil, nil, 0.2)
				return
			elseif combo == 3 then
				hithandler.hit(victim, 7, 0.55, rootpart.CFrame.lookVector*10, false, char, nil, "Slash", nil, nil, nil, 0.2)
				return
			end
			hithandler.hit(victim, 6, 0.55, rootpart.CFrame.lookVector*10, false, char, nil, "Slash", nil, nil, nil, 0.2)
		end
	end)

	ChangeStuff(hum)
	ChangeCombo(char)
	hum.AutoRotate = false
	track:Play()
	task.wait(0.15)
	if char:GetAttribute("Combo") == 4 then
		dash:FireClient(player, 25, 0.1)
	else
		dash:FireClient(player, 15, 0.1)
	end
	box:Start()
end)

local guardbreakcd = {}
guardbreak.OnServerEvent:Connect(function(player)
	if player:GetAttribute("Class") ~= "SwordDude" then return end
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
	local track = animator:LoadAnimation(game.ReplicatedStorage.Anim.SwordDude.Guardbreak)
	track:Play()
	effects.guardbreak(char.Head, 1)
	for i = 1, 10, 1 do
		task.wait(0.05)
		if char:GetAttribute("Stunned") then break end
		if i == 8 then
			dash:FireClient(player, 20, 0.1)
		end
	end
	local alreadyhit
	if not char:GetAttribute("Stunned") then
		local box = hitbox.Create(Vector3.new(2.97, 6.1, 7), rootpart, CFrame.new(0.285, 1.618, -3.57))
		local connection
		connection = box.Touched:Connect(function(hit, victim)
			if victim == hum  then return end
			if victim then
				alreadyhit = victim
				local animator2 = victim:FindFirstChild("Animator")
				if animator2 and not victim.Parent:GetAttribute("Blocking") and not victim.Parent:GetAttribute("SuperArmour") then
					--play hitanim
				end
				local kb = rootpart.CFrame.lookVector * 50
				hithandler.hit(victim, 10, 0.75, kb, true, char, nil, "Slash")
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
		task.wait(0.6)
		track:Stop()
		char:SetAttribute("Attacking", false)
		ChangeStuff(hum, true)
		hum.AutoRotate = true
	end
end)

local function touch(box:Instance, hum:Humanoid, kb:Vector3, char:Model, dur:number)
	 box.Touched:Connect(function(hit, victim)
		if victim == hum  then return end
		if victim then
			local animator2 = victim:FindFirstChild("Animator")
			if animator2 and not victim.Parent:GetAttribute("Blocking") and not victim.Parent:GetAttribute("SuperArmour") then
				--play hitanim
			end
			hithandler.hit(victim, 3, dur, kb, false, char, nil, "Slash", nil, nil, nil, 0.1)
		end
	end)
end

local SP1cd = {}
SP1.OnServerEvent:Connect(function(player)
	if player:GetAttribute("Class") ~= "SwordDude" then return end
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
	local cooldowntime = 11
	if attacking or stun or blocking or table.find(SP1cd, player) or sleeping then return end
	table.insert(SP1cd, player); task.delay(cooldowntime, function() table.remove(SP1cd, table.find(SP1cd, player)) end)
	ClassData.Cooldown(player, "AB1", cooldowntime)
	char:SetAttribute("Attacking", true)
	ChangeStuff(hum)
	local track = animator:LoadAnimation(game.ReplicatedStorage.Anim.SwordDude.Jabs)
	track:Play()
	for i = 1, 8, 1 do
		task.wait(0.05)
		if char:GetAttribute("Stunned") then break end
		if i == 7 then
			dash:FireClient(player, 25, 0.1)
		end
	end
	if not char:GetAttribute("Stunned") then
		char:SetAttribute("SuperArmour", true)
		effects.superarmour(char, 0.8)
		local box = hitbox.Create(Vector3.new(3.27, 1.94, 5.61), rootpart, CFrame.new(-0.825, -0.905, -3.744) * CFrame.fromEulerAnglesXYZ(math.rad(8.016),math.rad(-7.787),math.rad(-1.092)))
		touch(box, hum, rootpart.CFrame.lookVector * 10, char, 0.4)
		box:Start()
		task.wait(0.1333333333333333)
		box:Stop()
		task.wait(0.05)
		dash:FireClient(player, 15, 0.1)
		task.wait(0.0333333333333333)
		local box = hitbox.Create(Vector3.new(3.27, 1.8, 6.09), rootpart, CFrame.new(-0.793, -0.525, -3.93) * CFrame.fromEulerAnglesXYZ(math.rad(8.016),math.rad(-7.787),math.rad(-1.092)))
		touch(box, hum, rootpart.CFrame.lookVector * 10, char, 0.4)
		box:Start()
		task.wait(0.1333333333333333)
		box:Stop()
		task.wait(0.05)
		dash:FireClient(player, 15, 0.1)
		task.wait(0.0333333333333333)
		local box = hitbox.Create(Vector3.new(3.27, 1.8, 6.09), rootpart, CFrame.new(-0.793, -0.525, -3.93) * CFrame.fromEulerAnglesXYZ(math.rad(3.947),math.rad(-7.709),math.rad(-1.084)))
		touch(box, hum, rootpart.CFrame.lookVector * 10, char, 0.4)
		box:Start()
		task.wait(0.1333333333333333)
		box:Stop()
		task.wait(0.05)
		dash:FireClient(player, 15, 0.1)
		task.wait(0.0333333333333333)
		local box = hitbox.Create(Vector3.new(3.27, 1.8, 6.09), rootpart, CFrame.new(-0.793, -0.525, -3.93) * CFrame.fromEulerAnglesXYZ(math.rad(3.947),math.rad(-7.709),math.rad(-1.084)))
		touch(box, hum, rootpart.CFrame.lookVector * 10, char, 0.75)
		box:Start()
		task.wait(0.1333333333333333)
		box:Stop()
		char:SetAttribute("SuperArmour", false)
	end
	task.wait(0.3)
	char:SetAttribute("Attacking", false)
	ChangeStuff(hum, true)
end)

local hitalready = {}
local function touch2(box:Instance, hum:Humanoid)
	box.Touched:Connect(function(hit, victim)
		if victim == hum or table.find(hitalready[hum.Parent.Name], victim) then return end
		if victim then
			local animator2 = victim:FindFirstChild("Animator")
			if animator2 and not victim.Parent:GetAttribute("Blocking") and not victim.Parent:GetAttribute("SuperArmour") then
				local e = animator2:LoadAnimation(game.ReplicatedStorage.Anim.hit.hitspecial)
				e:Play()
			end
			local kb = hum.RootPart.CFrame.lookVector * 75
			hithandler.hit(victim, 12, 0.75, kb, false, hum.Parent, true, "Slash")
			effects.defence(victim, 6, -20)
			table.insert(hitalready[hum.Parent.Name], victim)
		end
	end)
end

local SP2cd = {}
SP2.OnServerEvent:Connect(function(player)
	if player:GetAttribute("Class") ~= "SwordDude" then return end
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
	if attacking or stun or blocking or table.find(SP2cd, player.Name) or sleeping then return end
	table.insert(SP2cd, player.Name); task.delay(cooldowntime, function() table.remove(SP2cd, table.find(SP2cd, player.Name)) end)
	ClassData.Cooldown(player, "AB2", cooldowntime)
	char:SetAttribute("Attacking", true)
	ChangeStuff(hum)
	local track = animator:LoadAnimation(game.ReplicatedStorage.Anim.SwordDude.ArmourPericer)
	track:Play()
	effects.guardbreak(char.Head, 1)
	for i = 1, 12, 1 do
		task.wait(0.05)
		if char:GetAttribute("Stunned") then break end
		if i == 6 then hum.AutoRotate = false end
		if i == 10 then
			dash:FireClient(player, 50, 0.1)
		end
	end
	track:AdjustSpeed(0.5)
	hitalready[player.Name] = {}
	if not char:GetAttribute("Stunned") then
		local start = rootpart.CFrame * CFrame.new(-0.651, 0.876, -3.805) * CFrame.fromEulerAnglesXYZ(0,0,math.rad(27.35))
		local box = hitbox.Create(Vector3.new(7.59, 1.81, 5.67), start)
		touch2(box, hum)
		box:Start()
		task.wait(0.08333333333)
		box:Stop()
		start *= CFrame.new(0,0,-3.5)
		local box = hitbox.Create(Vector3.new(7.59, 1.81, 5.67), start)
		touch2(box, hum)
		box:Start()
		task.wait(0.08333333333)
		box:Stop()
		start *= CFrame.new(0,0,-3.5)
		local box = hitbox.Create(Vector3.new(7.59, 1.81, 5.67), start)
		touch2(box, hum)
		box:Start()
		task.wait(0.08333333333)
		box:Stop()
	end
	if #hitalready[player.Name] > 0 then
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

local SP3cd = {}
SP3.OnServerEvent:Connect(function(player)
	if player:GetAttribute("Class") ~= "SwordDude" then return end
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
	if attacking or stun or blocking or table.find(SP3cd, player) or sleeping then return end
	
	table.insert(SP3cd, player); task.delay(cooldowntime, function() table.remove(SP3cd, table.find(SP3cd, player)) end)
	ClassData.Cooldown(player, "AB3", cooldowntime)
	char:SetAttribute("Attacking", true)
	ChangeStuff(hum)
	hum.AutoRotate = false
	local track = animator:LoadAnimation(game.ReplicatedStorage.Anim.SwordDude.ArmourPericer)
	track:Play()
	
	for i = 1, 12, 1 do
		task.wait(0.05)
		if char:GetAttribute("Stunned") then break end
	end
	
	if not char:GetAttribute("Stunned") then
		local projectile = game.ReplicatedStorage.vfx.Slash_Projectile:Clone()
		projectile.CFrame = rootpart.CFrame * CFrame.new(0,0,-1.5)
		projectile.Transparency = 1
		projectile.Parent = workspace.vfx
		local tween1 = TweenService:Create(projectile, TweenInfo.new(0.2), {Transparency = 0, Size = projectile.Size * 2})
		local tween2 = TweenService:Create(projectile, TweenInfo.new(0.6, Enum.EasingStyle.Linear), {CFrame = projectile.CFrame * CFrame.new(0,0,-40)})
		tween1:Play()
		task.wait(0.1)
		local box = hitbox.Create(Vector3.new(6.42, 1.81, 4.36), projectile, CFrame.new(0,0,-0.3))
		box:Start()
		local alreadyhit = {}
		box.Touched:Connect(function(hit, victim)
			if victim == hum or table.find(alreadyhit, victim) then return end
			if victim then
				table.insert(alreadyhit, victim)
				local animator2 = victim:FindFirstChild("Animator")
				if animator2 and not victim.Parent:GetAttribute("Blocking") and not victim.Parent:GetAttribute("SuperArmour") then
					local trck = animator2:LoadAnimation(game.ReplicatedStorage.Anim.hit.hitspecial)
					trck:Play()
				end
				local kb = rootpart.CFrame.lookVector * 60 + Vector3.new(0,30,0)
				hithandler.hit(victim, 12, 0.45, kb, false, char, nil, "Slash", true, nil, nil, 0.15)
			end
		end)
		tween2:Play()
		task.spawn(function() tween2.Completed:Wait(); projectile:Destroy(); box:Stop() end)
	end
	task.wait(0.2)
	track:Stop()
	char:SetAttribute("Attacking", false)
	ChangeStuff(hum, true)
	hum.AutoRotate = true
end)