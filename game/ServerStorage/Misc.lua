local ClassData = require(game.ServerStorage.ClassData)
local TS = game:GetService("TweenService")
local module = {}

function module.Reset(hum:Humanoid, forstun:boolean)
	if not hum or not hum.Parent then return end
	if forstun == nil then
		while hum.Parent:GetAttribute("Stunned") or hum.Parent:GetAttribute("Sleeping") do
			task.wait()
		end
	end
	local player = game.Players:GetPlayerFromCharacter(hum.Parent)
	local mod, cripple = 0, false
	for i, v in pairs(hum.Parent:GetChildren()) do
		if v.Name == "Effect" and v:GetAttribute("Type") == "Slow" then
			mod += v.Value
		end
		if v.Name == "Effect" and v:GetAttribute("Type") == "Cripple" then
			cripple = true
		end
	end
	if player then 
		hum.WalkSpeed = ClassData.WalkSpeeds[player:GetAttribute("Class")] - mod
	else
		hum.WalkSpeed = 18 - mod
	end
	if cripple then
		hum.JumpPower = 0
		hum.JumpHeight = 0
	else
		hum.JumpPower = 50.14500427246094
		hum.JumpHeight = 7.20009183883667
	end
end

function module.DamageMod(hum:Humanoid, attacker:Model, dmg:number)
	local mod = 0
	for i, v in pairs(hum.Parent:GetChildren()) do
		if v.Name == "Effect" and v:GetAttribute("Type") == "Defence" then
			mod -= dmg * v.Value/100
		end
		if v.Name == "Effect" and v:GetAttribute("Type") == "Sleep" then
			mod -= dmg * 0.35
			v:Destroy()
			hum.Parent:SetAttribute("Sleeping", false)
			local particle = hum.RootPart:FindFirstChild("Sleep")
			if particle then particle.Enabled = false; game.Debris:AddItem(particle, 3) end
		end
	end
	for i, v in pairs(attacker:GetChildren()) do
		if v.Name == "Effect" and v:GetAttribute("Type") == "Attack" then
			mod += dmg * v.Value/100
		end
	end
	return math.round(mod)
end

function module.DamageDisp(hum:Humanoid, dmg:number, Type:string, range:number)
	local color
	if Type == "Bleed" then
		color = Color3.fromRGB(205, 0, 0)
	elseif Type == "Poison" then
		color = Color3.fromRGB(150,0,150)
	elseif Type == "Regen" then
		color = Color3.fromRGB(0, 255, 0)
	else
		color = Color3.fromRGB(255,255,255)
	end
	if color ~= Color3.fromRGB(0, 255, 0) then
		local highlight = Instance.new("Highlight")
		highlight.Parent = hum.Parent
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.FillColor = color
		highlight.FillTransparency = 1
		highlight.OutlineTransparency = 1
		game.Debris:AddItem(highlight, 0.25)
		TS:Create(highlight, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true, 0), {FillTransparency = 0.25}):Play()
	end

	local part = Instance.new("Part", workspace.misc)
	game.Debris:AddItem(part, 0.6)
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Anchored = true
	part.Transparency = 1
	part.Size = Vector3.new(.01,.01,.01)
	if not hum or not hum.Parent then return end
	part.Position = hum.RootPart.Position
	
	local text = script.Dmg:Clone()
	if range then text.MaxDistance = range end
	text.Parent = part
	text.Size = UDim2.new(0,0,0,0)
	text.StudsOffsetWorldSpace = Vector3.new(math.random(-15, 15)/7.5, math.random(-15, 15)/7.5, math.random(-15, 15)/7.5)
	local info = TweenInfo.new(0.2, Enum.EasingStyle.Bounce, Enum.EasingDirection.In, 0, false,0)
	if dmg > 0 and dmg < 8 then
		text.TextLabel.Text = tostring(dmg)
		text.TextLabel.TextColor3 = color
		TS:Create(text, info, {Size = UDim2.new(0,35,0,35)}):Play()
	elseif dmg >= 8 and dmg < 15 then
		text.TextLabel.TextColor3 = Color3.new(255,255,0)
		if color ~= Color3.fromRGB(255,255,255) then text.TextLabel.TextColor3 = color end
		text.TextLabel.Text = tostring(dmg)
		TS:Create(text, info, {Size = UDim2.new(0,40,0,40)}):Play()
	elseif dmg >= 15 and dmg < 30 then
		text.TextLabel.TextColor3 = Color3.new(255,255,0)
		if color ~= Color3.fromRGB(255,255,255) then text.TextLabel.TextColor3 = color end
		text.TextLabel.Text = tostring(dmg) .. "!"
		TS:Create(text, info, {Size = UDim2.new(0,45,0,45)}):Play()
	elseif dmg >= 30 then
		text.TextLabel.TextColor3 = Color3.new(255,0,0)
		if color ~= Color3.fromRGB(255,255,255) then text.TextLabel.TextColor3 = color end
		text.TextLabel.Text = tostring(dmg) .. "!!"
		TS:Create(text, info, {Size = UDim2.new(0,55,0,55)}):Play()
	end
	task.wait(0.3)
	TS:Create(text.TextLabel, TweenInfo.new(0.2), {TextTransparency = 1})
end

return module
