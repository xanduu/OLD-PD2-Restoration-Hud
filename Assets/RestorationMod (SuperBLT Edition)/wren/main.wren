
import "base/native/DB_001" for DBManager, DBForeignFile
import "base/native/Environment_001" for Environment

var font_medium = DBManager.register_asset_hook("fonts/font_medium", "font")
font_medium.plain_file = "%(Environment.mod_directory)/assets/fonts/font_medium.font"

var font_mediumtex = DBManager.register_asset_hook("fonts/font_medium", "texture")
font_mediumtex.plain_file = "%(Environment.mod_directory)/assets/fonts/font_medium.texture"

var font_small = DBManager.register_asset_hook("fonts/font_small", "font")
font_small.plain_file = "%(Environment.mod_directory)/assets/fonts/font_small.font"

var font_smalltex = DBManager.register_asset_hook("fonts/font_small", "texture")
font_smalltex.plain_file = "%(Environment.mod_directory)/assets/fonts/font_small.texture"

