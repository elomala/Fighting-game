local ContentProvider = game:GetService("ContentProvider")
local Assets = {}
task.wait(1)
for i, v in pairs(game.ReplicatedStorage:WaitForChild("Anim"):GetDescendants()) do
	if v:IsA("Animation") then
		table.insert(Assets, v)
	end
end
for i, v in pairs(game.ReplicatedStorage:WaitForChild("vfx"):GetDescendants()) do
	if v:IsA("Folder") then continue end
	table.insert(Assets, v)
end

ContentProvider:PreloadAsync(Assets)