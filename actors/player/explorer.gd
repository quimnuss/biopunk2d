class_name Player 
extends CharacterBody2D
@onready var sprite_2d: Sprite2D = $Anchor/Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var last_walk_velocity : Vector2 = Vector2.ZERO

const SPEED = 100.0

var grabbable_objects : Array[Grabbable]

var tool : Node2D

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("interact") and last_obj:
        if tool:
            # todo drop
            tool.queue_free()
        last_obj.reparent(self.hand)
        tool = last_obj

func _physics_process(delta: float) -> void:
   
    var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    if direction.x < 0:
        sprite_2d.flip_h = true
    elif direction.x > 0:
        sprite_2d.flip_h = false

    if direction:
        velocity = direction * SPEED
    else:
        velocity = Vector2.ZERO


    if velocity.length() > 0:
        if abs(velocity.x) > 0:
            animation_player.play("walk_horizontal")
        elif velocity.y < 0:
            animation_player.play("walk_up")
        elif velocity.y > 0:
            animation_player.play("walk_down")
        last_walk_velocity = velocity
    else:
        if abs(last_walk_velocity.x) > 0:
            animation_player.play("idle_horizontal")
        elif last_walk_velocity.y < 0:
            animation_player.play("idle_up")
        elif last_walk_velocity.y > 0:
            animation_player.play("idle_down")
        else:
            animation_player.play("idle_horizontal")

    move_and_slide()

func closest_object(a : Node2D, b : Node2D):
    return self.global_position.distance_to(a.global_position) < self.global_position.distance_to(b.global_position)

@export var last_obj : Node2D

func grabbable_changed():
    if not grabbable_objects and last_obj:
        last_obj.focus_changed.emit(false)
        last_obj = null
        return
    grabbable_objects.sort_custom(closest_object)
    var new_last_obj : Grabbable = grabbable_objects.get(0)
    if last_obj != new_last_obj:
        if last_obj:
            last_obj.focus_changed.emit(false)
        last_obj = new_last_obj
        last_obj.focus_changed.emit(true)

func _on_grab_area_2d_area_entered(area: Area2D) -> void:
    if area is Grabbable:
        prints('grabbable',area.get_parent().name,'entered')
        grabbable_objects.append(area)
        grabbable_changed()


func _on_grab_area_2d_area_exited(area: Area2D) -> void:
    if area is Grabbable:
        grabbable_objects.erase(area)
        grabbable_changed()
