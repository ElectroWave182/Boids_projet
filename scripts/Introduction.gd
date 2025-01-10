class_name Introduction
extends Node


func _process (_d: float) -> void:
	
	# Lacement du jeu après un clic gauche
	if (Input. is_action_pressed ("Validation")):
		Jeu. debut = false;
		free ()
