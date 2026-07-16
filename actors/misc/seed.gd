class_name Seed
extends Node2D

@onready var seed: Sprite2D = $Seed
var is_highlighted : bool = false :
    set(new_is_highlighted):
        is_highlighted = new_is_highlighted
        seed.modulate.a = 0.5 if is_highlighted else 1.0


func _on_grabbable_area_2d_focus_changed(is_focused: bool) -> void:
    is_highlighted = is_focused
