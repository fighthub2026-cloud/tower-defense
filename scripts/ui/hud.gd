extends CanvasLayer

var game: Node2D
var ready_ui := false
var result_open := false
var status: Label
var lives_label: Label
var money_label: Label
var difficulty_label: Label
var message: Label
var coins: Label
var selection: Label
var context_label: Label
var wave_button: Button
var pause_button: Button
var speed_button: Button
var sell_button: Button
var bottom_panel: Panel
var upgrades: Array[Button] = []
var shop: Array[Button] = []
var portraits: Array[PenguinVisual] = []
var dialog: ColorRect
var dialog_box: VBoxContainer
var selection_preview: PenguinVisual
var ui_theme: Theme
const SHOP_ORDER: Array[int] = [0, 2, 3, 5, 1, 4]
const ROLES: Array[String] = ["Flechas precisas\nDano direto", "Estrelas velozes\nAtaque rápido", "Canhão pesado\nExplosão em área", "Neve pegajosa\nLentidão · sem dano", "Armadilhas na pista\nControle de território", "Magia arcana\nIgnora armaduras"]

func setup(controller: Node2D) -> void:
	game = controller
	process_mode = Node.PROCESS_MODE_ALWAYS
	ui_theme = HudArt.theme()
	# Indicadores flutuantes sobre a neve, sem barra superior.
	var top := Control.new()
	top.size = Vector2(1248, 70)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.theme = ui_theme
	add_child(top)
	picture(top, Vector2(14, 3), Vector2(53, 57), HudArt.icon(0))
	lives_label = label(top, Vector2(68, 8), Vector2(95, 45), "100", 31)
	outline(lives_label)
	picture(top, Vector2(173, 2), Vector2(57, 59), HudArt.icon(1))
	money_label = label(top, Vector2(231, 8), Vector2(208, 45), "$1.000", 31)
	outline(money_label)
	difficulty_label = label(top, Vector2(620, 15), Vector2(245, 40), "", 13)
	difficulty_label.visible = false
	status = label(top, Vector2(1074, 2), Vector2(106, 58), "ONDA\n0/60", 18)
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	outline(status)
	pause_button = button(top, Vector2(1187, 7), Vector2(52, 52), "", toggle_pause)
	pause_button.icon = HudArt.icon(3)
	pause_button.expand_icon = true
	pause_button.add_theme_constant_override("icon_max_width", 36)
	pause_button.tooltip_text = "Pausa e opções"
	var sidebar := panel(Vector2(1248, 0), Vector2(192, 810), "wood")
	var header := Panel.new()
	header.position = Vector2(9, 10)
	header.size = Vector2(175, 48)
	header.add_theme_stylebox_override("panel", HudArt.style("green"))
	sidebar.add_child(header)
	var title := label(header, Vector2.ZERO, Vector2(175, 43), "PINGUINS", 20)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	outline(title, 4)
	for slot in range(6):
		var i: int = SHOP_ORDER[slot]
		var type := i
		var column := slot % 2
		var row := slot / 2
		var b := button(sidebar, Vector2(10 + column * 89, 78 + row * 112), Vector2(83, 104), "", func(): game.choose(type))
		HudArt.button_skin(b, "card")
		b.toggle_mode = true
		b.tooltip_text = TowerData.CLASSES[i].name + "\n" + ROLES[i]
		var portrait := PenguinVisual.new()
		portrait.tower_type = i
		portrait.position = Vector2(38, 45)
		b.add_child(portrait)
		portrait.scale = Vector2(0.215, 0.215)
		portraits.append(portrait)
		var price := label(b, Vector2(0, 75), Vector2(83, 27), "$%d" % TowerData.CLASSES[i].cost, 19)
		price.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		outline(price, 4)
		shop.append(b)
	# Detalhes contextuais, sem quadros extras ocupando o cenário.
	context_label = label(sidebar, Vector2(14, 445), Vector2(169, 95), "", 13)
	context_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	coins = label(sidebar, Vector2(14, 657), Vector2(169, 26), "", 11)
	coins.visible = false
	speed_button = button(sidebar, Vector2(10, 716), Vector2(83, 81), "1×", toggle_speed)
	HudArt.button_skin(speed_button, "green")
	speed_button.add_theme_font_size_override("font_size", 29)
	speed_button.add_theme_constant_override("outline_size", 4)
	wave_button = button(sidebar, Vector2(100, 716), Vector2(83, 81), "", main_action)
	wave_button.icon = HudArt.icon(6)
	wave_button.expand_icon = true
	wave_button.add_theme_constant_override("icon_max_width", 47)
	bottom_panel = panel(Vector2(12, 652), Vector2(1224, 148), "panel")
	var portrait_frame := Panel.new()
	portrait_frame.position = Vector2(14, 10)
	portrait_frame.size = Vector2(114, 125)
	portrait_frame.add_theme_stylebox_override("panel", HudArt.style("portrait"))
	bottom_panel.add_child(portrait_frame)
	selection_preview = PenguinVisual.new()
	selection_preview.position = Vector2(67, 83)
	bottom_panel.add_child(selection_preview)
	selection = label(bottom_panel, Vector2(145, 17), Vector2(284, 86), "", 15)
	sell_button = button(bottom_panel, Vector2(145, 100), Vector2(284, 40), "Vender", game.sell_selected)
	HudArt.button_skin(sell_button, "red")
	sell_button.add_theme_font_size_override("font_size", 14)
	for path in range(3):
		var index := path
		var b := button(bottom_panel, Vector2(450 + path * 250, 12), Vector2(239, 124), "", func(): game.buy_upgrade(index))
		HudArt.button_skin(b, "green")
		b.add_theme_font_size_override("font_size", 14)
		upgrades.append(b)
	message = label(get_layer_holder(), Vector2(20, 617), Vector2(1210, 28), "Escolha um pinguim na loja para construir.", 13)
	dialog = ColorRect.new()
	dialog.color = Color(0.10, 0.22, 0.32, 0.78)
	dialog.size = Vector2(1440, 810)
	dialog.theme = ui_theme
	add_child(dialog)
	var center := PanelContainer.new()
	center.position = Vector2(420, 135)
	center.custom_minimum_size = Vector2(600, 540)
	center.add_theme_stylebox_override("panel", HudArt.style("panel"))
	dialog.add_child(center)
	dialog_box = VBoxContainer.new()
	dialog_box.add_theme_constant_override("separation", 15)
	center.add_child(dialog_box)
	ready_ui = true
	refresh()

