math.randomseed(os.time())
secret = math.random(100)

print("Guess a Number?\n(Between 1 to 100)")
local counterForInput = 0

repeat
    hogeri = tonumber(io.read())
    counterForInput = counterForInput + 1
    computerRand = math.random(100)

    if hogeri < secret then
        io.write("Too Low! Try Again..\n")
    elseif hogeri > secret then
        io.write("Too High! Try Again..\n")
    else
        io.write("🎉 Congratulations! You guessed the correct number!\n")
        break
    end
    
    io.write(string.format("\nComputer thinking.. \n%d\n", computerRand))
    if computerRand < secret then
        io.write("Too Low! Try Again..\n")
    elseif computerRand > secret then
        io.write("Too High! Try Again..\n")
    else
        io.write("🎉 Sucker! You lost to a Computer.\n")
        break
    end

until hogeri == secret or computerRand == secret

io.write(string.format("\nSucker you took %d attempts!\n", counterForInput))
