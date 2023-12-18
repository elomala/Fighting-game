local module = {}

module.WalkSpeeds = {
	Kungfu = 22,
	SwordDude = 20,
	Sheriff = 19,
	Medic = 19,
	Savage = 25
}

module.Healths = {
	Kungfu = 100,
	SwordDude = 105,
	Sheriff = 85,
	Medic = 80,
	Savage = 75
}

module.Staminas = {
	Kungfu = 10,
	SwordDude = 9,
	Sheriff = 8,
	Medic = 8,
	Savage = 12
}

module.MoveNames = {
	Kungfu = {
		GB = "Stomp",
		AB1 = "Spin Kick",
		AB2 = "Big Punch",
		AB3 = "Leg Breaker",
		Cooldowns = {10, 11, 14, 12}
	},
	SwordDude = {
		GB = "Charged Slash",
		AB1 = "Quick Jabs",
		AB2 = "Armour Pericer",
		AB3 = "Air Cutter",
		Cooldowns = {9, 11, 12, 12}
	},
	Sheriff = {
		GB = "BlastBreaker",
		AB1 = "Quickdraw Duel",
		AB2 = "Deadeye Shot",
		AB3 = "Reload Dash",
		Cooldowns = {8, 13, 13, 15}
	},
	Medic = {
		GB = "Tranquilizer Dart",
		AB1 = "Triage Ammunition",
		AB2 = "Grenade Throw",
		AB3 = "Switch",
		Cooldowns = {12, 11, 13, 3},
		Stacks = {AB1 = 2, AB2 = 2}
	},
	Savage = {
		GB = "Barbaric Sweep",
		AB1 = "Feral Strike",
		AB2 = "Serrated Slashes",
		AB3 = "Death's Embrace",
		Cooldowns = {8, 12, 13, 14}
	}
}


local TS :TweenService = game:GetService("TweenService")
local Tweens = {}
local function tweenies(GUI, move, player, cd, del)
	local size :UDim2 = UDim2.new(0.924, 0, 0.537, 0)
	local pos :UDim2 = UDim2.new(0.54, 0, 0.488, 0)
	GUI.Size = UDim2.new(0, 0, 0.537, 0)
	GUI.Position = UDim2.new(0.078, 0, 0.488, 0)
	if cd then
		if del then task.wait(del) end
		Tweens[move .. "_1" .. player.Name] = TS:Create(GUI, TweenInfo.new(cd, Enum.EasingStyle.Linear), {Size = size})
		Tweens[move .. "_1" .. player.Name]:Play()
		Tweens[move .. "_2" .. player.Name] = TS:Create(GUI, TweenInfo.new(cd, Enum.EasingStyle.Linear), {Position = pos})
		Tweens[move .. "_2" .. player.Name]:Play()
	end
end

function module.CooldownDark(player:Player, move:string)
	local MoveGUI = player.PlayerGui:WaitForChild("Moves"):WaitForChild("Main")
	if move == "AB1" then
		tweenies(MoveGUI.E.CD, move, player)
	elseif move == "AB2" then
		tweenies(MoveGUI.R.CD, move, player)
	elseif move == "AB3" then
		tweenies(MoveGUI.Z.CD, move, player)
	elseif move == "GB" then
		tweenies(MoveGUI.X.CD, move, player)
	end
end

function module.Cooldown(player:Player, move:string, cd:number, delaytime:number)
	local MoveGUI = player.PlayerGui:WaitForChild("Moves"):WaitForChild("Main")
	if move == "AB1" then
		tweenies(MoveGUI.E.CD, move, player, cd, delaytime)
	elseif move == "AB2" then
		tweenies(MoveGUI.R.CD, move, player, cd, delaytime)
	elseif move == "AB3" then
		tweenies(MoveGUI.Z.CD, move, player, cd, delaytime)
	elseif move == "GB" then
		tweenies(MoveGUI.X.CD, move, player, cd, delaytime)
	end
end

function module.CooldownReset(player:Player, move:string)
	if Tweens[move .. "_1" .. player.Name] ~= nil then
		Tweens[move .. "_1" .. player.Name]:Pause()
		Tweens[move .. "_2" .. player.Name]:Pause()
		local MoveGUI = player.PlayerGui:WaitForChild("Moves"):WaitForChild("Main")
		if move == "AB1" then
			TS:Create(MoveGUI.E.CD, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {Position = UDim2.new(0.547, 0, 0.488, 0)}):Play()
			TS:Create(MoveGUI.E.CD, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {Size = UDim2.new(0.91, 0, 0.537, 0)}):Play()
		elseif move == "AB2" then
			TS:Create(MoveGUI.R.CD, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {Position = UDim2.new(0.547, 0, 0.488, 0)}):Play()
			TS:Create(MoveGUI.R.CD, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {Size = UDim2.new(0.91, 0, 0.537, 0)}):Play()
		elseif move == "AB3" then
			TS:Create(MoveGUI.Z.CD, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {Position = UDim2.new(0.547, 0, 0.488, 0)}):Play()
			TS:Create(MoveGUI.Z.CD, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {Size = UDim2.new(0.91, 0, 0.537, 0)}):Play()
		elseif move == "GB" then
			TS:Create(MoveGUI.X.CD, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {Position = UDim2.new(0.547, 0, 0.488, 0)}):Play()
			TS:Create(MoveGUI.X.CD, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {Size = UDim2.new(0.91, 0, 0.537, 0)}):Play()
		end
	end
