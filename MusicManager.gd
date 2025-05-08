extends Node

var music_tracks = {
	"main_menu": preload("res://Music/black_tower_title.mp3"),
	"map": preload("res://Music/map.mp3"),
	"death": preload("res://Music/game_over_loop.mp3"),
	"wander": preload("res://Music/wander_wip.ogg")
}

@onready var music_player: AudioStreamPlayer = $MusicPlayer

func play_music(track_name: String):
	if music_tracks.has(track_name):
		if music_player.stream != music_tracks[track_name]:
			music_player.stop()
			music_player.stream = music_tracks[track_name]
			music_player.play()

func stop_music():
	music_player.stop()
