extends Camera2D

func shake_camera(intensity := 20.0, duration := 0.4):
	var original_offset := offset
	var tween := get_tree().create_tween()
	
	for i in range(5):
		var random_offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		tween.tween_property(self, "offset", random_offset, duration / 10)
		tween.tween_property(self, "offset", original_offset, duration / 10)
