extends Node2D

@onready var parallax := $ParallaxBackground
@onready var camera := $Camera2D
@onready var add_layer_button := $UI/AddLayerButton
@onready var texture_picker := $UI/TexturePicker
@onready var layer_list := $UI/LayerList
@onready var save_button := $UI/SaveButton
@onready var load_button := $UI/LoadButton

var layer_names := []
var layer_count := 0

var selected_layer: ParallaxLayer = null
const LAYER_MOVE_SPEED := 10

func _ready():
	add_layer_button.pressed.connect(_on_add_layer_pressed)
	$UI/RemoveLayerButton.pressed.connect(_on_RemoveLayerButton_pressed)
	$UI/MoveLayerUpButton.pressed.connect(_on_move_layer_up)
	$UI/MoveLayerDownButton.pressed.connect(_on_move_layer_down)
	$UI/TexturePicker.filters = PackedStringArray(["*.png", "*.jpg", "*.webp"])
	texture_picker.connect("file_selected", Callable(self, "_on_TexturePicker_file_selected"))
	layer_list.connect("item_selected", Callable(self, "_on_layer_selected"))
	layer_list.connect("item_activated", Callable(self, "_on_layer_rename_requested"))
	$UI/RenameLayerButton.pressed.connect(_on_RenameLayerButton_pressed)
	$UI/PopupRenameLayer/VBoxContainer/ConfirmButton.pressed.connect(_on_PopupRenameLayer_confirm)
	$UI/MotionScaleX.value_changed.connect(_on_motion_scale_x_changed)
	$UI/MotionScaleY.value_changed.connect(_on_motion_scale_y_changed)
	$UI/DuplicateLayerButton.pressed.connect(_on_DuplicateLayerButton_pressed)
	$UI/SaveButton.pressed.connect(_on_save_button_pressed)
	$UI/LoadButton.pressed.connect(_on_load_button_pressed)
	$UI/VBoxContainer/MirrorXSpinBox.value_changed.connect(_on_mirror_x_changed)
	$UI/VBoxContainer/MirrorYSpinBox.value_changed.connect(_on_mirror_y_changed)

	update_layer_list()

func _process(delta):
	var speed = 500
	if Input.is_key_pressed(KEY_CTRL) and selected_layer:
		var sprite := selected_layer.get_child(0)
		if sprite:
			if Input.is_action_pressed("ui_right"):
				sprite.position.x += LAYER_MOVE_SPEED
			if Input.is_action_pressed("ui_left"):
				sprite.position.x -= LAYER_MOVE_SPEED
			if Input.is_action_pressed("ui_up"):
				sprite.position.y -= LAYER_MOVE_SPEED
			if Input.is_action_pressed("ui_down"):
				sprite.position.y += LAYER_MOVE_SPEED
	else:
		if Input.is_action_pressed("ui_right"):
			camera.position.x += speed * delta
		if Input.is_action_pressed("ui_left"):
			camera.position.x -= speed * delta
		if Input.is_action_pressed("ui_up"):
			camera.position.y -= speed * delta
		if Input.is_action_pressed("ui_down"):
			camera.position.y += speed * delta

	if Input.is_action_just_pressed("zoom_in"):
		camera.zoom *= 0.9
	if Input.is_action_just_pressed("zoom_out"):
		camera.zoom *= 1.1
	if Input.is_action_just_pressed("reset_camera"):
		camera.position = Vector2.ZERO
		camera.zoom = Vector2.ONE


func _on_add_layer_pressed():
	texture_picker.popup_centered()

