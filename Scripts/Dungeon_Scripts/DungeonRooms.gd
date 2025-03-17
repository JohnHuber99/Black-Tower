extends Node2D

# Loading Room Objects
@export var MAX_BIG_ROOMS = 1 #Original value is 1
@export var MAX_LONG_ROOMS = 2 #Original value is 2
@export var BIG_ROOM_CHANCE = 0.01 #Original value is 0.01
@export var LONG_ROOM_CHANCE = 0.1 #Original value is 0.1

const NORMAL_ROOM = preload("res://Rooms/Normal_Room.tscn")
const TREASURE_ROOM = preload("res://Rooms/Normal_Room.tscn")
const SHOP_ROOM = preload("res://Rooms/Normal_Room.tscn")
const LONG_ROOM = preload("res://Rooms/Long_Room.tscn")
const BIG_ROOM = preload("res://Rooms/Big_Room.tscn")
const BOSS_ROOM = preload("res://Rooms/Big_Room.tscn")
const DOOR = preload("res://Rooms/Door.tscn")
const STARTING_ROOM = preload("res://Rooms/Starting_Room.tscn")

# Dungeon Grid Conditions
@export var WIDTH = 7 #Original value is 7
@export var HEIGHT = 7 #Original value is 7
@export var MAX_ROOMS = 7 #Original value is 7
@export var MAX_LOOPS = 40 #Original value is 40

# Contains a list of directions
var directions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

#Contains a 2D array of the dungeon
var dungeon = []

# Dictionary of room connections (Uses the room coordinates as a key to find what rooms it is connected to)
var room_connections = {}

# List of Room Types
enum { EMPTY, NORMAL, START, FINAL, TREASURE, SHOP, LONG_H, BIG, BOSS}

# ASCII representation of each room type
var room_symbols = {
	EMPTY: " ",
	START: "S",
	NORMAL: "N",
	FINAL: "F",
	TREASURE: "T",
	SHOP: "$",
	LONG_H: "=",
	BIG: "□",
	BOSS: "B"
}

# Tracking variables
var boss_room_list = []
var boss_room_list_spawn = []
var possible_neighbors = []
var long_room_list = []
var long_room_list_spawn = []
var big_room_list = []
var big_room_list_spawn = []
var normal_room_list = []
var long_h_count = 0  
var big_room_count = 0  
var treasure_room_count = 0
var is_shop_spawn = false
var num_loops = 0
var num_rooms = 1

var room_size = 27

#Creates x and y and centers them on the 2D Array
var start_x = WIDTH/2
var start_y = HEIGHT/2

var x = start_x
var y = start_y

# Initializes the creation of the Dungeon Map
func _init():
	# Generates the Seed for the Dungeon Layout that we can reuse
	var seed_value = randi() 
	seed(seed_value) 
	print("Generate Seed : ", seed_value)

	var attempts = 0
	while true:
		generate_dungeon()
		#place_final_room()
		place_boss_room()
		place_special_rooms()
		attempts += 1
		
		if is_valid_dungeon():
			print("Dungeon generated successfully after ", attempts, " attempts!")
			# Call a function to draw the dungeon on screen
			print_dungeon()
			spawn_dungeon()
			break
		
		if attempts % 100 == 0:
			print("Still generating... Attempt: ", attempts, "\n")  # Debugging output
			print("Unfinished Dungeon Attempt: \n")
			print_dungeon()
		
		if attempts == 1001:
			break

