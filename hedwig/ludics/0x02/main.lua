function love.load()
    love.window.setMode(640, 480)
    love.window.setTitle("0x02 -- Snaking")
    
    CELL_SIZE = 20
    GRID_WIDTH = 32
    GRID_HEIGHT = 24
    
    -- Gorgeous color palette
    COLOR_BG = {0.12, 0.15, 0.18}
    COLOR_BG_DARK = {0.08, 0.10, 0.12}
    COLOR_GRID = {0.18, 0.22, 0.26}
    
    -- Snake gradient colors (head to tail)
    COLOR_SNAKE_HEAD = {0.4, 0.9, 0.4}
    COLOR_SNAKE_BODY = {0.3, 0.75, 0.3}
    COLOR_SNAKE_TAIL = {0.2, 0.55, 0.2}
    COLOR_SNAKE_OUTLINE = {0.15, 0.4, 0.15}
    
    -- Food colors (glowing apple)
    COLOR_FOOD_CORE = {1.0, 0.3, 0.3}
    COLOR_FOOD_GLOW = {1.0, 0.15, 0.15}
    COLOR_FOOD_STEM = {0.4, 0.25, 0.1}
    
    -- Eye colors
    COLOR_EYE_WHITE = {0.95, 0.95, 0.95}
    COLOR_EYE_PUPIL = {0.1, 0.1, 0.1}
    
    -- Tongue colors
    COLOR_TONGUE = {0.9, 0.3, 0.4}
    COLOR_TONGUE_TIP = {0.95, 0.15, 0.25}
    
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
    
    -- Animation timers
    tongueTimer = 0
    tongueExtended = false
    pulseTimer = 0
    
    -- Particles for eating food
    particles = {}
    
    font = love.graphics.newFont(24)
    if not font then
        font = love.graphics.newFont(24)
    end
    love.graphics.setFont(font)
    
    highScore = 0
    if love.filesystem.getInfo("highscore.txt") then
        highScore = tonumber(love.filesystem.read("highscore.txt")) or 0
    end
    
    fullscreen = false
    
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
        return {x = fx, y = fy, pulseOffset = love.math.random() * 6.28}
    end
    
    food = placeFood()
end

