class_name Seed
extends Node2D

@onready var seed: Sprite2D = $Seed
@onready var explode_timer: Timer = $ExplodeTimer

var is_thrown : bool = false
@export var GRENADE_TIME : float = 3.0

var is_highlighted : bool = false :
    set(new_is_highlighted):
        is_highlighted = new_is_highlighted
        seed.modulate.a = 0.5 if is_highlighted else 1.0

func _ready():
    explode_timer.timeout.connect(_on_bomb_timer_timeout)
    
func set_thrown(new_is_thrown):
    is_thrown = new_is_thrown
    explode_timer.start(GRENADE_TIME)

func _on_grabbable_area_2d_focus_changed(is_focused: bool) -> void:
    is_highlighted = is_focused

func _on_bomb_timer_timeout():
    var smoke_bomb : Smoke = preload("res://actors/smoke.tscn").instantiate()
    smoke_bomb.smoke_ended.connect(queue_free)
    add_child(smoke_bomb)