func get_layer_holder() -> Control:
	var holder := Control.new()
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.theme = ui_theme
	add_child(holder)
	return holder

func panel(pos: Vector2, dimensions: Vector2, skin: String) -> Panel:
	var result := Panel.new()
	result.position = pos
	result.size = dimensions
	result.theme = ui_theme
	result.add_theme_stylebox_override("panel", HudArt.style(skin))
	add_child(result)
	return result

func picture(parent: Node, pos: Vector2, dimensions: Vector2, texture: Texture2D) -> TextureRect:
	var result := TextureRect.new()
	result.position = pos
	result.size = dimensions
	result.texture = texture
	result.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	result.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(result)
	return result

func label(parent: Node, pos: Vector2, dimensions: Vector2, content: String, font_size: int) -> Label:
	var result := Label.new()
	result.position = pos
	result.size = dimensions
	result.text = content
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
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

func main_action() -> void:
	if game.chosen >= 0:
		game.cancel_build()
	elif game.started and not game.ended:
		game.waves.start_wave()

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
	item.custom_minimum_size.y = 55
	HudArt.button_skin(item, "green")
	item.pressed.connect(action)
	dialog_box.add_child(item)

func show_menu() -> void:
	clear_dialog()
	dialog_label("PINGUINS vs. GOSMAS", 30)
	dialog_label("❄ VALE CONGELADO ❄", 20)
	dialog_label("Escolha sua dificuldade · 60 ondas", 16)
	for i in range(3):
		var index := i
		dialog_button(TowerData.DIFFICULTIES[i].name, func(): game.begin(index))
	dialog_label("Escolha um pinguim e construa na neve.\nEspaço: próxima onda · Esc: cancelar / pausa", 14)

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
	pause_button.icon = HudArt.icon(3)
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
	lives_label.text = str(game.lives)
	money_label.text = "$" + format_money(game.money)
	status.text = "ONDA\n%d/%s" % [game.waves.wave, "∞" if game.waves.infinite else "60"]
	difficulty_label.text = "VALE CONGELADO\n" + TowerData.DIFFICULTIES[game.difficulty].name
	coins.text = "%d Moedas de Gelo" % game.ice_coins
	if game.chosen >= 0:
		wave_button.disabled = false
		wave_button.text = ""
		wave_button.tooltip_text = "Cancelar posicionamento"
		wave_button.set_meta("action", &"cancel")
		wave_button.icon = HudArt.icon(7)
		HudArt.button_skin(wave_button, "red")
	else:
		wave_button.disabled = game.waves.active or not game.started or game.ended
		wave_button.text = ""
		wave_button.tooltip_text = "Onda em andamento" if game.waves.active else "Próxima onda"
		wave_button.set_meta("action", &"active" if game.waves.active else &"next")
		wave_button.icon = HudArt.icon(6 if game.waves.active else 4)
		HudArt.button_skin(wave_button, "green")
	for slot in range(shop.size()):
		var i: int = SHOP_ORDER[slot]
		shop[slot].disabled = not game.started or game.money < TowerData.CLASSES[i].cost or game.ended
		shop[slot].set_pressed_no_signal(game.chosen == i)
		portraits[slot].modulate = Color(0.7, 0.78, 0.83, 0.8) if shop[slot].disabled else Color.WHITE
	update_selection()

