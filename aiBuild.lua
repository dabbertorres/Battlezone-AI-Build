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

aiBuild.Faction.NSDF = 
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
	
aiBuild.Faction.CCA = 
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

aiBuild.Faction.CRA = 
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

aiBuild.Faction.BDOG = 
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

aiBuild.Constructor = 
{
	handle = nil,
	team = 0,
	queue = {}
}

function aiBuild.Constructor:update()
	--sort the queue by priority
	table.sort(self.queue, function(one, two) return one.priority > two.priority end)

	if self.handle ~= nil then
		if table.length(self.queue) == 0 then
			Goto(self.handle, GetRecyclerHandle(self.team))
		elseif CanCommand(self.handle) and CanBuild(self.handle) and not IsBusy(self.handle) then
			BuildAt(self.handle, self.queue[1].odf, self.queue.path)
		end
		
		return true		--all is well in the world. Minus the battle going on
	else
		return false	--send signal to build a new constructor
	end
end

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
	local newTeam = {}
	setmetatable(newTeam, Team)
	newTeam.teamNum = num
	newTeam.faction = f
	
	setmetatable(newTeam.constructor, Constructor)
	newTeam.constructor.handle = GetConstructorHandle(teamNum)
	
	if newTeam.constructor.handle == nil then
		Build(GetRecyclerHandle(newTeam.teamNum), Faction[f].constructor)
		newTeam.makingNewConst = true
	end
	
	return newTeam
end

--this should be called inside of the Script's function Update()
function aiBuild.Team:update()
	local result = constructor:update()
	
	if not result and not makingNewConst then
		Build(GetRecyclerHandle(self.teamNum), Faction[self.faction].constructor)
		self.makingNewConst = true
	end
	
	--iterate over buildings, if  destroyed, then add to queue to build
	for b in self.buildingList do
		if not IsValid(b.handle) then
			table.insert(self.constructor.queue, b)
		end
	end
end

--this should be called from within the Script's function AddObject(h)
function aiBuild.Team:addObject(h)
	--not my team? Don't care
	if GetTeamNum(h) ~= self.teamNum then
		return
	end
	
	if IsBuilding(h) then
		--if the building is the right type, and it's basically at the correct path, it's the right building
		if IsOdf(h, self.constructor.queue[1].odf) and GetDistance(h, self.constructor.queue[1].path) < 20 then
			self.constructor.queue[1].handle = h
			
			for b in self.buildingList do
				if self.constructor.queue[1] == b then
					b.handle = h
				end
			end
			
			table.remove(self.constructor.queue, 1)
		end
	elseif IsOdf(h, Faction[self.faction].constructor) then	--got a new constructor.
		self.constructor = h
		self.makingNewConst = false
	end
end

function aiBuild.Team:addBuilding(odf, path, priority)
	local newBuilding = {}
	setmetatable(newBuilding, Building)
	newBuilding.handle = nil
	newBuilding.odf = odf
	newBuilding.path = path
	newBuilding.priority = priority
	table.insert(self.buildingList, newBuilding)
end