local stunhandler = require(script.StunHandler)
local Misc = require(script.Parent.Misc)
local dash = game.ReplicatedStorage:WaitForChild("remotes"):WaitForChild("dash")
local module = {}

local function StopAnim(humanoid:Humanoid, animationName:StringValue)
	if humanoid.Parent:GetAttribute("SuperArmour") then return end
	local animator = if humanoid:FindFirstChild("Animator") then humanoid:FindFirstChild("Animator") else humanoid
	if animationName then
		for i, v in pairs(animator:GetPlayingAnimationTracks()) do
			if v.Name == animationName then
				v:Stop()
			end
		end
	else
		for i, v in pairs(animator:GetPlayingAnimationTracks()) do
			if v.Name == "hit1" or v.Name == "hit2" or v.Name == "BlockBreak" or v.Name == "hitspecial" or v.Name == "SP1_stance" or v.Name == "Svg_sp2hit" then continue end
			v:Stop()
		end
	end
end

local function hitvfx(rootpart, blocking, types)
	local attach = Instance.new("Attachment", rootpart)
	if blocking then
		local clone = game.ReplicatedStorage.vfx.hit.punch.circle:Clone()
		clone.Parent = attach
		clone:Emit(clone:GetAttribute("EmitCount"))
		game.Debris:AddItem(attach,0.5)
	else
		if not types then
			for i, v in pairs(game.ReplicatedStorage.vfx.hit.punch:GetChildren()) do
				local clone = v:Clone()
				clone.Parent = attach
				clone:Emit(v:GetAttribute("EmitCount"))
				game.Debris:AddItem(attach, 0.5)
			end
		elseif types == "Slash" then
			for i, v in pairs(game.ReplicatedStorage.vfx.hit.slash:GetChildren()) do
				local clone = v:Clone()
				clone.Parent = attach
				clone:Emit(v:GetAttribute("EmitCount"))
				game.Debris:AddItem(attach, 0.5)
			end
		end
	end
end

