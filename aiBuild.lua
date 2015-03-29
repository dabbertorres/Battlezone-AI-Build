aiBuild = {}
--table of odfs for each faction
--[[
NSDF = 1
CCA = 2
CRA = 3
BDOG = 4
]]--
aiBuild.Factions = {NSDF = 1, CCA = 2, CRA = 3, BDOG = 4}

aiBuild.Faction = {}

aiBuild.Faction[aiBuild.Factions.NSDF] = 
{
	constructor = "avcnst",
	sPower = "abspow",
	lPower = "ablpow",
	wPower = "abwpow",
	gunTower = "abtowe",
	silo = "absilo",
	supply = "absupp",
	hangar = "abhang",
	barracks = "abbarr",
	cafeteria = "abcafe",
	commTower = "abcomm",
	hq = "abhqcp"
}
	
aiBuild.Faction[aiBuild.Factions.CCA] = 
{
	constructor = "svcnst",
	sPower = "sbspow",
	lPower = "sblpow",
	wPower = "sbwpow",
	gunTower = "sbtowe",
	silo = "sbsilo",
	supply = "sbsupp",
	hangar = "sbhang",
	barracks = "sbbarr",
	cafeteria = "sbcafe",
	commTower = "sbcomm",
	hq = "sbhqcp"
}

aiBuild.Faction[aiBuild.Factions.CRA] = 
{
	constructor = "cvcnst",
	sPower = "cbspow",
	lPower = "cblpow",
	wPower = "cbwpow",
	gunTower = "cblasr",
	silo = "cbsilo",
	supply = "cbmbld",
	hangar = "cbhang",
	barracks = "cbbarr",
	cafeteria = "cbcafe",
	commTower = "cbcomm",
	hq = "cbhqcp"
}

aiBuild.Faction[aiBuild.Factions.BDOG] = 
{
	constructor = "bvcnst",
	sPower = "abspow",
	lPower = "ablpow",
	wPower = "abwpow",
	gunTower = "bbtowe",
	silo = "absilo",
	supply = "abmbld",
	hangar = "abhang",
	barracks = "abbarr",
	cafeteria = "abcafe",
	commTower = "bbcomm",
	hq = "bbhqcp"
}

aiBuild.Building = 
{
	handle = nil,
	odf = "",
	path = "",
	priority = 0
}
aiBuild.Building.__index = aiBuild.Building

aiBuild.Constructor = 
{
	handle = nil,
	team = 0,
	queue = {}
}

function aiBuild.Constructor:update()
	--sort the queue by priority
	table.sort(self.queue, function(one, two) return one.priority > two.priority end)
	
	--if we have a bad object in the queue, just remove it
	if self.queue[1] == nil then
		table.remove(self.queue, 1)
	end
	
	if IsValid(self.handle) then
		if #self.queue == 0 then
			Goto(self.handle, GetRecyclerHandle(self.team), 0)
		elseif CanBuild(self.handle) and not IsBusy(self.handle) then
			BuildAt(self.handle, self.queue[1].odf, self.queue[1].path)
		end
	else
		self.handle = GetConstructorHandle(self.team)
	end
end

aiBuild.Constructor.__index = aiBuild.Constructor

aiBuild.Team = 
{
	teamNum = 0,
	faction = 0,
	constructor = nil,
	makingNewConst = false,
	buildingList = {}
}

--num = team number, f = faction num
function aiBuild.Team.new(num, f)
	local newTeam = setmetatable({}, aiBuild.Team)
	newTeam.teamNum = num
	newTeam.faction = f
	
	newTeam.constructor = setmetatable({}, aiBuild.Constructor)
	newTeam.constructor.team = newTeam.teamNum
	newTeam.constructor.handle = GetConstructorHandle(teamNum)
	newTeam.constructor.queue = {}
	
	return newTeam
end

--this should be called inside of the Script's function Update()
function aiBuild.Team:update()
	self.constructor:update()
	
	--iterate over buildings, if  destroyed, then add to queue to build
	for p, b in pairs(self.buildingList) do
		if not IsValid(b.handle) then
			local h = GetNearestObject(p)
			if IsOdf(h, b.odf) and GetDistance(h, p) < 60 then
				b.handle = h
			else
				local inQueue = false
				for i, v in ipairs(self.constructor.queue) do
					if v.path == p then
						inQueue = true
						break
					end
				end
			
				if not inQueue then
					table.insert(self.constructor.queue, b)
				end
			end
		end
	end
end

--this should be called from within the Script's function AddObject(h)
function aiBuild.Team:addObject(h)
	--not my team? Don't care
	if GetTeamNum(h) ~= self.teamNum then
		return
	end
	
	if IsBuilding(h) or IsOdf(h, aiBuild.Faction[self.faction].gunTower) then
		--if the building is the right type, and it's basically at the correct path, it's the right building
		if IsOdf(h, self.constructor.queue[1].odf) and IsWithin(h, self.constructor.handle, 60) then
			self.buildingList[self.constructor.queue[1].path].handle = h
			table.remove(self.constructor.queue, 1)
		end
	end
end

function aiBuild.Team:addBuilding(odf, path, priority)
	local newBuilding = setmetatable({}, aiBuild.Building)
	newBuilding.handle = nil
	newBuilding.odf = odf
	newBuilding.path = path
	newBuilding.priority = priority
	self.buildingList[path] = newBuilding
end

aiBuild.Team.__index = aiBuild.Team
