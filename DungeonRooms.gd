extends Node2D

# Dungeon Grid Conditions
const WIDTH = 5
const HEIGHT = 5
const MAX_ROOMS = 7

# Contains a list of directions
var directions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

#Contains a 2D array of the dungeon
var dungeon = []

# Dictionary of room connections (Uses the room coordinates as a key to find what rooms it is connected to)
var room_connections = {}  

# List of Room Types
enum { EMPTY, NORMAL, START, BOSS, TREASURE, SHOP, LONG_H, BIG }

# ASCII representation of each room type
var room_symbols = {
	EMPTY: " ",
	START: "S",
	NORMAL: "N",
	BOSS: "B",
	TREASURE: "T",
	SHOP: "$",
	LONG_H: "=",
	BIG: "□"
}

# Tracking variables
var normal_room_list = []
var long_h_count = 0  
var big_room_count = 0  
var treasure_room_count = 0
var is_shop_spawn = false

#Creates x and y and centers them on the 2D Array
var x = int(ceilf(float(WIDTH) / 2.0 ))
var y = int(ceilf(float(HEIGHT) / 2.0 ))

# Initializes the creation of the Dungeon Map
func _ready():
	# Randomizes the set seed for all rand calls
	randomize()
	
	# Initializes the creation of the Dungeon Map
	generate_dungeon()
	ensure_full_connectivity()
	
	# Prints the Dungeon in ASCII
	print_dungeon()

#Generates the Dungeon
func generate_dungeon():
	
	# Creates the 2D Array for the Dungeon
	for y in range(HEIGHT):
		dungeon.append([])
		for x in range(WIDTH):
			dungeon[y].append(EMPTY)
	
	# Creates the starting room and sets up possible room connections
	var num_rooms = 1
	dungeon[y][x] = START
	room_connections[Vector2(x, y)] = []

	# Ensures the Dungeon creates the desired amount of rooms
	while num_rooms < MAX_ROOMS:
		# Picks a random direction
		var dir = directions[randi() % directions.size()]
		var new_x = x + dir.x
		var new_y = y + dir.y
		
		# Checks if the random direction is within the 2D Array Bounds
		if new_x >= 0 and new_x < WIDTH and new_y >= 0 and new_y < HEIGHT:
			# Calls pick_room_type function to pick a room type
			var room_type = pick_room_type(new_x, new_y)
			
			# Counts which room is created
			if room_type != EMPTY:
				x = new_x
				y = new_y
				if room_type == NORMAL:
					# Adds all normal rooms to a list
					normal_room_list.append(Vector2(x, y))
				elif room_type == LONG_H:
					long_h_count += 1
				elif room_type == BIG:
					big_room_count += 1
				# Adds all rooms to the dictionary
				room_connections[Vector2(x, y)] = []
				# Creates a random connection to neighboring (adjacent) rooms
				add_random_connection(Vector2(x, y))
				num_rooms += 1
	
	place_special_rooms()

func place_special_rooms():
	for pos in normal_room_list:
		if randf() < 0.1 and treasure_room_count < 2:
			dungeon[pos.y][pos.x] = TREASURE
			treasure_room_count += 1
		elif randf() < 0.35 and !is_shop_spawn:
			dungeon[pos.y][pos.x] = SHOP
			is_shop_spawn = true
	if treasure_room_count == 0:
		var rand = randi() % normal_room_list.size()
		dungeon[normal_room_list[rand].y][normal_room_list[rand].x] = TREASURE
		treasure_room_count += 1

func pick_room_type(x, y) -> int:
	if dungeon[y][x] != EMPTY:
		return EMPTY
	
	var possible_types = [NORMAL]

	# Check space for LONG_H (1x2 Horizontal Room)
	if long_h_count < 2 and x < WIDTH - 1:
		if dungeon[y][x + 1] == EMPTY:
			possible_types.append(LONG_H)
	
	# Check space for BIG (2x2 Room)
	if big_room_count < 1 and x < WIDTH - 1 and y < HEIGHT - 1:
		if (dungeon[y][x + 1] == EMPTY and dungeon[y + 1][x] == EMPTY and dungeon[y + 1][x + 1] == EMPTY):
			possible_types.append(BIG)
	
	# Weighted Random Selection of if to add a Big Room or Long Room
	if randf() < 0.01 and BIG in possible_types: # 1% Chance to add Big Room
		placeBIG(y,x)
		return BIG
	elif randf() < 0.1 and LONG_H in possible_types: # 10% Chance to add Big Room
		placeLONG_H(y,x)
		return LONG_H
	
	# 89% Chance to add a Normal Room
	dungeon[y][x] = NORMAL
	return NORMAL

# Creates a Big Room
func placeBIG(y, x):
	dungeon[y][x] = BIG
	dungeon[y][x + 1] = BIG
	dungeon[y + 1][x] = BIG
	dungeon[y + 1][x + 1] = BIG
	big_room_count += 1

# Creates a Horizontal Long Room
func placeLONG_H(y, x):
	dungeon[y][x] = LONG_H
	dungeon[y][x + 1] = LONG_H  
	long_h_count += 1

