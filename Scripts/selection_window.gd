## Handles locating the game folder.
extends CLVWindow

signal request_log_list_window


func _ready() -> void:
    $VBoxContainer/LocateGameButton.pressed.connect(_locate_button_pressed)
    $VBoxContainer/ViewLogsButton.pressed.connect(_view_logs_pressed)
    $LocateDialog.dir_selected.connect(_folder_selected)

    # Load settings
    _folder_selected(Settings.game_folder)
    $LocateDialog.current_path = Settings.game_folder

## Shows the dialog to locate the game folder.
func _locate_button_pressed() -> void:
    $LocateDialog.show()

## Display the game folder path and enables ViewLogsButton if the path is not empty.
func _folder_selected(folder: String) -> void:
    if folder != "":
        %GamePathLabel.text = folder
        $VBoxContainer/ViewLogsButton.disabled = false

## Saves the game folder and full search option to the settings and
## notifies the main window to display logs.
func _view_logs_pressed() -> void:
    Settings.game_folder = $LocateDialog.current_path
    
    request_log_list_window.emit()
