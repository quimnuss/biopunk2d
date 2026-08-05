extends Node2D
class_name EyePlant

@export var target : Player
@onready var eye_center: Node2D = $EyeCenter
@onready var eye: Sprite2D = $EyeCenter/Eye
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var dizzy_component: Node2D = $DizzyComponent
@onready var grabbable_area_2d: Grabbable = $GrabbableArea2D

var dizzy_eye_angle : float = 0.0
@export var DIZZY_DURATION : float = 5.0
@onready var dizzy_timer: Timer = $DizzyTimer

@export_enum("IDLE", "DIZZY", 'HIDDEN') var state = "IDLE" :
    set(new_state):
        if state != new_state:
            var previous_state = state
            state = new_state
            # exit state
            match previous_state:
                'DIZZY':
                    dizzy_component.visible = false
                    grabbable_area_2d.call_deferred("deactivate")
                    $Plant.modulate.a = 1.0
                'HIDDEN':
                    unhide_hole()
            
            # enter state
            match state:
                'DIZZY':
                    dizzy_component.visible = true
                    dizzy_timer.start(DIZZY_DURATION)
                    grabbable_area_2d.call_deferred("activate")
                'HIDDEN':
                    hide_hole()


func _ready():
    dizzy_timer.timeout.connect(_on_dizzy_ended)


func _process(delta: float) -> void:
    match state:
        'DIZZY':
            dizzy_eye_angle += delta*5
            var offset = Vector2(2, 0)
            eye.position = offset.rotated(dizzy_eye_angle)
        _:
            if target:
                eye.global_position = eye_center.global_position.move_toward(target.global_position, 3)


func hide_hole():
    animation_player.play("hide")

    
func unhide_hole():
    animation_player.play_backwards("hide")

    
func _on_dizzy_ended():
    state = 'HIDDEN'


func _on_sensor_body_entered(body: Node2D) -> void:
    if body is Player:
        target = body
        

func _on_sensor_body_exited(body: Node2D) -> void:
    var tween := get_tree().create_tween()
    tween.tween_property(eye, "position", Vector2.ZERO, 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
    target = null


func _on_close_sensor_body_entered(body: Node2D) -> void:
    if body is Player and state != 'DIZZY':
        state = 'HIDDEN'


func _on_close_sensor_body_exited(body: Node2D) -> void:
    if body is Player:
       state = 'IDLE'


func _on_grabbable_area_2d_focus_changed(is_focused: bool) -> void:
    $Plant.modulate.a = 0.5 if is_focused else 1.0


func _on_hurt_box_area_entered(area: Area2D) -> void:
    if area.get_parent() is Smoke and state != 'HIDDEN':
        state = 'DIZZY'