# Adds random room connections
func add_random_connection(room: Vector2):
	# Creates a list of all neighboring rooms
	var possible_neighbors = []

	# Check for all valid directions (up, down, left, right) to find neighbors
	for dir in directions:
		var neighbor = room + dir
		
		# Ensure the neighbor is within bounds
		if neighbor.x >= 0 and neighbor.x < WIDTH and neighbor.y >= 0 and neighbor.y < HEIGHT:
			
			# Check for LONG_H room (1x2) - Can connect vertically or horizontally
			if dungeon[room.y][room.x] == LONG_H:
				# Prevent connection to the other part of the LONG_H room horizontally
				if dir == Vector2.RIGHT and room.x + 1 < WIDTH and dungeon[room.y][room.x + 1] == LONG_H:
					continue  # Skips to the next direction in the for loop
					
				# Valid directions for Horizontal Long Rooms (checking up, down, right, left)
				elif dir == Vector2.LEFT and room.x > 0 and dungeon[room.y][room.x - 1] != EMPTY:
					possible_neighbors.append(neighbor)
				elif dir == Vector2.RIGHT and room.x + 1 < WIDTH and dungeon[room.y][room.x + 1] != EMPTY:
					possible_neighbors.append(neighbor)
				elif dir == Vector2.UP and room.y > 0 and dungeon[room.y - 1][room.x] != EMPTY:
					possible_neighbors.append(neighbor)
				elif dir == Vector2.DOWN and room.y + 1 < HEIGHT and dungeon[room.y + 1][room.x] != EMPTY:
					possible_neighbors.append(neighbor)
				
			# Check for BIG room (2x2) - Can connect on all four sides but not within itself
			elif dungeon[room.y][room.x] == BIG:
				# Prevent horizontal connections within the BIG room (left-right)
				if dir == Vector2.LEFT and room.x > 0 and dungeon[room.y][room.x - 1] == BIG:
					continue  
				elif dir == Vector2.RIGHT and room.x + 1 < WIDTH and dungeon[room.y][room.x + 1] == BIG:
					continue 
				# Prevent vertical connections within the BIG room (top-bottom)
				elif dir == Vector2.UP and room.y > 0 and dungeon[room.y - 1][room.x] == BIG:
					continue
				elif dir == Vector2.DOWN and room.y + 1 < HEIGHT and dungeon[room.y + 1][room.x] == BIG:
					continue 

				# Valid directions for Big Rooms (checking up, down, right, left)
				if dir == Vector2.LEFT and room.x > 0 and dungeon[room.y][room.x - 1] != EMPTY:
					possible_neighbors.append(neighbor)
				elif dir == Vector2.RIGHT and room.x + 1 < WIDTH and dungeon[room.y][room.x + 1] != EMPTY:
					possible_neighbors.append(neighbor)
				elif dir == Vector2.UP and room.y > 0 and dungeon[room.y - 1][room.x] != EMPTY:
					possible_neighbors.append(neighbor)
				elif dir == Vector2.DOWN and room.y + 1 < HEIGHT and dungeon[room.y + 1][room.x] != EMPTY:
					possible_neighbors.append(neighbor)

			# For normal rooms, check for valid connections to neighboring rooms
			elif dungeon[room.y][room.x] == NORMAL:
				# If neighbor has a room
				if dungeon[neighbor.y][neighbor.x] != EMPTY:  
					possible_neighbors.append(neighbor)

	# If there are valid neighbors, randomly choose one to connect
	if possible_neighbors.size() > 0:
		# Randomly decide the number of connections to create (can increase the "+ 1" to a "+ 2" or higher for a larger chance of room connectivity)
		var num_connections = randi() % (possible_neighbors.size()) + 1
		
		# Ensure each room only connects to a limited number of other rooms
		for i in range(num_connections):
			var chosen_neighbor = possible_neighbors[randi() % possible_neighbors.size()]
			# Avoid redundant connections
			if chosen_neighbor not in room_connections.get(room, []):
				# If the room is not in the dictionary then it adds it
				if not room_connections.has(room):
					room_connections[room] = []
				if not room_connections.has(chosen_neighbor):
					room_connections[chosen_neighbor] = []
				
				# Add bidirectional connections between rooms
				room_connections[room].append(chosen_neighbor)
				room_connections[chosen_neighbor].append(room)

# Ensures all rooms can be connected to each other at the end
func ensure_full_connectivity():
	var visited = {} # Dictionary to track visited rooms
	var queue = [Vector2(x, y)] # BFS queue initialized with the starting room 
	visited[Vector2(x, y)] = true # Mark the starting room as visited

	while queue.size() > 0:
		# Adds neighboring rooms to the queue and visits them
		var current = queue.pop_front() 
		for neighbor in room_connections[current]:
			if !visited.has(neighbor):
				visited[neighbor] = true
				queue.append(neighbor)
	
	# Checks if there are disconnected rooms by iterating over every room in the grid
	for room in room_connections.keys():
		# For all rooms not visited in the BFS it adds a random connection to another room
		if !visited.has(room):
			add_random_connection(room)
	
func print_dungeon():
	print("\nDungeon Layout:\n")
	
	for y in range(HEIGHT):
		var room_row = ""
		var door_row = ""  
		var first_vert = false

		for x in range(WIDTH):
			var pos = Vector2(x, y)
			
			# Add room symbol
			room_row += room_symbols[dungeon[y][x]]

			# Add horizontal door
			if Vector2(x + 1, y) in room_connections.get(pos, []):
				room_row += "  +  "  # Horizontal door
			else:
				room_row += "     "  # Maintain spacing
			
			# Add vertical doors
			if Vector2(x, y + 1) in room_connections.get(pos, []):
				if !first_vert:
					door_row += "+  " 
					first_vert = true
				else:
					door_row += "  +  "  # Vertical door
			else:
				door_row += "     "  # Maintain spacing
			door_row += " "

		# Print the room row
		print(room_row)

		# Print vertical doors
		print(door_row)
		first_vert = false

	print("\n")
