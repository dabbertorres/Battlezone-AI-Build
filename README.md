# Battlezone-AI-Build
A Lua powered AI extension to Battlezone that lets the AI rebuild buildings.

# How do I use this?
First off, if you don't have Battlezone, get it here: www.battlezone1.com

Second, figure out how to make maps with Battlezone from the forums: www.battlezone1.org

Now is where you get to coding. Write your Lua mission script. Then, when ready, edit your map by placing paths wherever you would like the AI to build a building. Feel free to name them whatever you want to make them easy to remember and find.

Next, create a Team variable for each AI team:
```lua
aiTeamOne = aiBuild.Team.new(teamNumber, FactionNumber)
```

If you haven't yet, create AddObject(h) and Update() functions in your script and call aiBuild.Team:update() and aiBuild.Team:addObject(h) in their respective functions:
```lua
function AddObject(h)
  aiTeamOne:addObject(h)
end

function Update()
  aiTeamOne:update()
end
```

Now, if you test your map, you may be surprised if nothing happens! Why? Well, you forgot to register buildings for each team to have. I would do this in the Start() function:
```lua
function Start()
  aiTeamOne:addBuilding("odf name 1", "path name 1", priorityNum)
  aiTeamOne:addBuilding("odf name 2", "path name 2", priorityNum)
  aiTeamOne:addBuilding("odf name 3", "path name 3", priorityNum)
end
```

Now, if all works well, it should start building buildings!

It does this by checking if the handle of a building is valid (IsValid(handle)) every update. If a handle is found to NOT be valid, it adds it to the team's Constructor queue. A constructor will, if it has buildings in it's queue, go around and build. If not, it will goto the recycler and stay put unless told otherwise.

As (for me at least) remembering lots of ODFs can be frustrating, I included a few helper tables inside of my script for that. They can be accessed as follows:
```lua
  aiBuild.Faction.NSDF.gunTower
```
and such. Look in the script if you get lost.

If all goes well, that is it! 