func spawn_dungeon(): 
	var tile_size = 16  # Change this based on your actual tile size
	var room_size = 27 * tile_size  # 27 tiles per room

	# Initialize counters for naming rooms
	var normal_room_name_count = 1
	var big_room_name_count = 1
	var long_room_name_count = 1
	var boss_room_count = 1
	var treasure_room_name_count = 1
	var shop_room_name_count = 1

	# First, spawn rooms
	var rooms = {}  # To store room instances by their positions
	for y in HEIGHT:
		for x in WIDTH:
			var room_type = dungeon[y][x]
			if room_type != EMPTY:
				var room_instance
				var room_name = ""

				match room_type:
					START: 
						room_instance = STARTING_ROOM.instantiate() 
						room_name = "Start Room"
					NORMAL: 
						room_instance = NORMAL_ROOM.instantiate() 
						room_name = "Normal Room %d" % normal_room_name_count
						normal_room_name_count += 1
					BIG:
						if Vector2(x, y) in big_room_list_spawn:
							room_instance = BIG_ROOM.instantiate()
							room_name = "Big Room %d" % big_room_name_count
							big_room_name_count += 1
					LONG_H:
						if Vector2(x, y) in long_room_list_spawn:
							room_instance = LONG_ROOM.instantiate()
							room_name = "Long Room %d" % long_room_name_count
							long_room_name_count += 1
					BOSS:
						if Vector2(x, y) in boss_room_list_spawn:
							room_instance = BOSS_ROOM.instantiate() 
							room_name = "Boss Room"
					TREASURE: 
						room_instance = TREASURE_ROOM.instantiate()
						room_name = "Treasure Room %d" % treasure_room_name_count
						treasure_room_name_count += 1
					SHOP: 
						room_instance = SHOP_ROOM.instantiate()
						room_name = "Shop Room %d" % shop_room_name_count
						shop_room_name_count += 1

				if room_instance:
					add_child(room_instance)
					room_instance.global_position = Vector2(x * room_size, y * room_size)
					room_instance.name = room_name  # Rename the room
					
					# Store rooms in the dictionary
					if room_type == NORMAL or room_type == START or room_type == TREASURE or room_type == SHOP:
						# For normal and other rooms, just store the single position
						rooms[Vector2(x, y)] = room_instance
					elif room_type == LONG_H:
						# LONG_H room takes up a 1x2 area, store both positions horizontally
						for dx in range(2):
							if is_room_in_long_list(Vector2(x + dx, y)):
								rooms[Vector2(x + dx, y)] = room_instance
							if is_room_in_long_list(Vector2(x - dx, y)):
								rooms[Vector2(x - dx, y)] = room_instance
					if room_type == BIG:
						# BIG room takes up a 2x2 area, store all its positions
						for dx in range(2):
							for dy in range(2):
								if is_room_in_big_list(Vector2(x + dx, y + dy - 1)):
									rooms[Vector2(x + dx, y + dy - 1)] = room_instance
								if is_room_in_big_list(Vector2(x - dx + 1, y - dy)):
									rooms[Vector2(x - dx + 1, y - dy)] = room_instance
					elif room_type == BOSS:
						# BIG room takes up a 2x2 area, store all its positions
						for dx in range(2):
							for dy in range(2):
								if is_room_in_boss_list(Vector2(x + dx, y + dy - 1)):
									rooms[Vector2(x + dx, y + dy - 1)] = room_instance
								if is_room_in_boss_list(Vector2(x - dx + 1, y - dy)):
									rooms[Vector2(x - dx + 1, y - dy)] = room_instance

	# Iterate through every key called, room_pos, in room_connections dictionary
	for room_pos in room_connections.keys():
		var room_world_pos = Vector2(room_pos.x * room_size, room_pos.y * room_size)

		# Iterate through every value called, neighbor, stored in the key room_pos
		for neighbor in room_connections[room_pos]:            
			# Create Door in Godot Scene
			var door_instance = DOOR.instantiate()
			
			# Find the corresponding room for the neighbor position
			var room_instance = rooms.get(room_pos)
			if room_instance:
				room_instance.add_child(door_instance)  # Add the door as a child of the room instance

			# Determine door placement coordinates
			var offset = neighbor - room_pos
			
			if offset == Vector2.UP: #up door
				door_instance.global_position = room_world_pos + Vector2(room_size / 2, 0) - Vector2(0, room_size - tile_size)
				door_instance.type = "up"
			elif offset == Vector2.DOWN: #down door
				door_instance.global_position = room_world_pos - Vector2(0, tile_size) + Vector2(room_size / 2, room_size) - Vector2(0, room_size - tile_size)
				door_instance.type = "down"
			elif offset == Vector2.LEFT: #left door
				door_instance.global_position = room_world_pos + Vector2(0, room_size / 2) - Vector2(0, room_size - tile_size)
				door_instance.type = "left"
			elif offset == Vector2.RIGHT: #right door
				door_instance.global_position = room_world_pos - Vector2(tile_size, 0) + Vector2(room_size, room_size / 2) - Vector2(0, room_size - tile_size)
				door_instance.type = "right"

