local TweenService = game:GetService("TweenService")
local effects = require(game.ServerStorage.effects)
local ClassData = require(game.ServerStorage.ClassData)
local remotes = game.ReplicatedStorage:WaitForChild("remotes")
local VfXRemotes = remotes:WaitForChild("vfx")
local combat = remotes:WaitForChild("COMBAT")
local big = remotes:WaitForChild("SPECIAL2")
local spin = remotes:WaitForChild("SPECIAL1")
local kick = remotes:WaitForChild("SPECIAL3")
local guardbreak = remotes:WaitForChild("GB")
local dash = remotes:WaitForChild("dash")
local hitbox = require(game.ServerStorage.hitbox)
local hithandler = require(game.ServerStorage.HitHandler)
local maxcombo = 4

game.Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		char:SetAttribute("Combo", 1)
	end)
end)

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

local circvfx = VfXRemotes:WaitForChild("circvfx")
combat.OnServerEvent:Connect(function(player)
	if player:GetAttribute("Class") ~= "Kungfu" then return end
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
	local track = animator:LoadAnimation(animations.Kungfu[combo])
	local box, pos
	if combo == 1 then
		box = hitbox.Create(Vector3.new(3.5, 3.3, 3.75), rootpart, CFrame.new(0,0,-2))
		task.delay(0.2, function() circvfx:FireAllClients(rootpart, combo) end)
	elseif combo == 2 then
		box = hitbox.Create(Vector3.new(3.5, 3.3, 3.75), rootpart, CFrame.new(0, 0.5, -2))
		task.delay(0.2, function() circvfx:FireAllClients(rootpart, combo) end)
	elseif combo == 3 then
		box = hitbox.Create(Vector3.new(3.5, 2.537, 4.3), rootpart, CFrame.new(0, 0, -2.238))
		task.delay(0.2, function() circvfx:FireAllClients(rootpart, combo) end)
	elseif combo == 4 then
		box = hitbox.Create(Vector3.new(3.5, 2.537, 4.3), rootpart, CFrame.new(0, 0.158, -2.297))
		task.delay(0.2, function() circvfx:FireAllClients(rootpart, combo) end)
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
					local e = victim.Animator:LoadAnimation(animations.hit.hit1)
					e:Play()
				else
					local e = victim.Animator:LoadAnimation(animations.hit.hit2)
					e:Play()
				end
			end
			if combo == maxcombo then
				hithandler.hit(victim, 7, 0.8, rootpart.CFrame.lookVector*100, false, char, nil, nil, nil, nil, nil, 0.2)
				return
			end
			hithandler.hit(victim, 5, 0.5, rootpart.CFrame.lookVector*10, false, char, nil, nil, nil, nil, nil, 0.2)
		end
	end)
	
	ChangeStuff(hum)
	ChangeCombo(char)
	hum.AutoRotate = false
	track:Play()
	task.wait(0.1)
	dash:FireClient(player, 15, 0.1)
	box:Start()
end)


local function touch(box:Instance, hum:Humanoid, dmg:IntValue, dur:IntValue, kb:IntValue, gb:BoolValue, alreadyhit:SharedTable, hitboxdur:IntValue, reverse:BoolValue, passthrough:BoolValue)
	if alreadyhit == nil then alreadyhit = {} end
	local rootpart = hum.RootPart
	box.Touched:Connect(function(hit, victim)
		if table.find(alreadyhit, victim) then return end
		if victim == hum  then return end
		if victim then
			table.insert(alreadyhit, victim)
			local animator = victim:FindFirstChild("Animator")
			if animator and not victim.Parent:GetAttribute("Blocking") and not victim.Parent:GetAttribute("SuperArmour") then
				local e = victim.Animator:LoadAnimation(game.ReplicatedStorage.Anim.hit.hitspecial)
				e:Play()
			end
			victim.WalkSpeed = 3
			local kbdirect
			if reverse then kbdirect = -rootpart.CFrame.lookVector*kb + Vector3.new(0,kb/3,0)
			elseif kb == 0 then kbdirect = Vector3.new()
			else kbdirect = rootpart.CFrame.lookVector*kb + Vector3.new(0,kb/3,0)
			end
			if passthrough then hithandler.hit(victim, dmg, dur, kbdirect, gb, nil, true, nil, nil, nil, nil, nil, 0.1)
			else hithandler.hit(victim, dmg, dur, kbdirect, gb, rootpart.Parent, nil, nil, true, nil, nil, 0.1) end
		end
	end)
	if hitboxdur then task.wait(hitboxdur) end
	return alreadyhit
