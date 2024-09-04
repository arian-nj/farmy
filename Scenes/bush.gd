extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea

func _ready() -> void:
	interaction_area.intract = Callable(self,"_on_intract")

func _on_intract():
	$AnimatedSprite2D.play("dont")
	print("cut")