func _on_TexturePicker_file_selected(path):
	var texture = load(path)
	if texture:
		# Create parallax layer
		var layer = ParallaxLayer.new()
		var sprite = Sprite2D.new()
		sprite.texture = texture
		sprite.centered = true
		sprite.position = Vector2.ZERO
		layer.add_child(sprite)
		layer.motion_scale = Vector2(0.0 + 0.05 * layer_count, 1)
		#layer.set("motion_mirroring", Vector2(2048, 0))
		#layer.motion_mirroring = Vector2(1080, 0)  # Répète tous les 1080px horizontalement
		layer.motion_mirroring = Vector2(texture.get_size().x, 0)
		layer.set_meta("custom_name", "Layer %d" % layer_count)  # <-- stocke le nom ici

		# Add parallax layer
		parallax.add_child(layer)
		layer_count += 1
		selected_layer = layer
		update_layer_list()
		layer_list.select(layer_count - 1)
		_update_motion_scale_ui()

func _on_RemoveLayerButton_pressed():
	if selected_layer and parallax.has_node(selected_layer.get_path()):
		selected_layer.queue_free()
		selected_layer = null
	else:
		var layers = parallax.get_children()
		if layers.size() > 0:
			layers[-1].queue_free()

	update_layer_list()
	_update_motion_scale_ui()


func _on_move_layer_up():
	if not selected_layer:
		return
	var index = parallax.get_children().find(selected_layer)
	if index > 0:
		parallax.move_child(selected_layer, index - 1)
	update_layer_list()
	_update_motion_scale_ui()


func _on_move_layer_down():
	if not selected_layer:
		return
	var children = parallax.get_children()
	var index = children.find(selected_layer)
	if index < children.size() - 1:
		parallax.move_child(selected_layer, index + 1)
	update_layer_list()
	_update_motion_scale_ui()


func _on_layer_selected(index):
	var layers = parallax.get_children()
	if index >= 0 and index < layers.size():
		selected_layer = layers[index]
	else:
		selected_layer = null
	_update_motion_scale_ui()


func _on_motion_scale_x_changed(value):
	if selected_layer:
		selected_layer.motion_scale.x = value
		print("motion_scale.x set to ", value)


func _on_motion_scale_y_changed(value):
	if selected_layer:
		selected_layer.motion_scale.y = value
		print("motion_scale.y set to ", value)

func _on_mirror_x_changed(value):
	if selected_layer:
		selected_layer.motion_mirroring.x = value

func _on_mirror_y_changed(value):
	if selected_layer:
		selected_layer.motion_mirroring.y = value

func _update_motion_scale_ui():
	if selected_layer:
		$UI/MotionScaleX.value = selected_layer.motion_scale.x
		$UI/MotionScaleY.value = selected_layer.motion_scale.y
		$UI/VBoxContainer/MirrorXSpinBox.value = selected_layer.motion_mirroring.x
		$UI/VBoxContainer/MirrorYSpinBox.value = selected_layer.motion_mirroring.y

# ============ RENOMMAGE ==============

func _on_RenameLayerButton_pressed():
	if selected_layer:
		var index = parallax.get_children().find(selected_layer)
		var popup = $UI/PopupRenameLayer
		var line_edit = popup.get_node("VBoxContainer/LineEdit")
		line_edit.text = selected_layer.get_meta("custom_name", "Layer %d" % index)
		line_edit.grab_focus()
		popup.set_meta("index", index)
		popup.popup_centered()


func _on_layer_rename_requested(index):
	var layers = parallax.get_children()
	if index < 0 or index >= layers.size():
		return
	selected_layer = layers[index]
	_on_RenameLayerButton_pressed()


func _on_PopupRenameLayer_confirm():
	var popup = $UI/PopupRenameLayer
	var index = popup.get_meta("index")
	var new_name = popup.get_node("VBoxContainer/LineEdit").text.strip_edges()
	var layers = parallax.get_children()
	if typeof(index) == TYPE_INT and index >= 0 and index < layers.size() and new_name != "":
		layers[index].set_meta("custom_name", new_name)
	update_layer_list()
	popup.hide()

