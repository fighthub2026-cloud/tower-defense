extends SceneTree

# Execute sem --headless: usa o renderizador real para detectar asas sob o mapa.
func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Este teste precisa de uma tela e renderização habilitada.")
		quit(1)
		return
	var game = load("res://scenes/main.tscn").instantiate()
	game.save_path = "user://render-test.cfg"
	root.add_child(game)
	await process_frame
	game.begin(0)
	root.size = Vector2i(1440, 900)
	var positions := [Vector2(200, 150), Vector2(530, 220), Vector2(900, 160), Vector2(170, 435), Vector2(510, 465), Vector2(900, 430)]
	var rotations := [PI, PI / 2.0, 0.0, -PI / 2.0, PI / 4.0, -PI / 4.0]
	var towers: Array[Penguin] = []
	for type in range(6):
		var tower: Penguin = load("res://scenes/actors/penguin.tscn").instantiate()
		tower.tower_type = type
		tower.position = positions[type]
		tower.rotation = rotations[type]
		game.world.add_child(tower)
		tower.set_physics_process(false)
		tower.visual.set_process(false)
		towers.append(tower)
	await process_frame
	await RenderingServer.frame_post_draw
	var with_arms := root.get_texture().get_image()
	var output := OS.get_environment("GODOT_TEST_SCREENSHOT")
	if not output.is_empty():
		with_arms.save_png(output)
	for tower in towers:
		tower.visual.arm.visible = false
	await process_frame
	await RenderingServer.frame_post_draw
	var without_arms := root.get_texture().get_image()
	var passed := true
	for type in range(6):
		var changed := 0
		var center: Vector2i = towers[type].global_position
		for y in range(center.y - 90, center.y + 90):
			for x in range(center.x - 90, center.x + 90):
				var difference: Color = with_arms.get_pixel(x, y) - without_arms.get_pixel(x, y)
				if absf(difference.r) + absf(difference.g) + absf(difference.b) > 0.08:
					changed += 1
		if changed < 80:
			passed = false
			push_error("Asa/arma oculta na classe %d: %d pixels visíveis" % [type, changed])
		else:
			print("PASS: %s com asa/arma visível (%d pixels)" % [TowerData.CLASSES[type].name, changed])
	game.queue_free()
	await process_frame
	quit(0 if passed else 1)
