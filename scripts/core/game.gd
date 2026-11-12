extends Node2D

const PENGUIN_SCENE := preload("res://scenes/actors/penguin.tscn")
var waves: Waves
var money := 850
var lives := 100
var kills := 0
var ice_coins := 0
var difficulty := 1
var chosen := -1
var started := false
var ended := false
var rewarded := false
var save_path := "user://progress.cfg"
var ghost: AnimatedSprite2D
@onready var world: Node2D = $World
@onready var map: FrozenMap = $World/FrozenMap
@onready var hud: CanvasLayer = $HUD

func _ready() -> void:
	waves = Waves.new()
	waves.world = world
	waves.route = map.route
	add_child(waves)
	waves.completed.connect(_on_wave_completed)
	waves.changed.connect(refresh)
	ghost = AnimatedSprite2D.new()
	ghost.modulate.a = 0.5
	ghost.visible = false
	world.add_child(ghost)
	var save := ConfigFile.new()
	if save.load(save_path) == OK:
		ice_coins = int(save.get_value("progress", "ice_coins", 0))
	hud.setup(self)
	hud.show_menu()

func begin(level: int) -> void:
	difficulty = level
	waves.difficulty = level
	money = TowerData.DIFFICULTIES[level].money
	started = true
	hud.hide_dialog()
	refresh()

func choose(type: int) -> void:
	if not started or ended:
		return
	chosen = type
	map.selected = null
	ghost.sprite_frames = SpriteLibrary.frames_for(type)
	ghost.play("idle")
	ghost.scale = Vector2(0.9, 0.9)
	ghost.visible = true
	hud.message.text = "Escolha uma área livre na neve. Esc cancela."
	refresh()

func _process(_delta: float) -> void:
	if chosen >= 0:
		ghost.position = world.get_local_mouse_position()
		ghost.visible = Rect2(0, 0, 1190, 650).has_point(ghost.position)
		map.ghost_position = ghost.position
		map.ghost_valid = map.valid_spot(ghost.position)
		ghost.modulate = Color(1, 1, 1, 0.6) if map.ghost_valid else Color(1, 0.4, 0.4, 0.5)
	map.show_ghost = chosen >= 0 and ghost.visible
	map.queue_redraw()
	if started and not ended:
		hud.update_selection()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			if chosen >= 0:
				cancel_build()
			elif started and not ended:
				hud.toggle_pause()
		elif event.keycode == KEY_SPACE and started and not ended and not get_tree().paused:
			waves.start_wave()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not started or ended or get_tree().paused:
			return
		var point := world.get_local_mouse_position()
		if not Rect2(0, 0, 1190, 650).has_point(point):
			return
		if chosen >= 0:
			build(point)
		else:
			map.selected = null
			for tower in get_tree().get_nodes_in_group("penguins"):
				if point.distance_to(tower.position) < 40.0:
					map.selected = tower
					break
			refresh()

func build(point: Vector2) -> void:
	var price: int = TowerData.CLASSES[chosen].cost
	if money < price:
		hud.message.text = "Dinheiro insuficiente."
		return
	if not map.valid_spot(point):
		hud.message.text = "Não é possível construir na pista ou sobre outro pinguim."
		return
	var tower := PENGUIN_SCENE.instantiate() as Penguin
	tower.tower_type = chosen
	tower.position = point
	world.add_child(tower)
	money -= price
	map.selected = tower
	cancel_build()
	refresh()

func cancel_build() -> void:
	chosen = -1
	ghost.visible = false
	hud.message.text = "Escolha uma torre. Espaço inicia a próxima onda."
	refresh()

func buy_upgrade(path: int) -> void:
	var tower := map.selected
	if not is_instance_valid(tower) or not tower.can_upgrade(path):
		return
	var price := tower.upgrade_cost(path)
	if money < price:
		hud.message.text = "Dinheiro insuficiente para esta melhoria."
		return
	money -= price
	tower.invested += price
	tower.upgrades[path] += 1
	refresh()

func sell_selected() -> void:
	if is_instance_valid(map.selected):
		money += int(map.selected.invested * 0.7)
		map.selected.queue_free()
		map.selected = null
		refresh()

func enemy_defeated(enemy: Slime) -> void:
	kills += 1
	money += 10 if enemy.kind < 3 else 18
	refresh()

func enemy_escaped(_enemy: Slime) -> void:
	if ended:
		return
	lives -= 1
	if lives <= 0:
		ended = true
		get_tree().paused = true
		hud.show_result(false)
	refresh()

func _on_wave_completed() -> void:
	money += 85 + waves.wave * 4
	if waves.wave == 60 and not rewarded:
		rewarded = true
		ice_coins += TowerData.DIFFICULTIES[difficulty].reward
		var save := ConfigFile.new()
		save.set_value("progress", "ice_coins", ice_coins)
		save.save(save_path)
		get_tree().paused = true
		hud.show_result(true)
	refresh()

func continue_infinite() -> void:
	waves.infinite = true
	get_tree().paused = false
	hud.hide_dialog()
	refresh()

func restart() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()

func refresh() -> void:
	if is_instance_valid(hud) and hud.ready_ui:
		hud.refresh()
