class_name SpriteLibrary
extends RefCounted

static var cache: Dictionary = {}

static func frames_for(type: int) -> SpriteFrames:
	if cache.has(type):
		return cache[type]
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	var texture := load("res://assets/sprites/penguins.png") as Texture2D
	for row in range(2):
		var animation: StringName = &"idle" if row == 0 else &"attack"
		frames.add_animation(animation)
		frames.set_animation_speed(animation, 12.0 if row == 0 else 30.0)
		frames.set_animation_loop(animation, row == 0)
		for frame in range(24):
			var tile := AtlasTexture.new()
			tile.atlas = texture
			tile.region = Rect2(frame * 128, type * 256 + row * 128, 128, 128)
			frames.add_frame(animation, tile)
	cache[type] = frames
	return frames
