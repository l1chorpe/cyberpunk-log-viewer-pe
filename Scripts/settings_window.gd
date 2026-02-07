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

    # Update value on change
    %IconSizeSlider.value_changed.connect(func(value): Settings.icon_size = value)
    # Double-clicking resets the slider
    %IconSizeLabel.gui_input.connect(_reset_icon_size_on_double_click)

    %FontSizeSpinBox.value_changed.connect(func(value):
        theme.default_font_size = value
    )
    %FontSizeLabel.gui_input.connect(_reset_font_size_on_double_click)

    $AppVersionLabel.text = \
            "Version " + ProjectSettings.get_setting("application/config/version")

    _fetch_settings()

func _on_hide() -> void:
    _apply_settings()
    request_hide_settings.emit()

#region Apply/fetch settings

func _apply_settings() -> void:
    Settings.full_search = %FullSearchToggle.button_pressed

func _fetch_settings() -> void:
    %FullSearchToggle.button_pressed = Settings.full_search
    %IconSizeSlider.value = Settings.icon_size

#endregion

func _reset_icon_size_on_double_click(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.double_click:
        Settings.reset_icon_size()
        # Deferring avoids the mouse moving the slider after value changed
        %IconSizeSlider.set_deferred("value", Settings.icon_size)

func _reset_font_size_on_double_click(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.double_click:
        Settings.reset_font_size()
        %FontSizeSpinBox.set_deferred("value", Settings.font_size)
