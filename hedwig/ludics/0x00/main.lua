function love.load()
	love.window.setTitle("0x00 -- Initializing Love2D")
	love.graphics.setBackgroundColor(0.12, 0.15, 0.18)
	--TODO:Adding Spritesheet!
end

function love.update(dt)
	--TODO:Motion for Spritesheet!
end

function love.draw()
	--TODO:Drawing Spritesheet!
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
