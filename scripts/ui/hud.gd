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
var shop_layer: Control
var upgrade_layer: Control
var close_button: Button
var back_button: Button
var selected_title: Label
var upgrade_titles: Array[Label] = []
var upgrade_effects: Array[Label] = []
var upgrade_prices: Array[Label] = []
var upgrade_pips: Array[Array] = []
var upgrade_icons: Array[TextureRect] = []
var mode: StringName = &"shop"
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
	picture(top, Vector2(14, 3), Vector2(53, 57), HudArt.texture("heart"))
	lives_label = label(top, Vector2(68, 8), Vector2(95, 45), "100", 36)
	outline(lives_label)
	picture(top, Vector2(173, 2), Vector2(57, 59), HudArt.texture("coins"))
	money_label = label(top, Vector2(231, 8), Vector2(208, 45), "$1.000", 36)
	outline(money_label)
	difficulty_label = label(top, Vector2(620, 15), Vector2(245, 40), "", 13)
	difficulty_label.visible = false
	var wave_title := label(top, Vector2(1074, 0), Vector2(106, 25), "ONDA", 19)
	wave_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	outline(wave_title)
	status = label(top, Vector2(1074, 23), Vector2(106, 37), "0/60", 28)
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	outline(status)
	pause_button = button(top, Vector2(1187, 7), Vector2(52, 52), "", toggle_pause)
	pause_button.icon = HudArt.texture("gear")
	pause_button.expand_icon = true
	pause_button.add_theme_constant_override("icon_max_width", 52)
	pause_button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	pause_button.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	pause_button.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	pause_button.tooltip_text = "Pausa e opções"
	var sidebar := panel(Vector2(1248, 0), Vector2(192, 810), "wood")
	shop_layer = Control.new()
	shop_layer.name = "TowerShop"
	shop_layer.size = Vector2(192, 708)
	shop_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sidebar.add_child(shop_layer)
	picture(shop_layer, Vector2(9, 10), Vector2(175, 48), HudArt.texture("header"))
	for slot in range(6):
		var i: int = SHOP_ORDER[slot]
		var type := i
		var column := slot % 2
		var row := slot / 2
		var b := button(shop_layer, Vector2(10 + column * 89, 78 + row * 112), Vector2(83, 104), "", func(): game.choose(type))
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
		b.set_meta("price_label", price)
		shop.append(b)
	# Detalhes contextuais, sem quadros extras ocupando o cenário.
	context_label = label(shop_layer, Vector2(14, 445), Vector2(169, 95), "", 13)
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
	upgrade_layer = Control.new()
	upgrade_layer.name = "TowerUpgrades"
	upgrade_layer.size = Vector2(192, 708)
	upgrade_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sidebar.add_child(upgrade_layer)
	var selected_header := Panel.new()
	selected_header.position = Vector2(45, 10)
	selected_header.size = Vector2(139, 48)
	selected_header.add_theme_stylebox_override("panel", HudArt.style("green"))
	upgrade_layer.add_child(selected_header)
	selected_title = label(selected_header, Vector2(3, 2), Vector2(133, 43), "Pinguim", 17)
	selected_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	selected_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	outline(selected_title, 3)
	close_button = button(upgrade_layer, Vector2(6, 14), Vector2(35, 36), "", close_selection)
	close_button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	close_button.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	close_button.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	close_button.icon = HudArt.texture("close")
	close_button.expand_icon = true
	close_button.add_theme_constant_override("icon_max_width", 35)
	close_button.tooltip_text = "Fechar e voltar à loja"
	var portrait_frame := Panel.new()
	portrait_frame.position = Vector2(10, 77)
	portrait_frame.size = Vector2(174, 124)
	portrait_frame.add_theme_stylebox_override("panel", HudArt.style("card"))
	upgrade_layer.add_child(portrait_frame)
	selection_preview = PenguinVisual.new()
	selection_preview.position = Vector2(86, 151)
	upgrade_layer.add_child(selection_preview)
	selection_preview.scale = Vector2(0.37, 0.37)
	selection = label(upgrade_layer, Vector2(13, 211), Vector2(171, 101), "", 14)
	for path in range(3):
		var index := path
		var b := button(upgrade_layer, Vector2(10, 321 + path * 96), Vector2(174, 89), "", func(): game.buy_upgrade(index))
		HudArt.button_skin(b, "upgrade")
		b.add_theme_stylebox_override("disabled", HudArt.style("upgrade"))
		var icon := picture(b, Vector2(8, 6), Vector2(31, 31), HudArt.texture(["upgrade_power", "upgrade_cadence", "upgrade_range"][path]))
		upgrade_icons.append(icon)
		var name_label := label(b, Vector2(42, 7), Vector2(124, 23), "", 15)
		outline(name_label, 3)
		upgrade_titles.append(name_label)
		upgrade_effects.append(label(b, Vector2(10, 30), Vector2(155, 20), "", 11))
		var price_frame := Panel.new()
		price_frame.position = Vector2(77, 49)
		price_frame.size = Vector2(88, 35)
		price_frame.add_theme_stylebox_override("panel", HudArt.style("green"))
		price_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(price_frame)
		var price_label := label(b, Vector2(78, 51), Vector2(86, 30), "", 19)
		price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		outline(price_label, 3)
		upgrade_prices.append(price_label)
		var pips: Array[Panel] = []
		for level in range(3):
			var pip := Panel.new()
			var pip_style := StyleBoxFlat.new()
			pip_style.bg_color = Color("b28d60")
			pip_style.set_corner_radius_all(3)
			pip_style.set_border_width_all(1)
			pip_style.border_color = Color("6f552d")
			pip.add_theme_stylebox_override("panel", pip_style)
			pip.position = Vector2(12 + level * 16, 66)
			pip.size = Vector2(12, 12)
			pip.mouse_filter = Control.MOUSE_FILTER_IGNORE
			b.add_child(pip)
			pips.append(pip)
		upgrade_pips.append(pips)
		upgrades.append(b)
	sell_button = button(upgrade_layer, Vector2(10, 622), Vector2(174, 45), "VENDER", game.sell_selected)
	HudArt.button_skin(sell_button, "red")
	sell_button.add_theme_font_size_override("font_size", 17)
	sell_button.tooltip_text = "Remove o pinguim e devolve 70% do investimento"
	back_button = button(upgrade_layer, Vector2(10, 676), Vector2(174, 32), "Voltar à loja", close_selection)
	HudArt.button_skin(back_button, "back")
	back_button.add_theme_font_size_override("font_size", 13)
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
	result.add_theme_font_override("font", ui_theme.default_font)
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
	pause_button.icon = HudArt.texture("gear")
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
	status.text = "%d/%s" % [game.waves.wave, "∞" if game.waves.infinite else "60"]
	difficulty_label.text = "VALE CONGELADO\n" + TowerData.DIFFICULTIES[game.difficulty].name
	coins.text = "%d Moedas de Gelo" % game.ice_coins
	if game.chosen >= 0:
		wave_button.disabled = false
		wave_button.text = ""
		wave_button.tooltip_text = "Cancelar posicionamento"
		wave_button.set_meta("action", &"cancel")
		wave_button.icon = null
		HudArt.button_skin(wave_button, "cancel")
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
		var price_label: Label = shop[slot].get_meta("price_label")
		price_label.add_theme_color_override("font_color", Color("e58f91") if shop[slot].disabled else Color.WHITE)
	update_selection()

