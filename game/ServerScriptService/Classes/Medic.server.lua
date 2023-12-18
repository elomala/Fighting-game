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
	task.delay(0.4, function()
		local current = char:GetAttribute("Combo")
		if current-1 == old then
			char:SetAttribute("Combo", 1)
		end
	end)
end

combat.OnServerEvent:Connect(function(player)
	if player:GetAttribute("Class") ~= "Medic" then return end
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
	local track = animator:LoadAnimation(animations.Medic[combo])
	local box
	if combo == 1 then
		box = hitbox.Create(Vector3.new(4.58, 1.241, 3.391), rootpart, CFrame.new(-0.449, 0.32, -2.29) * CFrame.fromEulerAnglesXYZ(math.rad(-15.437), math.rad(10.907), math.rad(29.76)))
	elseif combo == 2 then
		box = hitbox.Create(Vector3.new(2.018, 1.241, 5.042), rootpart, CFrame.new(0.894, 0.832, -2.968))
	elseif combo == 3 then
		box = hitbox.Create(Vector3.new(2.018, 1.241, 3.841), rootpart, CFrame.new(0.389, -0.14, -3.367))
	end

	task.delay(0.3, function()
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
				hithandler.hit(victim, 6, 0.75, rootpart.CFrame.lookVector*100, false, char, nil, nil, nil, nil, nil, 0.2)
				return
			end
			hithandler.hit(victim, 6, 0.55, rootpart.CFrame.lookVector*10, false, char, nil, "Slash", nil, nil, nil, 0.2)
		end
	end)

	ChangeStuff(hum)
	ChangeCombo(char)
	hum.AutoRotate = false
	track:Play()
	task.wait(0.1)
	if combo == 2 then
		dash:FireClient(player, 20, 0.1)
	else
		dash:FireClient(player, 10, 0.1)
	end
	box:Start()
end)

local guardbreakcd = {}
guardbreak.OnServerEvent:Connect(function(player)
	if player:GetAttribute("Class") ~= "Medic" then return end
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
	local cooldowntime = 12  -- COOLDOWNTIME LES GOOOOOOO!!!
	
	
	if attacking or stun or blocking or table.find(guardbreakcd, char.Name) or sleeping then return end
	table.insert(guardbreakcd, char.Name); task.delay(cooldowntime, function() table.remove(guardbreakcd, table.find(guardbreakcd, char.Name)) end) 
	ClassData.Cooldown(player, "GB", cooldowntime)
	char:SetAttribute("Attacking", true)
	ChangeStuff(hum)
	local track = animator:LoadAnimation(game.ReplicatedStorage.Anim.Medic.GB)
	track:Play()
	effects.guardbreak(char.Head, 1)
	for i = 1, 12, 1 do
		task.wait(0.05)
		if char:GetAttribute("Stunned") then break end
	end
	if not char:GetAttribute("Stunned") then
		local bullet = Instance.new("Part", workspace.misc)
		bullet.Size = Vector3.new(0.35, 0.35, 1.25); bullet.Material = Enum.Material.Neon; bullet.Color = Color3.fromRGB(33, 84, 185)
		bullet.CFrame = rootpart.CFrame * CFrame.new(-0.032, 1.271, -4.865); bullet.CanCollide = false; bullet.CanTouch = false
		bullet.CanQuery = false; bullet.Anchored = true
		local tween = TweenService:Create(bullet, TweenInfo.new(0.75, Enum.EasingStyle.Linear), {CFrame = bullet.CFrame * CFrame.new(0,0,-75)})
		dash:FireClient(player, -10, 0.1)
		game.ReplicatedStorage.remotes.vfx.medicvfx:FireAllClients(rootpart)
		
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
		local hiit = false
		box.Touched:Connect(function(hit, victim)
			if victim == hum or hiit then return end
			if victim then
				hiit = true
				bullet:Destroy()
				local animator2 = victim:FindFirstChild("Animator")
				if animator2 and not victim.Parent:GetAttribute("Blocking") and not victim.Parent:GetAttribute("SuperArmour") then
					local e = victim.Animator:LoadAnimation(game.ReplicatedStorage.Anim.hit.hitspecial)
					e:Play()
				end
				local kb = rootpart.CFrame.lookVector * 50 + Vector3.new(0,20,0)
				hithandler.hit(victim, 12, 0, kb, false, char, true, nil, nil, nil, 85)
				effects.sleep(victim, 5)
			end
		end)
		task.wait(0.5)
		track:Stop()
		char:SetAttribute("Attacking", false)
		ChangeStuff(hum, true)
	end
end)

