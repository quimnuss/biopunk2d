extends CharacterBody2D
@onready var sprite_2d: Sprite2D = $Anchor/Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var last_walk_velocity : Vector2 = Vector2.ZERO

const SPEED = 100.0


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
