class_name HudArt
extends RefCounted

# Cada nome aponta para um PNG individual gerado e aprovado no chat.
const SKINS: Dictionary = {
	"card": "card_normal", "selected": "card_selected", "hover": "card_hover",
	"disabled": "card_disabled", "green": "button_green", "red": "button_sell",
	"cancel": "button_cancel", "wood": "sidebar_wood", "upgrade": "upgrade_card",
	"back": "back", "portrait": "card_normal", "panel": "upgrade_card",
	"blue": "card_normal", "gold": "card_selected"
}
static var styles: Dictionary = {}
static var textures: Dictionary = {}

static func texture(name: String) -> Texture2D:
	if not textures.has(name):
		textures[name] = load("res://assets/ui/approved/%s.png" % name)
	return textures[name]

static func style(name: String) -> StyleBoxTexture:
	if styles.has(name):
		return styles[name]
	var result := StyleBoxTexture.new()
	result.texture = texture(SKINS.get(name, name))
	var margin := 8.0 if name in ["card", "hover", "disabled", "selected"] else 14.0
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		result.set_texture_margin(side, margin)
		result.set_content_margin(side, 8.0)
	if name == "back":
		result.set_content_margin(SIDE_LEFT, 59.0)
	styles[name] = result
	return result

static func icon(index: int) -> Texture2D:
	var names := {0: "heart", 1: "coins", 3: "gear", 4: "play_symbol", 7: "close"}
	if names.has(index):
		return texture(names[index])
	if index == 6:
		if textures.has("double_play"):
			return textures["double_play"]
		var arrow := texture("play_symbol").get_image()
		arrow.resize(32, 44, Image.INTERPOLATE_LANCZOS)
		var image := Image.create(64, 52, false, Image.FORMAT_RGBA8)
		image.blit_rect(arrow, Rect2i(0, 0, 32, 44), Vector2i(0, 4))
		image.blit_rect(arrow, Rect2i(0, 0, 32, 44), Vector2i(29, 4))
		textures["double_play"] = ImageTexture.create_from_image(image)
		return textures["double_play"]
	return texture("play_symbol")

static func theme() -> Theme:
	var result := Theme.new()
	result.default_font_size = 16
	result.default_font = load("res://assets/fonts/LilitaOne-Regular.ttf")
	result.set_color("font_color", "Label", Color("244b67"))
	result.set_color("font_color", "Button", Color("fffdf5"))
	result.set_color("font_hover_color", "Button", Color.WHITE)
	result.set_color("font_pressed_color", "Button", Color.WHITE)
	result.set_color("font_disabled_color", "Button", Color("8e8b84"))
	result.set_color("font_outline_color", "Button", Color("182532"))
	result.set_constant("outline_size", "Button", 3)
	result.set_stylebox("normal", "Button", style("green"))
	result.set_stylebox("hover", "Button", style("green"))
	result.set_stylebox("pressed", "Button", style("green"))
	result.set_stylebox("disabled", "Button", style("disabled"))
	return result

static func button_skin(button: Button, name: String) -> void:
	button.add_theme_stylebox_override("normal", style(name))
	button.add_theme_stylebox_override("hover", style("hover" if name == "card" else name))
	button.add_theme_stylebox_override("pressed", style("selected" if name == "card" else name))
