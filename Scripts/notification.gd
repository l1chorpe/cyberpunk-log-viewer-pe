## A Label that automatically disappears after a while, that is used as a notification.
extends Label

signal _fade_ended

var _fade_started := false
var _fade_interrupt := false


## Handles displaying notifications and fading them out, or sending a toast notification.
func trigger() -> void:
    # Interrupt fade out and wait in case of fast repeat notifications
    if _fade_started:
        _fade_interrupt = true
        await _fade_ended
        _fade_interrupt = false
    
    show()
    # Gradually fade out the notification after a delay
    _fade_started = true
    await get_tree().create_timer(0.75).timeout
    while modulate.a > 0 and not _fade_interrupt:
        # Mitigate floating point inaccuracy
        modulate.a = snappedf(modulate.a - 0.05, 0.01)
        await get_tree().create_timer(0.05).timeout
    
    # Reset state after the fade out
    _fade_started = false
    modulate.a = 1
    if not _fade_interrupt:
        hide()
    _fade_ended.emit()
