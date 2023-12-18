local char=script.Parent
local hum:Humanoid=char:WaitForChild("Humanoid")
local healvfx = char:WaitForChild("HumanoidRootPart"):WaitForChild("Healing")
local damaged = char:WaitForChild("Damaged")
local Misc = require(game.ServerStorage.Misc)

local healing=false

task.spawn(function()
	while task.wait(1) do
		if hum.Health>0 and hum.Health<hum.MaxHealth and healing==false then
			if os.time() - damaged.Value >= 7 then
				healing=true
				while hum.Health ~= hum.MaxHealth and healing==true and hum.Health >= 0 and os.time() - damaged.Value > 7 do
					task.wait(1)
					if hum.Health>0 then
						local healing=math.ceil(hum.MaxHealth/45)
						if hum.MaxHealth > 110 and hum.MaxHealth < 136 then healing = 4 end
						if healing>10 then healing=10 end
						if hum.Health >= hum.MaxHealth * 25/100 and hum.Health < hum.MaxHealth * 50/100 then
							healing=math.ceil(healing/1.5)
							if healing < 2 then healing = 2 end
						elseif hum.Health >= hum.MaxHealth * 50/100 and hum.Health < hum.MaxHealth * 70/100 then
							healing = math.ceil(healing/2)
						elseif hum.Health >= hum.MaxHealth * 70/100 then
							healing = 1
						end
						if hum.Health+healing>hum.MaxHealth then
							healing=hum.MaxHealth-hum.Health
						end
						hum.Health += healing
						healvfx:Emit(healvfx:GetAttribute("EmitCount"))
						task.spawn(Misc.DamageDisp, hum, healing, "Regen")
					end
				end
				healing=false
			end
		end
	end
end)

local staminathing = char:WaitForChild("Stamina")
local staminaing = false
repeat task.wait() until staminathing:GetAttribute("Last") ~= nil

task.spawn(function()
	while task.wait(1) do
		if staminathing.Value < staminathing:GetAttribute("Max") and staminaing == false then
			if os.time() - staminathing:GetAttribute("Last") > 3 then
				staminaing = true
				while staminathing.Value ~= staminathing:GetAttribute("Max") and staminaing == true and os.time() - staminathing:GetAttribute("Last") > 3  do
					local persec = if hum.Health >= hum.MaxHealth * 65/100 then 1 elseif hum.Health > hum.MaxHealth * 30/100 and hum.Health < hum.MaxHealth * 65 then 0.75 else 0.5
					staminathing.Value += persec/2
					if staminathing.Value > staminathing:GetAttribute("Max") then
						staminathing.Value = staminathing:GetAttribute("Max")
					end
					task.wait(0.625)
					staminathing.Value += persec/2
					task.wait(0.625)
				end
				staminaing = false
			end
		end
	end
end)
