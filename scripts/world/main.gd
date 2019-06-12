extends Node

var roomGraph = {}
var loadedRooms = []

func _ready():
	load_room_graph()

	var roomKey = get_initial_room()
	load_relevant_rooms(roomKey)

	var world = get_tree().get_root().get_node('World')

	var toph = ResourceLoader.load("res://scenes/player/toph.tscn").instance()
	world.add_child(toph)

func load_room_graph():
	var file = File.new()
	file.open('res://rooms.json', file.READ)
	var json = JSON.parse(file.get_as_text())
	file.close()

	if json.error == OK:
		roomGraph = json.result
	else:
		print("Error: ", json.error)
		print("Error Line: ", json.error_line)
		print("Error String: ", json.error_string)

func get_initial_room():
	return 'room1'

func load_relevant_rooms(roomKey):
	var rooms = get_neighboring_rooms(roomKey)
	rooms.push_front(roomKey)
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