func _on_DuplicateLayerButton_pressed():
	if not selected_layer:
		print("Aucun layer sélectionné à dupliquer.")
		return

	var original_index = parallax.get_children().find(selected_layer)
	if original_index == -1:
		print("Layer sélectionné introuvable.")
		return

	# Création d’un nouveau layer
	var duplicated_layer := ParallaxLayer.new()
	duplicated_layer.motion_scale = selected_layer.motion_scale

	# Copie du sprite
	var original_sprite = selected_layer.get_child(0)
	if original_sprite and original_sprite is Sprite2D:
		var new_sprite := Sprite2D.new()
		new_sprite.texture = original_sprite.texture
		new_sprite.centered = original_sprite.centered
		new_sprite.region_enabled = original_sprite.region_enabled
		new_sprite.region_rect = original_sprite.region_rect
		new_sprite.position = original_sprite.position
		duplicated_layer.add_child(new_sprite)
	else:
		print("Aucun sprite à copier.")

	# Insertion juste après l’original
	parallax.add_child(duplicated_layer)
	parallax.move_child(duplicated_layer, original_index + 1)

	# Gestion du nom
	var original_name = selected_layer.get_meta("custom_name", "Layer %d" % original_index)
	var new_name = "%s (copie)" % original_name

	selected_layer = duplicated_layer
	layer_count += 1

	update_layer_list()
	layer_list.select(original_index + 1)
	_update_motion_scale_ui()

# ============ LISTE SYNCHRO ==============

func update_layer_list():
	layer_list.clear()
	var layers = parallax.get_children()
	for i in range(layers.size()):
		var name = layers[i].get_meta("custom_name", "Layer %d" % i)
		layer_list.add_item("%d - %s" % [i, name])

# ============ Save in json =============

func save_layout_to_file(path: String):
	var layers_data = []
	for layer in parallax.get_children():
		if not (layer is ParallaxLayer):
			continue
		var sprite = layer.get_child(0)
		if not (sprite is Sprite2D):
			continue

		var layer_info = {
			"name": layer.get_meta("custom_name", ""),
			"motion_scale": [layer.motion_scale.x, layer.motion_scale.y],
			"motion_mirroring": [layer.motion_mirroring.x, layer.motion_mirroring.y],
			"position": [sprite.position.x, sprite.position.y],
			"texture_path": sprite.texture.resource_path
		}
		layers_data.append(layer_info)

	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(layers_data, "\t"))
	file.close()
	print("Layout saved to:", path)


# ============ Load from json =============

func load_layout_from_file(path: String):
	if not FileAccess.file_exists(path):
		print("Le fichier n'existe pas :", path)
		return

	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()

	var data = JSON.parse_string(content)
	if typeof(data) != TYPE_ARRAY:
		print("Le fichier JSON n'est pas un tableau.")
		return

	# Supprime les layers existants
	for child in parallax.get_children():
		child.queue_free()

	for layer_data in data:
		if typeof(layer_data) != TYPE_DICTIONARY:
			continue

		var texture_path = layer_data.get("texture_path", "")
		var texture = load(texture_path)
		if not texture:
			print("Impossible de charger la texture :", texture_path)
			continue

		var layer = ParallaxLayer.new()
		var sprite = Sprite2D.new()
		sprite.texture = texture
		sprite.centered = true

		# Position
		var pos = layer_data.get("position", [0, 0])
		if typeof(pos) == TYPE_ARRAY and pos.size() == 2:
			sprite.position = Vector2(pos[0], pos[1])
		else:
			sprite.position = Vector2.ZERO

		# Motion Scale
		var motion = layer_data.get("motion_scale", [0, 1])
		layer.motion_scale = Vector2(motion[0], motion[1])

		# Motion Mirroring
		var mirror = layer_data.get("motion_mirroring", [0, 0])
		layer.motion_mirroring = Vector2(mirror[0], mirror[1])

		layer.set_meta("custom_name", layer_data.get("name", "Layer"))
		layer.add_child(sprite)
		parallax.add_child(layer)

	update_layer_list()
	print("Layout chargé depuis :", path)


func _on_load_button_pressed():
	load_layout_from_file("res://tools/parallax_layout.json")
func _on_save_button_pressed():
	save_layout_to_file("res://tools/parallax_layout.json")
