local remote = game.ReplicatedStorage:WaitForChild("remotes"):WaitForChild("block")

local function StopAnim(humanoid, animation)
	for i, v in pairs(humanoid:GetPlayingAnimationTracks()) do
		if v.Name == animation then
			v:Stop()
		end
	end
end

local Walkspeeds = require(game.ServerStorage.ClassData).WalkSpeeds

remote.OnServerEvent:Connect(function(plr, block)
	local char = plr.Character
	local hum = char:WaitForChild("Humanoid")
	local animator = hum:WaitForChild("Animator")
	
	if char:GetAttribute("Attacking") or char:GetAttribute("Stunned") or char:GetAttribute("SuperArmour") or char:GetAttribute("Sleeping") then return end
	
	if block then
		hum.WalkSpeed = 2
		hum.JumpPower = 0
		hum.JumpHeight = 0
		hum.Parent:SetAttribute("Blocking", true)
		local blockinganim = game.ReplicatedStorage.Anim[plr:GetAttribute("Class")].Blocking
		if blockinganim then
			local track = animator:LoadAnimation(blockinganim)
			track:Play()
		end
	else
		while char:GetAttribute("Stunned") == true do
			task.wait()
		end
		local player = game.Players:GetPlayerFromCharacter(hum.Parent)
		local mod = 0
		for i, v in pairs(hum.Parent:GetChildren()) do
			if v.Name == "Effect" and v:GetAttribute("Type") == "Slow" then
				mod += v.Value
			end
		end
		if player then 
			hum.WalkSpeed = Walkspeeds[player:GetAttribute("Class")] - mod
		else
			hum.WalkSpeed = 18 - mod
		end
		hum.JumpPower = 50.14500427246094
		hum.JumpHeight = 7.20009183883667
		char:SetAttribute("Blocking", nil)
		StopAnim(hum, "Blocking")

	end
end)