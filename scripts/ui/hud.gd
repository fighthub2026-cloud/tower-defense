extends CanvasLayer

var game: Node2D
var ready_ui := false
var result_open := false
var status: Label
var message: Label
var coins: Label
var selection: Label
var wave_button: Button
var pause_button: Button
var speed_button: Button
var sell_button: Button
var upgrades: Array[Button] = []
var shop: Array[Button] = []
var dialog: ColorRect
var dialog_box: VBoxContainer
var selection_preview: PenguinVisual

func setup(controller: Node2D) -> void:
	game = controller
	process_mode = Node.PROCESS_MODE_ALWAYS
	var theme := Theme.new()
	theme.default_font_size = 16
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("294757")
	normal.set_corner_radius_all(10)
	normal.content_margin_left = 14
	normal.content_margin_right = 14
	normal.content_margin_top = 10
	normal.content_margin_bottom = 10
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("416a7d")
	var disabled := normal.duplicate() as StyleBoxFlat
	disabled.bg_color = Color("243c49")
	theme.set_stylebox("normal", "Button", normal)
	theme.set_stylebox("hover", "Button", hover)
	theme.set_stylebox("pressed", "Button", hover)
	theme.set_stylebox("disabled", "Button", disabled)
	theme.set_color("font_color", "Button", Color("eefaff"))
	theme.set_color("font_disabled_color", "Button", Color("79939f"))
	var top := panel(Vector2.ZERO, Vector2(1440, 72), Color("192f3c"))
	top.theme = theme
	status = label(top, Vector2(24, 18), Vector2(720, 40), "", 21)
	button(top, Vector2(1010, 14), Vector2(125, 44), "Reiniciar", game.restart)
	speed_button = button(top, Vector2(1145, 14), Vector2(75, 44), "1×", toggle_speed)
	pause_button = button(top, Vector2(1230, 14), Vector2(185, 44), "Pausar", toggle_pause)
	var sidebar := panel(Vector2(1190, 72), Vector2(250, 828), Color("cfb68e"))
	sidebar.theme = theme
	var title := label(sidebar, Vector2(22, 17), Vector2(210, 30), "PINGUINS", 23)
	title.modulate = Color("594d38")
	for i in range(6):
		var type := i
		var b := button(sidebar, Vector2(14, 65+i*96), Vector2(222, 87), "%s\n$ %d" % [TowerData.CLASSES[i].name, TowerData.CLASSES[i].cost], func(): game.choose(type))
		var texture := SpriteLibrary.part(i, 0)
		b.icon = texture
		b.expand_icon = true
		b.add_theme_constant_override("icon_max_width", 66)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		shop.append(b)
	wave_button = button(sidebar, Vector2(14, 659), Vector2(222, 54), "Iniciar onda", func(): game.waves.start_wave())
	coins = label(sidebar, Vector2(22, 738), Vector2(210, 70), "", 15)
	coins.modulate = Color("594d38")
	var bottom := panel(Vector2(0, 722), Vector2(1190, 178), Color("203a49"))
	bottom.theme = theme
	selection_preview = PenguinVisual.new()
	selection_preview.position = Vector2(73, 85)
	bottom.add_child(selection_preview)
	selection = label(bottom, Vector2(145, 16), Vector2(315, 100), "", 17)
	sell_button = button(bottom, Vector2(145, 119), Vector2(285, 41), "Vender", game.sell_selected)
	for path in range(3):
		var index := path
		var b := button(bottom, Vector2(455+path*241, 18), Vector2(226, 109), "", func(): game.buy_upgrade(index))
		upgrades.append(b)
	message = label(bottom, Vector2(455, 138), Vector2(720, 30), "Escolha um pinguim e posicione na neve.", 13)
	dialog = ColorRect.new()
	dialog.color = Color(0.04, 0.1, 0.15, 0.88)
	dialog.position = Vector2.ZERO
	dialog.size = Vector2(1440, 900)
	dialog.theme = theme
	add_child(dialog)
	var center := PanelContainer.new()
	center.position = Vector2(430, 185)
	center.size = Vector2(580, 530)
	center.add_theme_stylebox_override("panel", normal)
	dialog.add_child(center)
	dialog_box = VBoxContainer.new()
	dialog_box.add_theme_constant_override("separation", 15)
	center.add_child(dialog_box)
	ready_ui = true
	refresh()

func panel(pos: Vector2, dimensions: Vector2, color: Color) -> Panel:
	var result := Panel.new()
	result.position = pos
	result.size = dimensions
	var style := StyleBoxFlat.new()
	style.bg_color = color
	result.add_theme_stylebox_override("panel", style)
	add_child(result)
	return result

func label(parent: Node, pos: Vector2, dimensions: Vector2, content: String, font_size: int) -> Label:
	var result := Label.new()
	result.position = pos
	result.size = dimensions
	result.text = content
	result.add_theme_font_size_override("font_size", font_size)
	parent.add_child(result)
	return result

func button(parent: Node, pos: Vector2, dimensions: Vector2, content: String, action: Callable) -> Button:
	var result := Button.new()
	result.position = pos
	result.size = dimensions
	result.text = content
	result.pressed.connect(action)
	parent.add_child(result)
	return result

