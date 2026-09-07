local position = nil
local lastx, lasty = nil

function love.load()
	love.window.setTitle("0x01 -- Getting Motion Captured")
	love.graphics.setBackgroundColor(0.12, 0.15, 0.18)
	object = {
		mode = "fill",
		width = 100,
		height = 100,
		color = {1,1,1},
		x = 100,
		y = 200,
	}
end

function love.update(dt)
	if love.keyboard.isDown("up") then
		object.y = object.y - 1000 * dt
	elseif love.keyboard.isDown("down") then
		object.y = object.y + 1000 * dt
	end

	if love.keyboard.isDown("right") then
		object.x = object.x + 1000 * dt
	elseif love.keyboard.isDown("left") then
		object.x = object.x - 1000 * dt
	end

	object.x = math.max(0, math.min(object.x, love.graphics.getWidth() - object.width))
	object.y = math.max(0, math.min(object.y, love.graphics.getHeight() - object.height))

	if boundingCheck(object) and love.mouse.isDown(1) then
		object.color = {math.random(), math.random(), math.random()}
	end

	position = string.format("x: %.2f, y: %.2f\n", object.x, object.y)
	if object.x ~= lastx or object.y ~= lasty then
		logger("position_logs", position)
		lastx, lasty = object.x, object.y
	end
end

function love.draw()
	love.graphics.setColor(object.color)
	love.graphics.rectangle(object.mode, object.x, object.y, object.width, object.height)

	love.graphics.setColor(1,1,1)
	love.graphics.print(position, 10, 10)
end

function love.keypressed(key, scancode, isrepeat)
	if key == "escape" then
		love.event.quit()
	end

	if key == "f" then
		fullscreen = not fullscreen
		love.window.setFullscreen(fullscreen, "exclusive")
	end
end

--[[Logging Object's Position]]
function logger(filename, position)
	local fileptr, err = io.open(filename .. ".txt", "a+")

	if err then
		io.write("Logging-Error\n")
		return
	end

	fileptr:write(position)
	fileptr:close()
end

--[[Bounding Approach for Mouse-Event]]
function boundingCheck(object)
	local x,y = love.mouse.getPosition()

	local checkForX = x >= object.x and x <= object.x + object.width
	local checkForY = y >= object.y and y <= object.y + object.height

	if checkForX and checkForY then
		return true
	else
		return false
	end
end

