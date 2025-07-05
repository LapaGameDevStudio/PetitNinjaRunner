extends Node2D

@onready var parallax := $ParallaxBackground
@onready var camera := $Camera2D
@onready var add_layer_button := $UI/AddLayerButton
@onready var texture_picker := $UI/TexturePicker
@onready var layer_list := $UI/LayerList
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


func _on_add_layer_pressed():
	texture_picker.popup_centered()


func _on_TexturePicker_file_selected(path):
	var texture = load(path)
	if texture:
		var layer = ParallaxLayer.new()
		var sprite = Sprite2D.new()
		sprite.texture = texture
		sprite.centered = true
		sprite.position = Vector2.ZERO
		sprite.region_enabled = true
		var screen_size = get_viewport().size
		sprite.region_rect = Rect2(Vector2.ZERO, screen_size * 2)
		layer.add_child(sprite)
		layer.motion_scale = Vector2(0.4 + parallax.get_child_count() * 0.2, 1)
		layer.set_meta("custom_name", "Layer %d" % parallax.get_child_count())

		parallax.add_child(layer)
		selected_layer = layer
		update_layer_list()
		layer_list.select(parallax.get_children().find(layer))
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


func _update_motion_scale_ui():
	if selected_layer:
		$UI/MotionScaleX.value = selected_layer.motion_scale.x
		$UI/MotionScaleY.value = selected_layer.motion_scale.y


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
