extends Node

func onPlay(stream: AudioStream, db: float = 0.0) -> void:
	var audio_stream_player := AudioStreamPlayer.new()
	add_child(audio_stream_player)
	audio_stream_player.stream = stream
	audio_stream_player.volume_db = db
	audio_stream_player.play()
	audio_stream_player.finished.connect(audio_stream_player.queue_free)
