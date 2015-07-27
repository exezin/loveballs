-- require the lib, call it whatever you want
local softbody = require("loveballs")

-- create our world and a boundry
world = love.physics.newWorld(0, 9.81*64, false)
surface = {}
surface.body = love.physics.newBody(world, 0, 0)
surface.shape = love.physics.newChainShape(true, 0, 0, 800, 0, 800, 600, 0, 600)
surface.fixture = love.physics.newFixture(surface.body, surface.shape)

-- a table to store each instance of a softbody
softbodyTable = {}

-- a function to create and insert softbody instances into our table
function createSoftbody(x, y, r)
	-- a random color
	local red = love.math.random(80,255)
	local green = love.math.random(20,255)
	local blue = love.math.random(100,255)
	local rgb = {red, green, blue}

	table.insert(softbodyTable, {object = softbody(world, x, y, r), rgb = rgb})
end

function love.mousepressed(x, y)
	-- create a softbody with a random radius
	createSoftbody(x, y, love.math.random(60, 120))
end

function love.update(dt)
	--[[ 
		call the update for each instance
		this updates the tessellation for drawing
		only call this when you are drawing the softbody
	--]]
	for i,v in ipairs(softbodyTable) do
		v.object:update(dt)
	end

	world:update(dt)
end

function love.draw()
	for i,v in ipairs(softbodyTable) do
		love.graphics.setColor(v.rgb[1], v.rgb[2], v.rgb[3])
		v.object:draw()
	end
end