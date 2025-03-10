extends Node2D

#index vectors for current room position relative to 0, 0; assigned when created in DungeonRooms
@export var currentRoom = []
@export var targetRoom = []

#vectors for current and target rooms in actual positions; referenced when
#door hitbox is entered
@export var currentRoomPos = []
@export var targetRoomPos = []

#top, bottom, left, right; this matters
@export var type = "null"

#when collided with, move player targetroom door position that is opposite to this door's type
#but, adjust the position of the player so that they dont immediately re-enter the door
#like: if (type == "right") : player.position... + 0.5
#enters right door and exits right door, added x/y separation
#very simple

#...

#hopefully

#guys im not used to godot ts is so hardddd 

#func _physics_process(delta: float) -> void:
	##


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
