extends Node2D

@export var target : Player
@onready var eye_center: Node2D = $EyeCenter
@onready var eye: Sprite2D = $EyeCenter/Eye
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


func _process(delta: float) -> void:
    if target:
        target.global_position - eye_center.global_position
        eye.global_position = eye_center.global_position.move_toward(target.global_position, 3)
    

func _on_sensor_body_entered(body: Node2D) -> void:
    if body is Player:
        target = body
        


func _on_sensor_body_exited(body: Node2D) -> void:
    var tween := get_tree().create_tween()
    tween.tween_property(eye, "position", Vector2.ZERO, 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
    target = null


func _on_close_sensor_body_entered(body: Node2D) -> void:
    if body is Player:
        animation_player.play("hide")

func _on_close_sensor_body_exited(body: Node2D) -> void:
    if body is Player:
        animation_player.play_backwards("hide")
