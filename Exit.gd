extends Area2D

export(String, FILE, '*.tscn') var next_world

func _physics_process(delta):
	if Input.is_action_pressed('ui_up'):
		var bodies = get_overlapping_bodies()

		for body in bodies:
			if body.name == 'Toph':
				get_tree().change_scene(next_world)
