-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "physics" library
local physics = require "physics"

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX

function scene:create( event )

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view

	-- We need physics started to add bodies, but we don't want the simulaton
	-- running until the scene is on the screen.
	physics.start()
	physics.pause()


	-- create a grey rectangle as the backdrop
	-- the physical screen will likely be a different shape than our defined content area
	-- since we are going to position the background from it's top, left corner, draw the
	-- background at the real top, left corner.
	local background = display.newRect( display.screenOriginX, display.screenOriginY, screenW, screenH )
	background.anchorX = 0 
	background.anchorY = 0
	background:setFillColor( .5 )
	
	-- make a crate (off-screen), position it, and rotate slightly
		
	-- Abstract: CollisionDetection
	-- Version: 2.0
	-- Sample code is MIT licensed; see https://www.coronalabs.com/links/code/license
	-- Fish sprite images courtesy of Kenney; see http://kenney.nl/
	---------------------------------------------------------------------------------------

	local screenW = display.contentWidth - display.screenOriginX
	local screenH = display.contentHeight - display.screenOriginY
	local friction = 0.8
	local gravity = 0.098
	local speedX, speedY, prevX, prevY, lastTime, prevTime = 0, 0, 0, 0, 0, 0



	local background = display.newRect( display.screenOriginX, display.screenOriginY, screenW, screenH )
	background.anchorX = 0 
	background.anchorY = 0
	background:setFillColor( .5 )

	display.setStatusBar( display.HiddenStatusBar )
	math.randomseed( os.time() )

	------------------------------
	-- RENDER THE SAMPLE CODE UI
	------------------------------
	local sampleUI = require( "sampleUI.sampleUI" )
	sampleUI:newUI( { theme="darkgrey", title="Collision Detection", showBuildNum=false } )

	------------------------------
	-- CONFIGURE STAGE
	------------------------------
	display.getCurrentStage():insert( sampleUI.backGroup )
	local mainGroup = display.newGroup()
	display.getCurrentStage():insert( sampleUI.frontGroup )

	----------------------
	-- BEGIN SAMPLE CODE
	----------------------

	-- Local variables and forward references
	local letterboxWidth = math.abs(display.screenOriginX)
	local letterboxHeight = math.abs(display.screenOriginY)
	local currentDrawMode = "normal"

	-- Require libraries/plugins
	local widget = require( "widget" )
	local physics = require( "physics" )
	physics.start()	
	physics.setDrawMode( currentDrawMode )

	-- Set app font
	local appFont = sampleUI.appFont

	-- Create image sheet for fish
	local sheetOptions = {
		width = 55,
		height = 42,
		numFrames = 2,
		sheetContentWidth = 110,
		sheetContentHeight = 42
	}
	local imageSheet = graphics.newImageSheet( "fish.png", sheetOptions )

	-- Create "walls" around screen
	local wallL = display.newRect( mainGroup, 0-letterboxWidth, display.contentCenterY, 20, display.actualContentHeight )
	wallL.myName = "Left Wall"
	wallL.anchorX = 1
	physics.addBody( wallL, "static", { bounce=0.5, friction=0.1 } )

	local wallR = display.newRect( mainGroup, 320+letterboxWidth, display.contentCenterY, 20, display.actualContentHeight )
	wallR.myName = "Right Wall"
	wallR.anchorX = 0
	physics.addBody( wallR, "static", { bounce=0.5, friction=0.1 } )

	local wallT = display.newRect( mainGroup, display.contentCenterX, 0-letterboxHeight, display.actualContentWidth, 20 )
	wallT.myName = "Top Wall"
	wallT.anchorY = 1
	physics.addBody( wallT, "static", { bounce=0.5, friction=0.1 } )

	local wallB = display.newRect( mainGroup, display.contentCenterX, 480+letterboxHeight, display.actualContentWidth, 20 )
	wallB.myName = "Bottom Wall"
	wallB.anchorY = 0
	physics.addBody( wallB, "static", { bounce=0.5, friction=0.1 } )

	-- Function to place a visual "burst" at the collision point and animate it
	local function newBurst( collisionX, collisionY )

		local burst = display.newImageRect( mainGroup, "burst.png", 64, 64 )
		burst.x, burst.y = collisionX, collisionY
		burst.blendMode = "add"
		burst:toBack()
		transition.to( burst, { time=1000, rotation=45, alpha=0, transition=easing.outQuad,
			onComplete = function()
				display.remove( burst )
			end
		})
	end

	-- METHOD 1: "local" collision detection reports collisions between "self" and "event.other"
	local function onLocalCollision( self, event )

		if ( event.phase == "began" ) then
			print( "LOCAL REPORT: " .. self.myName .. " & " .. event.other.myName )
			newBurst( event.x, event.y )
		end
	end

	local function onComplete( event )
	    if ( event.action == "clicked" ) then
	        local i = event.index
	        if ( i == 1 ) then
	           composer.gotoScene( "menu" )
	        end   
	    end
	end
  
