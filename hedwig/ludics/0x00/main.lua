function love.load()
	ANIM = require 'libraries/anim8'

	love.window.setTitle("0x00 -- Initializing Love2D")
	love.graphics.setBackgroundColor(0.12, 0.15, 0.18)
	love.graphics.setDefaultFilter("nearest", "nearest")

	object = {
		x = 100,
		y = 100,
		velocity = 10,
		atlas = love.graphics.newImage('object.png'),
	}
	
	object.grid = ANIM.newGrid(12, 18, object.atlas:getWidth(), object.atlas:getHeight())
	object.animations = {
		idle = ANIM.newAnimation(object.grid('1-4', '1-4'), 0.2),
		down = ANIM.newAnimation(object.grid('1-4', 1), 0.2),
		left = ANIM.newAnimation(object.grid('1-4', 2), 0.2),
		right = ANIM.newAnimation(object.grid('1-4', 3), 0.2),
		up = ANIM.newAnimation(object.grid('1-4', 4), 0.2),
	}
	object.state = object.animations.idle
end

function love.update(dt)
	if love.keyboard.isDown("up") then
		object.y = object.y - object.velocity
		object.state = object.animations.up
	elseif love.keyboard.isDown("down") then
		object.y = object.y + object.velocity
		object.state = object.animations.down
	end

	if love.keyboard.isDown("right") then
		object.x = object.x + object.velocity
		object.state = object.animations.right
	elseif love.keyboard.isDown("left") then
		object.x = object.x - object.velocity
		object.state = object.animations.left
	end

	object.state:update(dt)

	object.x = math.max(0, math.min(object.x, love.graphics.getWidth() - object.atlas:getWidth()))
	object.y = math.max(0, math.min(object.y, love.graphics.getHeight() - object.atlas:getHeight()))
end

function love.draw()
	object.state:draw(object.atlas, object.x, object.y, nil, 7)
end

--[[Handling Keypresses]]
function love.keypressed(key, scancode, isrepeat)
	if key == "escape" then
		love.event.quit()
	end

	if key == "f" then
		fullscreen = not fullscreen
		love.window.setFullscreen(fullscreen, "exclusive")
	end
end
