extends ItemList

var _log_list: Array[Log]
var _last_clicked_log: Log


func _ready() -> void:
    # Limits the vertical size to 80% of the viewport.
    resized.connect(func(): custom_minimum_size.y = .8 * get_viewport_rect().size.y)

    item_clicked.connect(_item_clicked)

    $ContextMenu.request_folder_path_copy.connect(_copy_log_folder_path)
    $ContextMenu.request_file_path_copy.connect(_copy_log_file_path)

## Handles clicks on items in the list.
func _item_clicked(index: int, at_position: Vector2, mouse_button: int) -> void:
    _last_clicked_log = _log_list[index]

    if mouse_button == MouseButton.MOUSE_BUTTON_RIGHT:
        $ContextMenu.display(at_position)

## Updates the internal log list and the ItemList itself.
func update() -> Error:
    if not DirAccess.open(Settings.game_folder):
        return DirAccess.get_open_error()
    
    # Avoids repeating the list when refreshing
    clear()
    _log_list.clear()

    # Search through all folders
    for folder in _get_folders():
        _log_list.append_array(_search_logs_in(folder))
    
    # Return an error when no logs have been found
    if _log_list.is_empty():
        return ERR_UNAVAILABLE

    # Display filenames
    for log_file in _log_list:
        add_item(log_file.filename)
    
    return OK

func get_context_menu() -> Control:
    return $ContextMenu

func get_last_selected_log() -> Log:
    return _last_clicked_log

#region Folder searching functions
## Returns the folders that need to be scanned for logs.
func _get_folders() -> Array[String]:
    if Settings.full_search:
        return [Settings.game_folder]
    return [
        Settings.game_folder + "/bin/x64/plugins/cyber_engine_tweaks",
        Settings.game_folder + "/r6/logs",
        Settings.game_folder + "/red4ext/logs",
        Settings.game_folder + "/red4ext/plugins",
    ]

## Recursively searches through folders for logs.
func _search_logs_in(folder: String) -> Array[Log]:
    var logs: Array[Log]
    var dir = DirAccess.open(folder)
    dir.list_dir_begin()
    var filename = dir.get_next()
    while filename != "":
        if dir.current_is_dir():
            logs.append_array(_search_logs_in(folder + "/" + filename))
        elif filename.ends_with(".log"):
            logs.append(Log.new(folder, filename))
        filename = dir.get_next()
    return logs
#endregion

#region Copy log data operations

func _copy_log_folder_path() -> void:
    DisplayServer.clipboard_set(_last_clicked_log.folder_path)

func _copy_log_file_path() -> void:
    DisplayServer.clipboard_set(_last_clicked_log.full_path)

#endregion
