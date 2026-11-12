extends Node2D

func _ready() -> void:
	var heading := Label.new()
	heading.text = "ANIMAÇÕES · VISTA DE CIMA"
	heading.position = Vector2(40, 24)
	heading.add_theme_font_size_override("font_size", 28)
	add_child(heading)
	var hint := Label.new()
	hint.text = "Arma carregada → preparação → lançamento → recarga. F5 abre a partida."
	hint.position = Vector2(40, 66)
	add_child(hint)
	for type in range(6):
		var column := type % 3
		var row := type / 3
		var base := Vector2(135 + column * 450, 275 + row * 340)
		var enemy: Slime = load("res://scenes/actors/slime.tscn").instantiate()
		var curve := Curve2D.new()
		curve.add_point(base + Vector2(170, -75))
		curve.add_point(base + Vector2(270, -75))
		enemy.route = curve
		enemy.health = 1000000.0
		enemy.max_health = 1000000.0
		add_child(enemy)
		enemy.set_physics_process(false)
		enemy.position = base + Vector2(170, -75)
		var tower: Penguin = load("res://scenes/actors/penguin.tscn").instantiate()
		tower.tower_type = type
		tower.position = base
		add_child(tower)
		var caption := Label.new()
		caption.text = TowerData.CLASSES[type].name
		caption.position = base + Vector2(-50, 90)
		caption.add_theme_font_size_override("font_size", 21)
		add_child(caption)
