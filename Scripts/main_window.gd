## Handles showing and hiding all other windows, and saving settings when the
## program closes.
extends Control

var _previous_window: CLVWindow


func _ready() -> void:
    $SelectionWindow.request_log_list_window.connect(_display_log_list_window)
    $LogListWindow.request_selection_window.connect(_display_selection_window)
    $SettingsWindow.request_hide_settings.connect(_hide_settings)
    $SettingsWindow.display_icon_license.connect(_display_icon_license)
    $SettingsWindow.display_godot_license.connect(_display_godot_license)
    $LicenseWindow.request_settings_window.connect(_hide_license_window)

    $ShowSettingsButton.pressed.connect(_display_settings)


func _display_log_list_window() -> void:
    $SelectionWindow.hide()
    $LogListWindow.display()

func _display_selection_window() -> void:
    $LogListWindow.hide()
    $SelectionWindow.display()

func _display_settings() -> void:
    _previous_window = $LogListWindow if $LogListWindow.visible else $SelectionWindow
    _previous_window.hide()
    $ShowSettingsButton.hide()
    $SettingsWindow.display()

func _hide_settings() -> void:
    $SettingsWindow.hide()
    $ShowSettingsButton.show()
    _previous_window.display()

func _display_icon_license() -> void:
    $SettingsWindow.hide()
    $LicenseWindow.load_icon_license()
    $LicenseWindow.display()

func _display_godot_license() -> void:
    $SettingsWindow.hide()
    $LicenseWindow.load_godot_license()
    $LicenseWindow.display()

func _hide_license_window() -> void:
    $LicenseWindow.hide()
    $SettingsWindow.display()

## Handles saving settings when the app is closed.
func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        Settings.save_to_file()
