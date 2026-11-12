class_name TowerData
extends RefCounted

const CLASSES: Array[Dictionary] = [
	{"name": "Atirador", "cost": 170, "range": 200.0, "cooldown": 1.0, "damage": 18.0, "color": Color("69c8f2")},
	{"name": "Ninja", "cost": 300, "range": 190.0, "cooldown": 0.8, "damage": 16.0, "color": Color("e77577")},
	{"name": "Canhoneiro", "cost": 445, "range": 240.0, "cooldown": 1.9, "damage": 42.0, "color": Color("ffb35a")},
	{"name": "Congelador", "cost": 325, "range": 185.0, "cooldown": 1.4, "damage": 10.0, "color": Color("a8ecff")},
	{"name": "Engenheiro", "cost": 350, "range": 190.0, "cooldown": 2.1, "damage": 32.0, "color": Color("ffce62")},
	{"name": "Mago", "cost": 475, "range": 220.0, "cooldown": 1.25, "damage": 26.0, "color": Color("d3a1ff")}
]
const DIFFICULTIES: Array[Dictionary] = [
	{"name": "Fácil", "health": 0.85, "speed": 0.9, "money": 1000, "reward": 100},
	{"name": "Médio", "health": 1.0, "speed": 1.0, "money": 850, "reward": 200},
	{"name": "Difícil", "health": 1.3, "speed": 1.1, "money": 750, "reward": 350}
]
