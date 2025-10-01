if Restoration.options.restoration_hud_global == true then

if Restoration.options.restoration_bag_style == 2 then
function HUDManager:set_teammate_carry_info( i, carry_id, value )
	--[[if i == HUDManager.PLAYER_PANEL then
		return
	end]]
	self._teammate_panels[ i ]:set_carry_info( carry_id, value )
end

function HUDManager:remove_teammate_carry_info( i )
	--[[if i == HUDManager.PLAYER_PANEL then
		return
	end]]
	self._teammate_panels[ i ]:remove_carry_info()
end

end

function HUDManager:_setup_player_info_hud_pd2()
	print("_setup_player_info_hud_pd2")
	if not self:alive(PlayerBase.PLAYER_INFO_HUD_PD2) then
		return
	end
	local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
	self:_create_teammates_panel(hud)
	self:_create_present_panel(hud)
	self:_create_interaction(hud)
	self:_create_progress_timer(hud)
	self:_create_objectives(hud)
	self:_create_hint(hud)
	self:_create_heist_timer(hud)
	self:_create_temp_hud(hud)
	self:_create_suspicion(hud)
	self:_create_hit_confirm(hud)
	self:_create_hit_direction(hud)
	self:_create_downed_hud()
	self:_create_custody_hud()
	self:_create_hud_chat()
	self:_create_assault_corner()
	--[[if self:alive( "guis/player_downed_hud" ) then
		log("[RESTORATION] YAY!")
	else
		log("[RESTORATION] DANGIT!")
	end]]
	if not self:exists(Idstring("guis/mask_off_hud")) then
		managers.hud:load_hud(Idstring("guis/mask_off_hud"), false, false, true, {})
	end
	if self:alive( "guis/mask_off_hud" ) then
		self:script("guis/mask_off_hud").mask_on_text:set_center_y( hud.panel:center_y()/1.5 )
		self:script("guis/mask_off_hud").mask_on_text:set_font( Idstring("fonts/font_medium_shadow_mf") )
		self:script("guis/mask_off_hud").mask_on_text:set_font_size(32)
	else
		log("[RESTORATION] DANGIT!")
	end

end

--fix format here
	function HUDManager:add_waypoint( id, data )
		if self._hud.waypoints[ id ] then
			self:remove_waypoint( id )
		end
		
		local hud = managers.hud:script( PlayerBase.PLAYER_INFO_HUD_PD2 )
		if not hud then
			self._hud.stored_waypoints[ id ] = data
			return
		end
		
		local waypoint_panel = hud.panel -- hud.waypoint_panel
		local icon = data.icon or "wp_standard"
		local text = data.text or ""
		local icon, texture_rect = tweak_data.hud_icons:get_icon_data( icon, {0, 0, 32, 32} )
		local bitmap = waypoint_panel:bitmap( { name = "bitmap"..id, texture = icon, texture_rect = texture_rect, layer = 0, w = texture_rect[3], h = texture_rect[4], blend_mode = data.blend_mode } ) --or w = PxSize etc
		local arrow_icon, arrow_texture_rect = tweak_data.hud_icons:get_icon_data( "wp_arrow" )
		local arrow = waypoint_panel:bitmap( { name = "arrow"..id, texture = arrow_icon, texture_rect = arrow_texture_rect, color = (data.color or Color.white):with_alpha(0.75), visible = false, layer = 0, w = arrow_texture_rect[3], h = arrow_texture_rect[4], blend_mode = data.blend_mode } )
		
		local distance
		if data.distance then
			distance = waypoint_panel:text({
				name = "distance" .. id,
				text = "16.5",
				color = data.color or tweak_data.hud.prime_color,
				font = tweak_data.menu.medium_font,
				font_size = 32,
				align = "center",
				vertical = "center",
				w = 128,
				h = 24,
				layer = 0,
				blend_mode = data.blend_mode,
				rotation = 360
			})
			distance:set_visible( false )
		end
		
		local timer = data.timer and waypoint_panel:text( { name = "timer"..id, text = (math.round(data.timer) < 10 and "0" or "")..math.round(data.timer), font = tweak_data.hud.medium_font, font_size = 20, align = "center", vertical = "center", w = 128, h = 24, layer = 2} )
		--[[if data.timer then
			timer = hud.panel:text( { name = "timer"..id, text = "00", font = tweak_data.hud.medium_font, font_size = 20, align = "center", vertical = "center", w = 128, h = 24, layer = 2} )
			timer:set_visible(false)
		end]]--
		text = waypoint_panel:text( { name = "text"..id, text = utf8.to_upper( " "..text ), font = tweak_data.hud.small_font, font_size = tweak_data.hud.small_font_size, align = "center", vertical = "center", w = 512, h = 24, layer = 0, visible = true} )
		local _,_,w,_ = text:text_rect()
		text:set_w( w )
		local w, h = bitmap:size()
		
		self._hud.waypoints[ id ] = {
			init_data		= data,
			state			= "present",
			present_timer 	= managers.groupai:state():whisper_mode() and data.present_timer or 2, 
			bitmap 			= bitmap,
			arrow			= arrow,
			size			= Vector3( w, h, 0 ),
			text			= text,
			distance		= distance,
			timer_gui		= timer,
			timer			= data.timer,
			pause_timer = not data.pause_timer and data.timer and 0,
			position		= data.position,
			unit			= data.unit,
			no_sync			= data.no_sync,
			move_speed		= 1,
			radius			= data.radius or 160
		}
		self._hud.waypoints[ id ].init_data.position = data.position or data.unit:position() -- Stupid drop in fix
		
		-- The code below is not easy to follow, what it does is calculates where the waypoint should be presented if there are other being presented at the same time
		local slot = 1
		local t = {}
		for _,data in pairs( self._hud.waypoints ) do
			if data.slot then
				t[ data.slot ] = data.text:w()
			end
		end
		for i = 1, 10 do
			if not t[ i ] then
				self._hud.waypoints[ id ].slot = i
				break
			end
		end
		self._hud.waypoints[ id ].slot_x = 0
		if self._hud.waypoints[ id ].slot == 2 then
			self._hud.waypoints[ id ].slot_x = t[ 1 ]/2 + self._hud.waypoints[ id ].text:w()/2 + 10 * 1
		elseif self._hud.waypoints[ id ].slot == 3 then
			self._hud.waypoints[ id ].slot_x = -t[ 1 ]/2 - self._hud.waypoints[ id ].text:w()/2 - 10 * 1
		elseif self._hud.waypoints[ id ].slot == 4 then
			self._hud.waypoints[ id ].slot_x = t[ 1 ]/2 + t[ 2 ] + self._hud.waypoints[ id ].text:w()/2 + 10 * 2
		elseif self._hud.waypoints[ id ].slot == 5 then
			self._hud.waypoints[ id ].slot_x = -t[ 1 ]/2 - t[ 3 ] - self._hud.waypoints[ id ].text:w()/2 - 10 * 2
		end
	end
end