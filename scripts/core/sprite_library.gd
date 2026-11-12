class_name SpriteLibrary
extends RefCounted

# Recortes do atlas aprovado: corpo, asa/arma descarregada e projétil independente.
const REGIONS: Array[Array] = [
	[Rect2(105, 35, 250, 235), Rect2(475, 62, 170, 196), Rect2(792, 72, 64, 165)],
	[Rect2(105, 280, 250, 236), Rect2(490, 399, 105, 81), Rect2(766, 344, 119, 120)],
	[Rect2(105, 535, 250, 230), Rect2(490, 533, 133, 225), Rect2(777, 616, 98, 95)],
	[Rect2(100, 772, 255, 238), Rect2(490, 399, 105, 81), Rect2(762, 846, 126, 126)],
	[Rect2(100, 1025, 255, 239), Rect2(486, 1037, 125, 191), Rect2(748, 1090, 151, 126)],
	[Rect2(105, 1278, 250, 235), Rect2(484, 1300, 112, 183), Rect2(748, 1320, 156, 157)]
]
const BODY_PIVOTS: Array[Vector2] = [Vector2(244, 177), Vector2(240, 416), Vector2(244, 660), Vector2(244, 910), Vector2(244, 1166), Vector2(244, 1425)]
# Ponto de articulação da asa na imagem de cada arma.
const ARM_PIVOTS: Array[Vector2] = [Vector2(547, 215), Vector2(541, 440), Vector2(545, 714), Vector2(541, 440), Vector2(538, 1181), Vector2(531, 1434)]
const HELD_OFFSETS: Array[Vector2] = [Vector2(12, -80), Vector2(6, -38), Vector2(12, -139), Vector2(12, -50), Vector2(15, -60), Vector2(25, -108)]
const PROJECTILE_SIZES: Array[Vector2] = [Vector2(11, 50), Vector2(22, 22), Vector2(17, 17), Vector2(23, 23), Vector2(35, 29), Vector2(24, 24)]
static var cache: Dictionary = {}

static func part(type: int, column: int) -> AtlasTexture:
	var key := type * 3 + column
	if cache.has(key):
		return cache[key]
	var tile := AtlasTexture.new()
	tile.atlas = load("res://assets/sprites/penguin_layers.png")
	tile.region = REGIONS[type][column]
	cache[key] = tile
	return tile

static func projectile_scale(type: int) -> Vector2:
	return PROJECTILE_SIZES[type] / part(type, 2).get_size()

const WEAPON_REGIONS: Array[Rect2] = [Rect2(475, 62, 170, 129), Rect2(), Rect2(490, 533, 133, 170), Rect2(), Rect2(486, 1037, 125, 134), Rect2(484, 1300, 112, 124)]

static func weapon_part(type: int) -> AtlasTexture:
	var tile := AtlasTexture.new()
	tile.atlas = load("res://assets/sprites/penguin_layers.png")
	tile.region = WEAPON_REGIONS[type]
	return tile

static func enemy_frame(kind: int, frame: int) -> AtlasTexture:
	var key := 1000 + kind * 12 + frame
	if cache.has(key):
		return cache[key]
	var tile := AtlasTexture.new()
	tile.atlas = load("res://assets/sprites/slimes.png")
	tile.region = Rect2(frame * 96, kind * 96, 96, 96)
	cache[key] = tile
	return tile
