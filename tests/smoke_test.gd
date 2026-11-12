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
	game.save_path = "user://test-progress.cfg"
	root.add_child(game)
	await process_frame
	game.begin(0)
	check(game.started and game.money == 1000, "Dificuldade e economia inicial")
	check(not game.map.valid_spot(Vector2(200, 270)), "Construção bloqueada na pista")
	check(game.map.valid_spot(Vector2(180, 160)), "Construção permitida na neve")
	game.choose(0)
	game.build(Vector2(180, 160))
	var tower: Penguin = game.map.selected
	check(is_instance_valid(tower) and game.money == 830, "Compra e seleção de torre")
	check(not game.map.valid_spot(Vector2(180, 160)), "Sobreposição bloqueada")
	check(tower.visual.player.has_animation("attack"), "Animação de ataque em camadas")
	var original_damage := tower.attack_damage()
	game.buy_upgrade(0)
	check(tower.attack_damage() > original_damage, "Melhoria modifica dano")
	var original_range := tower.attack_range()
	game.buy_upgrade(2)
	check(tower.attack_range() > original_range, "Melhoria modifica alcance")
	var original_money: int = game.money
	var refund := int(tower.invested * 0.7)
	game.sell_selected()
	await process_frame
	check(game.money == original_money + refund, "Venda devolve 70% do investimento")
	check(get_nodes_in_group("penguins").is_empty(), "Torre removida após venda")
	# Ataques ofensivos eliminam; o congelador só desacelera.
	Engine.time_scale = 6.0
	for type in range(6):
		var actor: Penguin = load("res://scenes/actors/penguin.tscn").instantiate()
		actor.tower_type = type
		actor.position = Vector2(200, 180)
		game.world.add_child(actor)
		var enemy: Slime = load("res://scenes/actors/slime.tscn").instantiate()
		enemy.route = game.map.route
		enemy.distance = 200.0
		enemy.health = 5.0
		enemy.max_health = 5.0
		enemy.speed = 25.0
		game.world.add_child(enemy)
		var frames := 0
		while is_instance_valid(enemy) and frames < 150 and (type != 3 or enemy.slowed <= 0.0):
			await physics_frame
			frames += 1
		if type == 3:
			check(is_instance_valid(enemy) and enemy.health == 5.0 and enemy.slowed > 0.0 and actor.kills == 0, "Congelador desacelera sem causar dano")
		else:
			check(actor.kills > 0, "Ataque funcional da classe %d" % type)
		actor.queue_free()
		if is_instance_valid(enemy):
			enemy.queue_free()
		for child in game.world.get_children():
			if child is Projectile:
				child.queue_free()
		await process_frame
	# Pausa real: tempo de jogo não avança, HUD continua operável.
	game.hud.toggle_pause()
	check(paused, "Pausa da árvore")
	game.hud.toggle_pause()
	check(not paused, "Retomar pela interface")
	game.waves.start_wave()
	check(game.waves.active and game.waves.wave == 1, "Início da onda")
	for i in range(4):
		await physics_frame
	check(not get_nodes_in_group("slimes").is_empty(), "Onda cria inimigos")
	# Conclusão da onda 60 salva uma única recompensa e permite continuar.
	game.waves.active = false
	for enemy in get_nodes_in_group("slimes"):
		enemy.queue_free()
	await process_frame
	var coins_before: int = game.ice_coins
	game.waves.wave = 60
	game._on_wave_completed()
	check(paused and game.rewarded, "Vitória pausa o jogo")
	check(game.ice_coins == coins_before + 100, "Recompensa da dificuldade")
	game.continue_infinite()
	check(not paused and game.waves.infinite, "Continuação infinita")
	game._on_wave_completed()
	check(game.ice_coins == coins_before + 100, "Vitória não paga recompensa duplicada")
	game.waves.start_wave()
	check(game.waves.wave == 61, "Onda 61 no modo infinito")
	Engine.time_scale = 1.0
	DirAccess.remove_absolute(ProjectSettings.globalize_path(game.save_path))
	game.queue_free()
	await process_frame
	if failures.is_empty():
		print("PASS: compra, posição, melhorias, venda, seis ataques, pausa, ondas e vitória/infinito")
	quit(0 if failures.is_empty() else 1)
