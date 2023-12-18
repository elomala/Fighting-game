local player = game.Players.LocalPlayer
local character = player.Character

if not character or not character.Parent then
	character = player.CharacterAdded:Wait()
end

local hum = character:WaitForChild("Humanoid")
local rootpart = hum.RootPart
local frame = script:WaitForChild("Effect")

local Types = {
	Slow = Color3.fromRGB(0, 0, 180),
	Haste = Color3.fromRGB(0, 157, 255),
	Defence = Color3.fromRGB(150, 0, 0),
	Attack = Color3.fromRGB(85, 0, 0),
	Sleep = Color3.fromRGB(26, 255, 221),
	Bleed = Color3.fromRGB(205, 0, 0),
	Poison = Color3.fromRGB(150,0,150),
	Regen = Color3.fromRGB(0, 255, 0),
	Cripple = Color3.fromRGB(0,0,0)
}

character.ChildAdded:Connect(function(child)
	if child.Name == "Effect" then
		repeat task.wait() until child:GetAttribute("Type") ~= nil and child:GetAttribute("Duration") ~= nil
		if child:GetAttribute("Not_Show") == true then return end
		local effect = frame:Clone()
		effect.Parent = script.Parent
		effect.BackgroundColor3 = Types[child:GetAttribute("Type")]
		if child:IsA("IntValue") then
			if child:GetAttribute("Type") == "Slow" then
				if child:GetAttribute("Percent") < 0 then
					effect.TextLabel.Text = string.gsub(tostring(child:GetAttribute("Percent")), "-", "") .. "% Haste"
					effect.BackgroundColor3 = Types.Haste
				else 
					effect.TextLabel.Text = "-" .. tostring(child:GetAttribute("Percent")) .. "% Slow"
				end
			else
				effect.TextLabel.Text = tostring(child.Value) .. "% " .. tostring(child:GetAttribute("Type"))
			end
		elseif child:IsA("BoolValue") then
			effect.TextLabel.Text = child:GetAttribute("Type")
		end
		effect.TextLabel.Size = UDim2.new(0, effect.TextLabel.AbsoluteSize.X, 0, effect.TextLabel.AbsoluteSize.Y)
		effect:TweenSize(UDim2.new(0,0,effect.Size.Y.Scale, 0), Enum.EasingDirection.In, Enum.EasingStyle.Linear, child:GetAttribute("Duration"))
		game.Debris:AddItem(effect, child:GetAttribute("Duration"))
		while task.wait(0.2) do
			if not child or child.Parent == nil then
				effect:Destroy()
				break
			end
		end
	end
end)