func update_selection() -> void:
	var tower: Penguin = game.map.selected
	var valid := is_instance_valid(tower)
	var building: bool = game.chosen >= 0
	bottom_panel.visible = valid
	message.visible = valid or building
	message.position.y = 617.0 if valid else 779.0
	sell_button.disabled = not valid
	selection_preview.visible = valid or building
	var type: int = tower.tower_type if valid else game.chosen
	if type < 0:
		context_label.text = ""
		return
	context_label.text = TowerData.CLASSES[type].name.to_upper() + "\n" + ROLES[type]
	if selection_preview.tower_type != type:
		var parent := selection_preview.get_parent()
		selection_preview.queue_free()
		selection_preview = PenguinVisual.new()
		selection_preview.tower_type = type
		selection_preview.position = Vector2(67, 83)
		parent.add_child(selection_preview)
	if not valid:
		selection.text = "%s\n$ %d\nClique na neve para construir" % [TowerData.CLASSES[type].name, TowerData.CLASSES[type].cost]
		sell_button.text = "Aguardando posicionamento"
		for b in upgrades:
			b.disabled = true
			b.text = "Posicione o pinguim\npara liberar melhorias"
		return
	var main_stat := "Lentidão: %.2fs" % tower.slow_duration() if type == 3 else "Dano: %.0f" % tower.attack_damage()
	selection.text = "%s · %d derrotadas\n%s  |  Alcance: %.0f\nIntervalo: %.2fs" % [TowerData.CLASSES[type].name, tower.kills, main_stat, tower.attack_range(), TowerData.CLASSES[type].cooldown / (1.0 + tower.upgrades[1] * 0.3)]
	sell_button.text = "VENDER · $ %d" % int(tower.invested * 0.7)
	var names := ["Neve densa" if type == 3 else "Impacto", "Cadência", "Alcance"]
	var descriptions := ["+1,25s de lentidão" if type == 3 else "+55% de dano base", "+30% de velocidade", "+22% de alcance"]
	for path in range(3):
		var can := tower.can_upgrade(path)
		var price := tower.upgrade_cost(path)
		upgrades[path].disabled = not can or game.money < price
		upgrades[path].text = "%s · %d/3\n\n%s\n%s" % [names[path], tower.upgrades[path], descriptions[path], "$ %d" % price if can else "Máximo / bloqueado"]

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if game.started and game.chosen < 0:
			toggle_pause()
			get_viewport().set_input_as_handled()

func outline(item: Label, width: int = 5) -> void:
	item.add_theme_color_override("font_color", Color.WHITE)
	item.add_theme_color_override("font_outline_color", Color("152c3b"))
	item.add_theme_constant_override("outline_size", width)

func format_money(value: int) -> String:
	var digits := str(value)
	var result := ""
	for i in range(digits.length()):
		if i > 0 and (digits.length() - i) % 3 == 0:
			result += "."
		result += digits[i]
	return result
