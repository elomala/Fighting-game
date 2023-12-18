local TS = game:GetService("TweenService")
local main = script.Parent
local namedisp = main.plr
local pictureframe = main:WaitForChild("Thing")
local label = pictureframe.ImageLabel

local player = game.Players.LocalPlayer

-- inserting name
namedisp.Text = player.Name

-- inserting profile pic
local userId = player.UserId
local thumbType = Enum.ThumbnailType.HeadShot
local thumbSize = Enum.ThumbnailSize.Size420x420
local content, isReady = game.Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
label.Image = content


-- waits until a class is given to the player
repeat task.wait() until player:GetAttribute("Class") ~= nil
task.wait()

local char = player.Character
if not char or not char.Parent then player.CharacterAdded:Wait() end
local hum = char:FindFirstChildOfClass("Humanoid")

-- setting health
local Healthbar = main.Health.Bar
local HealthNumber = main.Health.TextLabel
local normsize = UDim2.new(0.983,0 ,0.6, 0)

HealthNumber.Text = tostring(hum.Health) .. "/" .. tostring(hum.MaxHealth)
local healthtween = nil
hum.HealthChanged:Connect(function()
	if healthtween ~= nil then if healthtween.PlaybackState == Enum.PlaybackState.Playing then healthtween:Cancel() end end
	HealthNumber.Text = tostring(hum.Health) .. "/" .. tostring(hum.MaxHealth)
	local percentage =	hum.Health/hum.MaxHealth
	healthtween = TS:Create(Healthbar, TweenInfo.new(0.3, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {Size = UDim2.new(normsize.X.Scale * percentage, 0, normsize.Y.Scale, 0)})
	healthtween:Play()
end)

-- setting stamina
local Staminabar = main.Stamina.Bar
local StaminaNumber = main.Stamina.TextLabel
local staminaValue = char:WaitForChild("Stamina")
local normalsize = UDim2.new(0.983,0 ,0.6, 0)

StaminaNumber.Text = tostring(staminaValue.Value) .. "/" .. tostring(staminaValue:GetAttribute("Max"))
local currenttween = nil
staminaValue.Changed:Connect(function()
	if currenttween ~= nil then if currenttween.PlaybackState == Enum.PlaybackState.Playing then currenttween:Cancel() end end
	StaminaNumber.Text = tostring(staminaValue.Value) .. "/" .. tostring(staminaValue:GetAttribute("Max"))
	local percentage = staminaValue.Value / staminaValue:GetAttribute("Max")
	currenttween = TS:Create(Staminabar, TweenInfo.new(0.3, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {Size = UDim2.new(normalsize.X.Scale * percentage, 0, normalsize.Y.Scale, 0)})
	currenttween:Play()
end)
