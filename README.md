# THIS IS OUDATED, NEW VERSION [HERE](https://github.com/exezin/loveblobs)

loveballs
=========

A simple love2d softbody lib


A quick example
```lua
    local Softbody = require "loveballs"

    function love.load()
       --I've found these to be optimal settings
       love.physics.setMeter(16)
       world = love.physics.newWorld(0, 9.81*16, true)

       --Lets make a floor object
       fbody = love.physics.newBody(world, 0, 400)
       fshape = love.physics.newRectangleShape(1000, 32)
       ffixture = love.physics.newFixture(fbody, fshape)

       --Now lets make some soft body's
       --World, X, Y, Radius, Smoothing, tesselate count
             --(I set soft1's tesselate count to low, and the 'smoothing' to high, giving a cool effect, similar to loco roco)
       soft1 = Softbody(world, 400, -200, 100, 2, 4)
       soft2 = Softbody(world, 400, 0, 35, 2, 4)

       --Get outer node 1's body
       local body = soft1[1].body

       --Get outer node 1's shape
       local shape = soft1[1].shape

       --Get outer node 1's fixture
       local fixture = soft1[1].fixture
    end

    function love.update(dt)
       world:update(dt)
       soft1:update()
       soft2:update()
    end

    function love.draw()
       love.graphics.setColor(220, 120, 200)

       --Now lets draw them
       soft1:draw()
       soft2:draw("line")
    end
```

Forum: http://love2d.org/forums/viewtopic.php?f=5&t=78882&p=174733#p174733

Video: https://www.youtube.com/watch?v=UeJzojkpp5Y
