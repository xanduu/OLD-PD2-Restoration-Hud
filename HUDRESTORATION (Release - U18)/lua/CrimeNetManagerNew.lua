if Restoration.options.crimenet == true then

CrimeNetGui = CrimeNetGui or class()
function CrimeNetManager:init()
	self._tweak_data = tweak_data.gui.crime_net
	self._active = false
	self._active_jobs = {}
	self:_setup_vars()
end

function CrimeNetGui:_create_polylines()
	local regions = tweak_data.gui.crime_net.regions
	
	if alive( self._region_panel ) then
		self._map_panel:remove( self._region_panel )
		self._region_panel = nil
	end
	self._region_panel = self._map_panel:panel( { halign="scale", valign="scale" } )
	self._region_locations = {}
	
	local xs
	local ys
	
	local num
	local vectors
	
	local my_polyline
	local tw = math.max( self._map_panel:child("map"):texture_width(), 1 )
	local th = math.max( self._map_panel:child("map"):texture_height(), 1 )
	
	local region_text_data
	local region_text
	local x, y
	for _, region in ipairs( regions ) do
		xs = region[1]
		ys = region[2]
		num = math.min( #xs, #ys )
		
		
		--[[vectors = {}
		my_polyline = self._region_panel:polyline( { line_width=2, alpha=0.6, layer=1, closed=region.closed, blend_mode="add", halign="scale", valign="scale", color=tweak_data.screen_colors.crimenet_lines } )
		for i=1, num do
			table.insert( vectors, Vector3( (xs[i]) / tw * self._map_size_w * self._zoom, (ys[i]) / th * self._map_size_h * self._zoom, 0 ) )
		end
		my_polyline:set_points( vectors )
		
		vectors = {}
		my_polyline = self._region_panel:polyline( { line_width=5, alpha=0.2, layer=1, closed=region.closed, blend_mode="add", halign="scale", valign="scale", color=tweak_data.screen_colors.crimenet_lines } )
		for i=1, num do
			table.insert( vectors, Vector3( (xs[i]) / tw * self._map_size_w * self._zoom, (ys[i]) / th * self._map_size_h * self._zoom, 0 ) )
		end
		my_polyline:set_points( vectors )]]
		
		
		region_text_data = region.text
		if region_text_data then
			x = region_text_data.x / tw * self._map_size_w * self._zoom
			y = region_text_data.y / th * self._map_size_h * self._zoom
			
			if region_text_data.title_id then
				region_text = self._region_panel:text( { font = tweak_data.menu.pd2_large_font, font_size = tweak_data.menu.pd2_large_font_size, text = managers.localization:to_upper_text(region_text_data.title_id), layer = 1, alpha = 0.6, blend_mode = "add", halign = "scale", valign = "scale", rotation=0 } )
				local _, _, w, h = region_text:text_rect()
				region_text:set_size( w, h )
				region_text:set_center( x, y )
				table.insert( self._region_locations, { object=region_text, size=region_text:font_size() } )
			end
			
			if region_text_data.sub_id then
				region_text = self._region_panel:text( { font = tweak_data.menu.pd2_small_font, font_size = tweak_data.menu.pd2_small_font_size, text = managers.localization:to_upper_text(region_text_data.sub_id), align = "center", vertical = "center", layer = 1, alpha = 0.6, blend_mode = "add", halign = "scale", valign = "scale", rotation=0 } )
				local _, _, w, h = region_text:text_rect()
				region_text:set_size( w, h )
				
				if region_text_data.title_id then
					region_text:set_position( self._region_locations[ #self._region_locations ].object:left(), self._region_locations[ #self._region_locations ].object:bottom() - 5 )
				else
					region_text:set_center( x, y )
				end
				
				table.insert( self._region_locations, { object=region_text, size=region_text:font_size() } )
			end
		end
	end
	
	if Application:production_build() and tweak_data.gui.crime_net.debug_options.regions then
		for _, data in ipairs( tweak_data.gui.crime_net.locations ) do
			local location = data[1]
			if location and location.dots then
				for _, dot in ipairs( location.dots ) do
					self._region_panel:rect( { w=1, h=1, color=Color.red, x=dot[1] / tw * self._map_size_w * self._zoom, y=dot[2] / th * self._map_size_h * self._zoom, halign="scale", valign="scale", layer=1000 } )
				end
			end
		end
	end
	
	--[[
	if Application:production_build() and tweak_data.gui.crime_net.debug_options.regions then
		regions = tweak_data.gui.crime_net.locations
		for _, region_data in ipairs( regions ) do
			local region = region_data[1]
			xs = region[1]
			ys = region[2]
			num = math.min( #xs, #ys )
			
			vectors = {}
			my_polyline = self._region_panel:polyline( { line_width=2, alpha=0.5, layer=2, closed=true, blend_mode="add", halign="scale", valign="scale", color=Color.red } )
			for i=1, num do
				table.insert( vectors, Vector3( xs[i] / tw * self._map_size_w * self._zoom, ys[i] / th * self._map_size_h * self._zoom, 0 ) )
			end
			my_polyline:set_points( vectors )
		end
	end]]
end

function CrimeNetGui:update(t, dt)
	self._rasteroverlay:set_texture_rect(0, -math.mod(Application:time() * 5, 32), 32, 640)
	if self._released_map then
		self._released_map.dx = math.lerp(self._released_map.dx, 0, dt * 2)
		self._released_map.dy = math.lerp(self._released_map.dy, 0, dt * 2)
		self:_set_map_position(self._released_map.dx, self._released_map.dy)
		if self._map_panel:x() >= -5 or -5 <= self._fullscreen_panel:w() - self._map_panel:right() then
			self._released_map.dx = 0
		end
		if -5 <= self._map_panel:y() or -5 <= self._fullscreen_panel:h() - self._map_panel:bottom() then
			self._released_map.dy = 0
		end
		self._released_map.t = self._released_map.t - dt
		if 0 > self._released_map.t then
			self._released_map = nil
		end
	end
	if not self._grabbed_map then
		local speed = 5
		if self._map_panel:x() > -self:_get_pan_panel_border() then
			local mx = math.lerp(0, -self:_get_pan_panel_border() - self._map_panel:x(), dt * speed)
			self:_set_map_position(mx, 0)
		end
		if self._fullscreen_panel:w() - self._map_panel:right() > -self:_get_pan_panel_border() then
			local mx = math.lerp(0, self:_get_pan_panel_border() - (self._map_panel:right() - self._fullscreen_panel:w()), dt * speed)
			self:_set_map_position(mx, 0)
		end
		if self._map_panel:y() > -self:_get_pan_panel_border() then
			local my = math.lerp(0, -self:_get_pan_panel_border() - self._map_panel:y(), dt * speed)
			self:_set_map_position(0, my)
		end
		if self._fullscreen_panel:h() - self._map_panel:bottom() > -self:_get_pan_panel_border() then
			local my = math.lerp(0, self:_get_pan_panel_border() - (self._map_panel:bottom() - self._fullscreen_panel:h()), dt * speed)
			self:_set_map_position(0, my)
		end
	end
	if not managers.menu:is_pc_controller() and managers.mouse_pointer:mouse_move_x() == 0 and managers.mouse_pointer:mouse_move_y() == 0 then
		local closest_job
		local closest_dist = 100000000
		local closest_job_x, closest_job_y = 0, 0
		local mouse_pos_x, mouse_pos_y = managers.mouse_pointer:modified_mouse_pos()
		local job_x, job_y
		local dist = 0
		local x, y
		for id, job in pairs(self._jobs) do
			job_x, job_y = job.marker_panel:child("select_panel"):world_center()
			x = job_x - mouse_pos_x
			y = job_y - mouse_pos_y
			dist = x * x + y * y
			if closest_dist > dist then
				closest_job = job
				closest_dist = dist
				closest_job_x = job_x
				closest_job_y = job_y
			end
		end
		if closest_job then
			closest_dist = math.sqrt(closest_dist)
			if closest_dist < self._tweak_data.controller.snap_distance then
				managers.mouse_pointer:force_move_mouse_pointer(math.lerp(mouse_pos_x, closest_job_x, dt * self._tweak_data.controller.snap_speed) - mouse_pos_x, math.lerp(mouse_pos_y, closest_job_y, dt * self._tweak_data.controller.snap_speed) - mouse_pos_y)
			end
		end
	end
end

function CrimeNetGui:set_players_online( players )
	local players_string = managers.money:add_decimal_marks_to_string( string.format( "%.3d", players ) )
end

function CrimeNetGui:toggle_legend()
	managers.menu_component:post_event( "menu_enter" )
end

function CrimeNetGui:mouse_pressed( o, button, x, y )
	if( not self._crimenet_enabled ) then
		return
	end
	
	-- if not self._panel:inside( x, y ) then
	-- 	return
	-- end
	--[[
	if self._text_box and self._text_box:visible() then
		if self:mouse_button_click( button ) then
			for i,panel in ipairs( self._text_box._text_box_buttons_panel:children() ) do
				if panel.child and panel:inside( x, y ) then
					if self._text_box:get_focus_button() == 1 then
						self:start_job()
					end
					return true
				end
			end
			
			if self._text_box:check_close( x, y ) then
				self._text_box:set_visible( false )
				for id,job in pairs( self._jobs ) do
					job.expanded = false
				end
				return true
			end
			if self._text_box:check_grab_scroll_bar( x, y ) then
				return true
			end
		elseif self:button_wheel_scroll_down( button ) then
			if self._text_box:mouse_wheel_down( x, y ) then
				return true
			end
		elseif self:button_wheel_scroll_up( button ) then
			if self._text_box:mouse_wheel_up( x, y ) then
				return true
			end
		end
	end
	]]
	
	if self:mouse_button_click( button ) then
		if( self._panel:child("back_button"):inside( x, y ) ) then
			managers.menu:back()
			return
		end
		if( self._panel:child("legends_button"):inside( x, y ) ) then
			self:toggle_legend()
			return
		end
		if self._panel:child("filter_button") and self._panel:child("filter_button"):inside( x, y ) then
			managers.menu_component:post_event( "menu_enter" )
			managers.menu:open_node( "crimenet_filters", {} )
			return
		end
		
		if self:check_job_pressed( x, y ) then
			return true
		end
		
		
		if self._panel:inside( x, y ) then
			self._released_map = nil
			-- self._grabbed_map = { x = x - self._pan_panel:x(), y = y - self._pan_panel:y() } 
			-- self._grabbed_map = { x = -self._panel:x() + x, y = -self._panel:y() + y }
			self._grabbed_map = { x = x, y = y, dirs = {} }
		end
		
	elseif self:button_wheel_scroll_down( button ) then
		if( self._one_scroll_out_delay ) then
			self._one_scroll_out_delay = nil
			-- return true		-- disabling for now
		end
		self:_set_zoom( "out", x, y )
		return true
	elseif self:button_wheel_scroll_up( button ) then
		if( self._one_scroll_in_delay ) then
			self._one_scroll_in_delay = nil
			-- return true		-- disabling for now
		end
		self:_set_zoom( "in", x, y )
		return true
	end
	
	return true
end
--[[
function CrimeNetGui:start_job()
	for id,job in pairs( self._jobs ) do
		if job.expanded then
			if job.preset_id then
				-- MenuCallbackHandler:start_job( job.job_id )
				MenuCallbackHandler:start_job( job )
				self:remove_job( job.preset_id )
				return true
			else
				print( "Is a server, don't want to join", id, job.side_panel:child("host_name"):text() == "WWWWWWWWWWWWµQQW" )
				-- if job.host_name:text() == "WWWWWWWWWWWWµQQW" or job.host_name:text() == "Gaspode" then
					managers.network.matchmake:join_server_with_check( id )
				-- end
				return
			end
		end
	end
end
]]
function CrimeNetGui:mouse_released( o, button, x, y )
	if( not self._crimenet_enabled ) then
		return
	end
	if( not self:mouse_button_click( button ) ) then
		return
	end

	if self._grabbed_map and #self._grabbed_map.dirs > 0 then
		local dx, dy = 0, 0
		for _,values in ipairs( self._grabbed_map.dirs ) do
			dx = dx + values[1]
			dy = dy + values[2]
		end
		dx = dx/#self._grabbed_map.dirs
		dy = dy/#self._grabbed_map.dirs
				
		self._released_map = { t = 2, dx = dx, dy = dy }
		self._grabbed_map = nil
	end 
		
	-- return self._text_box:release_scroll_bar()
end
--[[
function CrimeNetGui:_get_pan_panel_border()
	return self._pan_panel_border * self._zoom
end
]]
function CrimeNetGui:_set_map_position( mx, my )
	--[[
	local x = math.clamp( self._map_panel:x() + mx, self._fullscreen_panel:w() - self._map_panel:w(), 0 ) 
	local y = math.clamp( self._map_panel:y() + my, self._fullscreen_panel:h() - self._map_panel:h(), 0 )
	
	self._pan_panel:set_position( x, y )]]
	
	-- local x = self._map_panel:x() + mx
	-- local y = self._map_panel:y() + my
	
	local x = self._map_x + mx
	local y = self._map_y + my
	
	self._pan_panel:set_position( x, y )
	if self._pan_panel:left() > 0 then
		self._pan_panel:set_left( 0 )
	end
	
	if self._pan_panel:right() < self._fullscreen_panel:w() then
		self._pan_panel:set_right( self._fullscreen_panel:w() )
	end
	
	if self._pan_panel:top() > 0 then
		self._pan_panel:set_top( 0 )
	end
	
	if self._pan_panel:bottom() < self._fullscreen_panel:h() then
		self._pan_panel:set_bottom( self._fullscreen_panel:h() )
	end
	self._map_x, self._map_y = self._pan_panel:position()
	
	self._pan_panel:set_position( math.round(self._map_x), math.round(self._map_y) )
	x, y = self._map_x, self._map_y
	
	self._map_panel:set_shape( self._pan_panel:shape() )
	self._pan_panel:set_position( managers.gui_data:full_16_9_to_safe( x, y ) )
	
	
	local full_16_9 = managers.gui_data:full_16_9_size()
	
	local w_ratio = self._fullscreen_panel:w() / self._map_panel:w()
	local h_ratio = self._fullscreen_panel:h() / self._map_panel:h()
	local panel_x = -(self._map_panel:x() / self._fullscreen_panel:w()) * w_ratio
	local panel_y = -(self._map_panel:y() / self._fullscreen_panel:h()) * h_ratio
	
	
	local cross_indicator_h1 = self._fullscreen_panel:child( "cross_indicator_h1" )
	local cross_indicator_h2 = self._fullscreen_panel:child( "cross_indicator_h2" )
	local cross_indicator_v1 = self._fullscreen_panel:child( "cross_indicator_v1" )
	local cross_indicator_v2 = self._fullscreen_panel:child( "cross_indicator_v2" )
	
	--[[local line_indicator_h1 = self._fullscreen_panel:child( "line_indicator_h1" )
	local line_indicator_h2 = self._fullscreen_panel:child( "line_indicator_h2" )
	local line_indicator_v1 = self._fullscreen_panel:child( "line_indicator_v1" )
	local line_indicator_v2 = self._fullscreen_panel:child( "line_indicator_v2" )]]
		
	cross_indicator_h1:set_y( full_16_9.convert_y + (self._panel:h() * panel_y) )
	cross_indicator_h2:set_bottom( self._fullscreen_panel:child( "cross_indicator_h1" ):y() + (self._panel:h() * h_ratio) )
	cross_indicator_v1:set_x( full_16_9.convert_x + (self._panel:w() * panel_x) )
	cross_indicator_v2:set_right( self._fullscreen_panel:child( "cross_indicator_v1" ):x() + (self._panel:w() * w_ratio) )
	
	--[[line_indicator_h1:set_position( cross_indicator_v1:x(), cross_indicator_h1:y() )
	line_indicator_h2:set_position( cross_indicator_v1:x(), cross_indicator_h2:y() )
	line_indicator_v1:set_position( cross_indicator_v1:x(), cross_indicator_h1:y() )
	line_indicator_v2:set_position( cross_indicator_v2:x(), cross_indicator_h1:y() )
	
	line_indicator_h1:set_w( cross_indicator_v2:x() - cross_indicator_v1:x() )
	line_indicator_h2:set_w( cross_indicator_v2:x() - cross_indicator_v1:x() )
	line_indicator_v1:set_h( cross_indicator_h2:y() - cross_indicator_h1:y() )
	line_indicator_v2:set_h( cross_indicator_h2:y() - cross_indicator_h1:y() )]]
end

function CrimeNetGui:mouse_moved( o, x, y )
	if( not self._crimenet_enabled ) then
		return
	end
	-- self._pan_panel:child( "test" ):set_position( -self._panel:x() - self._pan_panel:x() + x, -self._panel:y() - self._pan_panel:y() + y )
	
	if managers.menu:is_pc_controller() then
		if( self._panel:child("back_button"):inside( x, y ) ) then
			if not self._back_highlighted then
				self._back_highlighted = true
				self._panel:child("back_button"):set_color( tweak_data.screen_color_yellow_selected )
				managers.menu_component:post_event( "highlight" )
			end
			return false, "arrow"
		elseif self._back_highlighted then
			self._back_highlighted = false
			self._panel:child("back_button"):set_color( tweak_data.screen_color_yellow )
		end

	end
	
	if self._grabbed_map then
		local left = x > self._grabbed_map.x
		local right = not left
		local up = y > self._grabbed_map.y
		local down = not up
		local mx = x - self._grabbed_map.x
		local my = y - self._grabbed_map.y
		
		if left and self._map_panel:x() > -self:_get_pan_panel_border() then
			mx = math.lerp( mx, 0, 1 - self._map_panel:x()/-self:_get_pan_panel_border() )
		end
		if right and self._fullscreen_panel:w() - self._map_panel:right() > -self:_get_pan_panel_border() then
			mx = math.lerp( mx, 0, 1 - (self._fullscreen_panel:w() - self._map_panel:right())/-self:_get_pan_panel_border() )
		end
		if up and self._map_panel:y() > -self:_get_pan_panel_border() then
			my = math.lerp( my, 0, 1 - self._map_panel:y()/-self:_get_pan_panel_border() )
		end
		if down and self._fullscreen_panel:h() - self._map_panel:bottom() > -self:_get_pan_panel_border() then
			my = math.lerp( my, 0, 1 - (self._fullscreen_panel:h() - self._map_panel:bottom())/-self:_get_pan_panel_border() )
		end
		
		table.insert( self._grabbed_map.dirs, 1, { mx, my } )
		self._grabbed_map.dirs[ 10 ] = nil
		
		self:_set_map_position( mx, my )
				
		self._grabbed_map.x = x
		self._grabbed_map.y = y
		return true, "grab"
	end

	local closest_job = nil
	local closest_dist = 100000000
	local closest_job_x, closest_job_y = 0, 0
	
	local job_x, job_y
	local dist = 0
	
	local inside_any_job = false
	local math_x, math_y
	
	for id, job in pairs( self._jobs ) do
		local inside = (job.marker_panel:child("select_panel"):inside( x, y ) and self._panel:inside( x, y ))
		inside_any_job = inside_any_job or inside
		
		if( inside ) then
			job_x, job_y = job.marker_panel:child("select_panel"):world_center()
		
			math_x = job_x - x
			math_y = job_y - y
			
			dist = math_x * math_x + math_y * math_y
			
			if( dist < closest_dist ) then
				closest_job = job
				closest_dist = dist
				
				closest_job_x = job_x
				closest_job_y = job_y
			end
		end
	end
	
	for id,job in pairs( self._jobs ) do
		local inside = ((job == closest_job) and 1) or (inside_any_job and 2) or 3
		
		self:update_job_gui( job, inside )
	end
	-- local inside_any_job = self:check_job_mouse_over( x, y )
	
	--[[
	local inside_any_job = false
	for id,job in pairs( self._jobs ) do
		local inside = (job.marker_panel:inside( x, y ) and self._panel:inside( x, y ))
		inside_any_job = inside_any_job or inside
		if job.mouse_over ~= inside then
			job.mouse_over = inside
			job.marker_panel:set_alpha(job.mouse_over and 1 or 0.8 )
			job.stars_panel:set_alpha( job.mouse_over and 1 or 0.8 )
			
			if( job.peers_panel ) then
				job.peers_panel:set_alpha( job.mouse_over and 1 or 0.8 )
			end
			
			local animate_show = function( o )
				local start_alpha = o:alpha()
				
				over( 0.3 * (1-start_alpha), function(p) o:set_alpha( math.lerp( start_alpha, 1, p ) ) end )
			end
			local animate_hide = function( o )
				local start_alpha = o:alpha()
				
				over( 0.3 * (start_alpha), function(p) o:set_alpha( math.lerp( start_alpha, 0, p ) ) end )
			end
			job.host_name:stop()
			job.info_text:stop()
			job.host_name:animate( job.mouse_over and animate_hide or animate_show )
			job.info_text:animate( job.mouse_over and animate_show or animate_hide )
			
			
			-- job.marker_rect:set_color( job.marker_rect:color():with_alpha( job.mouse_over and 0.9 or 0.5 ) )
			-- job.host_name:set_visible( job.mouse_over )
			-- job.stars_panel:set_visible( job.mouse_over  )
			-- job.info_panel:set_visible( job.mouse_over )
		end
		if job.expanded then
			-- if job.mouse_over_info ~= job.info_panel:inside( x, y ) then
				-- job.mouse_over_info = job.info_panel:inside( x, y )
				-- job.info_rect:set_color( Color.blue:with_alpha( job.mouse_over_info and 0.9 or 0.5 ) )
					-- job.info_panel:set_visible( job.mouse_over )
			-- end
		end
	end
	]]
	-- print( "CrimeNetGui:mouse_moved" )
	
	if not managers.menu:is_pc_controller() then		
		local to_left 	= x
		local to_right 	= self._panel:w() - x - 19
		local to_top 		= y
		local to_bottom	= self._panel:h() - y - 23
		
		local panel_border = self._pan_panel_border
		to_left 	= 1 - math.clamp( to_left   / panel_border, 0, 1 )
		to_right 	= 1 - math.clamp( to_right  / panel_border, 0, 1 )
		to_top 		= 1 - math.clamp( to_top    / panel_border, 0, 1 )
		to_bottom	= 1 - math.clamp( to_bottom / panel_border, 0, 1 )
		
		-- print( "to_left", to_left, "to_right", to_right, "to_top", to_top, "to_bottom", to_bottom )
		-- print( managers.mouse_pointer:mouse_move_x(), managers.mouse_pointer:mouse_move_y() )
		
		local mouse_pointer_move_x = managers.mouse_pointer:mouse_move_x()
		local mouse_pointer_move_y = managers.mouse_pointer:mouse_move_y()
		
		local mp_left 	= -math.min( 0, mouse_pointer_move_x )
		local mp_right 	= -math.max( 0, mouse_pointer_move_x )
		local mp_top 		= -math.min( 0, mouse_pointer_move_y )
		local mp_bottom = -math.max( 0, mouse_pointer_move_y )
		
		local push_x = mp_left * to_left + mp_right * to_right
		local push_y = mp_top * to_top + mp_bottom * to_bottom
		
		if( push_x ~= 0 or push_y ~= 0 ) then
			self:_set_map_position( push_x, push_y )
		end
		
		--[[
		if self._panel:world_left() - x > -self._pan_panel_border then
			local mx = math.lerp( 0, 1 - (x - self._panel:world_left()) / self._pan_panel_border, speed )
			self:_set_map_position( mx, 0 )
		end
		if self._panel:world_right() - x < self._pan_panel_border then
			local mx = math.lerp( 0, 1 - (self._panel:world_right() - x) / self._pan_panel_border, speed )
			self:_set_map_position( -mx, 0 )
		end
		if self._panel:world_top() - y > -self._pan_panel_border then
			local my = math.lerp( 0, 1 - (y - self._panel:world_top()) / self._pan_panel_border, speed )
			self:_set_map_position( 0, my )
		end
		if self._panel:world_bottom() - y < self._pan_panel_border then
			local my = math.lerp( 0, 1 - (self._panel:world_bottom() - y) / self._pan_panel_border, speed )
			self:_set_map_position( 0, -my )
		end]]
		
	end
	
	if inside_any_job then
		return false, "arrow"
	end
	
	if self._panel:inside( x, y ) then		
		return false, "hand"
	end	
end

function CrimeNetGui:_create_job_gui(data, type, fixed_x, fixed_y, fixed_location)
	local level_id = data.level_id
	local level_data = tweak_data.levels[level_id]
	local narrative_data = data.job_id and tweak_data.narrative.jobs[data.job_id]
	local is_server = type == "server"
	local is_professional = narrative_data and narrative_data.professional
	local got_job = data.job_id and true or false
	local x = fixed_x
	local y = fixed_y
	local location = fixed_location
	if not x and not y then
		x, y, location = self:_get_job_location(data)
	end
	local color = Color.white
	local friend_color = tweak_data.screen_colors.friend_color
	local regular_color = tweak_data.screen_colors.regular_color
	local pro_color = tweak_data.screen_colors.pro_color
	local side_panel = self._pan_panel:panel({layer = 26, alpha = 0})
	local stars_panel = side_panel:panel({
		name = "stars_panel",
		layer = -1,
		visible = true,
		w = 100
	})
	local num_stars = 0
	local star_size = 8
	local job_num = 0
	local job_cash = 0
	local difficulty_name = side_panel:text({
		name = "difficulty_name",
		text = "",
		vertical = "center",
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = color,
		blend_mode = "add",
		layer = 0
	})
	if data.job_id then
		local x = 0
		local y = 0
		local job_stars = math.ceil(tweak_data.narrative.jobs[data.job_id].jc / 10)
		local difficulty_stars = data.difficulty_id - 2
		local job_and_difficulty_stars = job_stars + difficulty_stars
		for i = 1, 10 do
			stars_panel:bitmap({
				texture = "guis/textures/pd2/crimenet_paygrade_marker",
				x = x,
				y = y,
				blend_mode = "normal",
				layer = 0,
				color = i > job_stars + difficulty_stars and Color.black or i > job_stars and tweak_data.screen_colors.risk or color
			})
			x = x + star_size
			num_stars = num_stars + 1
		end
		local money_multiplier = managers.money:get_contract_difficulty_multiplier(difficulty_stars)
		local money_stage_stars = managers.money:get_stage_payout_by_stars(job_stars)
		local money_job_stars = managers.money:get_job_payout_by_stars(job_stars)
		local plvl = managers.experience:current_level()
		local player_stars = math.max(math.ceil(plvl / 10), 1)
		local money_manager = tweak_data.money_manager.level_limit
		if player_stars <= job_and_difficulty_stars + tweak_data:get_value("money_manager", "level_limit", "low_cap_level") then
			local diff_stars = math.clamp(job_and_difficulty_stars - player_stars, 1, #money_manager.pc_difference_multipliers)
			local level_limit_mul = tweak_data:get_value("money_manager", "level_limit", "pc_difference_multipliers", diff_stars)
			local plr_difficulty_stars = math.max(difficulty_stars - diff_stars, 0)
			local plr_money_multiplier = managers.money:get_contract_difficulty_multiplier(plr_difficulty_stars) or 0
			local white_player_stars = player_stars - plr_difficulty_stars
			local cash_plr_stage_stars = managers.money:get_stage_payout_by_stars(white_player_stars, true)
			cash_plr_stage_stars = cash_plr_stage_stars + cash_plr_stage_stars * plr_money_multiplier
			local cash_stage = money_stage_stars + money_stage_stars * money_multiplier
			local diff_stage = cash_stage - cash_plr_stage_stars
			local new_cash_stage = cash_plr_stage_stars + diff_stage * level_limit_mul
			money_stage_stars = money_stage_stars * (new_cash_stage / cash_stage)
			local cash_plr_job_stars = managers.money:get_job_payout_by_stars(white_player_stars, true)
			cash_plr_job_stars = cash_plr_job_stars + cash_plr_job_stars * plr_money_multiplier
			local cash_job = money_job_stars + money_job_stars * money_multiplier
			local diff_job = cash_job - cash_plr_job_stars
			local new_cash_job = cash_plr_job_stars + diff_job * level_limit_mul
			money_job_stars = money_job_stars * (new_cash_job / cash_job)
		end
		job_num = #tweak_data.narrative.jobs[data.job_id].chain
		job_cash = managers.experience:cash_string(math.round(money_job_stars + tweak_data:get_value("money_manager", "flat_job_completion") + money_job_stars * money_multiplier + (money_stage_stars + tweak_data:get_value("money_manager", "flat_stage_completion") + money_stage_stars * money_multiplier) * #tweak_data.narrative.jobs[data.job_id].chain))
		local difficulty_string = managers.localization:to_upper_text(tweak_data.difficulty_name_ids[tweak_data.difficulties[data.difficulty_id]])
		difficulty_name:set_text(difficulty_string)
		difficulty_name:set_color(0 < difficulty_stars and tweak_data.screen_colors.risk or tweak_data.screen_colors.text)
	end
	local host_string = data.host_name or is_professional and managers.localization:to_upper_text("cn_menu_pro_job") or " "
	local job_string = data.job_id and managers.localization:to_upper_text(tweak_data.narrative.jobs[data.job_id].name_id) or data.level_name or "NO JOB"
	local contact_string = utf8.to_upper(data.job_id and managers.localization:text(tweak_data.narrative.contacts[tweak_data.narrative.jobs[data.job_id].contact].name_id)) or "BAIN"
	contact_string = contact_string .. ": "
	local info_string = managers.localization:to_upper_text("cn_menu_contract_short_" .. (1 < job_num and "plural" or "singular"), {days = job_num, money = job_cash})
	info_string = info_string .. (data.state_name and " / " .. data.state_name or "")
	local host_name = side_panel:text({
		name = "host_name",
		text = host_string,
		vertical = "center",
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = data.is_friend and friend_color or is_server and regular_color or pro_color,
		blend_mode = "add",
		layer = 0
	})
	local job_name = side_panel:text({
		name = "job_name",
		text = job_string,
		vertical = "center",
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = color,
		blend_mode = "add",
		layer = 0
	})
	local contact_name = side_panel:text({
		name = "contact_name",
		text = contact_string,
		vertical = "center",
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = color,
		blend_mode = "add",
		layer = 0
	})
	local info_name = side_panel:text({
		name = "info_name",
		text = info_string,
		vertical = "center",
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = color,
		blend_mode = "add",
		layer = 0
	})
	stars_panel:set_w(star_size * math.min(10, #stars_panel:children()))
	stars_panel:set_h(star_size)
	local focus = self._pan_panel:bitmap({
		name = "focus",
		texture = "guis/textures/crimenet_map_circle",
		layer = 10,
		color = color:with_alpha(0.6),
		blend_mode = "add"
	})
	do
		local _, _, w, h = host_name:text_rect()
		host_name:set_size(w, h)
		host_name:set_position(0, 0)
		if not is_server then
		end
	end
	do
		local _, _, w, h = job_name:text_rect()
		job_name:set_size(w, h)
		job_name:set_position(0, host_name:bottom())
	end
	do
		local _, _, w, h = contact_name:text_rect()
		contact_name:set_size(w, h)
		contact_name:set_top(job_name:top())
		contact_name:set_right(0)
	end
	do
		local _, _, w, h = info_name:text_rect()
		info_name:set_size(w, h)
		info_name:set_top(contact_name:bottom())
		info_name:set_right(0)
	end
	do
		local _, _, w, h = difficulty_name:text_rect()
		difficulty_name:set_size(w, h)
		difficulty_name:set_top(info_name:bottom())
		difficulty_name:set_right(0)
	end
	if not got_job then
		job_name:set_text(data.state_name or managers.localization:to_upper_text("menu_lobby_server_state_in_lobby"))
		local _, _, w, h = job_name:text_rect()
		job_name:set_size(w, h)
		job_name:set_position(0, host_name:bottom())
		contact_name:set_text(" ")
		contact_name:set_w(0, 0)
		contact_name:set_position(0, host_name:bottom())
		info_name:set_text(" ")
		info_name:set_size(0, 0)
		info_name:set_position(0, host_name:bottom())
		difficulty_name:set_text(" ")
		difficulty_name:set_w(0, 0)
		difficulty_name:set_position(0, host_name:bottom())
	end
	stars_panel:set_position(0, job_name:bottom())
	side_panel:set_h(math.max(stars_panel:bottom(), difficulty_name:bottom()))
	side_panel:set_w(300)
	self._num_layer_jobs = (self._num_layer_jobs + 1) % 1
	local marker_panel = self._pan_panel:panel({
		w = 36,
		h = 66,
		layer = 11 + self._num_layer_jobs * 3,
		alpha = 0
	})
	local select_panel = marker_panel:panel({
		name = "select_panel",
		w = 36,
		h = 38,
		x = -2,
		y = 0
	})
	local glow_panel = self._pan_panel:panel({
		w = 960,
		h = 192,
		layer = 10,
		alpha = 0
	})
	local glow_center = glow_panel:bitmap({
		texture = "guis/textures/pd2/crimenet_marker_glow",
		w = 192,
		h = 192,
		blend_mode = "add",
		alpha = 0.55,
		color = is_professional and pro_color or regular_color
	})
	local glow_stretch = glow_panel:bitmap({
		texture = "guis/textures/pd2/crimenet_marker_glow",
		w = 960,
		h = 50,
		blend_mode = "add",
		alpha = 0.55,
		color = is_professional and pro_color or regular_color
	})
	local glow_center_dark = glow_panel:bitmap({
		texture = "guis/textures/pd2/crimenet_marker_glow",
		w = 150,
		h = 150,
		blend_mode = "normal",
		alpha = 0.7,
		color = Color.black,
		layer = -1
	})
	local glow_stretch_dark = glow_panel:bitmap({
		texture = "guis/textures/pd2/crimenet_marker_glow",
		w = 990,
		h = 55,
		blend_mode = "normal",
		alpha = 0.7,
		color = Color.black,
		layer = -1
	})
	glow_center:set_center(glow_panel:w() / 2, glow_panel:h() / 2)
	glow_stretch:set_center(glow_panel:w() / 2, glow_panel:h() / 2)
	glow_center_dark:set_center(glow_panel:w() / 2, glow_panel:h() / 2)
	glow_stretch_dark:set_center(glow_panel:w() / 2, glow_panel:h() / 2)
	local marker_dot = marker_panel:bitmap({
		name = "marker_dot",
		texture = "guis/textures/pd2/crimenet_marker_" .. (is_server and "join" or "host") .. (is_professional and "_pro" or ""),
		color = color,
		w = 32,
		h = 64,
		x = 2,
		y = 2,
		layer = 1
	})
	if is_professional then
		marker_panel:bitmap({
			name = "marker_pro_outline",
			texture = "guis/textures/pd2/crimenet_marker_pro_outline",
			w = 64,
			h = 64,
			x = 0,
			y = 0,
			rotation = 0,
			layer = 0,
			alpha = 1,
			blend_mode = "add"
		})
	end
	local timer_rect, peers_panel
	if is_server then
		peers_panel = self._pan_panel:panel({
			layer = 11 + self._num_layer_jobs * 3,
			visible = true,
			w = 32,
			h = 62,
			alpha = 0
		})
		local cx = 0
		local cy = 0
		for i = 1, 4 do
			cx = 3 + 6 * (i - 1)
			cy = 8
			local player_marker = peers_panel:bitmap({
				name = tostring(i),
				texture = "guis/textures/pd2/crimenet_marker_peerflag",
				w = 8,
				h = 16,
				color = color,
				layer = 2,
				blend_mode = "normal",
				visible = i <= data.num_plrs
			})
			player_marker:set_position(cx, cy)
		end
	else
		timer_rect = marker_panel:bitmap({
			name = "timer_rect",
			texture = "guis/textures/pd2/crimenet_timer",
			color = Color.white,
			w = 32,
			h = 32,
			x = 1,
			y = 2,
			render_template = "VertexColorTexturedRadial",
			layer = 2
		})
		timer_rect:set_texture_rect(32, 0, -32, 32)
	end
	marker_panel:set_center(x * self._zoom, y * self._zoom)
	focus:set_center(marker_panel:center())
	glow_panel:set_world_center(marker_panel:child("select_panel"):world_center())
	local text_on_right = x < self._map_size_w - 200
	if text_on_right then
		side_panel:set_left(marker_panel:right())
	else
		job_name:set_text(contact_name:text() .. job_name:text())
		contact_name:set_text("")
		contact_name:set_w(0)
		local _, _, w, h = job_name:text_rect()
		job_name:set_size(w, h)
		host_name:set_right(side_panel:w())
		job_name:set_right(side_panel:w())
		contact_name:set_left(side_panel:w())
		info_name:set_left(side_panel:w())
		difficulty_name:set_left(side_panel:w())
		stars_panel:set_right(side_panel:w())
		side_panel:set_right(marker_panel:left())
	end
	side_panel:set_center_y(marker_panel:top() + 11)
	if peers_panel then
		peers_panel:set_center_x(marker_panel:center_x())
		peers_panel:set_center_y(marker_panel:center_y())
	end
	if not Application:production_build() or peers_panel then
	end
	local callout
	if narrative_data and narrative_data.crimenet_callouts and 0 < #narrative_data.crimenet_callouts then
		local variant = math.random(#narrative_data.crimenet_callouts)
		callout = narrative_data.crimenet_callouts[variant]
	end
	if location then
		location[3] = true
	end
	managers.menu:post_event("job_appear")
	local job = {
		room_id = data.room_id,
		job_id = data.job_id,
		level_id = level_id,
		level_data = level_data,
		marker_panel = marker_panel,
		peers_panel = peers_panel,
		timer_rect = timer_rect,
		side_panel = side_panel,
		focus = focus,
		difficulty = data.difficulty,
		difficulty_id = data.difficulty_id,
		num_plrs = data.num_plrs,
		job_x = x,
		job_y = y,
		state = data.state,
		layer = 11 + self._num_layer_jobs * 3,
		glow_panel = glow_panel,
		callout = callout,
		text_on_right = text_on_right,
		location = location
	}
	self:update_job_gui(job, 3)
	return job
end

function CrimeNetGui:remove_job(id)
	local data = self._jobs[id]
	if not data then
		return
	end
	if not alive(self._panel) then
		return
	end
	self._pan_panel:remove(data.marker_panel)
	self._pan_panel:remove(data.glow_panel)
	self._pan_panel:remove(data.side_panel)
	self._pan_panel:remove(data.focus)
	if data.location then
		data.location[3] = nil
	end
	if data.peers_panel then
		self._pan_panel:remove(data.peers_panel)
	end
	if data.expanded then
	end
	self._jobs[id] = nil
end

local job_heat = 0
local job_heat_mul = 0

if managers.job and managers.job.get_job_heat and managers.job.heat_to_experience_multiplier then
    job_heat = managers.job:get_job_heat(data.job_id) or 0
    job_heat_mul = managers.job:heat_to_experience_multiplier(job_heat) - 1
end

	if data and data.job_id and data.difficulty_id then
    local x = 0
    local y = 0
    
    if tweak_data.narrative and tweak_data.narrative.job_data then
        local job_data = tweak_data.narrative:job_data(data.job_id)
        if job_data and job_data.jc then
		local job_stars = math.ceil(tweak_data.narrative:job_data(data.job_id).jc / 10)
		local difficulty_stars = data.difficulty_id - 2
		local job_and_difficulty_stars = job_stars + difficulty_stars
		local start_difficulty = 1
		local num_difficulties = Global.SKIP_OVERKILL_290 and 3 or 4
		for i = start_difficulty, num_difficulties do
			stars_panel:bitmap({
				texture = "guis/textures/pd2/cn_miniskull",
				x = x,
				y = y,
				w = 12,
				h = 16,
				texture_rect = {
					0,
					0,
					12,
					16
				},
				alpha = i > difficulty_stars and 0.5 or 1,
				blend_mode = i > difficulty_stars and "normal" or "add",
				layer = 0,
				color = i > difficulty_stars and Color.black or Color.red
			})
			x = x + 11
			num_stars = num_stars + 1
		end
	end
end
		job_num = #tweak_data.narrative:job_chain(data.job_id)
		local total_payout, base_payout, risk_payout = managers.money:get_contract_money_by_stars(job_stars, difficulty_stars, job_num, data.job_id)
		job_cash = managers.experience:cash_string(math.round(total_payout))
		local difficulty_string = managers.localization:to_upper_text(tweak_data.difficulty_name_ids[tweak_data.difficulties[data.difficulty_id]])
		difficulty_name:set_text(difficulty_string)
		difficulty_name:set_color(difficulty_stars > 0 and tweak_data.screen_colors.risk or tweak_data.screen_colors.text)
		local heat_alpha = math.abs(job_heat) / 100
		local heat_size = 1
		local heat_color = managers.job:get_job_heat_color(data.job_id)
		heat_glow = self._pan_panel:bitmap({
			texture = "guis/textures/pd2/hot_cold_glow",
			layer = 11,
			w = 256 * heat_size,
			h = 256 * heat_size,
			blend_mode = "add",
			color = heat_color,
			alpha = 0
		})
		if job_heat_mul ~= 0 then
			local s = utf8.len(text_string)
			local heat_string = mul_to_procent_string(job_heat_mul)
			text_string = text_string .. heat_string
			table.insert(range_colors, {
				s,
				utf8.len(text_string),
				heat_color
			})
			got_heat = true
			got_heat_text = true
			heat_glow:set_alpha(heat_alpha)
		end
	end
    if tweak_data.narrative and tweak_data.narrative.job_data then
        local job_tweak = tweak_data.narrative:job_data(data.job_id)
        if job_tweak then
		
	local job_tweak = tweak_data.narrative:job_data(data.job_id)
	local host_string = data.host_name or is_professional and managers.localization:to_upper_text("cn_menu_pro_job") or " "
	local job_string = data.job_id and managers.localization:to_upper_text(job_tweak.name_id) or data.level_name or "NO JOB"
	local contact_string = utf8.to_upper(data.job_id and managers.localization:text(tweak_data.narrative.contacts[job_tweak.contact].name_id)) or "BAIN"
	contact_string = contact_string .. ": "
	local info_string = managers.localization:to_upper_text("cn_menu_contract_short_" .. (job_num > 1 and "plural" or "singular"), {days = job_num, money = job_cash})
	info_string = info_string .. (data.state_name and " / " .. data.state_name or "")
	if is_special then
		job_string = data.name_id and managers.localization:to_upper_text(data.name_id) or ""
		info_string = data.desc_id and managers.localization:to_upper_text(data.desc_id) or ""
	end
	local host_name = side_panel:text({
		name = "host_name",
		text = host_string,
		vertical = "center",
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = data.is_friend and friend_color or is_server and regular_color or pro_color,
		blend_mode = "add",
		layer = 0
	})
	local job_name = side_panel:text({
		name = "job_name",
		text = job_string,
		vertical = "center",
		font = tweak_data.menu.medium_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_color_yellow,
		blend_mode = "add",
		layer = 0
	})
	local contact_name = side_panel:text({
		name = "contact_name",
		text = contact_string,
		vertical = "center",
		font = tweak_data.menu.medium_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_color_yellow,
		blend_mode = "add",
		layer = 0
	})
	local info_name = side_panel:text({
		name = "info_name",
		text = info_string,
		vertical = "center",
		font = tweak_data.menu.medium_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_color_yellow,
		blend_mode = "add",
		layer = 0
	})
	stars_panel:set_w(star_size * math.min(11, #stars_panel:children()))
	stars_panel:set_h(star_size)
	local focus = self._pan_panel:bitmap({
		name = "focus",
		texture = "guis/textures/crimenet_map_circle",
		layer = 10,
		color = color:with_alpha(0.6),
		blend_mode = "add"
	})
	do
		local _, _, w, h = host_name:text_rect()
		host_name:set_size(w, h)
		host_name:set_position(0, 0)
		if not is_server then
		end
	end
	do
		local _, _, w, h = job_name:text_rect()
		job_name:set_size(w, h)
		job_name:set_position(0, host_name:bottom() - 2)
	end
	do
		local _, _, w, h = contact_name:text_rect()
		contact_name:set_size(w, h)
		contact_name:set_top(job_name:top())
		contact_name:set_right(0)
	end
	do
		local _, _, w, h = info_name:text_rect()
		info_name:set_size(w, h - 4)
		info_name:set_top(contact_name:bottom() - 4)
		info_name:set_right(0)
	end
	do
		local _, _, w, h = difficulty_name:text_rect()
		difficulty_name:set_size(w, h)
		difficulty_name:set_top(info_name:bottom() - 4)
		difficulty_name:set_right(0)
	end
	do
		local _, _, w, h = heat_name:text_rect()
		heat_name:set_size(w, h - 4)
		heat_name:set_top(difficulty_name:bottom() - 4)
		heat_name:set_right(0)
	end
	if not got_heat_text then
		heat_name:set_text(" ")
		heat_name:set_w(1)
		heat_name:set_position(0, host_name:bottom() - 4)
	end
	if is_special then
		contact_name:set_text(" ")
		contact_name:set_size(0, 0)
		contact_name:set_position(0, host_name:bottom())
		difficulty_name:set_text(" ")
		difficulty_name:set_w(0, 0)
		difficulty_name:set_position(0, host_name:bottom())
		heat_name:set_text(" ")
		heat_name:set_w(0, 0)
		heat_name:set_position(0, host_name:bottom())
	elseif not got_job then
		job_name:set_text(data.state_name or managers.localization:to_upper_text("menu_lobby_server_state_in_lobby"))
		local _, _, w, h = job_name:text_rect()
		job_name:set_size(w, h)
		job_name:set_position(0, host_name:bottom())
		contact_name:set_text(" ")
		contact_name:set_w(0, 0)
		contact_name:set_position(0, host_name:bottom())
		info_name:set_text(" ")
		info_name:set_size(0, 0)
		info_name:set_position(0, host_name:bottom())
		difficulty_name:set_text(" ")
		difficulty_name:set_w(0, 0)
		difficulty_name:set_position(0, host_name:bottom())
		heat_name:set_text(" ")
		heat_name:set_w(0, 0)
		heat_name:set_position(0, host_name:bottom())
	end
	stars_panel:set_position(0, job_name:bottom())
	side_panel:set_h(math.round(host_name:h() + job_name:h() + stars_panel:h()))
	side_panel:set_w(300)
	self._num_layer_jobs = (self._num_layer_jobs + 1) % 1
	local marker_panel = self._pan_panel:panel({
		w = 36,
		h = 66,
		layer = 11 + self._num_layer_jobs * 3,
		alpha = 0
	})
	local select_panel = marker_panel:panel({
		name = "select_panel",
		w = 36,
		h = 38,
		x = -2,
		y = 0
	})
	local glow_panel = self._pan_panel:panel({
		w = 960,
		h = 192,
		layer = 10,
		alpha = 0
	})
	local glow_center = glow_panel:bitmap({
		texture = "guis/textures/pd2/crimenet_marker_glow",
		w = 192,
		h = 192,
		blend_mode = "add",
		alpha = 0.55,
		color = data.pulse_color or is_professional and pro_color or regular_color
	})
	local glow_stretch = glow_panel:bitmap({
		texture = "guis/textures/pd2/crimenet_marker_glow",
		w = 960,
		h = 75,
		blend_mode = "add",
		alpha = 0.55,
		color = data.pulse_color or is_professional and pro_color or regular_color
	})
	local glow_center_dark = glow_panel:bitmap({
		texture = "guis/textures/pd2/crimenet_marker_glow",
		w = 175,
		h = 175,
		blend_mode = "normal",
		alpha = 0.7,
		color = Color.black,
		layer = -1
	})
	local glow_stretch_dark = glow_panel:bitmap({
		texture = "guis/textures/pd2/crimenet_marker_glow",
		w = 990,
		h = 75,
		blend_mode = "normal",
		alpha = 0.75,
		color = Color.black,
		layer = -1
	})
	glow_center:set_center(glow_panel:w() / 2, glow_panel:h() / 2)
	glow_stretch:set_center(glow_panel:w() / 2, glow_panel:h() / 2)
	glow_center_dark:set_center(glow_panel:w() / 2, glow_panel:h() / 2)
	glow_stretch_dark:set_center(glow_panel:w() / 2, glow_panel:h() / 2)
	if not is_special or not data.icon then
	end
	
	--marker_panel:set_halign( "scale" )	
	--marker_panel:set_valign( "scale" )
	
	--local marker_rect = marker_panel:rect( { color = (is_server and Color( 0.8, 0.8, 0.5) or Color( 0.5, 0.5, 0.8)):with_alpha( 0.5 ) } )
	--local marker_rect = marker_panel:bitmap( { name="map", texture = "guis/textures/crimenet_map_dot", color = (is_server and Color( 1, 1, 0.2) or Color( 0.2, 0.2, 1)):with_alpha( 0.5 ), w = 40, h = 40, x = -4, y = -4 } )
	--local timer_rect = marker_panel:rect( { color = Color.green:with_alpha( 0.5 ) } )
	--local timer_rect = marker_panel:bitmap( { name="map", texture = "guis/textures/crimenet_map_dot", color = Color.green:with_alpha( 0.5 ), w = 40, h = 40, x = -4, y = -4 } )
	
	--local marker_rect = marker_panel:bitmap( { name="marker_rect", texture = "guis/textures/pd2/crimenet_marker", color=color:with_alpha(0.5), w=64, h=64 } )
	local marker_dot_texture = (data.icon or "guis/textures/pd2/crimenet_marker_" .. (is_server and "join" or "host")) .. (is_professional and "_pro" or "")
	local marker_dot = marker_panel:bitmap({
		name = "marker_dot",
		texture = marker_dot_texture,
		color = color:with_alpha(0.7),
		w = 32,
		h = 64,
		x = 2,
		y = 2,
		layer = 1
	})
	if is_professional then
		marker_panel:bitmap({
			name = "marker_pro_outline",
			texture = "guis/textures/pd2/crimenet_marker_pro_outline",
			w = 64,
			h = 64,
			x = 0,
			y = 0,
			rotation = 0,
			layer = 0,
			alpha = 1,
			blend_mode = "add"
		})
	end
	local timer_rect, peers_panel
	local icon_panel = self._pan_panel:panel({
		layer = 26,
		alpha = 1,
		h = 64,
		w = 18
	})
	if data.job_id and managers.job:is_job_ghostable(data.job_id) then
		local ghost_icon = icon_panel:bitmap({
			name = "ghost_icon",
			texture = "guis/textures/pd2/cn_minighost",
			blend_mode = "add",
			color = tweak_data.screen_colors.ghost_color
		})
		local y = 0
		for i = 1, #icon_panel:children() - 1 do
			y = math.max(y, icon_panel:children()[i]:bottom())
		end
		ghost_icon:set_y(y)
	end
	if is_server then
		peers_panel = self._pan_panel:panel({
			layer = 11 + self._num_layer_jobs * 3,
			visible = true,
			w = 32,
			h = 62,
			alpha = 0
		})
		local cx = 0
		local cy = 0
		for i = 1, 4 do
			cx = 3 + 6 * (i - 1)
			cy = 8
			local player_marker = peers_panel:bitmap({
				name = tostring(i),
				texture = "guis/textures/pd2/crimenet_marker_peerflag",
				w = 8,
				h = 16,
				color = color,
				layer = 2,
				blend_mode = "normal",
				visible = i <= data.num_plrs
			})
			player_marker:set_position(cx, cy)
		end
		local kick_none_icon = icon_panel:bitmap({
			name = "kick_none_icon",
			texture = "guis/textures/pd2/cn_kick_marker",
			blend_mode = "add",
			alpha = 0
		})
		local kick_vote_icon = icon_panel:bitmap({
			name = "kick_vote_icon",
			texture = "guis/textures/pd2/cn_votekick_marker",
			blend_mode = "add",
			alpha = 0
		})
		local y = 0
		for i = 1, #icon_panel:children() - 1 do
			y = math.max(y, icon_panel:children()[i]:bottom())
		end
		kick_none_icon:set_y(y)
		kick_vote_icon:set_y(y)
	elseif not is_special then
		timer_rect = marker_panel:bitmap({
			name = "timer_rect",
			texture = "guis/textures/pd2/crimenet_timer",
			color = Color.white,
			w = 32,
			h = 32,
			x = 1,
			y = 2,
			render_template = "VertexColorTexturedRadial",
			layer = 2
		})
		timer_rect:set_texture_rect(32, 0, -32, 32)
	end
	--local x = marker_panel:x() + marker_panel:w()/2
	--local y = marker_panel:y() + marker_panel:h()-2
	--local info_panel = self._panel:panel( { w = 200, h = 200, x = x, y = y, visible = false, layer = 2 } )
	--local info_rect = info_panel:rect( { color = Color.blue:with_alpha( 0.5 ), layer = 0 } )
	--local name = info_panel:text( { text = managers.localization:text( level_data.name_id ), align="left", halign="left", vertical="top", hvertical="top",
					--font = tweak_data.menu.default_font, font_size = 24, layer = 1 } )
	marker_panel:set_center(x * self._zoom, y * self._zoom)
	focus:set_center(marker_panel:center())
	glow_panel:set_world_center(marker_panel:child("select_panel"):world_center())
	if heat_glow then
		heat_glow:set_world_center(marker_panel:child("select_panel"):world_center())
	end
	local num_containers = managers.job:get_num_containers()
	local middle_container = math.ceil(num_containers / 2)
	local job_container_index = managers.job:get_job_container_index(data.job_id) or middle_container
	local diff_containers = job_container_index - middle_container
	if diff_containers == 0 then
		if job_heat_mul < 0 then
			diff_containers = -1
		elseif job_heat_mul > 0 then
			diff_containers = 1
		end
	end
	local container_panel
	if diff_containers ~= 0 and job_heat_mul ~= 0 then
		container_panel = self._pan_panel:panel({
			layer = 11 + self._num_layer_jobs * 3,
			alpha = 0
		})
		container_panel:set_w(math.abs(num_containers - middle_container) * 10 + 6)
		container_panel:set_h(8)
		container_panel:set_center_x(marker_panel:center_x())
		container_panel:set_bottom(marker_panel:top())
		container_panel:set_x(math.round(container_panel:x()))
		local texture = "guis/textures/pd2/blackmarket/stat_plusminus"
		--[[if not (diff_containers > 0) or not {
			0,
			0,
			8,
			8
		} then
			local texture_rect = {
				8,
				0,
				8,
				8
			}
		end]]
		local texture_rect = {
			0,
			0,
			8,
			8
		}
		if not (diff_containers > 0) then
			texture_rect = {
					8,
					0,
					8,
					8
				}
		end
		for i = 1, math.abs(diff_containers) do
			container_panel:bitmap({
				texture = texture,
				texture_rect = texture_rect,
				x = (i - 1) * 10 + 3
			})
		end
	end
	local text_on_right = x < self._map_size_w - 200
	if text_on_right then
		side_panel:set_left(marker_panel:right())
	else
		job_name:set_text(contact_name:text() .. job_name:text())
		contact_name:set_text("")
		contact_name:set_w(0)
		local _, _, w, h = job_name:text_rect()
		job_name:set_size(w, h)
		host_name:set_right(side_panel:w())
		job_name:set_right(side_panel:w())
		contact_name:set_left(side_panel:w())
		info_name:set_left(side_panel:w())
		difficulty_name:set_left(side_panel:w())
		heat_name:set_left(side_panel:w())
		stars_panel:set_right(side_panel:w())
		side_panel:set_right(marker_panel:left())
	end
	side_panel:set_top(marker_panel:top() - job_name:top() + 1)
	if icon_panel then
		if text_on_right then
			icon_panel:set_right(marker_panel:left() + 2)
		else
			icon_panel:set_left(marker_panel:right() - 2)
		end
		icon_panel:set_top(math.round(marker_panel:top() + 1))
	end
	if peers_panel then
		peers_panel:set_center_x(marker_panel:center_x())
		peers_panel:set_center_y(marker_panel:center_y())
	end
	if not Application:production_build() or peers_panel then
	end
	local callout
	if narrative_data and narrative_data.crimenet_callouts and 0 < #narrative_data.crimenet_callouts then
		local variant = math.random(#narrative_data.crimenet_callouts)
		callout = narrative_data.crimenet_callouts[variant]
	end
	if location then
		location[3] = true
	end
	managers.menu:post_event("job_appear")
	local job = {
		room_id = data.room_id,
		info = data.info,
		job_id = data.job_id,
		level_id = level_id,
		level_data = level_data,
		marker_panel = marker_panel,
		peers_panel = peers_panel,
		kick_option = data.kick_option,
		container_panel = container_panel,
		is_friend = data.is_friend,
		timer_rect = timer_rect,
		side_panel = side_panel,
		icon_panel = icon_panel,
		focus = focus,
		difficulty = data.difficulty,
		difficulty_id = data.difficulty_id,
		num_plrs = data.num_plrs,
		job_x = x,
		job_y = y,
		state = data.state,
		layer = 11 + self._num_layer_jobs * 3,
		glow_panel = glow_panel,
		callout = callout,
		text_on_right = text_on_right,
		location = location,
		marker_rect = marker_rect,
		heat_glow = heat_glow
	}
	self:update_job_gui(job, 3)
	return job
   end
end

end