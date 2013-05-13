--[[
@projectDescription Touch screen helper utilities
@author Mike D Sutton
@version 1.0.0
]]

local frameStack = {}

-- The top-most frame on the stack is the current frame
local function getCurrentFrame()
	return frameStack[table.maxn(frameStack)]
end

--[[
Add a new hit area to the current interaction frame
@param {number} x Left bound of area
@param {number} y Top bound of area
@param {number} w Width of area
@param {number} h Height of area
@param {table, number, string, function} data User specified touch data (returned in hit test)
]]
function add(x, y, w, h, data)
	table.insert(getCurrentFrame(), {
		x = x, y = y, w = w, h = h,
		data = (data or true) })
end

--[[
Perform a hit test on any areas in the current interaction frame
@param {number} x Horizontal coordinate of hit test
@param {number} y Vertical cordinate of hit test
@returns {table, number, string, function} User specified touch data (set in 'add')
]]
function hitTest(x, y)
	local touchAreas = getCurrentFrame()
	
	for i = table.maxn(touchAreas), 1, -1 do
		local area = touchAreas[i]
		
		if (area) then
			if ((x >= area.x) and
				(y >= area.y) and
				(x < (area.x + area.w)) and
				(y < (area.y + area.h))) then
				return area.data
			end
		end
	end
	
	return nil
end

-- Clears the current interaction frame
function clear()
	table.remove(frameStack, table.maxn(frameStack))
	push()
end

-- Push a new interaction frame
function push()
	table.insert(frameStack, {})
end

-- Pop the current interaction frame
function pop()
	local idx = table.maxn(frameStack)
	table.remove(frameStack, idx)
	
	if (idx <= 1) then
		push()
	end
end

-- Since the handlers for monitor touches and mouse clicks are nearly identical,
-- abstract the logic here and call from the public methods with appropriate params
local function waitCore(param, evtName)
	while (next(getCurrentFrame())) do
		local evt, evtParam, x, y = os.pullEvent(evtName)
		
		if ((param == nil) or (param == evtParam)) then
			local touchData = hitTest(x, y)
			
			if (touchData ~= nil) then
				return touchData
			end
		end
	end
end

--[[
Waits for a monitor touch event
This is a blocking call; it won't return until a valid touch is detected
If no touch areas are defined then this will return immediately
@param {string} [side] Optionally specify the side to listen on
@returns {string} Touch data for hit area
]]
function waitForTouch(side)
	return waitCore(side, "monitor_touch")
end

--[[
Waits for a mouse click event
This has the same functionality as the waitForTouch function
@param {number} [button] Optionally specify the required mouse button (1 = Left, 2 = Right, 3 = Middle)
@returns {string} Touch data for hit area
]]
function waitForClick(button)
	return waitCore(button, "mouse_click")
end

-- Push initial frame on startup
push()