func is_room_in_big_list(position: Vector2) -> bool:
	for big_room in big_room_list:
		for big_room_position in big_room:
			var vector_big_room = Vector2(big_room_position[0], big_room_position[1])
			if position == vector_big_room:  
				return true
	return false

# Function to check if a room is part of the boss_room_list
func is_room_in_boss_list(position: Vector2) -> bool:
	for boss_room in boss_room_list:
		for boss_room_position in boss_room:
			var vector_boss_room = Vector2(boss_room_position[0], boss_room_position[1])
			if position == vector_boss_room:  
				return true
	return false

# Function to check if a room is part of the long_room_list
func is_room_in_long_list(position: Vector2) -> bool:
	for long_room in long_room_list:
		for long_room_position in long_room:
			var vector_long_room = Vector2(long_room_position[0], long_room_position[1])
			if position == vector_long_room: 
				return true
	return false

		
#Generates the Dungeon
func generate_dungeon():
	dungeon = []
	boss_room_list = []
	boss_room_list_spawn = []
	room_connections = {}  
	long_room_list = []
	long_room_list_spawn = []
	big_room_list = []
	big_room_list_spawn = []
	normal_room_list = []
	long_h_count = 0
	big_room_count = 0
	treasure_room_count = 0
	num_loops = 0
	num_rooms = 1
	is_shop_spawn = false
	x = start_x
	y = start_y
	var prevDir = null
	
	# Creates the 2D Array for the Dungeon
	for gridHeight in range(HEIGHT):
		dungeon.append([])
		for gridWidth in range(WIDTH):
			dungeon[gridHeight].append(EMPTY)
	
	# Creates the starting room and sets up possible room connections
	dungeon[start_y][start_x] = START
	room_connections[Vector2(start_x, start_y)] = []

	# Ensures the Dungeon creates the desired amount of rooms
	while num_rooms < MAX_ROOMS:
		if num_loops > MAX_LOOPS:
			break
		num_loops += 1
		
		# Picks a random direction
		var dir = directions[randi() % directions.size()]
		var new_x = x + dir.x
		var new_y = y + dir.y
		
		if (prevDir == dir):
			dir = directions[randi() % directions.size()]
			new_x = start_x + dir.x
			new_y = start_y + dir.y
		
		# Checks if the random direction is within the 2D Array Bounds
		if new_x >= 0 and new_x < WIDTH and new_y >= 0 and new_y < HEIGHT:
			prevDir = dir
			x = new_x
			y = new_y
			
			if dungeon[y][x] == EMPTY:
				# Calls pick_room_type function to pick a room type
				var room_type = pick_room_type(new_x, new_y)
				if room_type == NORMAL:
					# Adds all normal rooms to a list
					normal_room_list.append(Vector2(x, y))
				elif room_type == LONG_H:
					long_h_count += 1
				elif room_type == BIG:
					big_room_count += 1
				
				if room_type != EMPTY:
					num_rooms += 1
				
				# Adds all rooms to the dictionary
				room_connections[Vector2(x, y)] = []
				# Creates a random connection to neighboring (adjacent) rooms
				add_random_connection(Vector2(x, y))
		else:
			new_x = start_x
			new_y = start_y

