-- Credits to ApprenticeOfMadara

--[[
	Very simple to use stun module:
	Simply send a humanoid object and the amount of seconds you want the stun to last for to the function
	
	Example:
		local StunHandler = require(path.to.module)
		
		StunHandler.Stun(humanoid, 5)	-->>	stuns for 5 seconds
		
	The function saves the current speed and jump power of the humanoid before setting them to 0
	Once the specified duration passes, it will reset the speed and jump power back to what was stored
	
	If the function tries to stun an already stunned humanoid, it will compare the duration sent with the time left
	from the previous stun
	If there is less time left, the stun duration will update to the new one
	
	An attribute with the name "Stunned" is added to the humanoid's parent (character) and set to true whilst
	the humanoid is stunned
	It is set to false again once the stun wears off
	
	Note: The function does not yield whilst the humanoid has been stunned
]]

--//Private variables & functions
local heartbeat = game:GetService("RunService").Heartbeat
local ClassData = require(game.ServerStorage.ClassData)
local Misc = require(game.ServerStorage.Misc)

local Stunned = {}

local clock = os.clock
local isChecking = false
local checkConnection
local currentTime
local stunnedHumanoids

local Walkspeeds = ClassData.WalkSpeeds

local function stunChecker()
	currentTime = clock()
	stunnedHumanoids = 0

	for humanoid, data in pairs(Stunned) do
		if not data.stunned then continue end

		if currentTime >= data.duration then
			data.stunned = false

			data.changedConn:Disconnect()
			data.changedConn = nil

			if humanoid:IsDescendantOf(workspace) then
				Misc.Reset(humanoid, true)
				humanoid.Parent:SetAttribute("Stunned", false)
			end
		end

		stunnedHumanoids += 1
		-- print(string.format("waiting: %f", data.duration - currentTime))
	end

	if stunnedHumanoids == 0 then
		checkConnection:Disconnect()
		isChecking = false
	end
end


--//Stun Handler
return {Stun = function (humanoid, duration)
	if humanoid.Health <= 0 or duration == 0 then return end

	if not Stunned[humanoid] then
		Stunned[humanoid] = {}
	end

	local data = Stunned[humanoid]
	currentTime = clock()

	if not data.stunned then -- not stunned
		data.stunned = true
		data.duration = currentTime + duration
		data.speed = humanoid.WalkSpeed
		data.jumpPower = humanoid.JumpPower
		data.jumpHeight = humanoid.JumpHeight

		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
		humanoid.JumpHeight = 0

		humanoid.Parent:SetAttribute("Stunned", true)

	elseif data.duration - currentTime < duration then -- update duration if less time left
		data.duration = currentTime + duration
	end

	if not data.changedConn then
		data.changedConn = humanoid.Changed:Connect(function()
			humanoid.WalkSpeed = 0
			humanoid.JumpPower = 0
			humanoid.JumpHeight = 0
		end)
	end

	if not data.diedConn then
		data.diedConn = humanoid.AncestryChanged:Connect(function()
			data.diedConn:Disconnect()

			if data.changedConn then data.changedConn:Disconnect() end

			Stunned[humanoid] = nil
		end)
	end

	if not isChecking then
		isChecking = true
		checkConnection = heartbeat:Connect(stunChecker)
	end
end}
