class_name Sbire
extends Sprite2D


const personnages: Array = [
	preload ("res://images/personnages/type_louche_1.png"),
	preload ("res://images/personnages/type_louche_2.png"),
	preload ("res://images/personnages/type_louche_3.png"),
	preload ("res://images/personnages/type_louche_4.png"),
	preload ("res://images/personnages/type_louche_5.png"),
	preload ("res://images/personnages/type_louche_6.png"),
	preload ("res://images/personnages/type_louche_7.png"),
	preload ("res://images/personnages/type_louche_8.png")
]

static var rng = RandomNumberGenerator. new ()


func _ready () -> void:

	# Choisit une texture aléatoire dans l'étalage des personnages
	texture = personnages [rng. randi_range (0, personnages. size () - 1)]


"Détermine si le pointeur souris se situe sur le sbire"

func estDedans () -> bool:
	
	return get_node ("collision"). get_rect (). has_point (to_local (get_viewport (). get_mouse_position ()))
