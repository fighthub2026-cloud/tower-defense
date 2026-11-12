class_name Projectile
extends Node2D

var target: Slime
var source: Node2D
var tower_type := 0
var damage := 18.0
var lifetime := 3.0
var clock := 0.0
var trap := false

func _physics_process(delta: float) -> void:
	lifetime -= delta
	clock += delta
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
			position = position.move_toward(target.position, speed * delta)
	else:
		queue_free()
	queue_redraw()

func apply_damage(enemy: Slime) -> void:
	var killed := enemy.hit(damage, 2.5 if tower_type == 3 else 0.0, tower_type in [2, 5])
	if killed and is_instance_valid(source):
		source.kills += 1

func impact() -> void:
	var point := target.position
	apply_damage(target)
	if tower_type in [2, 3]:
		for enemy in get_tree().get_nodes_in_group("slimes"):
			if enemy != target and enemy.alive and point.distance_to(enemy.position) < 60.0:
				apply_damage(enemy)
	var ring := Impact.new()
	ring.position = point
	ring.color = TowerData.CLASSES[tower_type].color
	ring.radius = 65.0 if tower_type == 2 else 26.0
	get_parent().add_child(ring)

func _draw() -> void:
	var color: Color = TowerData.CLASSES[tower_type].color
	if trap:
		draw_rect(Rect2(-17, -7, 34, 14), Color("4f6677"))
		for i in range(3):
			var x := -12 + i * 10
			draw_colored_polygon(PackedVector2Array([Vector2(x, 5), Vector2(x+4, -12), Vector2(x+8, 5)]), Color("c1e2eb"))
	elif tower_type == 1:
		draw_set_transform(Vector2.ZERO, clock * 17.0)
		var points := PackedVector2Array()
		for i in range(8):
			points.append(Vector2.from_angle(i * PI / 4.0) * (11.0 if i % 2 == 0 else 3.0))
		draw_colored_polygon(points, Color("7795a8"))
		points.append(points[0])
		draw_polyline(points, Color("eafaff"), 1.5, true)
	else:
		draw_circle(Vector2.ZERO, 8.0, Color("263c50") if tower_type == 2 else color)
		draw_arc(Vector2.ZERO, 8.0, 0, TAU, 20, Color.WHITE, 1.5, true)
		draw_circle(Vector2(-2, -2), 2.5, Color(1, 1, 1, 0.8))