end

local debrisvfx = VfXRemotes:WaitForChild("debrisvfx")
local bigcooldown = {}
big.OnServerEvent:Connect(function(player)
	if player:GetAttribute("Class") ~= "Kungfu" then return end
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
	local cooldowntime = 14  -- COOLDOWNTIME LES GOOOOOOO!!!

	if attacking or stun or blocking or table.find(bigcooldown, char.Name) or sleeping then return end
	table.insert(bigcooldown, char.Name); task.delay(cooldowntime, function() table.remove(bigcooldown, table.find(bigcooldown, char.Name)) end) 
	ClassData.Cooldown(player, "AB2", cooldowntime)
	char:SetAttribute("Attacking", true)
	ChangeStuff(hum)
	local track = animator:LoadAnimation(game.ReplicatedStorage.Anim.Kungfu.big)
	track:Play()
	effects.guardbreak(char.Head, 0.85)
	for i = 1, 12, 1 do
		task.wait(0.05)
		if char:GetAttribute("Stunned") then break end
		if i == 5 then
			hum.AutoRotate = false
		end
	end
	if not char:GetAttribute("Stunned") then
		local attach = Instance.new("Attachment", rootpart)
		local clone = game.ReplicatedStorage.vfx.misc.ParticleEmitter:Clone()
		clone.Parent = attach
		clone:Emit(clone:GetAttribute("EmitCount"))
		game.Debris:AddItem(clone, 0.6)
		debrisvfx:FireAllClients(rootpart)
		effects.superarmour(char, 0.5)
		char:SetAttribute("SuperArmour", true)
		local box = hitbox.Create(Vector3.new(5, 5, 5), rootpart, CFrame.new(-0.265, 0.383, -3.255))
		box:Start()
		local hit1 = touch(box, hum, 20, 1, 125, true, nil, 0.125)
		box:Stop()
		local box = hitbox.Create(Vector3.new(7.5, 7.5, 7.5), rootpart, CFrame.new(-0.265, 0.473, -9.485))
		box:Start()
		local hit2 = touch(box, hum, 15, 0.75, 100, false, hit1,0.125)
		box:Stop()
		local box = hitbox.Create(Vector3.new(10, 10, 10), rootpart, CFrame.new(-0.265, 1.113, -18.215))
		box:Start()
		local hit3 = touch(box, hum, 13, 0.5, 75, false, hit2, 0.125)
		box:Stop()
		local box = hitbox.Create(Vector3.new(15, 15, 15), rootpart, CFrame.new(-0.265, 1.493, -30.735))
		box:Start()
		local hit4 = touch(box, hum, 10, 0.3, 50, false, hit3, 0.125)
		box:Stop()
		char:SetAttribute("SuperArmour", false)
		if #hit4 == 0 then task.wait(0.5) end
	end
	char:SetAttribute("Attacking", false)
	ChangeStuff(hum, true)
	hum.AutoRotate = true
end)

local spinvfx = VfXRemotes:WaitForChild("spinvfx")
local spincooldown = {}

