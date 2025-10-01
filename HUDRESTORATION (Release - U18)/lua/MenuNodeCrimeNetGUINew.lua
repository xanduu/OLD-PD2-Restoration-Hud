if Restoration.options.restoration_mrender == true then

function MenuNodeCrimenetGui:init( node, layer, parameters )
	
	parameters.font = tweak_data.menu.default_font
	parameters.font_size = tweak_data.menu.pd2_small_font_size
	parameters.align = "left"
	parameters.row_item_blend_mode = "normal"
	parameters.row_item_color = tweak_data.screen_color_yellow:with_alpha(0.6)
	parameters.row_item_hightlight_color = tweak_data.screen_color_yellow --/0.6
	parameters.marker_alpha = 0.1
	parameters.to_upper = false
	
	MenuNodeCrimenetGui.super.init( self, node, layer, parameters )
end

function MenuNodeCrimenetFiltersGui:init(node, layer, parameters)
	parameters.font = tweak_data.menu.pd2_medium_font
	parameters.font_size = tweak_data.menu.pd2_small_font_size
	parameters.align = "left"
	--parameters.halign = "center"
	parameters.row_item_blend_mode = "normal"
	parameters.row_item_color = tweak_data.screen_color_yellow:with_alpha(0.6)
	parameters.row_item_hightlight_color = tweak_data.screen_color_yellow
	parameters.marker_alpha = 0.1
	parameters.to_upper = false
	self.static_y = node:parameters().static_y
	MenuNodeCrimenetFiltersGui.super.init(self, node, layer, parameters)
end
function MenuNodeCrimenetFiltersGui:_setup_item_panel(safe_rect, res)
	MenuNodeCrimenetFiltersGui.super._setup_item_panel(self, safe_rect, res)
	self:_set_topic_position()
	local max_layer = 10000
	local min_layer = 0
	local child_layer = 0
	for _, child in ipairs(self.item_panel:children()) do
		child:set_halign("right")
		child_layer = child:layer()
		if 0 < child_layer then
			min_layer = math.min(min_layer, child_layer)
		end
		max_layer = math.max(max_layer, child_layer)
	end
	for _, child in ipairs(self.item_panel:children()) do
	end
	self.item_panel:set_w(safe_rect.width * (1 - self._align_line_proportions))
	self.item_panel:set_center(self.item_panel:parent():w() / 2, self.item_panel:parent():h() / 2)
	self.box_panel = self.item_panel:parent():panel()
	self.box_panel:set_shape(self.item_panel:shape())
	self.box_panel:set_layer(51)
	self.box_panel:grow(20, 20)
	self.box_panel:move(-10, -10)
	self.boxgui = BoxGuiObject:new(self.box_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})
	self.box_panel:rect({
		color = Color.black,
		alpha = 0.6
	})
end

end
