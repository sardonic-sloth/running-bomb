extends Area2D

export(String) var roomKey

func _ready():
	connect('body_entered', self, 'loadRoom')

func loadRoom(body):
	if body.name == 'Toph':
		Main.load_relevant_rooms(roomKey)
