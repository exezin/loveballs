--softbody lib by Shorefire/Steven
--tesselate function by Amadiro/Jonathan Ringstad
local function copy(from)
	local to = {};

	for i,v in pairs(from) do
		to[i] = v;
	end

	return to;
end

local softbody = setmetatable({}, {
	__call = function(self, world, x, y, r, s, t)
		local new = copy(self);
		new:init(world, x, y, r, s, t);

		return setmetatable(new, getmetatable(self));
	end,
	__index = function(self, i)
		return self.nodes[i] or false;
	end,
	__tostring = function(self)
		return "softbody";
	end
});

function softbody:init(world, x, y, r, s, t, reinit)
	self.radius = r;
	self.world = world;

	--create center body
	self.centerBody = love.physics.newBody(world, x, y, "dynamic");
	self.centerShape = love.physics.newCircleShape(r/4);
	self.centerfixture = love.physics.newFixture(self.centerBody, self.centerShape);
	self.centerfixture:setMask(1);

	--create 'nodes' (outer bodies) & connect to center body
	self.nodeShape = love.physics.newCircleShape(8);
	self.nodes = {};

	local nodes = r/2;

	for node = 1, nodes do
		local angle = (2*math.pi)/nodes*node;
		
		local posx = x+r*math.cos(angle);
		local posy = y+r*math.sin(angle);

		local b = love.physics.newBody(world, posx, posy, "dynamic");
		b:setAngularDamping(50);
		
		local f = love.physics.newFixture(b, self.nodeShape);
		f:setFriction(30);
		f:setRestitution(0);
		f:setUserData(node)
		
		local j = love.physics.newDistanceJoint(self.centerBody, b, posx, posy, posx, posy, false);
		j:setDampingRatio(0.1);
		j:setFrequency(12*(20/r));

		table.insert(self.nodes, {body = b, fixture = f, joint = j});
	end


	--connect nodes to eachother
	for i = 1, #self.nodes do
		if i < #self.nodes then
			local j = love.physics.newDistanceJoint(self.nodes[i].body, self.nodes[i+1].body, self.nodes[i].body:getX(), self.nodes[i].body:getY(),
			self.nodes[i+1].body:getX(), self.nodes[i+1].body:getY(), false);
			self.nodes[i].joint2 = j;
		else
			local j = love.physics.newDistanceJoint(self.nodes[i].body, self.nodes[1].body, self.nodes[i].body:getX(), self.nodes[i].body:getY(),
			self.nodes[1].body:getX(), self.nodes[1].body:getY(), false);
			self.nodes[i].joint3 = j;
		end
	end

	if not reinit then
		--set tesselation and smoothing
		self.smooth = s or 2;

		local tess = t or 4;
		self.tess = {};
		for i=1,tess do
			self.tess[i] = {};
		end
	end

	self.dead = false;
end

function softbody:update()
	--update tesselation (for drawing)
	local pos = {};
	for i = 1, #self.nodes, self.smooth do
		v = self.nodes[i];

		table.insert(pos, v.body:getX());
		table.insert(pos, v.body:getY());
	end

	tessellate(pos, self.tess[1]);
	for i=1,#self.tess - 1 do
		tessellate(self.tess[i], self.tess[i+1]);
	end
end

function softbody:destroy()
	if self.dead then
		return;
	end

	for i = #self.nodes, 1, -1 do
		self.nodes[i].body:destroy();
		self.nodes[i] = nil;
	end

	self.centerBody:destroy();
	self.dead = true;
end

function softbody:setFrequency(f)
	for i,v in pairs(self.nodes) do
		v.joint:setFrequency(f);
	end
end

function softbody:setDamping(d)
	for i,v in pairs(self.nodes) do
		v.joint:setDampingRatio(d);
	end
end

function softbody:setFriction(f)
	for i,v in ipairs(self.nodes) do
		v.fixture:setFriction(0);
	end
end

function softbody:getPoints()
	return self.tess[#self.tess];
end

function softbody:draw(type, debug)
	if self.dead then
		return;
	end

	love.graphics.setLineStyle("smooth");
	love.graphics.setLineWidth(self.nodeShape:getRadius()*2);

	if type == "line" then
		love.graphics.polygon("line", self.tess[#self.tess]);
	else
		love.graphics.polygon("fill", self.tess[#self.tess]);
		love.graphics.polygon("line", self.tess[#self.tess]);
	end

	love.graphics.setLineWidth(1);

	if debug then
		for i,v in ipairs(self.nodes) do
			love.graphics.circle("line", v.body:getX(), v.body:getY(), self.nodeShape:getRadius());
		end
	end
end

--tessellate function by Amadiro/Jonathan Ringstad
function tessellate(vertices, new_vertices)
   MIX_FACTOR = .5
   new_vertices[#vertices*2] = 0
   for i=1,#vertices,2 do
      local newindex = 2*i
      -- indexing brackets:
      -- [1, *2*, 3, 4], [5, *6*, 7, 8]
      -- bracket center: 2*i
      -- bracket start: 2*1 - 1
      new_vertices[newindex - 1] = vertices[i];
      new_vertices[newindex] = vertices[i+1]
      if not (i+1 == #vertices) then
	 -- x coordinate
	 new_vertices[newindex + 1] = (vertices[i] + vertices[i+2])/2
	 -- y coordinate
	 new_vertices[newindex + 2] = (vertices[i+1] + vertices[i+3])/2
      else
	 -- x coordinate
	 new_vertices[newindex + 1] = (vertices[i] + vertices[1])/2
	 -- y coordinate
	 new_vertices[newindex + 2] = (vertices[i+1] + vertices[2])/2
      end
   end

   for i = 1,#new_vertices,4 do
      if i == 1 then
   	 -- x coordinate
   	 new_vertices[1] = MIX_FACTOR*(new_vertices[#new_vertices - 1] + new_vertices[3])/2 + (1 - MIX_FACTOR)*new_vertices[1]
   	 -- y coordinate
   	 new_vertices[2] = MIX_FACTOR*(new_vertices[#new_vertices - 0] + new_vertices[4])/2 + (1 - MIX_FACTOR)*new_vertices[2]
      else
   	 -- x coordinate
   	 new_vertices[i] = MIX_FACTOR*(new_vertices[i - 2] + new_vertices[i + 2])/2 + (1 - MIX_FACTOR)*new_vertices[i]
   	 -- y coordinate
   	 new_vertices[i + 1] = MIX_FACTOR*(new_vertices[i - 1] + new_vertices[i + 3])/2 + (1 - MIX_FACTOR)*new_vertices[i + 1]
      end
   end
end

return softbody;