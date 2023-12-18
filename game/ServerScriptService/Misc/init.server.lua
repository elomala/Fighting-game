local remotes = game.ReplicatedStorage:WaitForChild("remotes")
local dash = remotes:WaitForChild("dash")
local changeclass = remotes:WaitForChild("classchange")
local stamina = remotes:WaitForChild("Stamina")
local ClassData = require(game.ServerStorage.ClassData)


game.Players.PlayerAdded:Connect(function(player)
	player:SetAttribute("Class", "Kungfu")
	player.CharacterAdded:Connect(function(char)
		-- giving the player walkspeed and stuff
		local hum = char:WaitForChild("Humanoid")
		char:SetAttribute("iframes", true)
		char:SetAttribute("Attacking", true)
		local class = player:GetAttribute("Class")
		hum.WalkSpeed = ClassData.WalkSpeeds[class]
		hum.MaxHealth = ClassData.Healths[class]
		hum.Health = ClassData.Healths[class]
		
		-- giving the stamina value 
		local StaminaVal = Instance.new("NumberValue", char)
		StaminaVal.Name = "Stamina"
		StaminaVal.Value = ClassData.Staminas[class]
		StaminaVal:SetAttribute("Max", ClassData.Staminas[class])
		StaminaVal:SetAttribute("Last", 100) -- to check the last time stamina was depleted
		-- NOTE: STAMINA IS HANDLED BY THE "HEALTH" SCRIPT IN STARTERCHARACTERSCRIPTS
		
		--this class has stacks on ab1 and ab2 and different types.
		if class == "Medic" then
			char:SetAttribute("AB1stacks", 2)
			char:SetAttribute("AB2stacks", 2)
			char:SetAttribute("SP1type", 1)
			char:SetAttribute("SP2type", 1)
		end
		-- puts in the healing effect (the + which appears when a player heals)
		local rootpart = char:WaitForChild("HumanoidRootPart")
		local thing = game.ReplicatedStorage.vfx.misc.Healing:Clone()
		thing.Parent = rootpart
		
		-- puts the effect display thing in
		local effectthing = script.effects:Clone()
		effectthing.Parent = char:WaitForChild("Head")
		effectthing.PlayerToHideFrom = player
		
		task.wait(1) -- gives 1 sec for everything to load i guess
		-- sets the move names on the cooldown indicatos.
		char:SetAttribute("iframes", false)
		char:SetAttribute("Attacking", false)
		local MoveGUI = player.PlayerGui:WaitForChild("Moves"):WaitForChild("Main")
		MoveGUI.E.MoveName.Text = ClassData.MoveNames[class].AB1
		MoveGUI.R.MoveName.Text = ClassData.MoveNames[class].AB2
		MoveGUI.Z.MoveName.Text = ClassData.MoveNames[class].AB3
		MoveGUI.X.MoveName.Text = ClassData.MoveNames[class].GB
		-- multiple cooldown display for stacks.
		if class == "Medic" then
			local c1 = MoveGUI.R.CD:Clone()
			local c2 = MoveGUI.E.CD:Clone()
			c1.Name = "CD1"
			c2.Name = "CD1"
			c1.Transparency = 1
			c2.Transparency = 1
			c1.Parent = MoveGUI.R
			c2.Parent = MoveGUI.E
		end
	end)
end)

dash.OnServerEvent:Connect(function(player)
	local char = player.Character
	local attacking = char:GetAttribute("Attacking")
	local stun = char:GetAttribute("Stunned")
	local blocking = char:GetAttribute("Blocking")

	if attacking or stun or blocking then return end
	char:SetAttribute("Attacking", true)
	task.wait(0.27)
	char:SetAttribute("Attacking", false)
end)

changeclass.OnServerEvent:Connect(function(player, class)
	player:SetAttribute("Class", class)
	task.wait(0.1)
	player:LoadCharacter()
end)

stamina.OnServerEvent:Connect(function(player, action)
	local char = player.Character
	local stam = char:FindFirstChild("Stamina")
	if stam == nil then return end
	stam:SetAttribute("Last", os.time())
	if action == "Dash" then
		if stam.Value < 2 then return end
		stam.Value -= 2
	elseif action == "Jump" then
		if stam.Value < 1 then return end
		stam.Value -= 1
	elseif action == "Air Dash" then
		if stam.Value < 3 then return end
		stam.Value -= 3
	end
end)