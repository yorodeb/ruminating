function love.load()
    love.window.setMode(640, 480)
    love.window.setTitle("0x02 -- Snaking")
    
    CELL_SIZE = 20
    GRID_WIDTH = 32
    GRID_HEIGHT = 24
    
    COLOR_BG = {0.2, 0.2, 0.2}
    COLOR_SNAKE = {0.2, 0.8, 0.2}
    COLOR_FOOD = {0.9, 0.2, 0.2}
    
    snake = {
        {x = 10, y = 12},
        {x = 9, y = 12},
        {x = 8, y = 12}
    }
    
    direction = 1
    moveTimer = 0
    moveDelay = 0.15
    
    score = 0
    gameOver = false
    
    font = love.graphics.newFont(24)
    love.graphics.setFont(font)
    
    highScore = 0
    if love.filesystem.getInfo("highscore.txt") then
        highScore = tonumber(love.filesystem.read("highscore.txt")) or 0
    end
    
    function placeFood()
        local validPosition = false
        local fx, fy
        while not validPosition do
            fx = love.math.random(1, GRID_WIDTH)
            fy = love.math.random(1, GRID_HEIGHT)
            validPosition = true
            for _, segment in ipairs(snake) do
                if segment.x == fx and segment.y == fy then
                    validPosition = false
                    break
                end
            end
        end
        return {x = fx, y = fy}
    end
    
    food = placeFood()
end

function love.update(dt)
    if gameOver then return end
    
    moveDelay = math.max(0.05, 0.15 - (#snake - 3) * 0.01)
    moveTimer = moveTimer + dt
    
    if moveTimer >= moveDelay then
        moveTimer = 0
        
        local head = {x = snake[1].x, y = snake[1].y}
        
        if direction == 1 then head.x = head.x + 1
        elseif direction == 2 then head.y = head.y + 1
        elseif direction == 3 then head.x = head.x - 1
        elseif direction == 4 then head.y = head.y - 1
        end
        
        if head.x < 1 or head.x > GRID_WIDTH or 
           head.y < 1 or head.y > GRID_HEIGHT then
            gameOver = true
            if score > highScore then
                highScore = score
                love.filesystem.write("highscore.txt", tostring(highScore))
            end
            return
        end
        
        for _, segment in ipairs(snake) do
            if head.x == segment.x and head.y == segment.y then
                gameOver = true
                if score > highScore then
                    highScore = score
                    love.filesystem.write("highscore.txt", tostring(highScore))
                end
                return
            end
        end
        
        table.insert(snake, 1, head)
        
        if head.x == food.x and head.y == food.y then
            food = placeFood()
            score = score + 10
        else
            table.remove(snake)
        end
    end
end

function love.keypressed(key)
    if key == "right" and direction ~= 3 then direction = 1
    elseif key == "down" and direction ~= 4 then direction = 2
    elseif key == "left" and direction ~= 1 then direction = 3
    elseif key == "up" and direction ~= 2 then direction = 4
    elseif key == "r" and gameOver then
        snake = {{x = 10, y = 12}, {x = 9, y = 12}, {x = 8, y = 12}}
        direction = 1
        food = placeFood()
        gameOver = false
        moveTimer = 0
        score = 0
    end
		if key == "escape" then
			love.event.quit()
		end

		if key == "f" then
			fullscreen = not fullscreen
			love.window.setFullscreen(fullscreen, "exclusive")
		end
end

function love.draw()
    love.graphics.setBackgroundColor(COLOR_BG)
    
    love.graphics.setColor(COLOR_SNAKE)
    for _, segment in ipairs(snake) do
        love.graphics.rectangle("fill",
            (segment.x - 1) * CELL_SIZE,
            (segment.y - 1) * CELL_SIZE,
            CELL_SIZE - 1, CELL_SIZE - 1)
    end
    
    love.graphics.setColor(COLOR_FOOD)
    love.graphics.rectangle("fill",
        (food.x - 1) * CELL_SIZE,
        (food.y - 1) * CELL_SIZE,
        CELL_SIZE - 1, CELL_SIZE - 1)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. score, 10, 10)
    love.graphics.print("High Score: " .. highScore, 10, 40)
    
    if gameOver then
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf("GAME OVER\nPress R to restart",
            0, 200, love.graphics.getWidth(), "center")
    end
end
