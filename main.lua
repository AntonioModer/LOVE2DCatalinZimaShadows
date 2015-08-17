--[[======================================================================

#LOVE2D Catalin Zima's shadows

This is "pixel-accuracy" 2D-shadows.
Shadows compute fully on the GPU's pixel-shaders.
Need GLSL 1.20 (OpenGL 2.1).

LÖVE 2D-framework: http://love2d.org
Catalin Zima's shadows: http://www.catalinzima.com/2010/07/my-technique-for-the-shader-based-dynamic-2d-shadows/
Sources: http://github.com/AntonioModer/LOVE2DCatalinZimaShadows

Used GLSL-shaders from: http://bitbucket.org/totorigolo/shadows
Thanks to:
  Catalin Zima (http://www.catalinzima.com/about/)
  Thomas Lacroix (http://plus.google.com/b/107248556103962831257/109936266256123891803/about?pageId=107248556103962831257)

==========================================================================]]

function love.run()
	if love.math then
		love.math.setRandomSeed(os.time())
		for i=1,3 do love.math.random() end
	end

	if love.event then
		love.event.pump()
	end

	if love.load then love.load(arg) end
	if love.timer then love.timer.step() end
	local dt = 0
	
	-- Main loop time
	while true do
		if love.event then
			love.event.pump()
			for e, a, b, c, d in love.event.poll() do
				if e == "quit" then
					if not love.quit or not love.quit() then
						if love.audio then
							love.audio.stop()
						end
						return
					end
				end
				love.handlers[e](a, b, c, d)
			end
		end

		-- Update dt, as we'll be passing it to update
		if love.timer then
			love.timer.step()
			dt = love.timer.getDelta()
		end

		-- will pass 0 if love.timer is disabled
		if love.update then love.update(dt) end

		if love.window and love.graphics and love.window.isCreated() then
			love.graphics.clear()
			love.graphics.origin()
			if love.draw then love.draw() end
			love.graphics.present()
		end

		-- For what this delay?: http://www.love2d.org/wiki/Talk:love.run; http://love2d.org/forums/viewtopic.php?f=4&t=76998
--		if love.timer then love.timer.sleep(0.001) end
	end
end

function love.load(arg)
--	love.mouse.setVisible(false)
	love.keyboard.setKeyRepeat(true)
	
	-- shaders -----------------------------------------------------------------------------------------------------------------------------------
	shader = {}
	
	shader.shadowsCZ = {}																														-- Catalin Zima's shadows
	
--	shader.shadowsCZ.byAntonioModer = {}
--	shader.shadowsCZ.byAntonioModer.computeDistances = love.graphics.newShader([[byAntonioModer/computeDistances.glsl]])	
--	shader.shadowsCZ.byAntonioModer.distort = love.graphics.newShader([[byAntonioModer/distort.glsl]])
--	shader.shadowsCZ.byAntonioModer.horizontalReduction = love.graphics.newShader([[byAntonioModer/horizontalReduction.glsl]])
--	shader.shadowsCZ.byAntonioModer.drawShadows = love.graphics.newShader([[byAntonioModer/drawShadows.glsl]])
	
	-- https://bitbucket.org/totorigolo/shadows
	shader.shadowsCZ.byThomasLacroix = {}
	shader.shadowsCZ.byThomasLacroix.distort = love.graphics.newShader[[byThomasLacroix/distort.glsl]]
	shader.shadowsCZ.byThomasLacroix.reduce = love.graphics.newShader[[byThomasLacroix/reduce.glsl]]
	shader.shadowsCZ.byThomasLacroix.shadow = love.graphics.newShader[[byThomasLacroix/shadow.glsl]]	
	shader.shadowsCZ.byThomasLacroix.blurH = love.graphics.newShader[[byThomasLacroix/blurH.glsl]]
	shader.shadowsCZ.byThomasLacroix.blurV = love.graphics.newShader[[byThomasLacroix/blurV.glsl]]

	-- images -----------------------------------------------------------------------------------------------------------------------------------
	image = {}
	image.background = love.graphics.newImage([[background.png]])
	
	image.shadowsCZ = {}
	image.shadowsCZ[1] = love.graphics.newImage([[shadowTest1.png]], 'normal')
	image.shadowsCZ[1]:setFilter('nearest', 'nearest')
	image.shadowsCZ[2] = love.graphics.newImage([[shadowTest2.png]], 'normal')
	image.shadowsCZ[2]:setFilter('nearest', 'nearest')	
	image.shadowsCZ[3] = love.graphics.newImage([[shadowTest3.png]], 'normal')
	image.shadowsCZ[3]:setFilter('nearest', 'nearest')		
	
	image.shadowsCZ.current = image.shadowsCZ[1]
	image.shadowsCZ.counter = 1
	image.shadowsCZ.counterMax = 2
	
	-- canvases -----------------------------------------------------------------------------------------------------------------------------------
	canvas = {}
	
	canvas.shadowsCZ = {}
	canvas.shadowsCZ[1] = love.graphics.newCanvas(image.shadowsCZ[1]:getWidth(), image.shadowsCZ[1]:getHeight(), 'normal')
	canvas.shadowsCZ[1]:setFilter('nearest', 'nearest')
	
	canvas.shadowsCZ[2] = love.graphics.newCanvas(image.shadowsCZ[1]:getWidth(), image.shadowsCZ[1]:getHeight(), 'normal')
	canvas.shadowsCZ[2]:setFilter('nearest', 'nearest')
end

function love.keypressed(key)
	if key == " " then
		if image.shadowsCZ.counter == image.shadowsCZ.counterMax+1 then image.shadowsCZ.counter = 0 end
		image.shadowsCZ.counter = image.shadowsCZ.counter + 1
		image.shadowsCZ.current = image.shadowsCZ[image.shadowsCZ.counter]
	end
end

function love.update(dt)
	
end

function love.draw()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(image.background)
	
	-- Catalin Zima's shadows --------------------------------
	love.graphics.setColor(255, 255, 255, 255)
	
	if false then
		canvas.shadowsCZ[1]:clear()
		love.graphics.setCanvas(canvas.shadowsCZ[1])
--		love.graphics.setShader(shader.shadowsCZ.byAntonioModer.computeDistances)
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.draw(image.shadowsCZ.current)
		love.graphics.setColor(255, 255, 255, 255)
	end
	
	if true then
		canvas.shadowsCZ[2]:clear()
		love.graphics.setCanvas(canvas.shadowsCZ[2])
		love.graphics.setShader(shader.shadowsCZ.byThomasLacroix.distort)
--		love.graphics.setShader(shader.shadowsCZ.byAntonioModer.distort)
--		love.graphics.draw(canvas.shadowsCZ[1])
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.draw(image.shadowsCZ.current)
		love.graphics.setColor(255, 255, 255, 255)
	end
	
	if true then
		canvas.shadowsCZ[1]:clear()
		love.graphics.setCanvas(canvas.shadowsCZ[1])
		love.graphics.setShader(shader.shadowsCZ.byThomasLacroix.reduce)
		love.graphics.draw(canvas.shadowsCZ[2])
	--	love.graphics.draw(image.shadowsCZ)
	end
	
	if true then
		canvas.shadowsCZ[2]:clear()
		love.graphics.setCanvas(canvas.shadowsCZ[2])
		love.graphics.setShader(shader.shadowsCZ.byThomasLacroix.shadow)
	--	love.graphics.setShader(shader.shadowsCZ.byAntonioModer.drawShadows)
		love.graphics.draw(canvas.shadowsCZ[1])
	end
	
	if true then
		canvas.shadowsCZ[1]:clear()
		love.graphics.setCanvas(canvas.shadowsCZ[1])
		love.graphics.setShader(shader.shadowsCZ.byThomasLacroix.blurH)
		love.graphics.draw(canvas.shadowsCZ[2])
		
		canvas.shadowsCZ[2]:clear()
		love.graphics.setCanvas(canvas.shadowsCZ[2])
		love.graphics.setShader(shader.shadowsCZ.byThomasLacroix.blurV)
		love.graphics.draw(canvas.shadowsCZ[1])		
	end	
	
	love.graphics.setShader()
	love.graphics.setCanvas()
	
	
	love.graphics.draw(canvas.shadowsCZ[2])				-- shadows result
	love.graphics.draw(image.shadowsCZ.current)
	---------------------------------------
	
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.rectangle('fill', 8, 10, 200, 15*2)	
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.print('FPS: '..love.timer.getFPS(), 10, 10)
	love.graphics.print('Press SPACE to change image', 10, 23)
end