local SP1cd = {}
local db = {}
SP1.OnServerEvent:Connect(function(player)
	if player:GetAttribute("Class") ~= "Medic" then return end
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
	local stacks = char:GetAttribute("AB1stacks")
	local sptype = char:GetAttribute("SP1type")
	local cooldowntime = 0.75
	local stacktime = 10
	
	if attacking and char:GetAttribute("Changing") and not stun and not blocking and not sleeping then
		if table.find(db, player) then return end
		table.insert(db, player); task.delay(0.5, function() table.remove(db, table.find(db, player)) end)
		local track = animator:LoadAnimation(game.ReplicatedStorage.Anim.Medic.SP3_Ammo)
		track:Play()
		if sptype < 3 then
			char:SetAttribute("SP1type", sptype+1)
		else
			char:SetAttribute("SP1type", 1)
		end
	end
	
	if attacking or stun or blocking or table.find(SP1cd, player) or sleeping or stacks <= 0  then return end
	local amt = 0
	table.insert(SP1cd, player); task.delay(cooldowntime, function() table.remove(SP1cd, table.find(SP1cd, player)) end)
	char:SetAttribute("AB1stacks", stacks-1)
	task.delay(stacktime, function() char:SetAttribute("AB1stacks", char:GetAttribute("AB1stacks")+1) end)
	ClassData.Stacks(player, "AB1", stacktime, char:GetAttribute("AB1stacks"))
	char:SetAttribute("Attacking", true)
	ChangeStuff(hum)
	local track = animator:LoadAnimation(game.ReplicatedStorage.Anim.Medic.SP1)
	track:Play()
	
	local color = if sptype == 1 then Color3.fromRGB(17, 17, 17)
		elseif sptype == 2 then Color3.fromRGB(255, 89, 89)
		elseif sptype == 3 then Color3.fromRGB(75, 151, 75)
		else Color3.fromRGB(17, 17, 17)
	
	local range = if sptype == 1 then 50
		elseif sptype == 2 then 60
		elseif sptype == 3 then 35
		else 50
	
	local bullettime = if sptype == 1 then 0.5
		elseif sptype == 2 then 0.6
		elseif sptype == 3 then 0.35
		else 0.5
	if sptype == 2 then effects.guardbreak(char.Head, 0.75) end
	for i = 1, 8, 1 do
		task.wait(0.05)
		if char:GetAttribute("Stunned") then break end
	end
	if not char:GetAttribute("Stunned") then
		local bullet = Instance.new("Part", workspace.misc)
		bullet.Size = Vector3.new(0.2, 0.2, 1.1); bullet.Material = Enum.Material.Neon; bullet.Color = color
		bullet.CFrame = rootpart.CFrame * CFrame.new(-0.032, 1.271, -4.865); bullet.CanCollide = false; bullet.CanTouch = false
		bullet.CanQuery = false; bullet.Anchored = true
		local tween = TweenService:Create(bullet, TweenInfo.new(bullettime, Enum.EasingStyle.Linear), {CFrame = bullet.CFrame * CFrame.new(0,0,-range)})
		dash:FireClient(player, -5, 0.05)
		
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
			if victim == hum or hiit then return end
			if victim then
				hiit = true
				bullet:Destroy()
				local animator2 = victim:FindFirstChild("Animator")
				if animator2 and color ~= Color3.fromRGB(75, 151, 75)  and not victim.Parent:GetAttribute("Blocking") and not victim.Parent:GetAttribute("SuperArmour") then
					local e = victim.Animator:LoadAnimation(game.ReplicatedStorage.Anim.hit.hitspecial)
					e:Play()
				end
				local kb = rootpart.CFrame.lookVector * 25
				if color == Color3.fromRGB(17, 17, 17) then
					local blocked = hithandler.hit(victim, 7, 0, kb, false, char, nil, nil, true, nil, 60, 0.15)
					if not blocked then effects.cripple(victim, 5) end
				elseif color == Color3.fromRGB(255, 89, 89) then
					hithandler.hit(victim, 7, 0, kb, false, char, true, nil, nil, nil, 85)
					effects.attack(victim, 5, -15)
				elseif color == Color3.fromRGB(75, 151, 75) then
					effects.regeneration(victim, 6, 1)
				end
			end
		end)
	end
	task.wait(0.25)
	char:SetAttribute("Attacking", false)
	ChangeStuff(hum, true)
end)

