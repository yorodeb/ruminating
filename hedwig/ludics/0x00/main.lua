function love.load()
	love.window.setTitle("0x00 -- Initializing Love2D")
	love.graphics.setBackgroundColor(0.12, 0.15, 0.18)

	object = {
		sprite = love.graphics.newImage("sprite.jpg"),
		x = 10,
		y = 10
	}

	object.width = object.sprite:getWidth()
  object.height = object.sprite:getHeight()
end

local fahh = love.audio.newSource("fahh.mp3", "stream")
function love.update(dt)
	object.x, object.y = love.mouse.getPosition()

	local collision = checkBoundaryCollision(object)
	if collision then
		love.audio.play(fahh)
	end

	object.x = math.max(0, math.min(object.x, love.graphics.getWidth() - object.width))
	object.y = math.max(0, math.min(object.y, love.graphics.getHeight() - object.height))
end

function love.draw()
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(object.sprite, object.x, object.y)
end

--[[
--User-Defined Functions
--(1) Closing Windows.
--(2) Boundary Collision.
--]]

function love.keypressed(key, scancode, isrepeat)
	if key == "escape" or key == "q" then
		love.event.quit()
	end

	if key == "f" then
		fullscreen = not fullscreen
		love.window.setFullscreen(fullscreen, "exclusive")
	end
end

function checkBoundaryCollision(object)
	local sceenWidth = love.graphics.getWidth()
	local screenHeight = love.graphics.getHeight()

	if object.x <= 0 then
		return true
	elseif object.x + object.width >= sceenWidth then
		return true
	end

	if object.y <= 0 then
		return true
	elseif object.y + object.height >= screenHeight then
		return true
	end
	
	return false
end
