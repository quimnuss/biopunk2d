class_name GenericGrabbable
extends Node2D

@onready var generic_grabbable_sprite: Sprite2D = $GenericGrabbableSprite
@onready var grabbable_area_2d: Grabbable = $GrabbableArea2D

@export var tooltype : Grabbable.ToolType 

var is_highlighted : bool = false :
    set(new_is_highlighted):
        is_highlighted = new_is_highlighted
        generic_grabbable_sprite.modulate.a = 0.5 if is_highlighted else 1.0

func _ready():
    generic_grabbable_sprite.frame = tooltype
    grabbable_area_2d.tooltype = tooltype

func _on_grabbable_area_2d_focus_changed(is_focused: bool) -> void:
    is_highlighted = is_focused
