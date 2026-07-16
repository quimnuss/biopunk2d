extends Node2D


func highlight():
    pass

func unhighlight():
    pass

func _on_grabbable_area_2d_focus_changed(is_focused: bool) -> void:
    if is_focused:
        highlight()
    else:
        unhighlight()
