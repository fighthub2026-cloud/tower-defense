class_name Slime
extends Node2D

signal defeated(enemy: Slime)
signal escaped(enemy: Slime)
var route: Curve2D
var distance := 0.0
var health := 50.0
var max_health := 50.0
var speed := 45.0
var kind := 0
var slowed := 0.0
var flash := 0.0
var clock := 0.0
var alive := true

func _ready() -> void:
	add_to_group("slimes")
	position = route.sample_baked(0.0)

func _physics_process(delta: float) -> void:
	if not alive:
		return
	clock += delta
	slowed = maxf(0.0, slowed - delta)
	flash = maxf(0.0, flash - delta)
	distance += speed * delta * (0.4 if slowed > 0.0 else 1.0)
	position = route.sample_baked(distance)
	if distance >= route.get_baked_length():
		alive = false
		escaped.emit(self)
		queue_free()
	queue_redraw()

func hit(damage: float, slow: float = 0.0, armor_piercing: bool = false) -> bool:
	if not alive:
		return false
	var dealt := damage * (0.55 if kind == 3 and not armor_piercing else 1.0)
	health -= dealt
	slowed = maxf(slowed, slow)
	flash = 0.1
	if health <= 0.0:
		alive = false
		defeated.emit(self)
		queue_free()
		return true
	return false

func _draw() -> void:
	var colors := [Color("55c9ed"), Color("8ed576"), Color("bb85e7"), Color("869bad")]
	var color: Color = colors[kind]
	if slowed > 0.0:
		color = Color("a9e5f6")
	if flash > 0.0:
		color = Color.WHITE
	var bounce := sin(clock * 7.0 + kind)
	var points := PackedVector2Array()
	for i in range(33):
		var angle := TAU * i / 32.0
		points.append(Vector2(cos(angle) * (19.0 + bounce), sin(angle) * (17.0 - bounce) - 2.0))
	draw_set_transform(Vector2(0, 13), 0.0, Vector2(1, 0.3))
	draw_circle(Vector2.ZERO, 21, Color(0.1, 0.3, 0.4, 0.12))
	draw_set_transform(Vector2.ZERO)
	draw_colored_polygon(points, color)
	draw_polyline(points, Color("366c87"), 2.0, true)
	draw_circle(Vector2(-6, 0), 2.5, Color("203b51"))
	draw_circle(Vector2(6, 0), 2.5, Color("203b51"))
	draw_circle(Vector2(-8, -10), 4, Color(1, 1, 1, 0.7))
	if kind == 3:
		for x in [-12, 0, 12]:
			draw_colored_polygon(PackedVector2Array([Vector2(x-4, -12), Vector2(x, -23), Vector2(x+4, -12)]), Color("c1d5df"))
	if health < max_health:
		draw_rect(Rect2(-20, -31, 40, 4), Color("507182"))
		draw_rect(Rect2(-20, -31, 40 * maxf(health, 0.0) / max_health, 4), Color("77d7a2"))
