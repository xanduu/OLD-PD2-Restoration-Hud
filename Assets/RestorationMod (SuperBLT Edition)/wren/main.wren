
import "base/native/DB_001" for DBManager, DBForeignFile
import "base/native/Environment_001" for Environment

var font_medium_noshadow = DBManager.register_asset_hook("fonts/font_medium_noshadow", "font")
font_medium_noshadow.plain_file = "%(Environment.mod_directory)/assets/fonts/font_medium_noshadow.font"

var font_medium_noshadowtex = DBManager.register_asset_hook("fonts/font_medium_noshadow", "texture")
font_medium_noshadowtex.plain_file = "%(Environment.mod_directory)/assets/fonts/font_medium_noshadow.texture"

var font_medium_shadow = DBManager.register_asset_hook("fonts/font_medium_shadow", "font")
font_medium_shadow.plain_file = "%(Environment.mod_directory)/assets/fonts/font_medium_shadow.font"

var font_medium_shadowtex = DBManager.register_asset_hook("fonts/font_medium_shadow", "texture")
font_medium_shadowtex.plain_file = "%(Environment.mod_directory)/assets/fonts/font_medium_shadow.texture"