local SP2cd = {}
local motionevent = game.ReplicatedStorage:WaitForChild("remotes"):WaitForChild("vfx"):WaitForChild("projectile")
local canrun = {}
local debounce = {}
SP2.OnServerEvent:Connect(function(player, mousepos)
	if player:GetAttribute("Class") ~= "Medic" then return end
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
	local stacks = char:GetAttribute("AB2stacks")
	local sptype = char:GetAttribute("SP2type")
	local cooldowntime = 1.5
	local stacktime = 13

	if attacking and char:GetAttribute("Changing") and not stun and not blocking and not sleeping then
		if table.find(debounce, player) then return end
		table.insert(debounce, player); task.delay(0.5, function() table.remove(debounce, table.find(debounce, player)) end)
		local track = animator:LoadAnimation(game.ReplicatedStorage.Anim.Medic.SP3_Grenade)
		track:Play()
		if sptype < 3 then
			char:SetAttribute("SP2type", sptype+1)
		else
			char:SetAttribute("SP2type", 1)
		end
	end
	
	if attacking or stun or blocking or table.find(SP2cd, player.Name) or sleeping or stacks == 0 then return end
	table.insert(SP2cd, player.Name); task.delay(cooldowntime, function() table.remove(SP2cd, table.find(SP2cd, player.Name)) end)
	char:SetAttribute("AB2stacks", stacks-1)
	task.delay(stacktime, function() char:SetAttribute("AB2stacks", char:GetAttribute("AB2stacks")+1) end)
	ClassData.Stacks(player, "AB2", stacktime, char:GetAttribute("AB2stacks"))
	char:SetAttribute("Attacking", true)
	local track = animator:LoadAnimation(game.ReplicatedStorage.Anim.Medic.SP2)
	track:Play()
	hum.WalkSpeed = 8
	
	local color = if sptype == 1 then Color3.fromRGB(156, 0, 156) 
		elseif sptype == 2 then Color3.fromRGB(163, 163, 0)
		elseif sptype == 3 then Color3.fromRGB(50, 161, 35)
		else Color3.fromRGB(156, 0, 156)
	
	local part, weld
	for i = 1, 14 ,1 do
		if i == 2 then
			part = Instance.new("Part")
			game.Debris:AddItem(part, 0.6)
			part.Size = Vector3.new(0.35, 0.5, 0.35)
			part.Material = Enum.Material.Neon
			part.Color = color
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.Massless = true
			part.Parent = char
			weld = Instance.new("Weld", char)
			game.Debris:AddItem(weld, 0.6)
			weld.Part0 = char:FindFirstChild("Left Arm")
			weld.Part1 = part
			weld.C1 = CFrame.new(0,0,1) * CFrame.fromEulerAnglesXYZ(math.rad(90),0,0)
		end
		if char:GetAttribute("Stunned") then part:Destroy(); weld:Destroy() break end
		task.wait(0.05)
		if i == 12 then
			ChangeStuff(hum)
		end
	end
	
	if not char:GetAttribute("Stunned") then
		part:Destroy(); weld:Destroy()
		local projectile = Instance.new("Part")
		game.Debris:AddItem(projectile, 6)
		projectile.Size = Vector3.new(1,1,2)
		projectile.Material = Enum.Material.Neon
		projectile.Color = color
		projectile.CanCollide = false
		projectile.CFrame = rootpart.CFrame * CFrame.new(0,0,-1)
		projectile.Parent = game.Workspace.misc
		
		local attachment1 = Instance.new("Attachment", projectile)
		attachment1.CFrame = CFrame.new(-0.5, 0, 0)
		local attachment2 = Instance.new("Attachment", projectile)
		attachment2.CFrame = CFrame.new(0.5, 0, 0)
		local trail = Instance.new("Trail", projectile)
		trail.LightEmission = 1
		trail.LightInfluence = 0
		trail.Lifetime = 0.2
		trail.Color = ColorSequence.new(projectile.Color)
		trail.Attachment0 = attachment1
		trail.Attachment1 = attachment2
		
		projectile:SetNetworkOwner(player)
		table.insert(canrun, player)
		task.delay(6, function() table.remove(canrun, table.find(canrun, player)) end)


		motionevent:FireClient(player, projectile)
	end
	task.wait(0.25)
	ChangeStuff(hum, true)
	char:SetAttribute("Attacking", false)
end)

