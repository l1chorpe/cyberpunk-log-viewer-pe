extends LineEdit

signal text_edited(delete_key_pressed: bool)


func _input(event):
    if not (event is InputEventKey and event.is_released() and has_focus()):
        return
    
    event = event as InputEventKey
    # Pressing the enter key doesn't count as editing the text
    if not event.keycode == Key.KEY_ENTER:
        text_edited.emit(event.keycode == Key.KEY_DELETE)
