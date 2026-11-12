class_name FrozenMap
extends Node2D

var route := Curve2D.new()
var selected: Penguin
var ghost_position := Vector2(-100, -100)
var ghost_valid := false
var show_ghost := false

func _init() -> void:
	var corners := [Vector2(0, 270), Vector2(400, 270), Vector2(400, 100), Vector2(690, 100), Vector2(690, 390), Vector2(300, 390), Vector2(300, 535), Vector2(995, 535), Vector2(995, 650)]
	route.add_point(corners[0])
	for i in range(1, corners.size() - 1):
		var point: Vector2 = corners[i]
		var before: Vector2 = point.move_toward(corners[i-1], 48.0)
		var after: Vector2 = point.move_toward(corners[i+1], 48.0)
		route.add_point(before, Vector2.ZERO, (point - before) * 0.55)
		route.add_point(after, (point - after) * 0.55, Vector2.ZERO)
	route.add_point(corners[-1])
	route.bake_interval = 4.0

func valid_spot(point: Vector2) -> bool:
	if not Rect2(45, 55, 1100, 540).has_point(point):
		return false
	if point.distance_to(route.get_closest_point(point)) < 66.0:
		return false
	for tower in get_tree().get_nodes_in_group("penguins"):
		if point.distance_to(tower.position) < 72.0:
			return false
	return true

func _draw() -> void:
	draw_rect(Rect2(0, 0, 1190, 650), Color("eaf6fa"))
	var random := RandomNumberGenerator.new()
	random.seed = 91
	for i in range(200):
		var point := Vector2(random.randf_range(0, 1190), random.randf_range(0, 650))
		draw_line(point, point + Vector2(5, -1), Color(1, 1, 1, 0.5), 1.0)
	var points := route.get_baked_points()
	draw_polyline(points, Color("b7dae7"), 68.0, true)
	draw_polyline(points, Color.WHITE, 62.0, true)
	draw_polyline(points, Color("8dd5e9"), 56.0, true)
	draw_polyline(points, Color("a4e1ee"), 43.0, true)
	for point in [Vector2(35, 37), Vector2(80, 23), Vector2(1135, 45), Vector2(1170, 80), Vector2(40, 580), Vector2(90, 610), Vector2(1120, 590)]:
		draw_tree(point)
	if is_instance_valid(selected):
		draw_circle(selected.position, selected.attack_range(), Color(0.4, 0.7, 0.8, 0.035))
		var radius := selected.attack_range()
		for i in range(70):
			draw_arc(selected.position, radius, i * TAU / 70, (i + 0.45) * TAU / 70, 3, Color(0.4, 0.65, 0.75, 0.45), 1.5, true)
	if show_ghost:
		draw_arc(ghost_position, 36.0, 0, TAU, 40, Color("5cb99b") if ghost_valid else Color("da697c"), 2.0, true)

func draw_tree(point: Vector2) -> void:
	draw_set_transform(point)
	draw_circle(Vector2(0, 18), 22.0, Color("bad8df"))
	for i in range(3):
		var width := 24.0 - i * 4.0
		var y := -i * 16.0
		var shape := PackedVector2Array([Vector2(-width, y+17), Vector2(0, y-19), Vector2(width, y+17)])
		draw_colored_polygon(shape, Color("81b4b7"))
		draw_colored_polygon(PackedVector2Array([Vector2(-width+2, y+11), Vector2(0, y-19), Vector2(width-2, y+11), Vector2(0, y+16)]), Color("fafdff"))
	draw_set_transform(Vector2.ZERO)
