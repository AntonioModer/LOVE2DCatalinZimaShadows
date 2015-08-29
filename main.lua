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

TODO:
	-+ освещение объектов
		-+ нужно рисовать свет на непрозрачных пикселях
			+ shader.shadowsCZ.byAntonioModer.blendMode.lightOnPixels
			- new blendModes in LOVE 0.9.2 API:
				- multiplicative from LOVE 0.8.0
				-? shader.shadowsCZ.byAntonioModer.blendMode.lightOnPixels
		- testing on this: http://www.andersriggelsen.dk/glblendfunc.php
		- (https://love2d.org/forums/viewtopic.php?f=4&t=14823#p78416)
	- translate comments to english
==========================================================================]]

if arg[#arg] == "-debug" then require("mobdebug").start() end																							-- ZeroBraneStudio debuger


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
	
	shader.shadowsCZ.byAntonioModer = {}
--	shader.shadowsCZ.byAntonioModer.computeDistances = love.graphics.newShader([[byAntonioModer/computeDistances.glsl]])	
--	shader.shadowsCZ.byAntonioModer.distort = love.graphics.newShader([[byAntonioModer/distort.glsl]])
--	shader.shadowsCZ.byAntonioModer.horizontalReduction = love.graphics.newShader([[byAntonioModer/horizontalReduction.glsl]])
--	shader.shadowsCZ.byAntonioModer.drawShadows = love.graphics.newShader([[byAntonioModer/drawShadows.glsl]])
	shader.shadowsCZ.byAntonioModer.lightGradient = love.graphics.newShader([[
	vec4 effect(vec4 color, Image texture, vec2 texCoord, vec2 screenCoord) {
		//texCoord.y = 1-texCoord.y;
		vec4 pixel = Texel(texture, texCoord);
		
		// Distance of this pixel from the center
		number dist = distance(texCoord, vec2(0.5, 0.5));
		
		pixel *= 0.6;									// яркость света (brightness); 0.0 ... 1.0
		pixel.a = 1.0 - (dist * 2.0);					// градиент радиальный; (* ...) - это чтобы за текстуру не светил		
		
		return pixel;
	}
	]])
	-- https://love2d.org/wiki/BlendMode_Formulas
	shader.shadowsCZ.byAntonioModer.blendMode = {}
	shader.shadowsCZ.byAntonioModer.blendMode.multiplicativeOld = love.graphics.newShader([[
	extern Image dstTexture;
	extern vec2 dstTextureSize = vec2(0, 0);
	
	vec4 effect(vec4 color, Image texture, vec2 texCoord, vec2 screenCoord) {
		screenCoord.y = dstTextureSize.y-screenCoord.y;											// BUG?
		vec4 pixel = Texel(texture, texCoord);
		vec4 res;
		vec4 dst = Texel(dstTexture, vec2(screenCoord.x/dstTextureSize.x, screenCoord.y/dstTextureSize.y));
		vec4 src = pixel*color;
		
		res.r = dst.r * (1 - src.a) + src.r * dst.r;
		res.g = dst.g * (1 - src.a) + src.g * dst.g;
		res.b = dst.b * (1 - src.a) + src.b * dst.b;
		res.a = dst.a * (1 - src.a) + src.a * dst.a;
		
		return res;
	}
	]])
	shader.shadowsCZ.byAntonioModer.blendMode.alpha = love.graphics.newShader([[
	extern Image dstTexture;
	extern vec2 dstTextureSize = vec2(0, 0);
	
	vec4 effect(vec4 color, Image texture, vec2 texCoord, vec2 screenCoord) {
		screenCoord.y = dstTextureSize.y-screenCoord.y;											// BUG?
		vec4 pixel = Texel(texture, texCoord);
		vec4 res;
		vec4 dst = Texel(dstTexture, vec2(screenCoord.x/dstTextureSize.x, screenCoord.y/dstTextureSize.y));
		vec4 src = pixel*color;
		
		res.r = (dst.r * (1 - src.a)) + (src.r * src.a);
		res.g = (dst.g * (1 - src.a)) + (src.g * src.a);
		res.b = (dst.b * (1 - src.a)) + (src.b * src.a);
		res.a = (dst.a * (1 - src.a)) + src.a;
		
		return res;
	}
	]])
	shader.shadowsCZ.byAntonioModer.blendMode.additive = love.graphics.newShader([[
	extern Image dstTexture;
	extern vec2 dstTextureSize = vec2(0, 0);
	
	vec4 effect(vec4 color, Image texture, vec2 texCoord, vec2 screenCoord) {
		screenCoord.y = dstTextureSize.y-screenCoord.y;											// BUG?
		vec4 pixel = Texel(texture, texCoord);
		vec4 res;
		vec4 dst = Texel(dstTexture, vec2(screenCoord.x/dstTextureSize.x, screenCoord.y/dstTextureSize.y));
		vec4 src = pixel*color;
		
		res.r = dst.r + (src.r * src.a);
		res.g = dst.g + (src.g * src.a);
		res.b = dst.b + (src.b * src.a);
		res.a = dst.a + (src.a * src.a);
		
		return res;
	}
	]])	
	shader.shadowsCZ.byAntonioModer.blendMode.lightOnPixels = love.graphics.newShader([[
	extern Image dstTexture;
	extern vec2 dstTextureSize = vec2(0, 0);
	
	vec4 effect(vec4 color, Image texture, vec2 texCoord, vec2 screenCoord) {
		screenCoord.y = dstTextureSize.y-screenCoord.y+(love_ScreenSize.y-dstTextureSize.y);											// BUG?
		vec4 pixel = Texel(texture, texCoord);
		vec4 res;
		vec4 dst = Texel(dstTexture, vec2(screenCoord.x/dstTextureSize.x, screenCoord.y/dstTextureSize.y));
		vec4 src = pixel*color;
		
		if (dst.a > 0.0) {
			// additive blend mode
			res.r = dst.r + (src.r * src.a);
			res.g = dst.g + (src.g * src.a);
			res.b = dst.b + (src.b * src.a);
			res.a = dst.a + (src.a * src.a);			
		}
		
		return res;
	}
	]])

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
	image.shadowsCZ[4] = love.graphics.newImage([[shadowTest4.png]], 'normal')
	image.shadowsCZ[4]:setFilter('nearest', 'nearest')		
	
	image.shadowsCZ.current = image.shadowsCZ[1]
	image.shadowsCZ.counter = 1
	image.shadowsCZ.counterMax = 4
	
	image.light = love.graphics.newImage([[light3.png]], 'normal')
	image.test = love.graphics.newImage([[test.png]], 'normal')
	
	-- canvases -----------------------------------------------------------------------------------------------------------------------------------
	canvas = {}
	
	canvas.main = {}
	canvas.main.obj = love.graphics.newCanvas(800, 600, 'normal')
	
	canvas.shadowsCZ = {}
	canvas.shadowsCZ[1] = love.graphics.newCanvas(image.shadowsCZ[1]:getWidth(), image.shadowsCZ[1]:getHeight(), 'normal')
	canvas.shadowsCZ[1]:setFilter('nearest', 'nearest')
	
	canvas.shadowsCZ[2] = love.graphics.newCanvas(image.shadowsCZ[1]:getWidth(), image.shadowsCZ[1]:getHeight(), 'normal')
	canvas.shadowsCZ[2]:setFilter('nearest', 'nearest')
	
	-------------------------------------
	light = {}
	light.computeShadows = true
	
end

function love.keypressed(key)
	if key == " " then
		light.computeShadows = true
		if image.shadowsCZ.counter == image.shadowsCZ.counterMax then image.shadowsCZ.counter = 0 end
		image.shadowsCZ.counter = image.shadowsCZ.counter + 1
		image.shadowsCZ.current = image.shadowsCZ[image.shadowsCZ.counter]
	end
end

function love.update(dt)
	
end

function love.draw()
	
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(image.background)
	
	if light.computeShadows then
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
	
	-- not done
	if false then
		love.graphics.setShader(shader.shadowsCZ.byAntonioModer.circle)
	end
	
	-- текстура света с тенями
	if true then
		love.graphics.setShader()
		canvas.shadowsCZ[1]:clear()
		love.graphics.setCanvas(canvas.shadowsCZ[1])
		
	
--		love.graphics.setBlendMode( 'additive' )
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.draw(image.light, 0, 0, 0, 512/512)													-- можно делать различные эффекты
--		love.graphics.setBlendMode( 'alpha' )
		
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.draw(canvas.shadowsCZ[2])
		
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.draw(image.shadowsCZ.current)		
		
	end
	
	love.graphics.setShader()
	love.graphics.setCanvas()
	
	light.computeShadows = false
	end
	
	--[[
	TODO:
		- 
	--]]
	
	-- test BlendMode
	if false then
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.setBlendMode('premultiplied')
		love.graphics.draw(image.test)
		love.graphics.setBlendMode('alpha')
	end
	
	-- test BlendMode on shader
	if false then
		canvas.main.obj:clear()
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.setCanvas(canvas.main.obj)
--		love.graphics.setBlendMode('premultiplied')
		love.graphics.draw(image.background)
		love.graphics.draw(image.shadowsCZ.current)
--		love.graphics.setBlendMode('alpha')
		love.graphics.setCanvas()
		
		shader.shadowsCZ.byAntonioModer.blendMode.multiplicativeOld:send('dstTexture', canvas.main.obj)
		shader.shadowsCZ.byAntonioModer.blendMode.multiplicativeOld:send('dstTextureSize', {800.0, 600.0})
		love.graphics.setShader(shader.shadowsCZ.byAntonioModer.blendMode.multiplicativeOld)
--		love.graphics.setBlendMode('multiplicative')		
		love.graphics.setColor(255, 255, 255, 4)
		love.graphics.draw(image.light)
--		love.graphics.setBlendMode('alpha')
		love.graphics.setShader()
	end
	
	-- final
	if true then
		-- предметы
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.draw(image.shadowsCZ.current)
		
		-- глобальный свет (солнце)
		local lBGlobal = 0.23								-- яркость света (light brightness); 0.0 ... 1.0
		if lBGlobal > 1.0 then lBGlobal = 1.00 elseif lBGlobal < 0 then lBGlobal = 0 end
		canvas.main.obj:clear(255*lBGlobal, 255*lBGlobal, 255*lBGlobal, 255)
		love.graphics.setCanvas(canvas.main.obj)
		
		-- локальный свет
		local lightColor = {r=255, g=255, b=255, a=255}
		local lightBrightness = 1.49									-- яркость света (brightness); 0.0 ... 1.0
		if lightBrightness > 1.0 then lightBrightness = 1.00 elseif lightBrightness < 0 then lightBrightness = 0 end
		love.graphics.setColor(lightColor.r*lightBrightness, lightColor.g*lightBrightness, lightColor.b*lightBrightness, lightColor.a)			-- цвет света		
		love.graphics.setBlendMode('screen')							-- screen or additive
--		love.graphics.draw(image.light, 0, 0, 0, 512/512)				-- без тени
--		love.graphics.setBlendMode('alpha')
		-- с тенью
--		love.graphics.setBlendMode('multiplicative')
--		love.graphics.setColor(255, 255, 255, 255-(255*lBGlobal))
		love.graphics.draw(canvas.shadowsCZ[1])		
		love.graphics.setBlendMode('alpha')
		
		love.graphics.setCanvas()
		
		-- результат ---------------------
		
		-- old multiplicative
--		shader.shadowsCZ.byAntonioModer.blendMode.multiplicativeOld:send('dstTexture', image.shadowsCZ.current)
--		shader.shadowsCZ.byAntonioModer.blendMode.multiplicativeOld:send('dstTextureSize', {512.0, 512.0})
--		love.graphics.setShader(shader.shadowsCZ.byAntonioModer.blendMode.multiplicativeOld)
		
		love.graphics.setBlendMode('multiplicative')
		local brightness = 1.11								-- яркость (brightness); 0.0 ... 1.0
		if brightness > 1.0 then brightness = 1.00 elseif brightness < 0 then brightness = 0 end
		love.graphics.setColor(255*brightness, 255*brightness, 255*brightness, 255)
		love.graphics.draw(canvas.main.obj)
		love.graphics.setShader()
		
		-- чтобы глобальный свет не перекрывал локальный
		local lightBrightness = 1.00								-- яркость света (brightness); 0.0 ... 1.0
		if lightBrightness > 1.0 then lightBrightness = 1.00 elseif lightBrightness < 0 then lightBrightness = 0 end
		love.graphics.setColor(lightColor.r*lightBrightness, lightColor.g*lightBrightness, lightColor.b*lightBrightness, 50)		
		love.graphics.setBlendMode('additive')
--		love.graphics.draw(image.light, 0, 0, 0, 512/512)										-- без тени
--		love.graphics.draw(canvas.shadowsCZ[1])													-- с тенью
		
		love.graphics.setBlendMode('alpha')
	end
	---------------------------------------
	
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.rectangle('fill', 8, 10, 200, 15*2)	
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.print('FPS: '..love.timer.getFPS(), 10, 10)
	love.graphics.print('Press SPACE to change image', 10, 23)
end
