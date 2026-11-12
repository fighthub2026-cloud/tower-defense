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
	game.save_path = "user://mechanics-test.cfg"
	root.add_child(game)
	await process_frame
	game.begin(0)
	check(game.hud.wave_button.get_meta("action") == &"next", "Próxima onda disponível")
	var before: int = game.money
	game.choose(0)
	check(game.hud.wave_button.get_meta("action") == &"cancel" and not game.hud.wave_button.disabled, "Seleção troca o botão por cancelar")
	game.hud.wave_button.pressed.emit()
	check(game.chosen == -1 and game.money == before and game.waves.wave == 0, "Cancelar não compra nem inicia onda")
	game.waves.active = true
	game.waves.remaining = 100
	game.waves.timer = 1000.0
	game.refresh()
	check(game.hud.wave_button.get_meta("action") == &"active" and game.hud.wave_button.disabled, "Onda ativa desabilita iniciar")
	game.choose(3)
	check(game.hud.wave_button.get_meta("action") == &"cancel" and not game.hud.wave_button.disabled, "Cancelar funciona durante onda ativa")
	game.hud.wave_button.pressed.emit()
	check(game.waves.active and game.chosen == -1 and game.hud.wave_button.get_meta("action") == &"active", "Cancelar restaura o estado da onda")
	game.waves.active = false
	game.choose(3)
	game.build(Vector2(180, 160))
	var freezer: Penguin = game.map.selected
	game.money = 10000
	game.buy_upgrade(0)
	check(freezer.attack_damage() == 0.0 and freezer.slow_duration() > 2.5, "Melhoria do congelador aumenta lentidão, nunca dano")
	var enemies: Array[Slime] = []
	for kind in range(8):
		var enemy: Slime = load("res://scenes/actors/slime.tscn").instantiate()
		enemy.kind = kind
		enemy.route = game.map.route
		game.world.add_child(enemy)
		enemy.set_physics_process(false)
		enemies.append(enemy)
		var snow := Projectile.new()
		snow.tower_type = 3
		snow.damage = 9999.0
		snow.slow_duration = 3.0
		snow.apply_damage(enemy)
		check(enemy.alive and enemy.health == 50.0, "Neve não causa dano nem em classe %d" % kind)
		check(enemy.slowed > 0.0 and enemy.snow_patches.size() == 1, "Neve adere e desacelera classe %d" % kind)
		snow.free()
	check(enemies[4].slowed < enemies[0].slowed, "Polar resiste à duração do gelo")
	enemies[0].hit(20.0)
	enemies[3].hit(20.0)
	check(enemies[3].health > enemies[0].health, "Blindagem reduz dano")
	var armor_before := enemies[3].health
	enemies[3].hit(10.0, 0.0, true)
	check(is_equal_approx(enemies[3].health, armor_before - 10.0), "Perfuração ignora armadura")
	enemies[5].health = 20.0
	enemies[5]._physics_process(2.0)
	check(enemies[5].health > 20.0, "Regeneradora recupera vida")
	enemies[0]._physics_process(4.0)
	check(enemies[0].slowed == 0.0 and enemies[0].snow_patches.is_empty(), "Placas de neve derretem junto com a lentidão")
	enemies[2].defeated.connect(game.enemy_defeated)
	enemies[2].hit(999.0)
	var fragments := 0
	for node in get_nodes_in_group("slimes"):
		if node.fragment:
			fragments += 1
	check(fragments == 2, "Divisora cria dois fragmentos reais")
	check(SpriteLibrary.PROJECTILE_SIZES[0].y >= 50.0, "Flecha carregada mantém tamanho legível")
	game.queue_free()
	await process_frame
	if failures.is_empty():
		print("PASS: cancelar em todos os estados, gelo sem dano, melhorias, oito classes, armadura, regeneração e divisão")
	quit(0 if failures.is_empty() else 1)
