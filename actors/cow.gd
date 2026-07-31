extends CharacterBody2D

@export var interest_array = [0, 0, 0, 0, 0]
@export var speed := 50
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var change_state_timer: Timer = $ChangeStateTimer

var direction : Vector2 = Vector2.RIGHT
var initial_position : Vector2
@export_enum('idle', 'patrol', 'surprised', 'scared', 'sleep') var state = 'idle'
@export var MAX_DRIFTING_DISTANCE : float = 400

func _ready() -> void:
    initial_position = global_position

func change_state(new_state):
    var previous_state = state
    
    # enter state
    state = new_state
    match state:
        'idle':
            animation_player.play('idle')
            change_state_timer.start(10.0)
        'patrol':
            animation_player.play('walk_horizontal')
            change_state_timer.start(2.0)
            if global_position.distance_to(initial_position) > MAX_DRIFTING_DISTANCE:
                direction = global_position.direction_to(initial_position)

func _physics_process(delta: float) -> void:
    if direction and state == 'patrol':
        velocity = speed * direction
    else:
        velocity = Vector2.ZERO
    
    if velocity.x < 0:
        sprite_2d.flip_h = true
    elif velocity.x > 0:
        sprite_2d.flip_h = false

    move_and_slide()

func _on_patrol_timer_timeout() -> void:
    direction = direction.rotated(randf()*PI/4)

func _on_change_state_timer_timeout() -> void:
    match state:
        'idle':
            change_state('patrol')
        'patrol':
            change_state('idle')
