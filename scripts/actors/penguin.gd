class_name Penguin
extends Node2D

var tower_type := 0
var cooldown := 0.0
var target: Slime
var attacking := false
var released := false
var kills := 0
var invested := 0
var upgrades: Array[int] = [0, 0, 0]
@onready var sprite: AnimatedSprite2D = $Sprite

func _ready() -> void:
	add_to_group("penguins")
	invested = TowerData.CLASSES[tower_type].cost
	sprite.sprite_frames = SpriteLibrary.frames_for(tower_type)
	sprite.play("idle")
	sprite.frame_changed.connect(_on_frame_changed)
	sprite.animation_finished.connect(_on_animation_finished)

func attack_range() -> float:
	return TowerData.CLASSES[tower_type].range * (1.0 + upgrades[2] * 0.22)

func attack_damage() -> float:
	return TowerData.CLASSES[tower_type].damage * (1.0 + upgrades[0] * 0.55)

func upgrade_cost(path: int) -> int:
	return int(TowerData.CLASSES[tower_type].cost * (0.5 + upgrades[path] * 0.7))

func can_upgrade(path: int) -> bool:
	if upgrades[path] >= 3:
		return false
	for other in range(3):
		if other != path and upgrades[other] == 3 and upgrades[path] >= 1:
			return false
	if upgrades[path] == 2:
		for other in range(3):
			if other != path and upgrades[other] > 1:
				return false
	return true

func _physics_process(delta: float) -> void:
	cooldown = maxf(0.0, cooldown - delta)
	if attacking or cooldown > 0.0:
		return
	var best: Slime = null
	for enemy in get_tree().get_nodes_in_group("slimes"):
		if enemy.alive and position.distance_to(enemy.position) <= attack_range():
			if best == null or enemy.distance > best.distance:
				best = enemy
	if best == null:
		return
	target = best
	sprite.flip_h = target.position.x < position.x
	attacking = true
	released = false
	cooldown = TowerData.CLASSES[tower_type].cooldown / (1.0 + upgrades[1] * 0.3)
	sprite.play("attack")

func _on_frame_changed() -> void:
	if sprite.animation != &"attack" or sprite.frame < 9 or released:
		return
	released = true
	if not is_instance_valid(target) or not target.alive:
		return
	var shot := Projectile.new()
	shot.tower_type = tower_type
	shot.target = target
	shot.source = self
	shot.damage = attack_damage()
	if tower_type == 4:
		shot.trap = true
		shot.position = target.route.sample_baked(target.distance + 20.0)
		shot.lifetime = 8.0
	else:
		shot.position = position + Vector2(-22 if sprite.flip_h else 22, 8)
	get_parent().add_child(shot)

func _on_animation_finished() -> void:
	if sprite.animation == &"attack":
		attacking = false
		sprite.play("idle")