func clear_dialog() -> void:
	for child in dialog_box.get_children():
		dialog_box.remove_child(child)
		child.queue_free()
	dialog.visible = true

func dialog_label(content: String, font_size: int = 20) -> void:
	var item := Label.new()
	item.text = content
	item.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	item.add_theme_font_size_override("font_size", font_size)
	dialog_box.add_child(item)

func dialog_button(content: String, action: Callable) -> void:
	var item := Button.new()
	item.text = content
	item.custom_minimum_size.y = 52
	item.pressed.connect(action)
	dialog_box.add_child(item)

func show_menu() -> void:
	clear_dialog()
	dialog_label("PINGUINS vs. GOSMAS", 31)
	dialog_label("Vale Congelado", 22)
	dialog_label("Escolha a dificuldade · 60 ondas", 16)
	for i in range(3):
		var index := i
		dialog_button(TowerData.DIFFICULTIES[i].name, func(): game.begin(index))
	dialog_label("Construa antes de iniciar a primeira onda.\nEspaço: próxima onda · Esc: pausa / cancelar", 15)

func hide_dialog() -> void:
	result_open = false
	dialog.visible = false

func toggle_speed() -> void:
	Engine.time_scale = 2.0 if Engine.time_scale == 1.0 else 1.0
	speed_button.text = "2×" if Engine.time_scale == 2.0 else "1×"

func toggle_pause() -> void:
	if not game.started or game.ended or result_open:
		return
	get_tree().paused = not get_tree().paused
	pause_button.text = "Continuar" if get_tree().paused else "Pausar"
	if get_tree().paused:
		clear_dialog()
		dialog_label("PAUSA", 32)
		dialog_label("A colônia está esperando por você.", 18)
		dialog_button("Continuar", toggle_pause)
		dialog_button("Reiniciar partida", game.restart)
	else:
		hide_dialog()

func show_result(victory: bool) -> void:
	result_open = true
	clear_dialog()
	dialog_label("VITÓRIA!" if victory else "A COLÔNIA CAIU", 30)
	dialog_label("%s · Onda %d\n%d gosmas derrotadas" % [TowerData.DIFFICULTIES[game.difficulty].name, game.waves.wave, game.kills], 21)
	if victory:
		dialog_label("+%d Moedas de Gelo salvas" % TowerData.DIFFICULTIES[game.difficulty].reward, 20)
		dialog_button("Continuar no modo infinito", game.continue_infinite)
	dialog_button("Voltar ao menu", game.restart)

func refresh() -> void:
	if not ready_ui:
		return
	status.text = "♥ %d     $ %d     Onda %d/%s — %s" % [game.lives, game.money, game.waves.wave, "∞" if game.waves.infinite else "60", TowerData.DIFFICULTIES[game.difficulty].name]
	coins.text = "MOEDAS DE GELO: %d\n%d gosmas derrotadas" % [game.ice_coins, game.kills]
	wave_button.disabled = game.waves.active or not game.started or game.ended
	wave_button.text = "Onda em andamento" if game.waves.active else "▶ Iniciar próxima onda"
	for i in range(shop.size()):
		shop[i].disabled = not game.started or game.money < TowerData.CLASSES[i].cost or game.ended
	update_selection()

func update_selection() -> void:
	var tower: Penguin = game.map.selected
	var valid := is_instance_valid(tower)
	sell_button.disabled = not valid
	selection_preview.visible = valid
	if not valid:
		selection.text = "Defenda a colônia\n\nSelecione uma torre para ver\no alcance e as melhorias."
		for b in upgrades:
			b.disabled = true
			b.text = "Selecione um pinguim"
		return
	if selection_preview.tower_type != tower.tower_type:
		var parent := selection_preview.get_parent()
		selection_preview.queue_free()
		selection_preview = PenguinVisual.new()
		selection_preview.tower_type = tower.tower_type
		selection_preview.position = Vector2(73, 85)
		parent.add_child(selection_preview)
	selection.text = "%s · %d derrotadas\nDano: %.0f  |  Alcance: %.0f\nCadência base: %.2fs" % [TowerData.CLASSES[tower.tower_type].name, tower.kills, tower.attack_damage(), tower.attack_range(), TowerData.CLASSES[tower.tower_type].cooldown / (1.0 + tower.upgrades[1] * 0.3)]
	sell_button.text = "Vender · $ %d" % int(tower.invested * 0.7)
	var names := ["Impacto", "Cadência", "Alcance"]
	var descriptions := ["+55% de dano base", "+30% de velocidade base", "+22% de alcance base"]
	for path in range(3):
		var can := tower.can_upgrade(path)
		var price := tower.upgrade_cost(path)
		upgrades[path].disabled = not can or game.money < price
		upgrades[path].text = "%s · %d/3\n%s\n%s" % [names[path], tower.upgrades[path], descriptions[path], "$ %d" % price if can else "Máximo / bloqueado"]

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if game.started and game.chosen < 0:
			toggle_pause()
			get_viewport().set_input_as_handled()
