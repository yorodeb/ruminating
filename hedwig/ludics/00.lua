function mathematica(x, y, operator)
	if operator == "+" then
		return x+y

	elseif operator == "-" then
		return x-y

	elseif operator == "*" then
		return x*y

	elseif operator == "/" then
		if y ~= 0 then
			return x/y
		else
			return
		end
	end

	return nil
end

repeat
	io.write("X: "); local x = tonumber(io.read())
	io.write("Y: "); local y = tonumber(io.read())
	io.write("Operator: "); local operator = io.read()
	print(string.format("%g\t%g\t%g\n", x, y, mathematica(x, y, operator)))

	io.write("Continue? (0/1)\n::> ")
	checkForLoop = tonumber(io.read())
until checkForLoop == 0
