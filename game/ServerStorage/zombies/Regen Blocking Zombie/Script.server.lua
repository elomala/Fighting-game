local zombie = script.Parent
local animator = zombie:WaitForChild("Humanoid"):WaitForChild("Animator")
local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://" .. tostring(13419159375)

local track = animator:LoadAnimation(animation)
track:Play()

zombie:GetAttributeChangedSignal("Blocking"):Connect(function()
	repeat task.wait(0.25)
		local blocking = zombie:GetAttribute("Blocking")
		if blocking then break end
		if zombie:GetAttribute("Stunned") or zombie:GetAttribute("Attacking") or zombie:GetAttribute("Sleeping") then continue end
		zombie:SetAttribute("Blocking", true)
		local track = animator:LoadAnimation(animation)
		track:Play()
	until blocking
end)

local humanoid = zombie.Humanoid
local connection 
connection = humanoid.HealthChanged:Connect(function(health)
	if health <= 0 then
		connection:Disconnect()
		local newzombie = game.ServerStorage.zombies[zombie.Name]:Clone()
		newzombie.Parent = workspace.npcs.zombies
		zombie:Destroy()
	end
end)