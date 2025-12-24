extends Control

signal request_open_log
signal request_open_with
signal request_folder_path_copy
signal request_file_path_copy

## Represents an operation to be done with logs.
enum LogOp
{
    ## Open a log with the LogViewer.
    OPEN,
    ## Open a log with an external editor.
    OPEN_WITH,
    ## Copy the log folder path.
    COPY_FOLDER_PATH,
    ## Copy the log file path.
    COPY_FILE_PATH,
}


func _ready() -> void:
    focus_exited.connect(_focus_exited)

    %OpenLogButton.pressed.connect(_handle_button_press.bind(LogOp.OPEN))
    %OpenWithButton.pressed.connect(_handle_button_press.bind(LogOp.OPEN_WITH))
    %CopyFolderPathButton.pressed.connect(_handle_button_press.bind(LogOp.COPY_FOLDER_PATH))
    %CopyFilePathButton.pressed.connect(_handle_button_press.bind(LogOp.COPY_FILE_PATH))

    # Allows the background to fill the menu and _clamp_position() to work
    size = $VBoxContainer.size

## Updates the position and size of the context menu, and grabs the focus.
func display(at_position: Vector2) -> void:
    position = _clamp_position(at_position)
    
    show()
    grab_focus.call_deferred()

## Offsets the position of the context menu when necessary to avoid overflow
## (which gets hidden by the ItemList).
func _clamp_position(new_position: Vector2) -> Vector2:
    if new_position.x + size.x > get_parent().size.x:
        new_position.x -= size.x
    if new_position.y + size.y > get_parent().size.y:
        new_position.y -= size.y
    
    return new_position

## Hides the context menu if something other than the "open with" button has focus.
func _focus_exited() -> void:
    # Wait in case the buttons requested focus
    await get_tree().process_frame
    if not is_ancestor_of(get_viewport().gui_get_focus_owner()):
        hide()

## Handles all the context menu button presses.
##
## LogOp.OPEN is handled by the LogList.
## LogOp.COPY_FOLDER_PATH and LogOp.COPY_FILE_PATH are handled by the LogListWindow.
func _handle_button_press(log_op: LogOp) -> void:
    match log_op:
        LogOp.OPEN:
            request_open_log.emit()
        LogOp.OPEN_WITH:
            request_open_with.emit()
            # Avoid hiding the context menu for aesthetic reasons
            return
        LogOp.COPY_FOLDER_PATH:
            request_folder_path_copy.emit()
        LogOp.COPY_FILE_PATH:
            request_file_path_copy.emit()
    hide()
