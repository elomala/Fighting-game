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
local maxcombo = 3

local function ChangeStuff(hum:Humanoid, def:boolean)
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

local bulletcd = {}
combat.OnServerEvent:Connect(function(player)
	if player:GetAttribute("Class") ~= "Sheriff" then return end
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
	local ammo = char:GetAttribute("Ammo")
	local sleeping = char:GetAttribute("Sleeping")
	
	if attacking and ammo and not stun and not blocking and not sleeping then
		if table.find(bulletcd, player) then return end
		table.insert(bulletcd, player)
		task.delay(0.3, function() table.remove(bulletcd, table.find(bulletcd, player)) end)
		local bulletno = ammo
		char:SetAttribute("Ammo", ammo-1)
		local track = animator:LoadAnimation(game.ReplicatedStorage.Anim.Sheriff.SP1_stance.Shot)
		track:Play()
		
		local thing = game.ReplicatedStorage.vfx.moves.sheriff.Shoot:Clone()
		game.Debris:AddItem(thing,0.5)
		thing.Parent = workspace.vfx
		thing.CFrame = rootpart.CFrame * CFrame.new(0.25, 0.738, -3.95)
		for i, v in pairs(thing:GetChildren()) do
			v:Emit(v:GetAttribute("EmitCount"))
		end
		
		local bullet = Instance.new("Part", workspace.misc)
		game.Debris:AddItem(bullet, 1)
		bullet.Size = Vector3.new(0.25, 0.25, 1); bullet.Material = Enum.Material.Neon; bullet.Color = Color3.fromRGB(255, 85, 0)
		if bulletno == 1 then bullet.Color = Color3.fromRGB(255,0,0); bullet.Size = Vector3.new(0.35,0.35,1.25) end
		bullet.CFrame = rootpart.CFrame * CFrame.new(0.665, 0.603, -4.265); bullet.CanCollide = false; bullet.CanTouch = false
		bullet.CanQuery = false; bullet.Anchored = true
		local tween = TweenService:Create(bullet, TweenInfo.new(0.75, Enum.EasingStyle.Linear), {CFrame = bullet.CFrame * CFrame.new(0,0,-75)})
		dash:FireClient(player, -10, 0.1)
		
		local attachment1 = Instance.new("Attachment", bullet)
		attachment1.CFrame = CFrame.new(-bullet.Size.X, 0, 0)
		local attachment2 = Instance.new("Attachment", bullet)
		attachment2.CFrame = CFrame.new(bullet.Size.X, 0, 0)
		local trail = Instance.new("Trail", bullet)
		trail.LightEmission = 0.2
		trail.LightInfluence = 0
		trail.Lifetime = 0.1
		trail.Color = ColorSequence.new(bullet.Color)
		trail.Attachment0 = attachment1
		trail.Attachment1 = attachment2
		
		local box = hitbox.Create(bullet.Size, bullet, CFrame.new(0,0,-0.1))
		box:Start()
		tween:Play()
		tween.Completed:Connect(function()
			bullet:Destroy()
			box:Stop()
		end)
		local hiit = false
		box.Touched:Connect(function(hit, victim)
			if victim == hum then return end
			if victim and not hiit then
				hiit = true
				bullet:Destroy()
				local animator2 = victim:FindFirstChild("Animator")
				if animator2 and not victim.Parent:GetAttribute("Blocking") and not victim.Parent:GetAttribute("SuperArmour") then
					local e = victim.Animator:LoadAnimation(game.ReplicatedStorage.Anim.hit.hit1)
					e:Play()
				end
				local kb = rootpart.CFrame.lookVector * 20 
				if bulletno == 1 then hithandler.hit(victim, 7, 0.1, kb, true, char, nil, nil, nil, nil, 85) return end
				hithandler.hit(victim, 7, 0.1, kb, false, char, nil, nil, true, nil, 85)
			end
		end)
		
		return
	end
	
	if attacking or stun or blocking or sleeping then return end
	char:SetAttribute("Attacking", true)

	local animations = game.ReplicatedStorage.Anim
	local track = animator:LoadAnimation(animations.Sheriff[combo])
	local box
	if combo == 1 then
		box = hitbox.Create(Vector3.new(6.59, 2.35, 4.31), rootpart, CFrame.new(0.295, 0.073, -2.822) * CFrame.fromEulerAnglesXYZ(math.rad(-16.5),0,0))
	elseif combo == 2 then
		box = hitbox.Create(Vector3.new(2.83, 2.35, 4.81), rootpart, CFrame.new(0.245, -0.487, -3.125))
	elseif combo == 3 then
		box = hitbox.Create(Vector3.new(5.04, 4.87, 5.82), rootpart, CFrame.new(0.22, 1.733, -4.54))
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
				hithandler.hit(victim, 10, 0.75, rootpart.CFrame.lookVector*100, false, char, nil, nil, nil, nil, nil, 0.2)
				return
			elseif combo == 2 then
				hithandler.hit(victim, 5, 0.55, rootpart.CFrame.lookVector*10, false, char, nil, nil, nil, nil, nil, 0.2)
				return
			end
			hithandler.hit(victim, 6, 0.55, rootpart.CFrame.lookVector*10, false, char, nil, nil, nil, nil, nil, 0.2)
		end
	end)

	ChangeStuff(hum)
	ChangeCombo(char)
	hum.AutoRotate = false
	track:Play()
	task.wait(0.15)
	if char:GetAttribute("Combo") == 1 then
		dash:FireClient(player, -15, 0.1)
	else
		dash:FireClient(player, 15, 0.1)
	end
	box:Start()
	if combo == 3 then
		local thing = game.ReplicatedStorage.vfx.moves.sheriff.M1:Clone()
		game.Debris:AddItem(thing,0.5)
		thing.Parent = workspace.vfx
		thing.CFrame = rootpart.CFrame * CFrame.new(0.29, 1.478, -4.87)
		for i, v in pairs(thing:GetChildren()) do
			v:Emit(v:GetAttribute("EmitCount"))
		end
	end
