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
		var current_connection = queue.pop_front()
		for neighbor_door in room_connections.get(current_connection, []):
			if neighbor_door not in visited:
				if connection_Check(current_connection, neighbor_door):
					door_number += 1
				visited[neighbor_door] = true
				queue.append(neighbor_door)

func connection_Check(from: Vector2, to: Vector2) -> bool:
	var difference = to - from
	var checkIfAjdacent = abs(difference.x) + abs(difference.y) == 1
	var check_connection = to in room_connections[from]
	return checkIfAjdacent && check_connection
	
