local TweenService = game:GetService("TweenService")
local ClassData = require(game.ServerStorage.ClassData)
local Misc = require(game.ServerStorage.Misc)
local effect = {}

function effect.guardbreak(part:Instance, dur:number)
	local exclam = game.ReplicatedStorage:WaitForChild("vfx"):WaitForChild("misc"):WaitForChild("guardbreak"):Clone()
	exclam.Parent = part
	task.delay(dur-0.1, function()
		local Tween = TweenService:Create(exclam.ImageLabel, TweenInfo.new(0.1), {ImageTransparency = 1})
		Tween:Play()
		task.wait(0.1)
		exclam:Destroy()
	end)
	local Tween = TweenService:Create(exclam.ImageLabel, TweenInfo.new(0.1), {ImageTransparency = 0})
	Tween:Play()
	task.spawn(function()
		task.wait(0.1)
		local colorTween = TweenService:Create(exclam.ImageLabel, TweenInfo.new(dur/2.2), {ImageColor3 = Color3.fromRGB(210,210,0)})
		colorTween:Play()
		colorTween.Completed:Wait()
		local colorTween2 = TweenService:Create(exclam.ImageLabel, TweenInfo.new(dur/2.2), {ImageColor3 = Color3.fromRGB(210,0,0)})
		colorTween2:Play()
	end)
end

function effect.superarmour(char, dur)
	local highlight = Instance.new("Highlight", game.Workspace.vfx)
	highlight.Adornee = char
	highlight.FillTransparency = 0.6
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.OutlineColor = Color3.fromRGB(64, 0, 255)
	highlight.FillColor = Color3.fromRGB(64, 0, 255)
	highlight.Enabled = true
	game.Debris:AddItem(highlight,dur)
end

local Walkspeeds = ClassData.WalkSpeeds

function effect.slow(hum:Humanoid, dur:number, speed:number, notshow)
	if not hum or not hum.Parent or hum.Parent:GetAttribute("iframes") then return end
	local Effect = Instance.new("IntValue", hum.Parent)
	Effect.Name = "Effect"
	Effect:SetAttribute("Type", "Slow")
	Effect:SetAttribute("Duration", dur)
	Effect:SetAttribute("Percent", speed)
	if notshow then Effect:SetAttribute("Not_Show", true) end
	local player = game.Players:GetPlayerFromCharacter(hum.Parent)
	if player then
		Effect.Value = Walkspeeds[player:GetAttribute("Class")] * speed/100
	else
		Effect.Value = 8
	end
	hum.WalkSpeed -= Effect.Value
	game.Debris:AddItem(Effect, dur-0.1)
	task.delay(dur, Misc.Reset, hum)
	task.spawn(function()
		while task.wait(0.2) do
			if Effect.Parent == nil then
				Misc.Reset(hum)
				break
			end
		end
	end)
end

function effect.defence(hum:Humanoid, dur:number, percent:number)
	if not hum or not hum.Parent or hum.Parent:GetAttribute("iframes") then return end
	local Effect = Instance.new("IntValue", hum.Parent)
	game.Debris:AddItem(Effect, dur)
	Effect.Name = "Effect"
	Effect:SetAttribute("Type", "Defence")
	Effect:SetAttribute("Duration", dur)
	Effect.Value = percent
end

function effect.attack(hum:Humanoid, dur:number, percent:number)
	if not hum or not hum.Parent or hum.Parent:GetAttribute("iframes") then return end
	local Effect = Instance.new("IntValue", hum.Parent)
	game.Debris:AddItem(Effect, dur)
	Effect.Name = "Effect"
	Effect:SetAttribute("Type", "Attack")
	Effect:SetAttribute("Duration", dur)
	Effect.Value = percent
end

