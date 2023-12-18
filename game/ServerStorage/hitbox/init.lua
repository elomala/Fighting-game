local muchi = require(script.MuchachoHitbox)
local hitbox = {}

function hitbox.Create(size, position, offset)
	local box = muchi.CreateHitbox()
	box.Size = size
	box.CFrame = position
	if offset then
		box.Offset = offset
	end
	box.Visualizer = false
	box.AutoDestroy = true
	return box
end

return hitbox