func pick_room_type(x, y) -> int:
	if dungeon[y][x] != EMPTY:
		return EMPTY
	
	var possible_types = [NORMAL]
	var isbigLeft = false
	var isbigRight = false
	var islongLeft = false
	var islongRight = false

	# Check space for LONG_H (1x2 Horizontal Room)
	if long_h_count < MAX_LONG_ROOMS and x < WIDTH - 1:
		if dungeon[y][x + 1] == EMPTY:
			possible_types.append(LONG_H)
			islongRight = true
		if x > 1:
			if dungeon[y][x - 1] == EMPTY:
				possible_types.append(LONG_H)
				islongLeft = true
	
	# Check space for BIG (2x2 Room)
	if big_room_count < MAX_BIG_ROOMS and x < WIDTH - 1 and y < HEIGHT - 1:
		if (dungeon[y][x + 1] == EMPTY and dungeon[y + 1][x] == EMPTY and dungeon[y + 1][x + 1] == EMPTY):
			possible_types.append(BIG)
			isbigRight = true
		if x > 1 and y > 1:
			if (dungeon[y][x - 1] == EMPTY and dungeon[y - 1][x] == EMPTY and dungeon[y - 1][x - 1] == EMPTY):
				possible_types.append(BIG)
				isbigLeft = true
	
	# Weighted Random Selection of if to add a Big Room or Long Room
	if randf() < BIG_ROOM_CHANCE and BIG in possible_types: # 1% Chance to add Big Room
		if isbigLeft and isbigRight:
			if randf() < 0.5:
				placeBIGLeft(y, x)
			else:
				placeBIGRight(y, x)
		elif isbigRight:
			placeBIGRight(y, x)
		else:
			placeBIGLeft(y, x)
		return BIG
	elif randf() < LONG_ROOM_CHANCE and LONG_H in possible_types: # 10% Chance to add Long Room
		if islongLeft and islongRight:
			if randf() < 0.5:
				placeLONG_HLeft(y, x)
			else:
				placeLONG_HRight(y, x)
		elif islongRight:
			placeLONG_HRight(y, x)
		elif islongLeft:
			placeLONG_HLeft(y, x)
		return LONG_H

	
	dungeon[y][x] = NORMAL
	return NORMAL

# Creates a Big Room on the right
func placeBIGRight(y, x):
	dungeon[y][x] = BIG
	dungeon[y][x + 1] = BIG
	dungeon[y + 1][x] = BIG
	dungeon[y + 1][x + 1] = BIG
	big_room_list.append([[x, y],[x + 1, y],[x, y + 1],[x + 1, y + 1]])
	big_room_list_spawn.append(Vector2(x, y+1))
	
# Creates a Big Room on the left
func placeBIGLeft(y, x):
	dungeon[y][x] = BIG
	dungeon[y][x - 1] = BIG
	dungeon[y - 1][x] = BIG
	dungeon[y - 1][x - 1] = BIG
	big_room_list.append([[x, y], [x - 1, y],[x, y - 1],[x - 1, y - 1]])
	big_room_list_spawn.append(Vector2(x-1, y))

# Creates a Boss Room on the right
func placeBossRight(y, x):
	dungeon[y][x] = BOSS
	dungeon[y][x + 1] = BOSS
	dungeon[y + 1][x] = BOSS
	dungeon[y + 1][x + 1] = BOSS
	boss_room_list.append([[x, y],[x + 1, y],[x, y + 1],[x + 1, y + 1]])
	boss_room_list_spawn.append(Vector2(x, y+1))
	
# Creates a Boss Room on the left
func placeBossLeft(y, x):
	dungeon[y][x] = BOSS
	dungeon[y][x - 1] = BOSS
	dungeon[y - 1][x] = BOSS
	dungeon[y - 1][x - 1] = BOSS
	boss_room_list.append([[x, y], [x - 1, y],[x, y - 1],[x - 1, y - 1]])
	boss_room_list_spawn.append(Vector2(x-1, y))

# Creates a Horizontal Long Room on the right
func placeLONG_HRight(y, x):
	dungeon[y][x] = LONG_H
	dungeon[y][x + 1] = LONG_H
	long_room_list.append([[x, y], [x + 1, y]])
	long_room_list_spawn.append(Vector2(x, y))

# Creates a Horizontal Long Room on the left
func placeLONG_HLeft(y, x):
	dungeon[y][x] = LONG_H
	dungeon[y][x - 1] = LONG_H
	long_room_list.append([[x, y], [x - 1, y]])
	long_room_list_spawn.append(Vector2(x-1, y))

