## Used to display licenses.
extends CLVWindow

signal request_settings_window


func _ready() -> void:
    $BackButton.pressed.connect(request_settings_window.emit)

func load_icon_license() -> void:
    $RichTextLabel.text = \
            FileAccess.open("res://icons/license.txt", FileAccess.READ).get_as_text()

func load_godot_license() -> void:
    $RichTextLabel.text = Engine.get_license_text()
    
