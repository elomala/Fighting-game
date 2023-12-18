local char=script.Parent
local hum=char:WaitForChild("Humanoid")
local healvfx = char:WaitForChild("HumanoidRootPart"):WaitForChild("Healing")
local damaged = char:WaitForChild("Damaged")
local Misc = require(game.ServerStorage.Misc)

local healing=false

while task.wait(1) do
	if hum.Health>0 and hum.Health<hum.MaxHealth and healing==false then
		if os.time() - damaged.Value >= 2 then
			healing=true
			while hum.Health ~= hum.MaxHealth and healing==true and hum.Health >= 0 and os.time() - damaged.Value > 2 do
				task.wait(0.75)
				if hum.Health>0 then
					local healing = 10
					hum.Health += healing
					healvfx:Emit(healvfx:GetAttribute("EmitCount"))
					task.spawn(Misc.DamageDisp, hum, healing, "Regen")
				end
			end
			healing=false
		end
	end
end