func update_selection() -> void:
	var tower: Penguin = game.map.selected
	var valid := is_instance_valid(tower)
	var building: bool = game.chosen >= 0
	mode = &"upgrades" if valid else &"shop"
	shop_layer.visible = not valid
	upgrade_layer.visible = valid
	message.visible = building
	message.position.y = 779.0
	sell_button.disabled = not valid
	if not valid:
		context_label.text = TowerData.CLASSES[game.chosen].name.to_upper() + "\n" + ROLES[game.chosen] if building else ""
		return
	var type: int = tower.tower_type
	selected_title.text = TowerData.CLASSES[type].name
	if selection_preview.tower_type != type:
		var parent := selection_preview.get_parent()
		selection_preview.queue_free()
		selection_preview = PenguinVisual.new()
		selection_preview.tower_type = type
		selection_preview.position = Vector2(86, 151)
		parent.add_child(selection_preview)
		selection_preview.scale = Vector2(0.37, 0.37)
	var primary := "Lentidão: %.2f s" % tower.slow_duration() if type == 3 else "Dano: %.0f" % tower.attack_damage()
	selection.text = "Acertos: %d\n%s\nAlcance: %.0f\nCadência: %.2f s" % [tower.hits, primary, tower.attack_range(), TowerData.CLASSES[type].cooldown / (1.0 + tower.upgrades[1] * 0.3)]
	selection.text = selection.text.replace(".", ",")
	sell_button.text = "VENDER $%s" % format_money(int(tower.invested * 0.7))
	var names := ["Neve densa" if type == 3 else "Impacto", "Cadência", "Alcance"]
	var descriptions := ["+1,25s de lentidão" if type == 3 else "+55% de dano base", "+30% de velocidade", "+22% de alcance"]
	for path in range(3):
		var can := tower.can_upgrade(path)
		var price := tower.upgrade_cost(path)
		upgrades[path].disabled = not can or game.money < price
		upgrade_titles[path].text = names[path]
		upgrade_effects[path].text = descriptions[path]
		upgrade_prices[path].text = "$%s" % format_money(price) if can else "Máx."
		upgrade_prices[path].add_theme_color_override("font_color", Color.WHITE if can and game.money >= price else Color("b77767"))
		for level in range(3):
			var pip_style: StyleBoxFlat = upgrade_pips[path][level].get_theme_stylebox("panel")
			pip_style.bg_color = Color("8fd728") if level < tower.upgrades[path] else Color("b28d60")

func close_selection() -> void:
	game.map.selected = null
	game.map.queue_redraw()
	game.refresh()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if game.started and game.chosen < 0:
			if is_instance_valid(game.map.selected):
				close_selection()
			else:
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
