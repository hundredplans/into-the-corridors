class_name Battery extends Node2D

@export var stream: AudioStream
func onPickedUp() -> void:
	Audio.onPlay(stream, -12)
	queue_free()
