extends Node


var hitstop_timer: Timer = null

func hitstop(duration: float) -> void:
	

	# Freeze everything
	Engine.time_scale = 0.0

	var start_ms = Time.get_ticks_msec()

	# Wait until real milliseconds have passed
	while Time.get_ticks_msec() - start_ms < int(duration * 1000):
		await get_tree().process_frame  # yields so each frame can still render


	Engine.time_scale = 1.0
