class_name Waves
extends Node

signal changed
signal completed
var world: Node2D
var route: Curve2D
var wave := 0
var active := false
var remaining := 0
var timer := 0.0
var difficulty := 1
var infinite := false
const SLIME_SCENE := preload("res://scenes/actors/slime.tscn")

func start_wave() -> void:
	if active:
		return
	wave += 1
	remaining = 7 + wave * 2
	timer = 0.0
	active = true
	changed.emit()

func _physics_process(delta: float) -> void:
	if not active:
		return
	timer -= delta
	if remaining > 0 and timer <= 0.0:
		spawn()
		remaining -= 1
		timer = maxf(0.18, 0.85 - wave * 0.009)
	if remaining == 0 and get_tree().get_nodes_in_group("slimes").is_empty():
		active = false
		completed.emit()
		changed.emit()

func spawn() -> void:
	var enemy := SLIME_SCENE.instantiate() as Slime
	enemy.route = route
	var properties: Dictionary = TowerData.DIFFICULTIES[difficulty]
	var last_kind := 0
	for threshold in [3, 7, 12, 18, 24, 30]:
		if wave >= threshold:
			last_kind += 1
	enemy.kind = randi_range(0, last_kind)
	if wave % 10 == 0 and remaining == 1:
		enemy.kind = 7
		enemy.scale = Vector2(1.6, 1.6)
	var breed: Dictionary = TowerData.ENEMIES[enemy.kind]
	enemy.max_health = (35.0 + wave * 7.0) * properties.health * breed.hp
	enemy.health = enemy.max_health
	enemy.speed = (40.0 + minf(wave * 0.6, 35.0)) * properties.speed * breed.speed
	world.add_child(enemy)
	enemy.defeated.connect(func(s: Slime): world.get_parent().enemy_defeated(s))
	enemy.escaped.connect(func(s: Slime): world.get_parent().enemy_escaped(s))
