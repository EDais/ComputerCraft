--[[
@projectDescription Simple turtle L-System builder
@author Mike D Sutton
@version 1.0.0
@date 20.01.2014

 To run, fill Turtle's inventory with
 placeable blocks (a level 4 structure
 will require ~12 stacks), and place a
 fuel source (i.e: Coal or Charcoal)
 in the last slot.

 Modify the size and complexity of the
 structure by changing the maxLevel
 parameter for the main lsystem call;
 higher is more complex. ]]

-- Define L-System
local moore = {
	axiom = "AFALFLAFA",
	rules = {
		A = "RBFLAFALFBR",
		B = "LAFRBFBRFAL"
	}
}

local function lsystem(command, rules, maxLevel, level, dictionary)
	local i, cmd, rule, func
	
	for i = 1, #command do
		cmd = command:sub(i, i)
		rule = rules[cmd]
		
		if (rule and (level < maxLevel)) then
			lsystem(rule, rules, maxLevel, level + 1, dictionary)
		else
			local func = dictionary[cmd]
			if (func) then func() end
		end
	end
end

local fuelSlot = 16

local function doBlock()
	local i, j
	
	for i = 1, 3 do
		-- Automatically refuel if needed
		if (turtle.getFuelLevel() == 0) then
			turtle.select(fuelSlot)
			turtle.refuel(1)
		end
		
		if (turtle.back()) then
			-- Select first available slot
			for j = 1, 16 do
				if ((j ~= fuelSlot) and
					(turtle.getItemCount(j) > 0)) then
					turtle.select(j)
					break
				end
			end
			
			-- Place block
			if (not turtle.place()) then
				return false
			end
		else
			return false
		end
	end
	
	return true
end

-- Kick off system
lsystem(moore.axiom, moore.rules, 3, 1, {
	-- Since we're building backwards, reverse turns
	L = turtle.turnRight,
	R = turtle.turnLeft,
	F = doBlock
})