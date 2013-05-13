-- Get monitor
local mon = peripheral.wrap("top")
local mw, mh = mon.getSize()

-- Load API
os.loadAPI("disk/touchAPI")

-- Add hit area
touchAPI.add(3, 2, 12, 8, "Hit")

-- Add second hit area
touchAPI.add(16, 4, 12, 8, "Other")

while true do
	-- Colour hittable areas of screen in green
	-- All other areas in red
	for y = 1, mh do
		mon.setCursorPos(1, y)

		for x = 1, mw do
			mon.setBackgroundColour(
				touchAPI.hitTest(x, y)
				and colours.lime
				or colours.red)
			mon.write(" ")
		end
	end

	-- Listen for touches
	local touchData = touchAPI.waitForTouch()

	-- Print touch information
	mon.setCursorPos(1, 1)
	mon.write(touchData)

	os.sleep(1)
end
