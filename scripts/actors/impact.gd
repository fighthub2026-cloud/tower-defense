class_name Impact
extends Node2D
var color := Color.WHITE
var radius := 30.0
var life := 0.35
func _process(delta: float) -> void:
	life -= delta
	if life <= 0.0:
		queue_free()
	queue_redraw()
func _draw() -> void:
	var progress := 1.0 - life / 0.35
	var tint := Color(color, maxf(0.0, 1.0 - progress))
	draw_arc(Vector2.ZERO, 5.0 + progress * radius, 0, TAU, 32, tint, 3.0, true)
	for i in range(7):
		draw_circle(Vector2.from_angle(i * TAU / 7.0) * progress * radius, 3.0 * (1.0 - progress), tint)
