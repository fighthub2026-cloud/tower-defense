extends SceneTree

var failures: Array[String] = []
func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)
func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Use renderização gráfica neste teste.")
		quit(1)
		return
	var game = load("res://scenes/main.tscn").instantiate()
	game.save_path = "user://polish-test.cfg"
	root.add_child(game)
	await process_frame
	game.begin(0)
	game.choose(5)
	game.build(Vector2(180, 160))
	var tower: Penguin = game.map.selected
	for price in game.hud.upgrade_prices:
		check(price.vertical_alignment == VERTICAL_ALIGNMENT_CENTER, "Preço centralizado verticalmente")
		check(price.get_global_rect().get_center().distance_to(price.get_parent().get_global_rect().get_center()) < 0.01, "Preço no centro da etiqueta verde")
	game.waves.active = true
	game.waves.remaining = 100
	game.waves.timer = 1000.0
	game.refresh()
	game.hud.main_action()
	check(paused and not game.hud.dialog.visible, "Pausa rápida sem abrir menu")
	check(game.hud.wave_button.icon == HudArt.icon(4), "Pausado exibe iniciar/continuar")
	game.hud.main_action()
	check(not paused and game.hud.wave_button.icon == HudArt.icon(5), "Continuar restaura ícone de pausa")
	game.hud.main_action()
	game.hud.toggle_pause()
	check(paused and game.hud.dialog.visible, "Engrenagem abre menu mesmo durante pausa rápida")
	game.hud.toggle_pause()
	check(not paused and not game.hud.dialog.visible, "Menu retoma a partida")
	for resolution in [Vector2i(1280, 720), Vector2i(1600, 900)]:
		root.size = resolution
		await process_frame
		await process_frame
		for selected in [false, true]:
			game.map.selected = tower if selected else null
			game.refresh()
			check(game.world.scale.is_equal_approx(Vector2.ONE), "Tabuleiro mantém escala")
			game.waves.active = false
			game.refresh()
			await check_icon(game.hud.wave_button, "play")
			game.waves.active = true
			game.refresh()
			await check_icon(game.hud.wave_button, "pause")
			await check_icon(game.hud.pause_button, "gear")
			if selected:
				await check_icon(game.hud.close_button, "close")
			var output := OS.get_environment("GODOT_CAPTURE_DIR")
			if not output.is_empty():
				await RenderingServer.frame_post_draw
				var name := "polish-%s-%dx%d.png" % ["upgrades" if selected else "shop", resolution.x, resolution.y]
				root.get_texture().get_image().save_png(output.path_join(name))
	game.queue_free()
	await process_frame
	if failures.is_empty():
		print("PASS: ícones centralizados no renderizador em loja/melhorias a 1280×720 e 1600×900; preços e pausa rápida")
	quit(0 if failures.is_empty() else 1)

func check_icon(button: Button, name: String) -> void:
	var original := button.icon
	check(original != null, "Símbolo presente: " + name)
	check(button.icon_alignment == HORIZONTAL_ALIGNMENT_CENTER and button.vertical_icon_alignment == VERTICAL_ALIGNMENT_CENTER, "Alinhamento explícito: " + name)
	await process_frame
	await RenderingServer.frame_post_draw
	var foreground := root.get_texture().get_image()
	button.icon = null
	await process_frame
	await RenderingServer.frame_post_draw
	var background := root.get_texture().get_image()
	var factor := Vector2(foreground.get_size()) / Vector2(1440, 810)
	var rect := button.get_global_rect()
	var start := Vector2i((rect.position + Vector2(2, 2)) * factor)
	var end := Vector2i((rect.end - Vector2(2, 2)) * factor)
	var left := end.x
	var right := start.x
	var top := end.y
	var bottom := start.y
	var count := 0
	for y in range(start.y, end.y):
		for x in range(start.x, end.x):
			var a := foreground.get_pixel(x, y)
			var b := background.get_pixel(x, y)
			if absf(a.r-b.r) + absf(a.g-b.g) + absf(a.b-b.b) > 0.15:
				left = mini(left, x)
				right = maxi(right, x)
				top = mini(top, y)
				bottom = maxi(bottom, y)
				count += 1
	check(count > 15, "Símbolo realmente visível: " + name)
	if count > 0:
		var painted_center := Vector2(left+right+1, top+bottom+1) * 0.5
		var expected := rect.get_center() * factor
		check(painted_center.distance_to(expected) <= 3.0, "Centro visual de %s (%s vs %s)" % [name, painted_center, expected])
	button.icon = original
	await process_frame