-- Show alert with two buttons


	local function onLocalBallCollision( self, event )
		physics.pause()
		native.showAlert( "Corona", "You Lost!!!" ,{ "OK"  } , onComplete  	 )

		if ( event.phase == "began" ) then
			print( "LOCAL REPORT: " .. self.myName .. " & " .. event.other.myName )
			newBurst( event.x, event.y )
		end
	end

	-- METHOD 2: "global" collision detection uses a Runtime listener to report collisions between "event.object1" and "event.object2"
	-- Note that the order of "event.object1" and "event.object2" may be reported arbitrarily in any collision
	local function onGlobalCollision( event )

		if ( event.phase == "began" ) then
			print( "GLOBAL REPORT: " .. event.object1.myName .. " & " .. event.object2.myName )
			newBurst( event.x, event.y )
		end
	end
	Runtime:addEventListener( "collision", onGlobalCollision )

	-- Create blue fish
	for b = 1,2 do
		local blueFish = display.newSprite( mainGroup, imageSheet, { name="swim", start=1, count=2, time=500 } )
		blueFish.x, blueFish.y = letterboxWidth, 60*b
		blueFish:setFillColor( 0.8, 1, 1 )
		blueFish.myName = "Blue Fish " .. b
		blueFish.fill.effect = "filter.hue"
		blueFish.fill.effect.angle = 10
		blueFish:play()
		physics.addBody( blueFish, "dynamic", { bounce=1, friction=0, radius=20 } )
		blueFish.isFixedRotation = true
		blueFish:applyLinearImpulse( math.random(2,6)/50, 0, blueFish.x, blueFish.y )
		-- Add local collision detection to this fish (an alternative to global detection set via line 105)
		blueFish.collision = onLocalCollision
		blueFish:addEventListener( "collision" )
	end

	-- Create orange fish
	for r = 1,2 do
		local orangeFish = display.newSprite( mainGroup, imageSheet, { name="swim", start=1, count=2, time=200 } )
		orangeFish.x, orangeFish.y = 320-letterboxWidth, 60*r
		orangeFish:setFillColor( 1, 1, 0.5 )
		orangeFish.myName = "Orange Fish " .. r
		orangeFish.fill.effect = "filter.hue"
		orangeFish.fill.effect.angle = 250
		orangeFish.xScale = -1
		orangeFish:play()
		physics.addBody( orangeFish, "dynamic", { bounce=1, friction=0, radius=20 } )
		orangeFish.isFixedRotation = true
		orangeFish:applyLinearImpulse( (math.random(2,6)/50)*-1, 0, orangeFish.x, orangeFish.y )
		-- Add local collision detection to this fish (an alternative to global detection set via line 105)
		orangeFish.collision = onLocalCollision
		orangeFish:addEventListener( "collision" )
	end

	--local msg = display.newText( mainGroup, "Drag or fling the ball to bounce", 0, 0, appFont, 13 )
	--msg:setFillColor( 1, 0.4, 0.25 )

	local counter = 60
	local msg = display.newText(counter,0,0,native.systemFrontBold,64)
	msg.x = display.contentCenterX
	msg.y = 100
	 
	local function updateTimer(event)
	    counter = counter - 1
	    msg.text = counter
	    if counter == 0 then
	         native.showAlert( "Corona", "Game Finished... You Won!!!" 	 )
	    end
	end
	 
	timer.performWithDelay(1000, updateTimer, 60)




	local ball = display.newCircle( mainGroup, 0, 0, 15 )
	ball:setFillColor( 0.95, 0.1, 0.3 )
	ball.xScale = -1
	ball.myName = "myball"
	physics.addBody( ball,  "static" , { bounce=0, friction=0, radius=15 } )
	ball.isFixedRotation = true
	--ball:applyLinearImpulse( (math.random(2,6)/50)*-1, 0, ball.x, ball.y )
		-- Add local collision detection to this fish (an alternative to global detection set via line 105)
	ball.collision = onLocalBallCollision
	ball:addEventListener( "collision" )



	local function onMoveBall( event )

		local timePassed = event.time - lastTime
		lastTime = lastTime + timePassed

		speedY = speedY + gravity

		ball.x = ball.x + ( speedX * timePassed )
		ball.y = ball.y + ( speedY * timePassed )

		if ( ball.x >= screenW - ( ball.width * 0.5 ) ) then
			ball.x = screenW - ( ball.width * 0.5 )
			speedX = speedX * friction
			speedX = speedX * -1  -- Change direction
		elseif ( ball.x <= display.screenOriginX + ( ball.width * 0.5 ) ) then
		    ball.x = display.screenOriginX + ( ball.width * 0.5 )
			speedX = speedX * friction
			speedX = speedX * -1  -- Change direction
		end

		if ( ball.y >= screenH - ( ball.height * 0.5 ) ) then
			ball.y = screenH - ( ball.height * 0.5 )
			speedY = speedY * friction
			speedX = speedX * friction
			speedY = speedY * -1  -- Change direction
		elseif ( ball.y <= display.screenOriginY + ( ball.height * 0.5 ) ) then
			ball.y = display.screenOriginY + ( ball.height * 0.5 )
			speedY = speedY * friction
			speedY = speedY * -1  -- Change direction
		end
	end

	-- Function to track velocity (for fling)
	local function trackVelocity( event )

		local timePassed = event.time - prevTime
		prevTime = prevTime + timePassed
		speedX = ( ball.x - prevX ) / timePassed
		speedY = ( ball.y - prevY ) / timePassed
		prevX = ball.x
		prevY = ball.y
	end

	-- General function for dragging objects
	local function startDrag( event )

		local t = event.target
		local phase = event.phase

		if ( "began" == phase ) then

			-- Set touch focus on ball
			display.currentStage:setFocus( t )
			t.isFocus = true

			-- Store initial touch position
			t.x0 = event.x - t.x
			t.y0 = event.y - t.y

			-- Stop ball's current motion, if any
			Runtime:removeEventListener( "enterFrame", onMoveBall )
			-- Start tracking velocity
			Runtime:addEventListener( "enterFrame", trackVelocity )

		elseif ( t.isFocus ) then

			if ( "moved" == phase ) then

				t.x = event.x - t.x0
				t.y = event.y - t.y0

				-- Force pseudo-touch of "ended" if ball is dragged past any screen edge
				if ( ( t.x > screenW - ( t.width * 0.5 ) ) or
					 ( t.x < display.screenOriginX + ( t.width * 0.5 ) ) or
					 ( t.y > screenH - ( t.height * 0.5 ) ) or
					 ( t.y < display.screenOriginY + ( t.height * 0.5 ) )
				) then
					t:dispatchEvent( { name="touch", phase="ended", target=t, time=event.time } )
				end

			elseif ( "ended" == phase or "cancelled" == phase ) then

				lastTime = event.time

				-- Stop tracking velocity
				Runtime:removeEventListener( "enterFrame", trackVelocity )
				-- Start ball's motion
				Runtime:addEventListener( "enterFrame", onMoveBall )

				-- Release touch focus from ball
				display.currentStage:setFocus( nil )
				t.isFocus = false
			end
		end
		return true
	end

	-- Resize event handler
	local function onResizeEvent( event )

		screenW = display.contentWidth - display.screenOriginX
		screenH = display.contentHeight - display.screenOriginY

		msg.x = display.contentCenterX
		msg.y = 55 + display.screenOriginY

		-- Reset ball location to center of the screen
		ball.x = display.contentCenterX
		ball.y = display.contentCenterY
	end

	-- Set up orientation initially after the app starts
	onResizeEvent()

	Runtime:addEventListener( "resize", onResizeEvent )
	Runtime:addEventListener( "enterFrame", onMoveBall )
	ball:addEventListener( "touch", startDrag )


-- Obtain collision positions in content coordinates
physics.setReportCollisionsInContentCoordinates( true )

-- Obtain an average of all collision positions
physics.setAverageCollisionPositions( true )

-- Physics "draw mode" buttons

-- Include callback function for showing/hiding info box
-- In this sample, the physics draw mode is adjusted when appropriate
sampleUI.onInfoEvent = function( event )

	if ( event.action == "show" and event.phase == "will" ) then
		physics.setDrawMode( "normal" )
	elseif ( event.action == "hide" and event.phase == "did" ) then
		physics.setDrawMode( currentDrawMode )
	end
end


end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
		physics.start()
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
		physics.stop()
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
	
end

function scene:destroy( event )

	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	local sceneGroup = self.view
	
	package.loaded[physics] = nil
	physics = nil
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene