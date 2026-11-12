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
	game.save_path = "user://animation-test.cfg"
	root.add_child(game)
	await process_frame
	# Avanço manual determinístico: verifica o estado de carga e a origem do disparo.
	for type in [0, 1, 2, 3, 5]:
		var enemy: Slime = load("res://scenes/actors/slime.tscn").instantiate()
		enemy.route = game.map.route
		enemy.health = 10000.0
		enemy.max_health = 10000.0
		game.world.add_child(enemy)
		enemy.set_physics_process(false)
		enemy.position = Vector2(550, 240)
		var tower: Penguin = load("res://scenes/actors/penguin.tscn").instantiate()
		tower.tower_type = type
		tower.position = Vector2(250, 160)
		game.world.add_child(tower)
		tower.set_physics_process(false)
		tower.target = enemy
		tower.attacking = true
		tower.visual.play_attack()
		tower.visual.player.pause()
		var releases: Array[Vector2] = []
		tower.visual.released.connect(func():
			for node in game.world.get_children():
				if node is Projectile and node.source == tower:
					check(node.global_position.distance_to(tower.visual.launch_position()) < 0.01, "Origem exata da classe %d" % type)
					check(node.art.texture == tower.visual.held.texture, "Mesma textura da mão e projétil, classe %d" % type)
					check(node.heading.dot(node.global_position.direction_to(enemy.global_position)) > 0.999, "Arma alinhada com alvo, classe %d" % type)
					node.set_physics_process(false)
					releases.append(node.global_position)
		)
		var shoulder := tower.visual.arm.position
		tower.visual.player.advance(0.29)
		check(tower.visual.arm.z_index < tower.visual.body.z_index, "Asa desenhada atrás da cabeça, classe %d" % type)
		check(tower.visual.arm.position.is_equal_approx(shoulder), "Ombro fixo na preparação, classe %d" % type)
		check(tower.visual.held.visible == (type != 2), "Objeto carregado antes da soltura, classe %d" % type)
		check(releases.is_empty(), "Nenhum disparo antecipado, classe %d" % type)
		tower.visual.player.advance(0.02)
		await process_frame
		check(not tower.visual.held.visible, "Objeto desaparece da asa/arma, classe %d" % type)
		check(releases.size() == 1, "Um único projétil na soltura, classe %d" % type)
		if type == 5:
			check(tower.visual.glow.scale.length() < 0.01, "Brilho da varinha descarrega na soltura")
		tower.visual.player.advance(0.34)
		check(not tower.visual.held.visible, "Objeto continua ausente durante recuperação, classe %d" % type)
		tower.visual.player.advance(0.10)
		check(tower.visual.held.visible == (type != 2), "Objeto reaparece na recarga, classe %d" % type)
		check(tower.visual.release_count == 1, "Recarga não duplica o tiro, classe %d" % type)
		for node in game.world.get_children():
			if node is Projectile:
				node.queue_free()
		tower.queue_free()
		enemy.queue_free()
		await process_frame
	var snow_enemy: Slime = load("res://scenes/actors/slime.tscn").instantiate()
	snow_enemy.route = game.map.route
	game.world.add_child(snow_enemy)
	snow_enemy.set_physics_process(false)
	var snow := Projectile.new()
	snow.tower_type = 3
	snow.damage = 1.0
	snow.apply_damage(snow_enemy)
	check(snow_enemy.slowed > 2.0 and snow_enemy.snow_patches.size() == 1, "Neve fica presa e desacelera o inimigo")
	snow_enemy._physics_process(3.0)
	check(snow_enemy.slowed == 0.0 and snow_enemy.snow_patches.is_empty(), "Neve e lentidão expiram juntas")
	snow.free()
	snow_enemy.queue_free()
	game.queue_free()
	await process_frame
	if failures.is_empty():
		print("PASS: carga, soltura única, origem/rotação exatas, recarga, varinha e neve aderente")
	quit(0 if failures.is_empty() else 1)
