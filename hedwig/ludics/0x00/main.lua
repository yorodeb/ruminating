function love.load()
	love.window.setTitle("0x00 -- Initializing Love2D")

	object = {
		mode = "fill",
		x = 100,
		y = 0,
		width = 50,
		height = 50,
	}
end

function love.update()
	--TODO: (1) Bounds for traversing over the canvas.
	--(2) Better colorscheme
	--(3) Sprite and Mouse Click
	if love.keyboard.isDown("right") and object.x < 500 then
		object.x = object.x + 10
	end

	if love.keyboard.isDown("left") and object.x > 100 then
		object.x = object.x - 10
	end
end

function love.draw()
	love.graphics.rectangle(object.mode, object.x, object.y, object.width, object.height)
end
