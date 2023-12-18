local main = script.Parent
local open = main.Parent:WaitForChild("TextButton")
local Displays = main:GetChildren()
local close = main:WaitForChild("Close")
local ClassInfo = require(game.ReplicatedStorage:WaitForChild("MoveInfo"))
local player = game.Players.LocalPlayer
repeat task.wait() until player:GetAttribute("Class") ~= nil
local class = player:GetAttribute("Class")

open.MouseButton1Click:Connect(function()
	if main.Visible == false then
		main.Visible = true
	else
		main.Visible = false
	end
end)

for i, v in pairs(Displays) do
	if not v:FindFirstChild("Name") then continue end
	local info = ClassInfo[v.Name][class]
	if info == nil then print("failed to load info") continue end
	v:FindFirstChild("Name").Text = info.Name
	v.Desc.Text = info.Desc
	v.Effects.Text = info.Effects
end

close.MouseButton1Click:Connect(function()
	main.Visible = false
end)