end)

local guardbreakcd = {}
guardbreak.OnServerEvent:Connect(function(player)
	if player:GetAttribute("Class") ~= "Sheriff" then return end
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
	local track = animator:LoadAnimation(game.ReplicatedStorage.Anim.Sheriff.GB)
	track:Play()
	effects.guardbreak(char.Head, 1)
	for i = 1, 10, 1 do
		task.wait(0.05)
		if char:GetAttribute("Stunned") then break end
	end
	local alreadyhit
	if not char:GetAttribute("Stunned") then
		local box = hitbox.Create(Vector3.new(6, 6, 6.27), rootpart, CFrame.new(0.455, 1.528, -5.4))
		local connection
		connection = box.Touched:Connect(function(hit, victim)
			if victim == hum  then return end
			if victim then
				alreadyhit = victim
				local animator2 = victim:FindFirstChild("Animator")
				if animator2 and not victim.Parent:GetAttribute("Blocking") and not victim.Parent:GetAttribute("SuperArmour") then
					local e = victim.Animator:LoadAnimation(game.ReplicatedStorage.Anim.hit.hitspecial)
					e:Play()
				end
				local kb = rootpart.CFrame.lookVector * 75
				hithandler.hit(victim, 12, 0.75, kb, true, char)
			end
		end)
		local thing = game.ReplicatedStorage.vfx.moves.sheriff.GB:Clone()
		game.Debris:AddItem(thing,0.5)
		thing.Parent = workspace.vfx
		thing.CFrame = rootpart.CFrame * CFrame.new(0.45, 1.103, -5.51)
		for i, v in pairs(thing:GetChildren()) do
			v:Emit(v:GetAttribute("EmitCount"))
		end
		box:Start()
		task.wait(0.1)
		dash:FireClient(player, -25, 0.1)
		task.wait(0.1)
		box:Stop()
	end
	if alreadyhit then
		task.wait(0.15)
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

local SP1cd = {}
SP1.OnServerEvent:Connect(function(player)
	if player:GetAttribute("Class") ~= "Sheriff" then return end
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
	if attacking and char:GetAttribute("Ammo") then
		
		char:SetAttribute("Ammo", 0)
		return
	end
	if attacking or stun or blocking or table.find(SP1cd, player) or sleeping then return end
	table.insert(SP1cd, player); 
	ClassData.CooldownDark(player, "AB1")
	char:SetAttribute("Attacking", true)
	effects.slow(hum, 10, 50, true)
	hum.JumpPower = 0
	hum.JumpHeight = 0
	local track = animator:LoadAnimation(game.ReplicatedStorage.Anim.Sheriff.SP1_stance)
	track:Play()
	char:SetAttribute("Ammo", 6)
	local connection, alreadydone
	connection = char:GetAttributeChangedSignal("Ammo"):Connect(function()
		if char:GetAttribute("Ammo") == 0 then
			alreadydone = true
			task.delay(cooldowntime, function() table.remove(SP1cd, table.find(SP1cd, player)) end)
			ClassData.Cooldown(player, "AB1", cooldowntime)
			char:SetAttribute("Ammo", nil)
			ChangeStuff(hum)
			task.wait(0.5)
			char:SetAttribute("Attacking", false)
			for i, v in pairs(char:GetChildren()) do
				if v.Name == "Effect" and v:GetAttribute("Type") == "Slow" and v:GetAttribute("Not_Show") == true then
				v:Destroy()	
				end
			end
			track:Stop()
			ChangeStuff(hum, true)
			connection:Disconnect()
		end
	end)
	task.delay(10, function()
		if not char:GetAttribute("Ammo") or alreadydone then return end
		if char:GetAttribute("Ammo") > 0 then
			task.delay(cooldowntime, function() table.remove(SP1cd, table.find(SP1cd, player)) end)
			ClassData.Cooldown(player, "AB1", cooldowntime)
			ChangeStuff(hum)
			char:SetAttribute("Ammo", nil)
			task.wait(0.5)
			char:SetAttribute("Attacking", false)
			connection:Disconnect()
			track:Stop()
			ChangeStuff(hum, true)
		end
	end)
end)

local SP2cd = {}
local done = false
SP2.OnServerEvent:Connect(function(player)
	if player:GetAttribute("Class") ~= "Sheriff" then return end
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
	table.insert(SP2cd, player.Name); task.delay(cooldowntime, function()
		if not table.find(SP2cd, player.Name) then return end;
		if done then done = false return end -- done so that the cooldown doesn't end if player resets using AB3
		table.remove(SP2cd, table.find(SP2cd, player.Name)) 
	end)
	ClassData.Cooldown(player, "AB2", cooldowntime)
	char:SetAttribute("Attacking", true)
	ChangeStuff(hum)
	local track = animator:LoadAnimation(game.ReplicatedStorage.Anim.Sheriff.SP2)
	track:Play()
	effects.guardbreak(char.Head, 1)
	for i = 1, 7, 1 do
		task.wait(0.05)
		if char:GetAttribute("Stunned") then break end
	end
	local thing = game.ReplicatedStorage.vfx.moves.sheriff.Shoot:Clone()
	game.Debris:AddItem(thing,0.5)
	thing.Parent = workspace.vfx
	thing.CFrame = rootpart.CFrame * CFrame.new(-0.1, 0.938, -4.18)
	for i, v in pairs(thing:GetChildren()) do
		v:Emit(v:GetAttribute("EmitCount"))
	end
	local bullet = Instance.new("Part", workspace.misc)
	game.Debris:AddItem(bullet, 1)
	bullet.Size = Vector3.new(0.35,0.35,1.25); bullet.Material = Enum.Material.Neon; bullet.Color = Color3.fromRGB(255, 50, 14)
	bullet.CFrame = rootpart.CFrame * CFrame.new(0.285, 0.723, -4.505); bullet.CanCollide = false; bullet.CanTouch = false
	bullet.CanQuery = false; bullet.Anchored = true
	local tween = TweenService:Create(bullet, TweenInfo.new(0.75, Enum.EasingStyle.Linear), {CFrame = bullet.CFrame * CFrame.new(0,0,-100)})
	dash:FireClient(player, -20, 0.1)
	game.ReplicatedStorage.remotes.vfx.medicvfx:FireAllClients(rootpart, bullet.Color)
	
	local attachment1 = Instance.new("Attachment", bullet)
	attachment1.CFrame = CFrame.new(-bullet.Size.X, 0, 0)
	local attachment2 = Instance.new("Attachment", bullet)
	attachment2.CFrame = CFrame.new(bullet.Size.X, 0, 0)
	local trail = Instance.new("Trail", bullet)
	trail.LightEmission = 0.2
	trail.LightInfluence = 0
	trail.Lifetime = 0.15
	trail.Color = ColorSequence.new(bullet.Color)
	trail.Attachment0 = attachment1
	trail.Attachment1 = attachment2
	
	local box = hitbox.Create(bullet.Size, bullet, CFrame.new(0,0,-0.1))
	box:Start()
	tween:Play()
	tween.Completed:Connect(function()
		bullet:Destroy()
		box:Stop()
	end)
	local alreadyhit = {}
	box.Touched:Connect(function(hit, victim)
		if victim == hum or table.find(alreadyhit, victim) then return end
		if victim then
			table.insert(alreadyhit, victim)
			local animator2 = victim:FindFirstChild("Animator")
			if animator2 and not victim.Parent:GetAttribute("Blocking") and not victim.Parent:GetAttribute("SuperArmour") then
				local e = victim.Animator:LoadAnimation(game.ReplicatedStorage.Anim.hit.hitspecial)
				e:Play()
			end
			local kb = rootpart.CFrame.lookVector * 60 + Vector3.new(0,20,0)
			hithandler.hit(victim, 15, 0.5, kb, false, char, true, nil, nil, nil, 110)
		end
	end)
	task.wait(0.35)
	track:Stop()
	char:SetAttribute("Attacking", false)
	ChangeStuff(hum, true)
end)

SP3cd = {}
SP3.OnServerEvent:Connect(function(player)
	if player:GetAttribute("Class") ~= "Sheriff" then return end
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
	local ammo = char:GetAttribute("Ammo")
	local sleeping = char:GetAttribute("Sleeping")
	local cooldowntime = 15
	if attacking and ammo and not stun and not blocking and not table.find(SP3cd, player.Name) and not sleeping then
		table.insert(SP3cd, player.Name); task.delay(cooldowntime, function() table.remove(SP3cd, table.find(SP3cd, player.Name)) end)
		ClassData.Cooldown(player, "AB3", cooldowntime)
		dash:FireClient(player, 75, 0.1)
		local track = animator:LoadAnimation(game.ReplicatedStorage.Anim.Sheriff.SP3)
		track:Play()
		local cammo = ammo + 3
		cammo = if cammo > 6 then 6 else cammo
		char:SetAttribute("Ammo", cammo)
		return
	end
	if attacking or stun or blocking or table.find(SP3cd, player.Name) or sleeping then return end
	table.insert(SP3cd, player.Name); task.delay(cooldowntime, function() table.remove(SP3cd, table.find(SP3cd, player.Name)) end)
	ClassData.Cooldown(player, "AB3", cooldowntime)
	char:SetAttribute("Attacking", true)
	dash:FireClient(player, 75, 0.1)
	local track = animator:LoadAnimation(game.ReplicatedStorage.Anim.Sheriff.SP3)
	track:Play()
	local pos = table.find(SP2cd, player.Name)
	if pos then table.remove(SP2cd, pos); done = true end
	ClassData.CooldownReset(player, "AB2")
	task.wait(0.2)
	char:SetAttribute("Attacking", false)
end)