function love.update(dt)
    if gameOver then return end
    
    -- Update animations
    tongueTimer = tongueTimer + dt
    pulseTimer = pulseTimer + dt
    
    -- Tongue flicks every 0.4-0.8 seconds
    if tongueTimer > 0.4 then
        tongueExtended = not tongueExtended
        tongueTimer = 0
        if tongueExtended then
            -- Quick retract
            love.timer.sleep(0.05)
            tongueExtended = false
        end
    end
    
    -- Update particles
    for i = #particles, 1, -1 do
        local p = particles[i]
        p.life = p.life - dt
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        if p.life <= 0 then
            table.remove(particles, i)
        end
    end
    
    moveDelay = math.max(0.05, 0.15 - (#snake - 3) * 0.005)
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
            -- Spawn particles
            for _ = 1, 12 do
                table.insert(particles, {
                    x = (food.x - 0.5) * CELL_SIZE,
                    y = (food.y - 0.5) * CELL_SIZE,
                    vx = love.math.random(-80, 80),
                    vy = love.math.random(-80, 80),
                    life = 0.4,
                    color = {love.math.random(0.8, 1), love.math.random(0.2, 0.5), love.math.random(0.2, 0.4)},
                    size = love.math.random(3, 6)
                })
            end
            
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
        particles = {}
    end
    if key == "escape" then
        love.event.quit()
    end
    if key == "f" then
        fullscreen = not fullscreen
        love.window.setFullscreen(fullscreen, "exclusive")
    end
end

function lerpColor(c1, c2, t)
    return {
        c1[1] + (c2[1] - c1[1]) * t,
        c1[2] + (c2[2] - c1[2]) * t,
        c1[3] + (c2[3] - c1[3]) * t
    }
end

function love.draw()
    -- Gradient background
    for y = 0, love.graphics.getHeight(), 2 do
        local t = y / love.graphics.getHeight()
        local c = lerpColor(COLOR_BG, COLOR_BG_DARK, t)
        love.graphics.setColor(c[1], c[2], c[3])
        love.graphics.rectangle("fill", 0, y, love.graphics.getWidth(), 2)
    end
    
    -- Draw subtle grid
    love.graphics.setColor(COLOR_GRID[1], COLOR_GRID[2], COLOR_GRID[3], 0.3)
    for x = 0, GRID_WIDTH do
        love.graphics.line(x * CELL_SIZE, 0, x * CELL_SIZE, GRID_HEIGHT * CELL_SIZE)
    end
    for y = 0, GRID_HEIGHT do
        love.graphics.line(0, y * CELL_SIZE, GRID_WIDTH * CELL_SIZE, y * CELL_SIZE)
    end
    
    -- Draw food with glow effect
    local foodX = (food.x - 1) * CELL_SIZE
    local foodY = (food.y - 1) * CELL_SIZE
    local pulse = 1 + math.sin(pulseTimer * 4 + food.pulseOffset) * 0.1
    
    -- Outer glow
    love.graphics.setColor(COLOR_FOOD_GLOW[1], COLOR_FOOD_GLOW[2], COLOR_FOOD_GLOW[3], 0.3)
    love.graphics.circle("fill", foodX + CELL_SIZE/2, foodY + CELL_SIZE/2, CELL_SIZE/2 * pulse * 1.5)
    
    -- Apple body
    love.graphics.setColor(COLOR_FOOD_CORE)
    love.graphics.circle("fill", foodX + CELL_SIZE/2, foodY + CELL_SIZE/2 + 1, CELL_SIZE/2 * pulse - 1)
    
    -- Highlight
    love.graphics.setColor(1, 0.6, 0.6, 0.5)
    love.graphics.circle("fill", foodX + CELL_SIZE/2 - 2, foodY + CELL_SIZE/2 - 2, 3)
    
    -- Stem
    love.graphics.setColor(COLOR_FOOD_STEM)
    love.graphics.rectangle("fill", foodX + CELL_SIZE/2 - 1, foodY + 1, 2, 4)
    
    -- Draw snake
    for i, segment in ipairs(snake) do
        local segX = (segment.x - 1) * CELL_SIZE
        local segY = (segment.y - 1) * CELL_SIZE
        
        -- Gradient color from head to tail
        local t = (i - 1) / math.max(#snake - 1, 1)
        local segColor = lerpColor(COLOR_SNAKE_HEAD, COLOR_SNAKE_TAIL, t)
        
        -- Body segment with rounded corners
        love.graphics.setColor(COLOR_SNAKE_OUTLINE)
        love.graphics.rectangle("fill", segX, segY, CELL_SIZE, CELL_SIZE, 3)
        
        love.graphics.setColor(segColor)
        love.graphics.rectangle("fill", segX + 1, segY + 1, CELL_SIZE - 2, CELL_SIZE - 2, 2)
        
        -- Shine effect on top
        love.graphics.setColor(segColor[1] + 0.15, segColor[2] + 0.15, segColor[3] + 0.15, 0.6)
        love.graphics.rectangle("fill", segX + 3, segY + 2, CELL_SIZE - 6, CELL_SIZE/3, 1)
        
        -- Draw eyes and tongue on head
        if i == 1 then
            drawHeadFeatures(segX, segY)
        end
    end
    
    -- Draw particles
    for _, p in ipairs(particles) do
        local alpha = p.life / 0.4
        love.graphics.setColor(p.color[1], p.color[2], p.color[3], alpha)
        love.graphics.circle("fill", p.x, p.y, p.size * alpha)
    end
    
    -- Draw UI with shadow
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.print("Score: " .. score, 12, 12)
    love.graphics.print("High Score: " .. highScore, 12, 42)
    
    love.graphics.setColor(0.9, 0.95, 0.9)
    love.graphics.print("Score: " .. score, 10, 10)
    love.graphics.print("High Score: " .. highScore, 10, 40)
    
    if gameOver then
        -- Semi-transparent overlay
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        
        -- Game over text with glow
        love.graphics.setColor(0.8, 0.2, 0.2, 0.5)
        love.graphics.printf("GAME OVER", 0, 178, love.graphics.getWidth(), "center")
        love.graphics.setColor(1, 0.3, 0.3)
        love.graphics.printf("GAME OVER", 0, 175, love.graphics.getWidth(), "center")
        
        love.graphics.setColor(0.9, 0.9, 0.9)
        love.graphics.printf("Press R to restart", 0, 220, love.graphics.getWidth(), "center")
    end
end

function drawHeadFeatures(x, y)
    local cx = x + CELL_SIZE / 2
    local cy = y + CELL_SIZE / 2
    
    -- Eye positions based on direction
    local eyeOffset = 4
    local leftEye, rightEye = {cx - eyeOffset, cy - 2}, {cx + eyeOffset, cy - 2}
    local tongueStart = {cx, cy + 5}
    local tongueEnd = {cx, cy + 12}
    
    -- Adjust for direction
    if direction == 1 then -- right
        leftEye, rightEye = {cx + 2, cy - eyeOffset}, {cx + 2, cy + eyeOffset}
        tongueStart = {cx + 8, cy}
        tongueEnd = {cx + 16, cy}
    elseif direction == 2 then -- down
        leftEye, rightEye = {cx - eyeOffset, cy + 2}, {cx + eyeOffset, cy + 2}
        tongueStart = {cx, cy + 8}
        tongueEnd = {cx, cy + 16}
    elseif direction == 3 then -- left
        leftEye, rightEye = {cx - 2, cy - eyeOffset}, {cx - 2, cy + eyeOffset}
        tongueStart = {cx - 8, cy}
        tongueEnd = {cx - 16, cy}
    end -- up is default
    
    -- Draw tongue (flicking animation)
    if tongueExtended then
        -- Tongue stem
        love.graphics.setColor(COLOR_TONGUE)
        love.graphics.setLineWidth(3)
        love.graphics.line(tongueStart[1], tongueStart[2], tongueEnd[1], tongueEnd[2])
        
        -- Forked tip
        love.graphics.setColor(COLOR_TONGUE_TIP)
        local forkAngle = 0.5
        local forkLen = 5
        
        if direction == 1 or direction == 3 then -- horizontal
            local tipX = tongueEnd[1] + (direction == 1 and 1 or -1)
            love.graphics.line(tongueEnd[1], tongueEnd[2], tipX, tongueEnd[2] - forkLen)
            love.graphics.line(tongueEnd[1], tongueEnd[2], tipX, tongueEnd[2] + forkLen)
        else -- vertical
            local tipY = tongueEnd[2] + (direction == 2 and 1 or -1)
            love.graphics.line(tongueEnd[1], tongueEnd[2], tongueEnd[1] - forkLen, tipY)
            love.graphics.line(tongueEnd[1], tongueEnd[2], tongueEnd[1] + forkLen, tipY)
        end
        
        love.graphics.setLineWidth(1)
    end
    
    -- Draw eyes (white sclera)
    love.graphics.setColor(COLOR_EYE_WHITE)
    love.graphics.circle("fill", leftEye[1], leftEye[2], 4)
    love.graphics.circle("fill", rightEye[1], rightEye[2], 4)
    
    -- Draw pupils (looking forward based on direction)
    local pupilOffset = 1.5
    local pupilX, pupilY = 0, -pupilOffset
    
    if direction == 1 then pupilX, pupilY = pupilOffset, 0
    elseif direction == 2 then pupilX, pupilY = 0, pupilOffset
    elseif direction == 3 then pupilX, pupilY = -pupilOffset, 0
    end -- up is default
    
    love.graphics.setColor(COLOR_EYE_PUPIL)
    love.graphics.circle("fill", leftEye[1] + pupilX, leftEye[2] + pupilY, 2)
    love.graphics.circle("fill", rightEye[1] + pupilX, rightEye[2] + pupilY, 2)
    
    -- Eye shine
    love.graphics.setColor(1, 1, 1, 0.7)
    love.graphics.circle("fill", leftEye[1] + pupilX - 0.5, leftEye[2] + pupilY - 0.5, 0.8)
    love.graphics.circle("fill", rightEye[1] + pupilX - 0.5, rightEye[2] + pupilY - 0.5, 0.8)
end
