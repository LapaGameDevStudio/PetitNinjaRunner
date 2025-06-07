extends StaticBody2D

# Vitesse de déplacement vers la gauche (en pixels/seconde)
const SPEED = 100

func _process(delta):
	position.x -= SPEED * delta
	
	# Si l'obstacle est complètement hors écran à gauche, on le supprime
	if position.x < -100:
		queue_free()
