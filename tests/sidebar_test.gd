extends SceneTree

var failures: Array[String] = []
func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)
func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	game.save_path = "user://sidebar-test.cfg"
	root.add_child(game)
	await process_frame
	game.begin(0)
	var initial_transform: Transform2D = game.world.transform
	check(game.hud.mode == &"shop" and game.hud.shop_layer.visible and not game.hud.upgrade_layer.visible, "Loja é o estado inicial")
	check(not game.hud.get_property_list().any(func(property): return property.name == "bottom_panel"), "Painel inferior removido")
	check(game.hud.ui_theme.default_font is FontFile, "Fonte local empacotada")
	var green := HudArt.texture("button_green").get_image()
	check(green.get_pixel(green.get_width()/2, green.get_height()/2).a > 0.9, "Botão verde com face preenchida")
	for y in range(20, 65, 8):
		for x in range(20, 65, 8):
			check(green.get_pixel(x, y).a > 0.99, "Face verde sem furos de transparência")
	check(green.get_pixel(0, 0).a < 0.1, "Fundo externo transparente")
	game.choose(0)
	game.build(Vector2(180, 160))
	await process_frame
	var tower: Penguin = game.map.selected
	check(game.hud.mode == &"upgrades" and not game.hud.shop_layer.visible and game.hud.upgrade_layer.visible, "Selecionar torre transforma a lateral")
	check(game.world.transform.is_equal_approx(initial_transform), "Seleção não altera câmera ou escala do mapa")
	for button in game.hud.upgrades:
		check(button.global_position.x >= 1248.0 and button.get_global_rect().end.x <= 1440.0, "Melhoria fica dentro da lateral")
	game.money = 10000
	game.refresh()
	var damage := tower.attack_damage()
	game.hud.upgrades[0].pressed.emit()
	check(tower.attack_damage() > damage, "Botão de melhoria compra efeito funcional")
	var cash: int = game.money
	game.hud.close_button.pressed.emit()
	check(game.hud.mode == &"shop" and is_instance_valid(tower) and game.money == cash, "Fechar retorna à loja sem vender")
	game.map.selected = tower
	game.refresh()
	game.hud.back_button.pressed.emit()
	check(game.hud.mode == &"shop", "Voltar à loja fecha detalhes")
	game.map.selected = tower
	game.refresh()
	var key := InputEventKey.new()
	key.pressed = true
	key.keycode = KEY_ESCAPE
	game.hud._unhandled_key_input(key)
	check(game.hud.mode == &"shop" and not paused, "Esc fecha detalhes antes de pausar")
	game.map.selected = tower
	game.refresh()
	var refund := int(tower.invested * 0.7)
	var before: int = game.money
	game.hud.sell_button.pressed.emit()
	await process_frame
	check(game.hud.mode == &"shop" and game.money == before + refund and not is_instance_valid(tower), "Venda remove e retorna à loja")
	check(game.world.transform.is_equal_approx(initial_transform), "Mapa continua fixo após venda")
	game.queue_free()
	await process_frame
	if failures.is_empty():
		print("PASS: lateral loja/melhorias, fechar, voltar, Esc, compra, venda, transparência e mapa fixo")
	quit(0 if failures.is_empty() else 1)
