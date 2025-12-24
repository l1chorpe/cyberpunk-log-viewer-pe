## Handles showing the log list, error messages and notifications when copying
## to the clipboard.
extends CLVWindow

signal request_selection_window

const LogViewer := preload("uid://dqfcxhd8ley3n")


func _ready() -> void:
    $BackButton.pressed.connect(request_selection_window.emit)
    $VBoxContainer/RefreshButton.pressed.connect(display)

    # Triggers during double-clicks and when pressing enter on an item
    %LogList.item_activated.connect(func(_ignored): _open_log())

    %LogList.get_context_menu().request_open_log.connect(_open_log)
    %LogList.get_context_menu().request_open_with.connect(_show_open_with_dialog)
    %LogList.get_context_menu().request_folder_path_copy.connect(_send_folder_path_copied_notif)
    %LogList.get_context_menu().request_file_path_copy.connect(_send_file_path_copied_notif)

    $OpenWithDialog.file_selected.connect(_open_with_accepted)
    $OpenWithDialog.canceled.connect(_open_with_dismissed)

## Handles displaying the log list.
##
## TODO: handle more errors
func display() -> void:
    match %LogList.update():
        OK: 
            %LogList.show()
        ERR_UNAVAILABLE:
            $VBoxContainer/NoLogsLabel.show()

    show()

#region Log operations

func _open_log() -> void:
    var last_log: Log = %LogList.get_last_selected_log()
    add_child(LogViewer.instantiate().with(
            last_log.filename,
            last_log.full_path
    ))

## Displays a notification when the folder path was copied.
func _send_folder_path_copied_notif() -> void:
    $FolderPathCopiedNotification.trigger()

## Displays a notification when the file path was copied.
func _send_file_path_copied_notif() -> void:
    $FilePathCopiedNotification.trigger()

func _show_open_with_dialog() -> void:
    $OpenWithDialog.show()

## Opens a log with the selected program and hides the context menu.
func _open_with_accepted(exe_path: String) -> void:
    OS.create_process(
            exe_path,
            [%LogList.get_last_selected_log().full_path]
    )
    %LogList.get_context_menu().hide()

## Prevents the context menu from disappearing if no program was selected.
func _open_with_dismissed() -> void:
    %LogList.get_context_menu().grab_focus.call_deferred()

#endregion
