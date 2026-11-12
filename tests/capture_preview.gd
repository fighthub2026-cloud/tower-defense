extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func capture(name: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var directory := OS.get_environment("GODOT_CAPTURE_DIR")
	if not directory.is_empty():
		root.get_texture().get_image().save_png(directory.path_join(name + ".png"))

func run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Execute este utilitário com uma tela gráfica.")
		quit(1)
		return
	var game = load("res://scenes/main.tscn").instantiate()
	game.save_path = "user://preview.cfg"
	root.add_child(game)
	await process_frame
	game.begin(0)
	root.size = Vector2i(1440, 810)
	for type in [0, 1, 3, 5]:
		var tower: Penguin = load("res://scenes/actors/penguin.tscn").instantiate()
		tower.tower_type = type
		tower.position = [Vector2(290, 190), Vector2(800, 350), Vector2(210, 510), Vector2(620, 230)][[0, 1, 3, 5].find(type)]
		tower.rotation = [0.0, PI, PI / 2.0, -PI / 2.0][[0, 1, 3, 5].find(type)]
		game.world.add_child(tower)
		tower.set_physics_process(false)
	for kind in range(8):
		var enemy: Slime = load("res://scenes/actors/slime.tscn").instantiate()
		enemy.route = game.map.route
		enemy.kind = kind
		enemy.distance = 140 + kind * 76
		enemy.scale = Vector2.ONE * (1.15 if kind == 7 else 1.0)
		enemy.clock = kind * 0.06
		game.world.add_child(enemy)
		enemy.set_physics_process(false)
		if kind in [0, 1]:
			enemy.stick_snow(3.0)
	game.waves.wave = 12
	game.waves.active = true
	game.waves.remaining = 100
	game.waves.timer = 1000.0
	game.refresh()
	await capture("hud-battle")
	game.map.selected = get_nodes_in_group("penguins")[2]
	game.refresh()
	await capture("hud-freezer")
	game.choose(0)
	game._process(0.0)
	game.ghost.position = Vector2(520, 350)
	game.ghost.visible = true
	await process_frame
	game.ghost.position = Vector2(580, 360)
	game.ghost.visible = true
	game.map.ghost_position = game.ghost.position
	game.map.ghost_range = 200.0
	game.map.show_ghost = true
	game.map.queue_redraw()
	game.set_process(false)
	await capture("hud-cancel")
	game.queue_free()
	await process_frame
	quit()
