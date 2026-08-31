function love.load()
	love.window.setTitle("0x00 -- Initializing Love2D")
	love.graphics.setBackgroundColor(0.12, 0.15, 0.18)

	object = {
		sprite = love.graphics.newImage("sprite.jpg"),
		x = 0,
		y = 0
	}

	object.width = object.sprite:getWidth()
  object.height = object.sprite:getHeight()
end

function love.update(dt)
	if love.keyboard.isDown("right") then
		object.x = object.x + 500 * dt
	elseif love.keyboard.isDown("left") then
		object.x = object.x - 500 * dt
	end

	if love.keyboard.isDown("up") then
		object.y = object.y - 500 * dt
	elseif love.keyboard.isDown("down") then
		object.y = object.y + 500 * dt
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