# Adds random room connections
func add_random_connection(room: Vector2):
	# Resets list of all possible neighbors
	possible_neighbors = []

	# Check for all valid directions (up, down, left, right) to find neighbors
	for dir in directions:
		var neighbor = room + dir
		
		# Ensure the neighbor is within bounds
		if neighbor.x >= 0 and neighbor.x < WIDTH and neighbor.y >= 0 and neighbor.y < HEIGHT:

			# Check for LONG_H room (1x2) - Can connect vertically or horizontally
			if dungeon[room.y][room.x] == LONG_H:
				# Prevent connection to the other part of the LONG_H room horizontally
				if (dir == Vector2.RIGHT and [[room.x, room.y],[room.x + 1, room.y]] in long_room_list):
					continue  # Skips to the next direction in the for loop
				if (dir == Vector2.LEFT and [[room.x, room.y],[room.x - 1, room.y]] in long_room_list):
					continue  # Skips to the next direction in the for loop
					
				# Valid directions for Horizontal Long Rooms (checking up, down, right, left)
				valid_neighbors(dir, room, neighbor)
				
			# Check for BIG room (2x2) - Can connect on all four sides but not within itself
			elif dungeon[room.y][room.x] == BIG:
				# Prevent horizontal connections within the BIG room (left-right)
				if (dir == Vector2.LEFT and
				[[room.x, room.y],[room.x - 1, room.y],[room.x, room.y - 1],[room.x - 1, room.y - 1]] in big_room_list):
					continue  
				elif (dir == Vector2.RIGHT and 
				[[room.x, room.y],[room.x + 1, room.y],[room.x, room.y + 1],[room.x + 1, room.y + 1]] in big_room_list):
					continue 
				# Prevent vertical connections within the BIG room (top-bottom)
				elif (dir == Vector2.UP and 
				[[room.x, room.y],[room.x - 1, room.y],[room.x, room.y - 1],[room.x - 1, room.y - 1]] in big_room_list):
					continue
				elif (dir == Vector2.DOWN and 
				[[room.x, room.y],[room.x + 1, room.y],[room.x, room.y + 1],[room.x + 1, room.y + 1]] in big_room_list):
					continue 

				# Valid directions for Big Rooms (checking up, down, right, left)
				valid_neighbors(dir, room, neighbor)

			# For normal rooms, check for valid connections to neighboring rooms
			elif dungeon[room.y][room.x] == NORMAL:
				# If neighbor has a room
				if dungeon[neighbor.y][neighbor.x] != EMPTY:  
					possible_neighbors.append(neighbor)

	# If there are valid neighbors, randomly choose one to connect 
	if possible_neighbors.size() > 0:
		var connected_neighbors = []  # List to track neighbors that were connected

		# Go through each valid neighbor and randomly decide if it should be connected
		for neighbor in possible_neighbors:
			# Random chance to connect (could be adjusted to a percentage if needed)
			if randf() < 0.65:  # 65% chance to connect to this neighbor
				if neighbor not in room_connections.get(room, []):
					room_connections[room] = room_connections.get(room, [])
					room_connections[neighbor] = room_connections.get(neighbor, [])
					room_connections[room].append(neighbor)
					room_connections[neighbor].append(room)
					connected_neighbors.append(neighbor)
		
		# If no neighbors were connected, force a connection with one
		if connected_neighbors.size() == 0:
			var forced_neighbor = possible_neighbors[randi() % possible_neighbors.size()]
			if forced_neighbor not in room_connections.get(room, []):
				room_connections[room] = room_connections.get(room, [])
				room_connections[forced_neighbor] = room_connections.get(forced_neighbor, [])
				room_connections[room].append(forced_neighbor)
				room_connections[forced_neighbor].append(room)


func valid_neighbors(dir, room, neighbor):
	if dir == Vector2.LEFT and room.x > 0 and dungeon[room.y][room.x - 1] != EMPTY:
		possible_neighbors.append(neighbor)
	elif dir == Vector2.RIGHT and room.x + 1 < WIDTH and dungeon[room.y][room.x + 1] != EMPTY:
		possible_neighbors.append(neighbor)
	elif dir == Vector2.UP and room.y > 0 and dungeon[room.y - 1][room.x] != EMPTY:
		possible_neighbors.append(neighbor)
	elif dir == Vector2.DOWN and room.y + 1 < HEIGHT and dungeon[room.y + 1][room.x] != EMPTY:
		possible_neighbors.append(neighbor)

