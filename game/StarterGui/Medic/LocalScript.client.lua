local player = game.Players.LocalPlayer
local gui = script.Parent
local gren = gui.Gren
local ammo = gui.Ammo
local connections = {}

repeat task.wait() until player:GetAttribute("Class")
if player:GetAttribute("Class") == "Medic" then gui.Enabled = true else gui.Enabled = false end
player:GetAttributeChangedSignal("Class"):Connect(function()
	if player:GetAttribute("Class") == "Medic" then gui.Enabled = true
	else gui.Enabled = false end
end)

local cripple = '<mark><font color="rgb(0,0,0)">CRIPPLING AMMO</font></mark>'
local shatter = '<mark><font color="rgb(255, 63, 5)">SHATTER DART</font></mark>'
local regen = '<mark><font color="rgb(100, 255, 92)">HEALING DART</font></mark>'
local toxic = '<mark><font color="rgb(156, 0, 156)">TOXIC VIAL</font></mark>'
local adrenaline = '<mark><font color="rgb(255, 255, 0)">ADRENALINE BOMB</font></mark>'
local healing = '<mark><font color="rgb(100, 255, 92)">MEDI-GRENADE</font></mark>'

local chara = player.Character
if not chara or not chara.Parent then
	player.CharacterAdded:Wait()
end
local grentype = if chara:GetAttribute("SP2type") == 1 then toxic
	elseif chara:GetAttribute("SP2type") == 2 then adrenaline
	elseif chara:GetAttribute("SP2type") == 3 then healing
	else toxic

local ammotype = if chara:GetAttribute("SP1type") == 1 then cripple
	elseif chara:GetAttribute("SP1type") == 2 then shatter
	elseif chara:GetAttribute("SP1type") == 3 then regen
	else cripple

gren.Text = "GRENADE TYPE: " .. grentype
ammo.Text = "AMMO TYPE: " .. ammotype
connections[player.Name .. "Gren"] = chara:GetAttributeChangedSignal("SP2type"):Connect(function()
	local grentype = if chara:GetAttribute("SP2type") == 1 then toxic
		elseif chara:GetAttribute("SP2type") == 2 then adrenaline
		elseif chara:GetAttribute("SP2type") == 3 then healing
		else toxic
	gren.Text = "GRENADE TYPE: " .. grentype
end)

connections[player.Name .. "Ammo"] = chara:GetAttributeChangedSignal("SP1type"):Connect(function()
	local ammotype = if chara:GetAttribute("SP1type") == 1 then cripple
		elseif chara:GetAttribute("SP1type") == 2 then shatter
		elseif chara:GetAttribute("SP1type") == 3 then regen
		else cripple
	ammo.Text = "AMMO TYPE: " .. ammotype
end)

player.CharacterAdded:Connect(function(char)
	local hum = char:WaitForChild("Hum")
	repeat task.wait()
	until char:GetAttribute("SP1type") and char:GetAttribute("SP2type")
	
	for i, v in pairs(connections) do
		v:Disconnect()
		connections[i] = nil
	end
	
	local grentype = if char:GetAttribute("SP2type") == 1 then toxic
		elseif char:GetAttribute("SP2type") == 2 then adrenaline
		elseif char:GetAttribute("SP2type") == 3 then healing
		else toxic

	local ammotype = if char:GetAttribute("SP1type") == 1 then cripple
		elseif char:GetAttribute("SP1type") == 2 then shatter
		elseif char:GetAttribute("SP1type") == 3 then regen
		else cripple

	gren.Text = "GRENADE TYPE: " .. grentype
	ammo.Text = "AMMO TYPE: " .. ammotype
	connections[player.Name] = char:GetAttributeChangedSignal("SP2type"):Connect(function()
		local grentype = if char:GetAttribute("SP2type") == 1 then toxic
			elseif char:GetAttribute("SP2type") == 2 then adrenaline
			elseif char:GetAttribute("SP2type") == 3 then healing
			else toxic
		gren.Text = "GRENADE TYPE: " .. grentype
	end)
	connections[player.Name .. "Ammo"] = chara:GetAttributeChangedSignal("SP1type"):Connect(function()
		local ammotype = if chara:GetAttribute("SP1type") == 1 then cripple
			elseif chara:GetAttribute("SP1type") == 2 then shatter
			elseif chara:GetAttribute("SP1type") == 3 then regen
			else cripple
		ammo.Text = "AMMO TYPE: " .. ammotype
	end)

end)