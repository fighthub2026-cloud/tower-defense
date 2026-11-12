extends SceneTree

# Normaliza apenas tamanho e margens transparentes dos PNGs individuais aprovados.
# Não extrai peças de mockups ou folhas. Mantém os originais fora da pasta de destino.
const SIZES: Dictionary = {
	"card_normal": Vector2i(90, 112), "card_selected": Vector2i(90, 112),
	"card_hover": Vector2i(90, 112), "card_disabled": Vector2i(90, 112),
	"button_green": Vector2i(84, 84), "button_cancel": Vector2i(84, 84),
	"button_sell": Vector2i(174, 46), "sidebar_wood": Vector2i(192, 810),
	"upgrade_card": Vector2i(174, 89), "heart": Vector2i(64, 64),
	"coins": Vector2i(64, 64), "gear": Vector2i(56, 56), "header": Vector2i(175, 48),
	"back": Vector2i(174, 38), "close": Vector2i(36, 36),
	"play_symbol": Vector2i(44, 44), "upgrade_power": Vector2i(38, 38),
	"upgrade_cadence": Vector2i(38, 38), "upgrade_range": Vector2i(38, 38)
}
func _initialize() -> void:
	var source := OS.get_environment("GODOT_UI_SOURCES")
	if source.is_empty():
		push_error("Defina GODOT_UI_SOURCES com a pasta dos PNGs individuais aprovados.")
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://assets/ui/approved"))
	for name in SIZES:
		var image := Image.load_from_file(source.path_join(name + ".png"))
		if image == null or image.is_empty():
			push_error("PNG ausente: " + name)
			quit(1)
			return
		if name in ["button_green", "header"]:
			# Remove apenas branco conectado ao exterior, preservando o verde inteiro.
			image.convert(Image.FORMAT_RGBA8)
			var factor := minf(1.0, 768.0 / maxf(image.get_width(), image.get_height()))
			image.resize(maxi(1, int(image.get_width() * factor)), maxi(1, int(image.get_height() * factor)), Image.INTERPOLATE_LANCZOS)
			remove_exterior_white(image)
		var bounds := image.get_used_rect()
		if bounds.has_area():
			image = image.get_region(bounds)
		var size: Vector2i = SIZES[name]
		image.resize(size.x, size.y, Image.INTERPOLATE_LANCZOS)
		if image.save_png("res://assets/ui/approved/" + name + ".png") != OK:
			quit(1)
			return
	print("PASS: 19 PNGs individuais aprovados preparados para o Godot")
	quit()

func remove_exterior_white(image: Image) -> void:
	var width := image.get_width()
	var height := image.get_height()
	var visited := PackedByteArray()
	visited.resize(width * height)
	var queue := PackedInt32Array()
	for x in range(width):
		visit(image, x, 0, visited, queue)
		visit(image, x, height - 1, visited, queue)
	for y in range(height):
		visit(image, 0, y, visited, queue)
		visit(image, width - 1, y, visited, queue)
	var i := 0
	while i < queue.size():
		var index := queue[i]
		var x := index % width
		var y := index / width
		image.set_pixel(x, y, Color.TRANSPARENT)
		visit(image, x - 1, y, visited, queue)
		visit(image, x + 1, y, visited, queue)
		visit(image, x, y - 1, visited, queue)
		visit(image, x, y + 1, visited, queue)
		i += 1

func visit(image: Image, x: int, y: int, visited: PackedByteArray, queue: PackedInt32Array) -> void:
	if x < 0 or y < 0 or x >= image.get_width() or y >= image.get_height():
		return
	var index := y * image.get_width() + x
	if visited[index]:
		return
	visited[index] = 1
	var color := image.get_pixel(x, y)
	if color.r > 0.8 and color.g > 0.8 and color.b > 0.8 and absf(color.r - color.g) < 0.1 and absf(color.g - color.b) < 0.1:
		queue.append(index)