func place_boss_room():
	var start_room = Vector2(start_x, start_y) 
	var visited = {}
	var queue = []
	var last_normal_room = null  # Stores the last NORMAL room found during BFS
	var isBossLeft = false
	var isBossRight = false

	queue.append(start_room)

	while queue.size() > 0:
		var current_room = queue.pop_front()

		if current_room in visited:
			continue

		visited[current_room] = true

		# Update last NORMAL room encountered
		if dungeon[current_room.y][current_room.x] == NORMAL:
			last_normal_room = current_room

		for neighbor in room_connections.get(current_room, []):
			if neighbor not in visited:
				queue.append(neighbor)

	if last_normal_room != null:
		# Check space for BIG (2x2 Room)
		if last_normal_room.x < WIDTH - 1 and last_normal_room.y < HEIGHT - 1:
			if (dungeon[last_normal_room.y][last_normal_room.x + 1] == EMPTY and dungeon[last_normal_room.y + 1][last_normal_room.x] == EMPTY and dungeon[last_normal_room.y + 1][last_normal_room.x + 1] == EMPTY):
				isBossRight = true
			if last_normal_room.x > 1 and last_normal_room.y > 1:
				if (dungeon[last_normal_room.y][last_normal_room.x - 1] == EMPTY and dungeon[last_normal_room.y - 1][last_normal_room.x] == EMPTY and dungeon[last_normal_room.y - 1][last_normal_room.x - 1] == EMPTY):
					isBossLeft = true	
		
		if isBossLeft or isBossRight: 
			normal_room_list.erase(last_normal_room)
			if isBossLeft and isBossRight:
				if randf() < 0.5:
					placeBossLeft(last_normal_room.y, last_normal_room.x)
				else:
					placeBossRight(last_normal_room.y, last_normal_room.x)
			elif isBossRight:
				placeBossRight(last_normal_room.y, last_normal_room.x)
			elif isBossLeft:
				placeBossLeft(last_normal_room.y, last_normal_room.x)
	else:
		print("Error: No NORMAL room found to place BOSS room!\n")
		
func place_final_room():
	var start_room = Vector2(start_x, start_y) 
	var visited = {}
	var queue = []
	var last_normal_room = null  # Stores the last NORMAL room found during BFS

	queue.append(start_room)

	while queue.size() > 0:
		var current_room = queue.pop_front()

		if current_room in visited:
			continue

		visited[current_room] = true

		# Update last NORMAL room encountered
		if dungeon[current_room.y][current_room.x] == NORMAL:
			last_normal_room = current_room

		for neighbor in room_connections.get(current_room, []):
			if neighbor not in visited:
				queue.append(neighbor)

	if last_normal_room != null:
		dungeon[last_normal_room.y][last_normal_room.x] = FINAL
		normal_room_list.erase(last_normal_room)
	else:
		print("Error: No NORMAL room found to place FINAL room!\n")

func place_special_rooms():
	for pos in normal_room_list:
		if randf() < 0.1 and treasure_room_count < 2 and dungeon[pos.y][pos.x] == NORMAL:
			dungeon[pos.y][pos.x] = TREASURE
			treasure_room_count += 1
		elif randf() < 0.35 and !is_shop_spawn and dungeon[pos.y][pos.x] == NORMAL:
			dungeon[pos.y][pos.x] = SHOP
			is_shop_spawn = true
	while treasure_room_count == 0:
		var rand = randi() % normal_room_list.size()
		if dungeon[normal_room_list[rand].y][normal_room_list[rand].x] == NORMAL:
			dungeon[normal_room_list[rand].y][normal_room_list[rand].x] = TREASURE
			treasure_room_count += 1

func is_valid_dungeon() -> bool:
	# Ensure at least one FINAL and TREASURE room exist
	var has_treasure = false
	var has_boss = false
	for y in range(HEIGHT):
		for x in range(WIDTH):
			if dungeon[y][x] == TREASURE:
				has_treasure = true
			if dungeon[y][x] == BOSS:
				has_boss = true
	
	# Define your criteria
	return has_treasure and has_boss and num_rooms == MAX_ROOMS and dungeon[start_y][start_x] == START

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
