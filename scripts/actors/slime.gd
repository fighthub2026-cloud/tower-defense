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
var damage_timer := 0.0
var alive := true
var fragment := false
var snow_patches: Array[float] = []

func _ready() -> void:
	add_to_group("slimes")
	position = route.sample_baked(distance)

func _physics_process(delta: float) -> void:
	if not alive:
		return
	clock += delta
	damage_timer += delta
	for i in range(snow_patches.size() - 1, -1, -1):
		snow_patches[i] -= delta
		if snow_patches[i] <= 0.0:
			snow_patches.remove_at(i)
	slowed = maxf(0.0, slowed - delta)
	flash = maxf(0.0, flash - delta)
	if kind == 5 and damage_timer > 1.5:
		health = minf(max_health, health + max_health * 0.035 * delta)
	distance += speed * delta * (0.5 if slowed > 0.0 else 1.0)
	position = route.sample_baked(distance)
	if distance >= route.get_baked_length():
		alive = false
		escaped.emit(self)
		queue_free()
	queue_redraw()

func hit(damage: float, _slow: float = 0.0, armor_piercing: bool = false) -> bool:
	if not alive or damage <= 0.0:
		return false
	var multiplier: float = TowerData.ENEMIES[kind].armor
	health -= damage * (1.0 if armor_piercing else multiplier)
	damage_timer = 0.0
	flash = 0.075
	if health <= 0.0:
		alive = false
		defeated.emit(self)
		queue_free()
		return true
	return false

func _draw() -> void:
	var frame := int(clock * 12.0) % 12
	var tint := Color(1, 1, 1) if flash <= 0.0 else Color(1.5, 1.5, 1.5)
	draw_texture_rect(SpriteLibrary.enemy_frame(kind, frame), Rect2(-32, -37, 64, 64), false, tint)
	if slowed > 0.0:
		# Liseré gelado e pequenas placas achatadas; o rosto permanece visível.
		var fade := minf(1.0, slowed / 0.35)
		draw_arc(Vector2(0, 1), 20.0, 0.15, PI - 0.15, 18, Color(0.83, 0.96, 1.0, fade * 0.8), 2.0, true)
		var offsets := [Vector2(-15, 5), Vector2(14, 7), Vector2(2, -18)]
		for i in range(snow_patches.size()):
			var local_fade := minf(1.0, snow_patches[i] / 0.3)
			draw_set_transform(offsets[i], -0.25 if i % 2 == 0 else 0.25, Vector2(1.0, 0.42))
			draw_circle(Vector2.ZERO, 5.0, Color(0.68, 0.86, 0.96, local_fade * 0.8))
			draw_circle(Vector2(0, -1), 4.0, Color(0.97, 1, 1, local_fade))
		draw_set_transform(Vector2.ZERO)
	if health < max_health:
		draw_rect(Rect2(-19, -33, 38, 4), Color("4c6b86"))
		draw_rect(Rect2(-18, -32, 36 * maxf(health, 0.0) / max_health, 2), Color("7fda9d"))

func stick_snow(duration: float) -> void:
	if not alive:
		return
	var effective := duration * float(TowerData.ENEMIES[kind].slow)
	slowed = maxf(slowed, effective)
	if snow_patches.size() >= 3:
		snow_patches.pop_front()
	snow_patches.append(effective)
	queue_redraw()