motionevent.OnServerEvent:Connect(function(player, project, pos2)
	if not table.find(canrun, player) then return end
	project:Destroy()
	local explosion = Instance.new("Part", workspace)
	explosion.Position = pos2
	explosion.Size = Vector3.new(1,1,1)
	explosion.Transparency = 0.8
	explosion.Anchored = true
	explosion.CanCollide = false
	explosion.CanTouch = false
	explosion.CanQuery = false
	explosion.Shape = Enum.PartType.Ball
	explosion.Color = project.Color
	
	local tween = TweenService:Create(explosion, TweenInfo.new(0.2, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {Size = Vector3.new(15,15,15), Transparency = 0.3})
	tween:Play()
	explosion.Material = Enum.Material.Neon
	local attach = Instance.new("Attachment", workspace.SpawnLocation)
	attach.WorldCFrame = explosion.CFrame
	game.Debris:AddItem(attach, 1.1)
	local blasteff = game.ReplicatedStorage.vfx.misc.blast:Clone()
	blasteff.Parent = attach
	blasteff.Color = ColorSequence.new(explosion.Color)
	blasteff:Emit(blasteff:GetAttribute("EmitCount"))
	
	local box = hitbox.Create(Vector3.new(13,13,13), CFrame.new(pos2), CFrame.new())
	box:Start()
	local alreadyhit = {}
	box.Touched:Connect(function(hit, victim)
		if table.find(alreadyhit, victim) then return end
		table.insert(alreadyhit, victim)
		local animator2 = victim:FindFirstChild("Animator")
		if animator2 and not victim.Parent:GetAttribute("Blocking") and not victim.Parent:GetAttribute("SuperArmour") then
			local e = victim.Animator:LoadAnimation(game.ReplicatedStorage.Anim.hit.hitspecial)
			e:Play()
		end
		local kb = (victim.RootPart.Position - pos2).Unit * 45
		if project.Color == Color3.fromRGB(156, 0, 156) then
			if victim == player.Character.Humanoid then
				effects.dot(victim, 1, 4, "Poison")
				return end
			hithandler.hit(victim, 7, 0.3, kb, false, player.Character, nil, nil, true, nil, 90, 0.1)
			effects.dot(victim, 1, 5, "Poison")
		elseif project.Color == Color3.fromRGB(163, 163, 0) then
			if victim == player.Character.Humanoid then
				effects.slow(victim, 4, -20)
				local stm = victim.Parent:FindFirstChild("Stamina")
				if stm then stm.Value = math.min(stm.Value+2, stm:GetAttribute("Max")) end
			else
				hithandler.hit(victim, 7, 0.3, kb, false, player.Character, nil, nil, true, nil, 90, 0.1)
				effects.slow(victim, 5, 15)
			end
		elseif project.Color == Color3.fromRGB(50, 161, 35) then
			if victim == player.Character.Humanoid then
				effects.regeneration(victim, 2, 3)
			end
		end
	end)
	task.delay(0.25, function()
		local tween2 = TweenService:Create(explosion, TweenInfo.new(0.2), {Transparency = 1})
		tween2:Play()
		task.wait(0.1)
		box:Stop()
		task.wait(0.1)
		explosion:Destroy()
	end)
end)

SP3cd = {}
SP3.OnServerEvent:Connect(function(player)
	if player:GetAttribute("Class") ~= "Medic" then return end
	local char = player.Character
	local hum = char:FindFirstChild("Humanoid")
	local animator = hum.Animator
	local rootpart = hum.RootPart

	local attacking = char:GetAttribute("Attacking")
	local stun = char:GetAttribute("Stunned")
	local blocking = char:GetAttribute("Blocking")
	local ammo = char:GetAttribute("Ammo")
	local sleeping = char:GetAttribute("Sleeping")
	local changing = char:GetAttribute("Changing")
	local cooldowntime = 5
	local stop = false
	
	if attacking and changing then char:SetAttribute("Changing", false); char:SetAttribute("Attacking", false); ChangeStuff(hum, true) stop = true return end
	
	if attacking or stun or blocking or sleeping then return end
	if table.find(SP3cd, player.Name) then return end
	table.insert(SP3cd, player.Name); task.delay(cooldowntime, function() table.remove(SP3cd, table.find(SP3cd, player.Name)) end)
	ClassData.Cooldown(player, "AB3", cooldowntime)
	char:SetAttribute("Attacking", true)
	char:SetAttribute("Changing", true)
	ChangeStuff(hum)
	while task.wait(0.1) do
		if stop then break end
		if char:GetAttribute("Stunned") or char:GetAttribute("Sleeping") then
			char:SetAttribute("Changing", false); char:SetAttribute("Attacking", false)
			ChangeStuff(hum, true)
			break
		end
	end
end)