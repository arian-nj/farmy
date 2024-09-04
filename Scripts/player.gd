extends CharacterBody2D

@export var inv:Inv

@export var SPEED = 200.0
var scrolling:bool = false

enum 	FARMING_MODES {
	SEED,DIRT
}
var farming_mode_state = FARMING_MODES.DIRT

var touch_points :Dictionary = {}

@onready var tile_map: TileMap = $"../TileMap"
var ground_layer = 1 
var enviorment_layer = 2

var can_place_seed_custom_data = "can_place_seed"
var can_place_dirt_custom_data = "can_place_dirt"

var dirt_tiles = []
func _physics_process(delta: float) -> void:
	if touch_points.size() ==1:
		move_and_slide()
	else:
		velocity = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if scrolling:
		velocity = Vector2.ZERO
		return
	
	if event is InputEventScreenTouch:
		handle_touch(event)
	elif event is InputEventScreenDrag:
		handle_drag(event)

func handle_touch(event:InputEventScreenTouch):
	# Intraction
	if event.pressed:
		touch_points[event.index] = event.position
		var intracted = await InteractionManager.intract()
		if intracted:
			print("intract")
			return
	else:
		touch_points.erase(event.index)
	
	# plant seed
	if event.pressed:
		var tile_map_position := tile_map.local_to_map(tile_map.to_local(global_position))
		var source_id := 0
		
		if farming_mode_state == FARMING_MODES.SEED:
			var atlas_cords := Vector2i(11,1)
			if retrive_cutom_data(tile_map_position,can_place_seed_custom_data,ground_layer) == true:
				tile_map.set_cell(enviorment_layer,tile_map_position,source_id,atlas_cords)
		elif farming_mode_state == FARMING_MODES.DIRT:
			if retrive_cutom_data(tile_map_position,can_place_dirt_custom_data,ground_layer) == true:
				dirt_tiles.append(tile_map_position)
				tile_map.set_cells_terrain_connect(ground_layer,dirt_tiles,2,0)
	else:
		touch_points.erase(event.index)

func retrive_cutom_data(tile_map_position:Vector2i,custom_data_layer,layer:int):
	var clicked_tile_data:TileData = tile_map.get_cell_tile_data(layer,tile_map_position)
	if clicked_tile_data:
		return clicked_tile_data.get_custom_data(custom_data_layer)
	return false

func handle_drag(event:InputEventScreenDrag):
	touch_points[event.index] = event.position
	if touch_points.size() == 1 and event.relative.length() >1.5:
		var direction = event.relative.clamp(Vector2(-1,-1),Vector2(1,1))
		velocity = direction * SPEED


func _on_scroll_container_scroll_started() -> void:
	scrolling = true


func _on_scroll_container_scroll_ended() -> void:
	scrolling = false