function module.hit(hum:Humanoid, dmg:number, dur:number, kb:Vector3, gb:boolean, charac:Model, passthrough:boolean, hittype:string, blockanywhere:boolean, ignoreiframe:boolean, dmgviewrange:number, blockstun:number)
	if not hum or not hum.Parent then return end
	if hum.Parent:GetAttribute("iframes") and not ignoreiframe then return end
	local blocking = hum.Parent:GetAttribute("Blocking")
	local broken = false
	local rootpart = hum.RootPart
	local attackerrootpart = charac.HumanoidRootPart
	local back = false
	if charac then
		if charac:GetAttribute("Stunned") and not charac:GetAttribute("SuperArmour") then return end
	end
	if not gb then
		if blockanywhere then
			hitvfx(rootpart, true)
			if blocking and not passthrough then
				if hum.Health > hum.MaxHealth/3 then
					local mod = Misc.DamageMod(hum, charac, dmg)
					dmg += mod
					local dm2 = math.round(dmg/5)
					dm2 = dm2 < 1 and 1 or dm2
					hum:TakeDamage(dm2) 
				end
				local damaged = hum.Parent:FindFirstChild("Damaged")
				if damaged then
					damaged.Value = os.time()
				end
				if blockstun ~= nil then
					stunhandler.Stun(hum, blockstun)
					local bar = game.ReplicatedStorage:WaitForChild("vfx"):WaitForChild("misc"):WaitForChild("stunbar"):Clone()
					game.Debris:AddItem(bar, blockstun)
					bar.Parent = hum.Parent.Head
					bar.Frame:TweenSize(UDim2.new(0, 0, 1, 0), Enum.EasingDirection.In, Enum.EasingStyle.Linear, blockstun, false)
					bar.Frame:TweenPosition(UDim2.new(0.5, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Linear, blockstun, false)
				end
				return true
			end
		else
			local Front, Behind	= rootpart.CFrame * CFrame.new(0, 0, -1), rootpart.CFrame * CFrame.new(0, 0, 1.5)
			if (attackerrootpart.Position - Front.Position).Magnitude > (attackerrootpart.Position - Behind.Position).Magnitude then
				back = true
			else
				hitvfx(rootpart, true)
				if blocking and not passthrough then
					if hum.Health > hum.MaxHealth/3 then
						local mod = Misc.DamageMod(hum, charac, dmg)
						dmg += mod
						
						local dm2 = math.round(dmg/5)
						dm2 = dm2 < 1 and 1 or dm2
						hum:TakeDamage(dm2) 
					end
					local damaged = hum.Parent:FindFirstChild("Damaged")
					if damaged then
						damaged.Value = os.time()
					end
					if blockstun ~= nil then
						stunhandler.Stun(hum, blockstun)
						local bar = game.ReplicatedStorage:WaitForChild("vfx"):WaitForChild("misc"):WaitForChild("stunbar"):Clone()
						game.Debris:AddItem(bar, blockstun)
						bar.Parent = hum.Parent.Head
						bar.Frame:TweenSize(UDim2.new(0, 0, 1, 0), Enum.EasingDirection.In, Enum.EasingStyle.Linear, blockstun, false)
						bar.Frame:TweenPosition(UDim2.new(0.5, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Linear, blockstun, false)
					end
					return true
				end
			end
		end
	else
		if blocking then
			broken = true
			StopAnim(hum, "Blocking")
			hum.Parent:SetAttribute("Blocking", false)
			local track = hum.Animator:LoadAnimation(game.ReplicatedStorage.Anim.block.BlockBreak)
			track:Play()
			task.delay(2, function()
				track:Stop()
			end)
			local bar = game.ReplicatedStorage:WaitForChild("vfx"):WaitForChild("misc"):WaitForChild("stunbar"):Clone()
			bar.Frame.BackgroundColor3 = Color3.fromRGB(255,0,0)
			game.Debris:AddItem(bar, 2)
			bar.Parent = hum.Parent.Head
			bar.Frame:TweenSize(UDim2.new(0, 0, 1, 0), Enum.EasingDirection.In, Enum.EasingStyle.Linear, 2, false)
			bar.Frame:TweenPosition(UDim2.new(0.5, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Linear, 2, false)
			stunhandler.Stun(hum, 2)
			
			local highlight = Instance.new("Highlight", game.Workspace.vfx)
			highlight.Adornee = hum.Parent
			highlight.FillTransparency = 0.6
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.OutlineColor = Color3.fromRGB(255,0,0)
			highlight.Enabled = true
			
			game.Debris:AddItem(highlight, 2)
		end
	end
	
	if broken then dmg = dmg * 1.15 end
	local mod = Misc.DamageMod(hum, charac, dmg)
	dmg += mod
	if passthrough or back then 
		StopAnim(hum, "Blocking")
		hum.Parent:SetAttribute("Blocking", false)
	end
	StopAnim(hum)
	hum:TakeDamage(math.ceil(dmg))
	task.spawn(Misc.DamageDisp, hum, math.ceil(dmg), nil, dmgviewrange)
	if hum.Parent then
		local damaged = hum.Parent:FindFirstChild("Damaged")
		if damaged then
			damaged.Value = os.time()
		end
	end
	if not broken and hum.Parent then 
		local bar = game.ReplicatedStorage:WaitForChild("vfx"):WaitForChild("misc"):WaitForChild("stunbar"):Clone()
		game.Debris:AddItem(bar, dur)
		bar.Parent = hum.Parent.Head
		bar.Frame:TweenSize(UDim2.new(0, 0, 1, 0), Enum.EasingDirection.In, Enum.EasingStyle.Linear, dur, false)
		bar.Frame:TweenPosition(UDim2.new(0.5, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Linear, dur, false)
	end
	if not hum.Parent or not hum then return end
	if not hum.Parent:GetAttribute("SuperArmour") then
		stunhandler.Stun(hum, dur)
	end
	hitvfx(rootpart, nil, hittype)
	
	if not hum or not hum.Parent then return end
	if kb and not broken and not hum.Parent:GetAttribute("SuperArmour") then
		local player = game.Players:GetPlayerFromCharacter(hum.Parent)
		if player then
			dash:FireClient(game.Players:GetPlayerFromCharacter(hum.Parent), kb, 0.1, charac.HumanoidRootPart)
		else
			local attachment = Instance.new("Attachment", rootpart)
			local LV = Instance.new("LinearVelocity", attachment)
			LV.Attachment0 = attachment
			LV.MaxForce = rootpart.AssemblyMass * 5000
			LV.VectorVelocity = kb
			game.Debris:AddItem(attachment, 0.1)
		end
	end
end

return module
