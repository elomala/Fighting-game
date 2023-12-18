local zombie = script.Parent
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