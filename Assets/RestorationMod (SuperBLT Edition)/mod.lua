if not ResMod then
    ResMod = ModInstance
end

    DB:create_entry(
        Idstring("texture"),
        Idstring("guis/textures/pd2/cn_miniskull"),
        ResMod:GetPath() .. "assets/guis/textures/pd2/cn_miniskull.texture"
    )

    DB:create_entry(
        Idstring("texture"),
        Idstring("guis/textures/pd2/hud_difficultymarkers"),
        ResMod:GetPath() .. "assets/guis/textures/pd2/hud_difficultymarkers.texture"
    )

    DB:create_entry(
        Idstring("texture"),
        Idstring("guis/textures/pd2/endscreen/exp_ring"),
        ResMod:GetPath() .. "assets/guis/textures/pd2/endscreen/exp_ring.texture"
    )

    DB:create_entry(
        Idstring("texture"),
        Idstring("guis/textures/loading/loading_bg"),
        ResMod:GetPath() .. "assets/guis/textures/loading/loading_bg.texture"
    )    
	
	DB:create_entry(
        Idstring("texture"),
        Idstring("guis/textures/hud_icons"),
        ResMod:GetPath() .. "assets/guis/textures/hud_icons.texture"
    )
