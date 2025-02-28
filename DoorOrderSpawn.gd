extends Node2D

const WIDTH = 7
const HEIGHT = 7
const start_x = int(ceilf(float(WIDTH) / 2.0)) - 1
const start_y = int(ceilf(float(HEIGHT) / 2.0)) - 1

var door_number = 1
var room_connections = {}

func _ready():
	door_ordering()
	
func door_ordering():
	var startingpos = Vector2(start_x, start_y) 
	var visited = {}
	var queue = []
	
	queue.append(startingpos)
	visited[startingpos] = true
	
	while queue.size() > 0:
		var currentDoor = queue.pop_front()
		
		for neighbor_door in room_connections.get(currentDoor, []):
			if neighbor_door not in visited:
				create_numbered_connection(currentDoor, neighbor_door)
				visited[neighbor_door] = true
				
func create_numbered_connection(from: Vector2, to: Vector2):
	room_connections[from].erase(to)
	room_connections[to].erase(from)
	room_connections[from].append([to, door_number])
	room_connections[to].append([from, door_number])
	door_number += 1
	
	
				
				
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