end

local function stacktweenies(GUI, move, player, cd, stacks)
	-- normal size and pos
	local size :UDim2 = UDim2.new(0.924, 0, 0.537, 0)
	local pos :UDim2 = UDim2.new(0.54, 0, 0.488, 0)
	-- one CD bar for first stack, second for second
	local CD1 = GUI:FindFirstChild("CD")
	local CD2 = GUI:FindFirstChild("CD1")
	-- saving class to check if text should be changed when tween ends
	local class = player:GetAttribute("Class")
	GUI.MoveName.Text = module.MoveNames[player:GetAttribute("Class")][move] .. " (" .. tostring(stacks) .. ")" -- edits text to tell how many stacks u got
	if stacks == 1 then
		CD1.Position = UDim2.new(0.078, 0, 0.488, 0) 
		CD1.Size = UDim2.new(0, 0, 0.537, 0)
		CD1.Transparency = 0
		CD2.Transparency = 1
		Tweens[move .. "_1" .. player.Name] = TS:Create(CD1, TweenInfo.new(cd, Enum.EasingStyle.Linear), {Size = size})
		Tweens[move .. "_1" .. player.Name]:Play()
		Tweens[move .. "_2" .. player.Name] = TS:Create(CD1, TweenInfo.new(cd, Enum.EasingStyle.Linear), {Position = pos})
		Tweens[move .. "_2" .. player.Name]:Play()
		Tweens[move .. "_1" .. player.Name].Completed:Connect(function()
			if CD2.Size ~= size then
				CD2.Transparency = 0
				CD1.Transparency = 1
			end
			task.wait(0.1)
			if not GUI:FindFirstChild("MoveName") then return end
			GUI.MoveName.Text = module.MoveNames[player:GetAttribute("Class")][move] .. " (" .. tostring(player.Character:GetAttribute(move .. "stacks")) .. ")"
		end)
	elseif stacks == 0 then
		if CD1.Size == size then
			if CD2.Size == size then
				CD2.Position = UDim2.new(0.078, 0, 0.488, 0)
				CD2.Size = UDim2.new(0, 0, 0.537, 0)
				Tweens[move .. "_3" .. player.Name] = TS:Create(CD2, TweenInfo.new(cd, Enum.EasingStyle.Linear), {Size = size})
				Tweens[move .. "_3" .. player.Name]:Play()
				Tweens[move .. "_4" .. player.Name] = TS:Create(CD2, TweenInfo.new(cd, Enum.EasingStyle.Linear), {Position = pos})
				Tweens[move .. "_4" .. player.Name]:Play()
			end
			CD1.Position = UDim2.new(0.078, 0, 0.488, 0)
			CD1.Size = UDim2.new(0, 0, 0.537, 0)
			Tweens[move .. "_1" .. player.Name] = TS:Create(CD1, TweenInfo.new(cd, Enum.EasingStyle.Linear), {Size = size})
			Tweens[move .. "_1" .. player.Name]:Play()
			Tweens[move .. "_2" .. player.Name] = TS:Create(CD1, TweenInfo.new(cd, Enum.EasingStyle.Linear), {Position = pos})
			Tweens[move .. "_2" .. player.Name]:Play()
			Tweens[move .. "_1" .. player.Name].Completed:Connect(function()
				if CD2.Size ~= size then
					CD1.Transparency = 1
					CD2.Transparency = 0
				end
				task.wait(0.1)
				if not GUI:FindFirstChild("MoveName") then return end
				GUI.MoveName.Text = module.MoveNames[player:GetAttribute("Class")][move] .. " (" .. tostring(player.Character:GetAttribute(move .. "stacks")) .. ")"
			end)
		else
			CD2.Position = UDim2.new(0.078, 0, 0.488, 0)
			CD2.Size = UDim2.new(0, 0, 0.537, 0)
			Tweens[move .. "_3" .. player.Name] = TS:Create(CD2, TweenInfo.new(cd, Enum.EasingStyle.Linear), {Size = size})
			Tweens[move .. "_3" .. player.Name]:Play()
			Tweens[move .. "_4" .. player.Name] = TS:Create(CD2, TweenInfo.new(cd, Enum.EasingStyle.Linear), {Position = pos})
			Tweens[move .. "_4" .. player.Name]:Play()
			Tweens[move .. "_3" .. player.Name].Completed:Connect(function()
				if CD1.Size ~= size then
					CD2.Transparency = 1
					CD1.Transparency = 0
				end
				task.wait(0.1)
				if not GUI:FindFirstChild("MoveName") then return end
				GUI.MoveName.Text = module.MoveNames[player:GetAttribute("Class")][move] .. " (" .. tostring(player.Character:GetAttribute(move .. "stacks")) .. ")"
			end)
		end
	end
end

function module.Stacks(player:Player, move:string, cd:number, stacks:number)
	local MoveGUI = player.PlayerGui:WaitForChild("Moves"):WaitForChild("Main")
	if move == "AB1" then
		stacktweenies(MoveGUI.E, move, player, cd, stacks)
	elseif move == "AB2" then
		stacktweenies(MoveGUI.R, move, player, cd, stacks)
	elseif move == "AB3" then
		stacktweenies(MoveGUI.Z, move, player, cd, stacks)
	elseif move == "GB" then
		stacktweenies(MoveGUI.X, move, player, cd, stacks)
	end
end

return module
