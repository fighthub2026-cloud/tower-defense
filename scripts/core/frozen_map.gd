class_name FrozenMap
extends Node2D

var route := Curve2D.new()
var snow_art: Texture2D = preload("res://assets/environment/snow.png")
var tree_art: Texture2D = preload("res://assets/environment/tree.png")
var crystal_art: Texture2D = preload("res://assets/environment/crystal.png")
var selected: Penguin
var ghost_position := Vector2(-100, -100)
var ghost_valid := false
var show_ghost := false
var ghost_range := 200.0

func _init() -> void:
	var corners := [Vector2(0, 310), Vector2(470, 310), Vector2(470, 140), Vector2(740, 140), Vector2(740, 460), Vector2(330, 460), Vector2(330, 575), Vector2(900, 575), Vector2(900, 810)]
	route.add_point(corners[0])
	for i in range(1, corners.size() - 1):
		var point: Vector2 = corners[i]
		var before: Vector2 = point.move_toward(corners[i-1], 55.0)
		var after: Vector2 = point.move_toward(corners[i+1], 55.0)
		route.add_point(before, Vector2.ZERO, (point - before) * 0.55)
		route.add_point(after, (point - after) * 0.55, Vector2.ZERO)
	route.add_point(corners[-1])
	route.bake_interval = 4.0

func valid_spot(point: Vector2) -> bool:
	if not Rect2(45, 80, 1150, 660).has_point(point):
		return false
	if point.distance_to(route.get_closest_point(point)) < 66.0:
		return false
	if point.distance_to(Vector2(1070, 310)) < 48.0:
		return false
	for tower in get_tree().get_nodes_in_group("penguins"):
		if point.distance_to(tower.position) < 72.0:
			return false
	return true

func _draw() -> void:
	draw_texture_rect(snow_art, Rect2(0, 0, 1248, 810), true)
	var points := route.get_baked_points()
	draw_polyline(points, Color("b7dae7"), 68.0, true)
	draw_polyline(points, Color("ddf6fc"), 65.0, true)
	draw_polyline(points, Color("8dd5e9"), 56.0, true)
	draw_polyline(points, Color("a4e1ee"), 43.0, true)
	for i in range(24):
		var d := i * route.get_baked_length() / 24.0
		var center := route.sample_baked(d)
		var tangent := (route.sample_baked(minf(d+3.0, route.get_baked_length())) - center).normalized()
		var side := tangent.orthogonal()
		var p := center + side * (14.0 if i % 2 == 0 else -14.0)
		draw_polyline(PackedVector2Array([p + tangent*7, center - tangent*4, center - side*10 - tangent*7]), Color(0.9, 1, 1, 0.24), 1.0, true)
	draw_texture_rect(crystal_art, Rect2(1030, 270, 80, 80), false)
	for point in [Vector2(30, 87), Vector2(76, 58), Vector2(1120, 40), Vector2(1156, 69), Vector2(30, 750), Vector2(78, 773), Vector2(1175, 737)]:
		draw_tree(point)
	if is_instance_valid(selected):
		draw_circle(selected.position, selected.attack_range(), Color(0.4, 0.7, 0.8, 0.035))
		var radius := selected.attack_range()
		for i in range(70):
			draw_arc(selected.position, radius, i * TAU / 70, (i + 0.45) * TAU / 70, 3, Color(0.4, 0.65, 0.75, 0.45), 1.5, true)
	if show_ghost:
		draw_circle(ghost_position, ghost_range, Color(0.30, 0.70, 0.85, 0.065))
		draw_arc(ghost_position, ghost_range, 0, TAU, 80, Color(0.35, 0.68, 0.78, 0.45), 1.0, true)
		draw_arc(ghost_position, 36.0, 0, TAU, 40, Color("5cb99b") if ghost_valid else Color("da697c"), 2.0, true)

func draw_tree(point: Vector2) -> void:
	draw_texture_rect(tree_art, Rect2(point - Vector2(44, 60), Vector2(88, 88)), false)
