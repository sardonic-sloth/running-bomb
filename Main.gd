extends Node

var roomGraph = {
	'nodes': {
		'room1': {
			'scene': 'res://Room1.tscn'
		},
		'room2': {
			'scene': 'res://Room2.tscn'
		},
		'room3': {
			'scene': 'res://Room3.tscn'
		}
	},
	'edges': {
		'room1': 'room2',
		'room2': 'room3'
	}
}

var loadedRooms = []

func _ready():
	var roomKey = get_initial_room()
	load_relevant_rooms(roomKey)

	var world = get_tree().get_root().get_node('World')

	var toph = ResourceLoader.load("res://Toph.tscn").instance()
	world.add_child(toph)

func get_initial_room():
	return 'room1'

func load_relevant_rooms(roomKey):
	var rooms = get_neighboring_rooms(roomKey)
	rooms.append(roomKey)
	load_rooms(rooms)
	unload_rooms_except(rooms)

func get_neighboring_rooms(roomKey):
	var neighbors = []
	var edges = roomGraph['edges']
	for room1 in edges.keys():
		var room2 = edges[room1]
		if room1 == roomKey:
			neighbors.append(room2)
		elif room2 == roomKey:
			neighbors.append(room1)
	return neighbors

func unload_rooms_except(rooms):
	for room in loadedRooms:
		if not rooms.has(room):
			unload_room(room)

func load_rooms(rooms):
	for room in rooms:
		if not loadedRooms.has(room):
			load_room(room)

func load_room(roomKey):
	print("loading " + roomKey)
	var world = get_tree().get_root().get_node('World')
	var room = roomGraph['nodes'][roomKey]
	var roomObj = ResourceLoader.load(room['scene']).instance()
	world.add_child(roomObj)
	loadedRooms.append(roomKey)

func unload_room(roomKey):
	print("unloading " + roomKey)
	var world = get_tree().get_roo().get_node('World')
	world.remove_child(roomKey)
	loadedRooms.erase(roomKey)
