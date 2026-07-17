extends Path2D

@export var speed := 400
@export var target_position : Vector2

@onready var path_follow_2d: PathFollow2D = $PathFollow2D

func _ready() -> void:
    curve.set_point_out(0, Vector2(target_position.x/2, -abs(target_position.x)))
    curve.set_point_position(1, target_position)


func _process(delta: float) -> void:
    if not target_position:
        return
        
    if path_follow_2d.progress_ratio >= 0.98:
        queue_free()
