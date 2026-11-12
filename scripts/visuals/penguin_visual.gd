class_name PenguinVisual
extends Node2D

signal released
signal finished

const RELEASE_TIME := 0.30
const RELOAD_TIME := 0.70
const ATTACK_DURATION := 0.90
var tower_type := 0
var body_pivot: Node2D
var arm: Node2D
var held: Sprite2D
var body: Sprite2D
var glow: Node2D
var player: AnimationPlayer
var clock := 0.0
var attacking := false
var release_count := 0

func _ready() -> void:
	build()

func build() -> void:
	body_pivot = Node2D.new()
	body_pivot.name = "Body"
	add_child(body_pivot)
	body = Sprite2D.new()
	body.z_index = 2
	body.texture = SpriteLibrary.part(tower_type, 0)
	body.centered = false
	body.offset = SpriteLibrary.REGIONS[tower_type][0].position - SpriteLibrary.BODY_PIVOTS[tower_type]
	body_pivot.add_child(body)
	arm = Node2D.new()
	arm.name = "Arm"
	# Acima do mapa (0), abaixo da cabeça (2); nunca usar profundidade negativa.
	arm.z_index = 1
	arm.position = Vector2(115, 12)
	body_pivot.add_child(arm)
	var weapon := Sprite2D.new()
	weapon.texture = SpriteLibrary.part(tower_type, 1)
	weapon.centered = false
	weapon.offset = SpriteLibrary.REGIONS[tower_type][1].position - SpriteLibrary.ARM_PIVOTS[tower_type]
	arm.add_child(weapon)
	held = Sprite2D.new()
	held.name = "Held"
	held.texture = SpriteLibrary.part(tower_type, 2)
	held.scale = SpriteLibrary.projectile_scale(tower_type) / 0.32
	held.position = SpriteLibrary.HELD_OFFSETS[tower_type]
	# Bala fica no interior do canhão; armadilha só aparece na pista.
	held.visible = tower_type in [0, 1, 3, 5]
	arm.add_child(held)
	glow = Node2D.new()
	glow.name = "Glow"
	glow.position = held.position
	arm.add_child(glow)
	glow.draw.connect(_draw_glow)
	glow.visible = tower_type == 5
	player = AnimationPlayer.new()
	player.name = "AnimationPlayer"
	player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS
	add_child(player)
	var library := AnimationLibrary.new()
	library.add_animation("attack", create_attack())
	player.add_animation_library("", library)
	player.animation_finished.connect(_animation_finished)
	scale = Vector2(0.32, 0.32)

func add_track(animation: Animation, path: NodePath, keys: Array, discrete: bool = false) -> void:
	var track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track, path)
	if discrete:
		animation.value_track_set_update_mode(track, Animation.UPDATE_DISCRETE)
	for key in keys:
		animation.track_insert_key(track, key[0], key[1])

func create_attack() -> Animation:
	var animation := Animation.new()
	animation.length = ATTACK_DURATION
	var wind := 0.38 if tower_type in [1, 3] else 0.045
	var follow := -0.16 if tower_type in [1, 3] else -0.045
	add_track(animation, ^"Body:rotation", [[0.0, 0.0], [0.22, -0.055], [0.30, -0.055], [0.40, 0.065], [0.65, 0.0], [0.90, 0.0]])
	add_track(animation, ^"Body:position", [[0.0, Vector2.ZERO], [0.24, Vector2(0, 3)], [0.30, Vector2(0, 3)], [0.38, Vector2(0, 10 if tower_type == 2 else -3)], [0.62, Vector2.ZERO], [0.90, Vector2.ZERO]])
	add_track(animation, ^"Body/Arm:rotation", [[0.0, 0.0], [0.24, wind], [0.30, wind], [0.40, follow], [0.64, 0.0], [0.90, 0.0]])
	# Ombro fixo: não transladar a asa pelo topo da cabeça.
	add_track(animation, ^"Body/Arm:position", [[0.0, Vector2(115, 12)], [0.90, Vector2(115, 12)]])
	# O objeto some no mesmo instante em que o sinal cria o projétil.
	var has_held := tower_type in [0, 1, 3, 5]
	add_track(animation, ^"Body/Arm/Held:visible", [[0.0, has_held], [RELEASE_TIME, false], [RELOAD_TIME, has_held]], true)
	add_track(animation, ^"Body/Arm/Held:modulate", [[0.0, Color.WHITE], [0.30, Color.WHITE], [0.69, Color(1, 1, 1, 0)], [0.70, Color(1, 1, 1, 0)], [0.83, Color.WHITE], [0.90, Color.WHITE]])
	add_track(animation, ^"Body/Arm/Glow:scale", [[0.0, Vector2.ONE * 0.5], [0.28, Vector2.ONE * 1.7], [RELEASE_TIME, Vector2.ZERO], [0.65, Vector2.ZERO], [0.82, Vector2.ONE * 0.5], [0.90, Vector2.ONE * 0.5]])
	var method := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(method, ^".")
	animation.track_insert_key(method, RELEASE_TIME, {"method": &"_release", "args": []})
	return animation

func play_attack() -> void:
	attacking = true
	player.play("attack")
	player.advance(0.0)

func _release() -> void:
	release_count += 1
	released.emit()

func launch_position() -> Vector2:
	return held.global_position

func launch_rotation() -> float:
	return held.global_rotation

func _animation_finished(_name: StringName) -> void:
	attacking = false
	finished.emit()

func _process(delta: float) -> void:
	clock += delta
	if not attacking:
		body_pivot.position.y = sin(clock * 2.4) * 1.5
		body_pivot.rotation = 0.0
		arm.position = Vector2(115, 12)
		arm.rotation = 0.0
		held.visible = tower_type in [0, 1, 3, 5]
		held.modulate = Color.WHITE
		glow.scale = Vector2.ONE * (0.45 + sin(clock * 3.0) * 0.05)
	if tower_type == 5:
		glow.queue_redraw()

func _draw_glow() -> void:
	for i in range(5, 0, -1):
		glow.draw_circle(Vector2.ZERO, 8.0 + i * 7.0, Color(0.68, 0.25, 1.0, 0.035))
