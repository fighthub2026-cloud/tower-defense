extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Este teste precisa do renderizador gráfico.")
		quit(1)
		return
	var game = load("res://scenes/main.tscn").instantiate()
	game.save_path = "user://ui-alpha-test.cfg"
	root.add_child(game)
	await process_frame
	game.begin(0)
	root.size = Vector2i(1440, 810)
	for portrait in game.hud.portraits:
		portrait.set_process(false)
	var button: Button = game.hud.shop[0]
	var ok := true
	for state in ["card", "selected", "hover", "disabled"]:
		button.add_theme_stylebox_override("normal", HudArt.style(state))
		await process_frame
		await RenderingServer.frame_post_draw
		var visible_image := root.get_texture().get_image()
		button.visible = false
		await process_frame
		await RenderingServer.frame_post_draw
		var background := root.get_texture().get_image()
		var rect := button.get_global_rect()
		var corners := [rect.position + Vector2(1, 1), Vector2(rect.end.x - 2, rect.position.y + 1), Vector2(rect.position.x + 1, rect.end.y - 2), rect.end - Vector2(2, 2)]
		for corner in corners:
			var a := visible_image.get_pixel(int(corner.x), int(corner.y))
			var b := background.get_pixel(int(corner.x), int(corner.y))
			if absf(a.r-b.r) + absf(a.g-b.g) + absf(a.b-b.b) > 0.10:
				ok = false
				push_error("Canto opaco no cartão: " + state)
		button.visible = true
		print("Verificado: " + state)
	game.queue_free()
	await process_frame
	if ok:
		print("PASS: cantos dos quatro estados deixam a madeira visível no renderizador")
	quit(0 if ok else 1)
