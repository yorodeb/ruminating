function mathematica(x, y, operator)
	if operator == "+" then
		return x+y

	elseif operator == "-" then
		return x-y

	elseif operator == "*" then
		return x*y

	elseif operator == "/" then
		return x/y
	end

end

print(10,5,"+", mathematica(10, 5, "+"))
print(10,5,"-", mathematica(10, 5, "-"))
print(10,5,"*", mathematica(10, 5, "*"))
print(10,5,"/", mathematica(10, 5, "/"))