function effect.sleep(hum:Humanoid, dur:number)
	if not hum or not hum.Parent or hum.Parent:GetAttribute("SuperArmour") == true or hum.Parent:GetAttribute("iframes") then return end
	hum.Parent:SetAttribute("Sleeping", true)
	local track = hum.Animator:LoadAnimation(game.ReplicatedStorage.Anim.misc.Sleep)
	track:Play()
	local particle = game.ReplicatedStorage.vfx.misc.Sleep:Clone()
	particle.Parent = hum.RootPart
	local Effect = Instance.new("BoolValue", hum.Parent)
	game.Debris:AddItem(Effect, dur)
	Effect.Name = "Effect"
	Effect:SetAttribute("Type", "Sleep")
	Effect:SetAttribute("Duration", dur)
	Effect.Value = true
	
	hum.WalkSpeed = 0
	hum.JumpPower = 0
	hum.JumpHeight = 0
	task.delay(dur, function()
		pcall(function()
			if particle then particle.Enabled = false; game.Debris:AddItem(particle, 3) end
			track:Stop()
			hum.Parent:SetAttribute("Sleeping", false)
			Misc.Reset(hum)
		end)
	end)
end

function effect.dot(hum:Humanoid, dmgpersec:number, dur:number, Type:string)
	if hum.Parent:GetAttribute("iframes") and Type ~= "Bleed" then return end
	local Effect = Instance.new("BoolValue", hum.Parent)
	Effect.Name = "Effect"
	local vfx
	if typeof(Type == string) then
		Effect:SetAttribute("Type", Type)
	else
		Effect:SetAttribute("Type", "Bleed")
	end
	Effect:SetAttribute("Duration", dur)
	Effect.Value = dmgpersec
	if Effect:GetAttribute("Type") == "Bleed" then
		vfx = game.ReplicatedStorage.vfx.hit.slash.Blood:Clone()
		vfx.Parent = hum.RootPart
		game.Debris:AddItem(vfx, dur+0.2)
	end
	
	game.Debris:AddItem(Effect, dur+0.2)
	for i = 1, dur, 1 do
		if not Effect.Parent or not hum.Parent then break end
		if vfx then vfx:Emit(vfx:GetAttribute("EmitCount")) end
		hum:TakeDamage(dmgpersec)
		task.spawn(Misc.DamageDisp, hum, dmgpersec, Effect:GetAttribute("Type"))
		if not hum.Parent or not hum then break end
		local damaged = hum.Parent:FindFirstChild("Damaged")
		if damaged then
			damaged.Value = os.time()
		end
		task.wait(1)
	end
end

function effect.regeneration(hum:Humanoid, regenpersec:number, dur:number)
	if hum.Parent:GetAttribute("iframes") then return end
	local Effect = Instance.new("BoolValue", hum.Parent)
	Effect.Name = "Effect"
	Effect:SetAttribute("Type", "Regen")
	Effect:SetAttribute("Duration", dur)
	Effect.Value = regenpersec
	game.Debris:AddItem(Effect, dur+0.2)
	local vfx = hum.RootPart:FindFirstChild("Healing")
	for i = 1, dur, 1 do
		if Effect.Parent == nil then break end
		if vfx then vfx:Emit(vfx:GetAttribute("EmitCount")) end
		hum.Health += regenpersec
		task.spawn(Misc.DamageDisp, hum, regenpersec, Effect:GetAttribute("Type"))
		if hum.Health > hum.MaxHealth then
			hum.Health = hum.MaxHealth
		end
		task.wait(1)
	end
end

function effect.cripple(hum:Humanoid, dur:number)
	if not hum or not hum.Parent then return end
	if hum.Parent:GetAttribute("iframes") then return end
	local Effect = Instance.new("BoolValue", hum.Parent)
	Effect.Name = "Effect"
	Effect:SetAttribute("Type", "Cripple")
	Effect:SetAttribute("Duration", dur)
	
	game.Debris:AddItem(Effect, dur)
	
	hum.JumpPower = 0
	hum.JumpHeight = 0
	task.delay(dur, Misc.Reset, hum)
	while task.wait(0.2) do
		if Effect.Parent == nil then
			Misc.Reset(hum)
			break
		end
	end
end

return effect