local function touch2(box:Instance, hum:Humanoid, dmg:number, dur:number, hitboxdur:number, alreadyhit:SharedTable)
	if alreadyhit == nil then alreadyhit = {} end
	local rootpart = hum.RootPart
	box.Touched:Connect(function(hit, victim)
		if table.find(alreadyhit, victim) then return end
		if victim == hum  then return end
		if victim then
			table.insert(alreadyhit, victim)
			local kb = (victim.RootPart.Position - rootpart.Position).Unit * 75 + Vector3.new(0,75/2.5,0)
			if victim.Parent:GetAttribute("Blocking") then
				local attachment = Instance.new("Attachment", victim.RootPart)
				local LV = Instance.new("LinearVelocity", attachment)
				LV.Attachment0 = attachment
				LV.MaxForce = math.huge
				LV.VectorVelocity = kb
				game.Debris:AddItem(attachment, 0.1)
			end
			local animator = victim:FindFirstChild("Animator")
			if animator and not victim.Parent:GetAttribute("Blocking") and not victim.Parent:GetAttribute("SuperArmour") then
				local track = animator:LoadAnimation(game.ReplicatedStorage.Anim.hit.hitspecial)
				track:Play()
			end
			victim.WalkSpeed = 3
			hithandler.hit(victim, dmg, dur, kb, nil, rootpart.Parent, nil, nil, true, nil, nil, 0.3) 
		end
	end)
	if hitboxdur then task.wait(hitboxdur) end
	return alreadyhit
end
spin.OnServerEvent:Connect(function(player)
	if player:GetAttribute("Class") ~= "Kungfu" then return end
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
	local cooldowntime = 11 -- AAAAAA COOLDOWNTIME!!!!! LES GOOOO!!!

	if attacking or stun or blocking or table.find(spincooldown, char.Name) or sleeping then return end
	hum.AutoRotate = false
	table.insert(spincooldown, char.Name); task.delay(cooldowntime, function() table.remove(spincooldown, table.find(spincooldown, char.Name)) end) 
	ClassData.Cooldown(player, "AB1", cooldowntime)
	char:SetAttribute("Attacking", true)
	char:SetAttribute("SuperArmour", true)
	ChangeStuff(hum)
	local track = animator:LoadAnimation(game.ReplicatedStorage.Anim.Kungfu.spinattack)
	track:Play()
	effects.superarmour(char, 1.2)
	task.wait(0.5)
	spinvfx:FireAllClients(rootpart)
	local box = hitbox.Create(Vector3.new(4.65, 4.33, 6), rootpart, CFrame.new(-3.05, -0.807, -0.835))
	box:Start()
	local hit1 = touch2(box, hum, 15, 1, 0.2, nil)
	box:Stop()
	local box = hitbox.Create(Vector3.new(6.82, 4.33, 4), rootpart, CFrame.new(-0.18, -0.807, -2.915))
	box:Start()
	local hit2 = touch2(box, hum, 15, 1, 0.2, hit1)
	box:Stop()
	local box = hitbox.Create(Vector3.new(4.65, 4.33, 6), rootpart, CFrame.new(2.755, -0.807, -0.83))
	box:Start()
	local hit3 = touch2(box, hum, 15, 1, 0.2, hit2)
	box:Stop()
	local box = hitbox.Create(Vector3.new(6.37, 5.88, 3.34), rootpart, CFrame.new(0.725, -0.032, 2.67))
	box:Start()
	local hit4 = touch2(box, hum, 15, 1, 0.2, hit3)
	box:Stop()
	char:SetAttribute("SuperArmour", false)
	track:AdjustSpeed(1.5)
	task.wait(0.35)
	char:SetAttribute("Attacking", false)
	ChangeStuff(hum, true)
	hum.AutoRotate = true
end)

