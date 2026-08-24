function fibonacci(x)
    local firstTerm, secondTerm = 0, 1
    local nextTerm = firstTerm + secondTerm

    io.write(string.format("Fibonacci Series: %d, %d, ", firstTerm, secondTerm))
    for i = 3, x do
        io.write(string.format("%d, ", nextTerm))

        firstTerm = secondTerm
        secondTerm = nextTerm
        nextTerm = firstTerm + secondTerm
    end
    io.write("\n")
end

function factorial(x)
    if x == 1 then
        return x
    end
    
    return x * factorial(x-1)
end

function checkPrime(x)
    if x <= 1 then
        return false
    end

    if x == 2 then
        return true
    end
    
    for i = 2, x-1 do
        if x % i == 0 then
            return false
        end
    end
    
    return true
end

print("Fibonacci Series -- till what term?")
local foo = tonumber(io.read())
fibonacci(foo)

print("Factorial -- Number?")
local bar = tonumber(io.read())
io.write(string.format("Factorial(%d): %d\n", bar, factorial(bar)))

print("CheckForPrime -- Number?")
local qux = tonumber(io.read())
io.write(string.format("CheckForPrime(%d): %s\n", qux, tostring(checkPrime(qux))))
