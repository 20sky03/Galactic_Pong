
push = require "push"
Class = require "class"
require 'Paddle'
require 'Ball'

--Setting the Window Height and Width

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

--
VIRTUAL_WIDTH = 1280
VIRTUAL_HEIGHT = 720

PADDLE_SPEED = 600

--importing a background picture
local background = love.graphics.newImage('background.jpg')

function love.load()


    --to make the text on the game more crisp looking
    love.graphics.setDefaultFilter('nearest', 'nearest')

    --To randomize ball throw we will use this operation
    math.randomseed(os.time())

    --Setting the title
    love.window.setTitle("Galactic Pong Battle!")

    --To display game text font on the screen
    smallFont = love.graphics.newFont('gamer.ttf', 30)
    largeFont = love.graphics.newFont('gamer.ttf', 75)

    --Setting fonts for displaying scores on the screen
    scoreFont = love.graphics.newFont("gamer.ttf", 120)

    love.graphics.setFont(smallFont)
    
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
        --['music'] = love.audio.newSource('sounds/music.ogg', 'static')
    }
    --kick of music
    --sounds['music']:setLooping(true)
   -- sounds['music']:play()

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT,{
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    --Initializing score variables to track the player 1 and player 2 Scores
    player1Score = 0
    player2Score = 0

    --Intializing paddle positions on Y-Axis as paddles can only move up or down
    player1 = Paddle(10, 150, 10, 60)
    player2 = Paddle(VIRTUAL_WIDTH - 25, VIRTUAL_HEIGHT - 150, 10, 60)

    --Initializing a starting position for the ball (the center position)
    ball = Ball(VIRTUAL_WIDTH/2 - 2 , VIRTUAL_HEIGHT / 2 - 2, 16, 16)

    gameState = 'start'

end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)

    if key == 'escape' then
        love.event.quit()
    
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            
            gameState = 'serve'

            ball:reset()

            -- reset scores to 0
            player1Score = 0
            player2Score = 0

            -- decide serving player as the opposite of who won
            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
end

function love.update(dt)
    if gameState == 'serve' then
        -- before switching to play, initialize ball's velocity based
        -- on player who last scored
        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = math.random(100, 150)
        else
            ball.dx = -math.random(100, 150)
        end
    elseif gameState == 'play' then
        -- detect ball collision with paddles
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 10

            -- keep velocity going in the same direction, but randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(50, 200)
            else
                ball.dy = math.random(50, 200)
            end

            sounds['paddle_hit']:play()
        end
        if ball:collides(player2) then
            ball.dx = -ball.dx 
            ball.x = player2.x - 16

            -- keep velocity going in the same direction, but randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
            sounds['paddle_hit']:play()
        end

        -- upper and lower screen boundary collision 
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        -- -16 to account for the ball's size
        if ball.y >= VIRTUAL_HEIGHT - 16 then
            ball.y = VIRTUAL_HEIGHT - 16
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end
        
        --If we reach any of the edge then increment respective player's score
        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1
            sounds['score']:play()

            if player2Score == 10 then
                winningPlayer = 2
                gameState = 'done'
            else
                gameState = 'serve'
                -- places the ball in the middle of the screen, no velocity
                ball:reset()
            end
        end

        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1
            sounds['score']:play()
            
            if player1Score == 10 then
                winningPlayer = 1
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end
    end

    -- player 1 movement
    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    -- player 2 movement
    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end

    if gameState == 'play' then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
end

function love.draw()
    push:apply('start')
    --setting the background for the game
    love.graphics.draw(background, 0, 0)

    love.graphics.setFont(smallFont)
    
    --Displaying the scores of the players
    love.graphics.setFont(scoreFont)
    --Calling the display score function created below
    displayScore()

    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Inter galaxy!', 0, 10, VIRTUAL_WIDTH, 'center')

        love.graphics.printf('Press Enter to begin!', 0, 40, VIRTUAL_WIDTH, 'center')

    elseif gameState == 'serve' then

        love.graphics.setFont(smallFont)

        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 
            0, 10, VIRTUAL_WIDTH, 'center')

        love.graphics.printf('Press Enter to serve!', 0, 40, VIRTUAL_WIDTH, 'center')
        
    elseif gameState == 'play' then
        -- no messages to display in play

    elseif gameState == 'done' then
        --results

        love.graphics.setFont(largeFont)

        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!',
            0, 10, VIRTUAL_WIDTH, 'center')

        love.graphics.setFont(smallFont)

        love.graphics.printf('Press Enter to restart!', 0, 70, VIRTUAL_WIDTH, 'center')
    end


    --Displaying assets

    --Paddle 1
    player1:render()

    --Paddle 2
    player2:render()

    --Ball
    ball:render()    

    push:apply('end')

end

function displayScore()
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 150, 
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 130,
        VIRTUAL_HEIGHT / 3)
end