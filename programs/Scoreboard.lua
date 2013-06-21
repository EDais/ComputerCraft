--[[
@projectDescription Basic scoreboard implementation
@author Mike D Sutton
@version 1.0.0

@remarks IMPORTANT:
Requires an attached ChatBox from MiscPeripherals mod pack
]]

local Scoreboard

(function()
	-- Return the key names in a table
	local function getKeys(t)
		local ret = {}

		for k,_ in pairs(t) do
			table.insert(ret, k)
		end

		return ret
	end

	Scoreboard = {
		-- Format of score table:
		--	killer: { victim: count }
		scoreTable = {},
		config = {
			countSuicides = true
		},
		reset = function(self)
			self.scoreTable = {}
		end
	}
	
	--[[
	Register a kill
	@param {table} self Scoreboard (implicit if called using ':')
	@param {string} player Player name who died
	@param {string} killer Player/Mob name who killed player
	@param {string} cause Reason for death (currently unused)
	]]
	Scoreboard.addKill = function(self, player, killer, cause)
		if (killer == nil) then
			killer = player -- Suicide
		end
		
		local kills = self.scoreTable[killer]
		if (kills == nil) then
			kills = {}
			self.scoreTable[killer] = kills
		end
		
		kills[player] = (kills[player] or 0) + 1
	end
	
	--[[
	Lookup all known player names (killers and victims)
	@param {table} self Scoreboard (implicit if called using ':')
	@returns {table} List of player names
	]]
	Scoreboard.getKnownPlayerNames = function(self)
		local known = {}

		for k,v in pairs(self.scoreTable) do
			known[k] = true

			for l,_ in pairs(v) do
				known[l] = true
			end
		end
		
		return getKeys(known)
	end
	
	--[[
	Lookup the number of kills this player made
	@param {table} self Scoreboard (implicit if called using ':')
	@param {string} playerName Player name
	@param {boolean} countSuicides Should suicides be included in count
	@returns {number} Kill count
	]]
	Scoreboard.getPlayerKills = function(self, playerName, countSuicides)
		local playerKills, kills = self.scoreTable[playerName], 0
		
		if (playerKills ~= nil) then
			for k,v in pairs(playerKills) do
				if ((k ~= playerName) or
					(countSuicides or self.config.countSuicides)) then
					kills = kills + v
				end
			end
		end
		
		return kills
	end
	
	--[[
	Lookup the number of times this player died
	@param {table} self Scoreboard (implicit if called using ':')
	@param {string} playerName Player name
	@param {boolean} countSuicides Should suicides be included in count
	@returns {number} Death count
	]]
	Scoreboard.getPlayerDeaths = function(self, playerName, countSuicides)
		local deaths = 0
		
		for k,v in pairs(self.scoreTable) do
			if ((k ~= playerName) or
				(countSuicides or self.config.countSuicides)) then
				local killCount = v[playerName]
				
				if (killCount ~= nil) then
					deaths = deaths + killCount
				end
			end
		end
		
		return deaths
	end
	
	--[[
	Lookup a player's score
	@param {table} self Scoreboard (implicit if called using ':')
	@param {string} playerName Player name
	@returns {number, number, number} Kills, deaths, and KDR
	]]
	Scoreboard.getPlayerScore = function(self, playerName, countSuicides)
		local kills, deaths, KDR =
			self:getPlayerKills(playerName, countSuicides),
			self:getPlayerDeaths(playerName, countSuicides)
		
		if (deaths > 0) then
			KDR = kills / deaths
		else
			KDR = kills
		end
		
		return kills, deaths, KDR
	end
	
	--[[
	Basic scoreboard display implementation - Printed to terminal
	@param {table} self Scoreboard (implicit if called using ':')
	]]
	Scoreboard.printScores = function(self)
		local players, maxNameLen = self:getKnownPlayerNames(), 0
		local scoreData = {}
		
		-- Work out longest player name length
		for _,v in ipairs(players) do
			if (#v > maxNameLen) then
				maxNameLen = #v
			end
			
			local playerData = { self:getPlayerScore(v) }
			table.insert(playerData, 1, v)
			table.insert(scoreData, playerData)
		end
		
		-- Sort scores by kills
		table.sort(scoreData,
			function(a, b)
				return a[2] > b[2]
			end)
		
		pad = function(v, len, left, char)
			local ret = tostring(v or "")
			local pad = string.rep(
				(char or " "), math.max(len - #ret, 0))
			
			return (left and pad or "") .. ret .. (left and "" or pad)
		end
		
		print("\n", pad("Name ", maxNameLen + 1), "Kills   Deaths     KDR")
		print(string.rep("-", math.max(maxNameLen, 4) + 23))
		
		for _,v in ipairs(scoreData) do
			print(pad(v[1], maxNameLen + 1),
				pad(v[2], 5, true), "   ",
				pad(v[3], 6, true), "  ",
				pad(pad(string.format("%f",
					math.floor((v[4] * 100) + 0.5) / 100), 4, false, "0"),
					6, true))
		end
		
		print(string.rep("-", math.max(maxNameLen, 4) + 23), "\n")
	end
end)()

-- Register event handlers
local working = true
local eventHandlers = {
	chat_death = function(player, killer, cause)
		Scoreboard:addKill(player, killer, cause)
	end,
	key = function(keycode)
		if (keycode == keys.q) then -- Quit
			working = false
		elseif (keycode == keys.r) then -- Reset
			print("Resetting scroes")
			Scoreboard:reset()
		elseif (keycode == keys.p) then -- Print scores
			Scoreboard:printScores()
		end
	end
}

print("Listening.\n\t'q' to quit\n\t'r' to reset\n\t'p' to print scores")

-- Main app loop
while working do
	local evt = { os.pullEvent() }
	local handler = eventHandlers[evt[1]]
	
	if (handler) then
		-- Pop event name, and invoke handler with remaining params
		table.remove(evt, 1)
		handler(unpack(evt))
	end
end

term.clear()
term.setCursorPos(1, 1)
term.write("Goodbye!")
term.setCursorPos(1, 2)
