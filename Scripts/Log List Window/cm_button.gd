extends Button


func _ready() -> void:
    # Prevents the icon from shrinking to size (0,0)
    custom_minimum_size.x = size.x + icon.get_size().x
