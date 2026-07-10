extends ItemList

signal request_open_log(log: Log)
signal request_open_with(log: Log)

var _log_list: Array[Log]
var _last_clicked_log: Log


func _ready() -> void:
    resized.connect(func():
        # Limits the vertical size to 80% of the viewport
        custom_minimum_size.y = .35 * get_viewport_rect().size.y
        # Prevents the menu from being too small for the context menu
        custom_minimum_size.x = 2 * $ContextMenu.size.x
    )

    item_clicked.connect(_item_clicked)

    # Delegates the requests to the parent
    $ContextMenu.request_open_log.connect(request_open_log.emit.bind(_last_clicked_log))
    $ContextMenu.request_open_with.connect(request_open_with.emit.bind(_last_clicked_log))
    # Triggers on double-click and enter on a focused item; also delegated
    item_activated.connect(func(_ignored): request_open_log.emit(_last_clicked_log))

    $ContextMenu.request_folder_path_copy.connect(_copy_log_folder_path)
    $ContextMenu.request_file_path_copy.connect(_copy_log_file_path)

## Handles clicks on items in the list.
func _item_clicked(index: int, at_position: Vector2, mouse_button: int) -> void:
    _last_clicked_log = _log_list[index]

    if mouse_button == MouseButton.MOUSE_BUTTON_RIGHT:
        $ContextMenu.display(at_position)

func update_with(logs: Array[Log]) -> void:
    for l in logs:
        add_item(l.filename)
    _log_list = logs

func get_last_selected_log() -> Log:
    return _last_clicked_log

#region Copy log data operations

func _copy_log_folder_path() -> void:
    DisplayServer.clipboard_set(_last_clicked_log.folder_path)

func _copy_log_file_path() -> void:
    DisplayServer.clipboard_set(_last_clicked_log.full_path)

#endregion