local kickcd = {}
kick.OnServerEvent:Connect(function(player)
	if player:GetAttribute("Class") ~= "Kungfu" then return end
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
	local cooldowntime = 11  -- COOLDOWNTIME LES GOOOOOOO!!!

	if attacking or stun or blocking or table.find(kickcd, char.Name) or sleeping then return end
	table.insert(kickcd, char.Name); task.delay(cooldowntime, function() table.remove(kickcd, table.find(kickcd, char.Name)) end) 
	ClassData.Cooldown(player, "AB3", cooldowntime)
	char:SetAttribute("Attacking", true)
	ChangeStuff(hum)
	local track = animator:LoadAnimation(game.ReplicatedStorage.Anim.Kungfu.kick)
	track:Play()
	track:AdjustSpeed(2.5)
	for i = 1, 4, 1 do
		if i == 2 then
			dash:FireClient(player, 25, 0.1)
		end
		task.wait(0.03)
		if char:GetAttribute("Stunned") then break end
	end
	local alreadyhit
	track:AdjustSpeed(1)
	if not char:GetAttribute("Stunned") then
		local box = hitbox.Create(Vector3.new(3.68, 2.11, 4), rootpart, CFrame.new(0.28, -0.375, -3.134) * CFrame.fromEulerAnglesXYZ(math.rad(-5.24), 0, 0))
		local connection
		connection = box.Touched:Connect(function(hit, victim)
			if victim == hum  then return end
			if victim then
				connection:Disconnect()
				local animator2 = victim:FindFirstChild("Animator")
				if animator2 and not victim.Parent:GetAttribute("Blocking") and not victim.Parent:GetAttribute("SuperArmour") then
					local track = animator2:LoadAnimation(game.ReplicatedStorage.Anim.hit.hit1)
					track:Play()
				end
				alreadyhit = victim
				local blocked = hithandler.hit(victim, 7, 0.85, nil, false, char, nil, nil, nil, nil, nil, 0.2)
				effects.slow(alreadyhit,6,30)
				if blocked then
					rootpart.CFrame = victim.RootPart.CFrame * CFrame.new(0,0,1)
				end
			end
		end)
		box:Start()
		task.wait(0.2)
		box:Stop()
	end
	if alreadyhit then
		char:SetAttribute("Attacking", false)
		ChangeStuff(hum, true)
	else
		task.wait(0.4)
		char:SetAttribute("Attacking", false)
		ChangeStuff(hum, true)
	end
end)

guardbreakcd = {}
local guardbreakvfx = game.ReplicatedStorage:WaitForChild("remotes"):WaitForChild("vfx"):WaitForChild("gbvfx")
guardbreak.OnServerEvent:Connect(function(player)
	if player:GetAttribute("Class") ~= "Kungfu" then return end
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
	local cooldowntime = 10  -- COOLDOWNTIME LES GOOOOOOO!!!

	if attacking or stun or blocking or table.find(guardbreakcd, char.Name) or sleeping then return end
	hum.AutoRotate = false
	table.insert(guardbreakcd, char.Name); task.delay(cooldowntime, function() table.remove(guardbreakcd, table.find(guardbreakcd, char.Name)) end) 
	ClassData.Cooldown(player, "GB", cooldowntime)
	char:SetAttribute("Attacking", true)
	ChangeStuff(hum)
	local track = animator:LoadAnimation(game.ReplicatedStorage.Anim.Kungfu.GuardBreak)
	track:Play()
	track:AdjustSpeed(0.833)
	effects.guardbreak(char.Head, 1)
	for i = 1, 12, 1 do
		task.wait(0.05)
		if char:GetAttribute("Stunned") then break end
	end
	track:AdjustSpeed(1)
	local alreadyhit
	if not char:GetAttribute("Stunned") then
		local box = hitbox.Create(Vector3.new(9.25, 2, 9.25), rootpart, CFrame.new(0, -2, 0))
		local connection
		connection = box.Touched:Connect(function(hit, victim)
			if victim == hum  then return end
			if victim then
				alreadyhit = victim
				local animator2 = victim:FindFirstChild("Animator")
				if animator2 and not victim.Parent:GetAttribute("Blocking") and not victim.Parent:GetAttribute("SuperArmour") then
					local track = animator2:LoadAnimation(game.ReplicatedStorage.Anim.hit.hit1)
					track:Play()
				end
				local kb = (victim.RootPart.Position - rootpart.Position).Unit * 45 + Vector3.new(0,30,0)
				hithandler.hit(victim, 12, 0.7, kb, true, char)
			end
		end)
		box:Start()
		guardbreakvfx:FireAllClients(rootpart)
		task.wait(0.1667)
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
