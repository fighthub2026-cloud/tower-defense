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
	enemy.kind = 0 if wave < 3 else randi_range(0, 1)
	if wave >= 7:
		enemy.kind = randi_range(0, 2)
	if wave >= 12:
		enemy.kind = randi_range(0, 3)
	enemy.max_health = (35.0 + wave * 7.0) * properties.health * (1.8 if enemy.kind == 3 else 1.0)
	enemy.health = enemy.max_health
	enemy.speed = (40.0 + minf(wave * 0.6, 35.0)) * properties.speed * (1.3 if enemy.kind == 1 else 1.0)
	if wave % 10 == 0 and remaining == 1:
		enemy.scale = Vector2(1.65, 1.65)
		enemy.health *= 7.0
		enemy.max_health = enemy.health
		enemy.speed *= 0.65
	world.add_child(enemy)
	enemy.defeated.connect(func(s: Slime): world.get_parent().enemy_defeated(s))
	enemy.escaped.connect(func(s: Slime): world.get_parent().enemy_escaped(s))
