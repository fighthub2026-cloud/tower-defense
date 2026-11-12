extends Node2D

var samples: Array[Slime] = []
const DETAILS: Array[String] = ["Equilibrada", "Mais rápida e frágil", "Divide-se em duas", "Reduz dano comum", "Resiste à lentidão", "Regenera após dano", "Rápida e resistente", "Chefe a cada 10 ondas"]
func _ready() -> void:
	var title := Label.new()
	title.text = "GOSMAS DO VALE CONGELADO"
	title.position = Vector2(32, 24)
	title.add_theme_font_size_override("font_size", 30)
	add_child(title)
	for kind in range(8):
		var point := Vector2(170 + kind % 4 * 360, 220 + kind / 4 * 340)
		var curve := Curve2D.new()
		curve.add_point(point)
		curve.add_point(point + Vector2(100, 0))
		var enemy: Slime = load("res://scenes/actors/slime.tscn").instantiate()
		enemy.kind = kind
		enemy.route = curve
		enemy.scale = Vector2(2.8, 2.8)
		add_child(enemy)
		enemy.set_physics_process(false)
		samples.append(enemy)
		var caption := Label.new()
		caption.text = TowerData.ENEMIES[kind].name + "\n" + DETAILS[kind]
		caption.position = point + Vector2(-160, 95)
		caption.size = Vector2(320, 80)
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		caption.add_theme_font_size_override("font_size", 18)
		add_child(caption)
func _process(delta: float) -> void:
	for sample in samples:
		sample.clock += delta
		sample.queue_redraw()
