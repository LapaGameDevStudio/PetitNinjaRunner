extends Node2D

@onready var parallax: Node = $ParallaxBackground
@onready var camera := $Camera2D
@onready var add_layer_button := $UI/AddLayerButton
@onready var texture_picker := $UI/TexturePicker
@onready var layer_list := $UI/LayerList
var layer_names := []  # Liste des noms des layers, correspond à l’ordre des enfants dans parallax
var rename_index := -1

var layer_count := 0
var selected_layer: ParallaxLayer = null
const LAYER_MOVE_SPEED := 10

func _ready():
	add_layer_button.pressed.connect(_on_add_layer_pressed)
	$UI/RemoveLayerButton.pressed.connect(_on_RemoveLayerButton_pressed)
	$UI/MoveLayerUpButton.pressed.connect(_on_move_layer_up)
	$UI/MoveLayerDownButton.pressed.connect(_on_move_layer_down)
	$UI/TexturePicker.filters = PackedStringArray(["*.png", "*.jpg", "*.webp"])
	$UI/TexturePicker.connect("file_selected", Callable(self, "_on_TexturePicker_file_selected"))
	layer_list.connect("item_selected", Callable(self, "_on_layer_selected"))
	layer_list.connect("item_activated", Callable(self, "_on_layer_rename_requested"))  # double clic
	$UI/RenameLayerButton.pressed.connect(_on_RenameLayerButton_pressed)
	$UI/PopupRenameLayer/VBoxContainer/ConfirmButton.pressed.connect(_on_PopupRenameLayer_confirm)

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
		layer.motion_scale = Vector2(0.4 + 0.2 * layer_count, 1)
		parallax.add_child(layer)
		layer_count += 1
		selected_layer = layer
		update_layer_list()
		layer_list.select(layer_count - 1)


func _on_RemoveLayerButton_pressed():
	if selected_layer and parallax.has_node(selected_layer.get_path()):
		selected_layer.queue_free()
		selected_layer = null
	else:
		var layers = parallax.get_children()
		if layers.size() > 0:
			layers[-1].queue_free()

	layer_count = max(0, layer_count - 1)
	update_layer_list()


func _on_move_layer_up():
	if not selected_layer:
		return
	var index = parallax.get_children().find(selected_layer)
	if index > 0:
		parallax.move_child(selected_layer, index - 1)
	update_layer_list()


func _on_move_layer_down():
	if not selected_layer:
		return
	var children = parallax.get_children()
	var index = children.find(selected_layer)
	if index < children.size() - 1:
		parallax.move_child(selected_layer, index + 1)
	update_layer_list()


func _on_layer_selected(index):
	var layers = parallax.get_children()
	if index >= 0 and index < layers.size():
		selected_layer = layers[index]
	else:
		selected_layer = null


# ============ RENOMMAGE ==============

func _on_RenameLayerButton_pressed():
	if selected_layer:
		var index = parallax.get_children().find(selected_layer)
		if index >= 0 and index < layer_names.size():
			var popup = $UI/PopupRenameLayer
			var line_edit = popup.get_node("VBoxContainer/LineEdit")
			line_edit.text = layer_names[index]
			line_edit.grab_focus()  # ← important pour écrire directement
			popup.set_meta("index", index)  # stocke l'index proprement
			popup.popup_centered()

func _on_layer_rename_requested(index):
	if index < 0 or index >= layer_names.size():
		return
	rename_index = index  # <-- on stocke l'index ici
	$UI/PopupRenameLayer.popup_centered()
	$UI/PopupRenameLayer/VBoxContainer/LineEdit.text = layer_names[index]

func _on_PopupRenameLayer_confirm():
	var popup = $UI/PopupRenameLayer
	var index = popup.get_meta("index")
	var new_name = popup.get_node("VBoxContainer/LineEdit").text.strip_edges()
	if typeof(index) == TYPE_INT and index >= 0 and new_name != "":
		layer_names[index] = new_name
		update_layer_list()
	popup.hide()



# ============ MISE À JOUR LISTE ==============

func update_layer_list():
	layer_list.clear()
	var layers = parallax.get_children()

	while layer_names.size() < layers.size():
		layer_names.append("Layer %d" % layer_names.size())
	while layer_names.size() > layers.size():
		layer_names.pop_back()

	for i in range(layers.size()):
		layer_list.add_item(layer_names[i])
