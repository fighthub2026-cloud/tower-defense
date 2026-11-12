class_name HudArt
extends RefCounted

static var styles: Dictionary = {}
static func style(name: String) -> StyleBoxTexture:
	if styles.has(name):
		return styles[name]
	var result := StyleBoxTexture.new()
	result.texture = load("res://assets/ui/%s.png" % name)
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		result.set_texture_margin(side, 24.0)
		result.set_content_margin(side, 10.0)
	styles[name] = result
	return result

static func icon(index: int) -> AtlasTexture:
	var result := AtlasTexture.new()
	result.atlas = load("res://assets/ui/icons.png")
	result.region = Rect2(index * 64, 0, 64, 64)
	return result

static func theme() -> Theme:
	var result := Theme.new()
	result.default_font_size = 16
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["DejaVu Sans", "Arial"])
	font.font_weight = 700
	result.default_font = font
	result.set_color("font_color", "Label", Color("244b67"))
	result.set_color("font_color", "Button", Color("fafff8"))
	result.set_color("font_hover_color", "Button", Color.WHITE)
	result.set_color("font_pressed_color", "Button", Color.WHITE)
	result.set_color("font_disabled_color", "Button", Color("6b8aa1"))
	result.set_color("font_outline_color", "Button", Color("315d78"))
	result.set_constant("outline_size", "Button", 3)
	result.set_stylebox("normal", "Button", style("blue"))
	result.set_stylebox("hover", "Button", style("card"))
	result.set_stylebox("pressed", "Button", style("gold"))
	result.set_stylebox("disabled", "Button", style("disabled"))
	return result

static func button_skin(button: Button, name: String) -> void:
	button.add_theme_stylebox_override("normal", style(name))
	button.add_theme_stylebox_override("hover", style("selected" if name == "card" else name))
	button.add_theme_stylebox_override("pressed", style("selected" if name == "card" else name))
