class_name Projectile
extends Node2D

var target: Slime
var source: Node2D
var tower_type := 0
var damage := 18.0
var slow_duration := 2.5
var lifetime := 3.0
var clock := 0.0
var trap := false
var heading := Vector2.UP
var art: Sprite2D

func _ready() -> void:
	z_index = 3
	art = Sprite2D.new()
	art.texture = SpriteLibrary.part(tower_type, 2)
	art.scale = SpriteLibrary.projectile_scale(tower_type)
	add_child(art)
	if not trap:
		rotation = heading.angle() + PI / 2.0

func _physics_process(delta: float) -> void:
	lifetime -= delta
	clock += delta
	if tower_type == 1 and is_instance_valid(art):
		art.rotation += delta * 20.0
	if lifetime <= 0.0:
		queue_free()
		return
	if trap:
		for enemy in get_tree().get_nodes_in_group("slimes"):
			if enemy.alive and position.distance_to(enemy.position) < 27.0:
				apply_damage(enemy)
				queue_free()
				return
	elif is_instance_valid(target) and target.alive:
		var distance := position.distance_to(target.position)
		var speed := 310.0 if tower_type == 2 else 440.0
		if distance < speed * delta + 10.0:
			impact()
			queue_free()
		else:
			heading = position.direction_to(target.position)
			rotation = heading.angle() + PI / 2.0
			position += heading * speed * delta
	else:
		queue_free()
	queue_redraw()

func apply_damage(enemy: Slime) -> void:
	if is_instance_valid(source) and enemy.alive:
		source.hits += 1
	if tower_type == 3:
		enemy.stick_snow(slow_duration)
		return
	var killed := enemy.hit(damage, 0.0, tower_type in [2, 5])
	if killed and is_instance_valid(source):
		source.kills += 1

func impact() -> void:
	var point := target.position
	apply_damage(target)
	if tower_type == 2:
		for enemy in get_tree().get_nodes_in_group("slimes"):
			if enemy != target and enemy.alive and point.distance_to(enemy.position) < 60.0:
				apply_damage(enemy)
	var ring := Impact.new()
	ring.position = point
	ring.color = TowerData.CLASSES[tower_type].color
	ring.radius = 65.0 if tower_type == 2 else (13.0 if tower_type == 3 else 26.0)
	ring.frost = tower_type == 3
	get_parent().add_child(ring)

func _draw() -> void:
	if tower_type == 5 and not trap:
		for i in range(3):
			draw_circle(Vector2(0, 5 + i * 5), 4.0 - i, Color(0.7, 0.3, 1.0, 0.2 - i * 0.05))
