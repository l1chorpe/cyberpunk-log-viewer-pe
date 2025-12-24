## Displays all the settings available in the app and makes available the licenses
## for the icons and Godot.
extends CLVWindow

signal display_icon_license
signal display_godot_license
signal request_hide_settings


func _ready() -> void:
    $VBoxContainer/ShowIconLicenseButton.pressed.connect(display_icon_license.emit)
    $VBoxContainer/ShowGodotLicenseButton.pressed.connect(display_godot_license.emit)
    $CloseButton.pressed.connect(_on_hide)

    $AppVersionLabel.text = \
            "Version " + ProjectSettings.get_setting("application/config/version")

    _load_settings()

func _on_hide() -> void:
    _save_settings()
    request_hide_settings.emit()

#region Load/save settings

func _save_settings() -> void:
    Settings.full_search = %FullSearchToggle.button_pressed

func _load_settings() -> void:
    %FullSearchToggle.button_pressed = Settings.full_search

#endregion
