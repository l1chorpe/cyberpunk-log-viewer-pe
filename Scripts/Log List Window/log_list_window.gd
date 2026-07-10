## Handles showing the log list, error messages and notifications when copying
## to the clipboard.
extends CLVWindow

signal request_selection_window

const LogViewer := preload("uid://dqfcxhd8ley3n")

## Used to separate core mod logs
static var _core_mods_regex: Dictionary[String, RegEx] = {
    "CET": RegEx.create_from_string("cyber_engine_tweaks"),
    "redscript": RegEx.create_from_string("redscript_r"),
    "red4ext": RegEx.create_from_string("red4ext"),
    "ArchiveXL": RegEx.create_from_string("ArchiveXL"),
    "Codeware": RegEx.create_from_string("Codeware"),
    "TweakXL": RegEx.create_from_string("TweakXL")
}

static var _core_logs: Array[Log]
static var _other_logs: Array[Log]


func _ready() -> void:
    $BackButton.pressed.connect(request_selection_window.emit)
    $VBoxContainer/RefreshButton.pressed.connect(display)

    %CoreLogList.request_open_log.connect(_open_log)
    %CoreLogList.request_open_with.connect(_show_open_with_dialog)
    %OtherLogList.request_open_log.connect(_open_log)
    %OtherLogList.request_open_with.connect(_show_open_with_dialog)

    $OpenWithDialog.file_selected.connect(_open_with)
    $OpenWithDialog.canceled.connect(_open_with_dismissed)

## Handles displaying the log list.
##
## TODO: handle more errors
func display() -> void:
    _update_logs()
    _push_logs()
    show()

## Updates the logs (either when searching or refreshing).
func _update_logs() -> void:
    # TODO: handle path not accessible

    _core_logs.clear()
    _other_logs.clear()

    # Search for logs
    var logs: Array[Log]
    for path in _get_folders_paths():
        logs.append_array(_search_logs_in(path))

    _split_logs(logs)

## Pushes logs into the corresponding lists or shows an error if no logs were found.
func _push_logs() -> void:
    if _core_logs.size() != 0:
        %CoreLogList.update_with(_core_logs)
        %CLLContainer.show()
    else:
        $VBoxContainer/NoCoreLogsLabel.show()
        %CLLContainer.hide()

    if _other_logs.size() != 0:
        %OtherLogList.update_with(_other_logs)
        %OLLContainer.show()
    else:
        $VBoxContainer/NoOtherLogsLabel.show()
        %OLLContainer.hide()



#region Log opening

func _open_log(log_: Log) -> void:
    # Open externally if set to do so
    if Settings.always_ext_edit:
        _open_with(Settings.ext_edit_path, log_)
        return

    # Open with internal editor
    add_child(LogViewer.instantiate().with(
            log_.filename,
            log_.full_path
    ))

func _show_open_with_dialog() -> void:
    $OpenWithDialog.show()

## Opens a log with the selected program and hides the context menu.
func _open_with(exe_path: String, log_: Log) -> void:
    OS.create_process(
            exe_path,
            [log_.full_path]
    )
    %LogList.get_context_menu().hide()

## Prevents the context menu from disappearing if no program was selected.
func _open_with_dismissed() -> void:
    %LogList.get_context_menu().grab_focus.call_deferred()

#endregion


#region Log searching

## Splits logs into core and other mod logs.
func _split_logs(logs: Array[Log]) -> void:
    # Underscore avoids name collision with log()
    for log_ in logs:
        if _is_core_mod(log_):
            _core_logs.push_back(log_)
        else:
            _other_logs.push_back(log_)

## Checks if a mod is core or not.
static func _is_core_mod(log_: Log) -> bool:
    for mod in _core_mods_regex:
        if _core_mods_regex[mod].search(log_.filename) != null:
            return true
    return false

## Returns the folders to be searched according to the settings.
static func _get_folders_paths() -> Array[String]:
    if Settings.full_search:
        return [Settings.game_folder]
    return [
        Settings.game_folder + "/bin/x64/plugins/cyber_engine_tweaks",
        Settings.game_folder + "/r6/logs",
        Settings.game_folder + "/red4ext/logs",
        Settings.game_folder + "/red4ext/plugins",
    ]

## Searches for the logs in the given folder.
static func _search_logs_in(folder: String) -> Array[Log]:
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


#region notifications

## Displays a notification when the folder path was copied.
func _send_folder_path_copied_notif() -> void:
    $FolderPathCopiedNotification.trigger()

## Displays a notification when the file path was copied.
func _send_file_path_copied_notif() -> void:
    $FilePathCopiedNotification.trigger()

#endregion
