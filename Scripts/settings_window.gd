## Displays all the settings available in the app and makes available the licenses
## for the icons and Godot.
extends CLVWindow

signal display_icon_license
signal display_godot_license
signal request_hide_settings


func _ready() -> void:
    $CloseButton.pressed.connect(_on_hide)

    # Connect license buttons
    $VBoxContainer/ShowIconLicenseButton.pressed.connect(display_icon_license.emit)
    $VBoxContainer/ShowGodotLicenseButton.pressed.connect(display_godot_license.emit)

    # Connect icon size label and slider
    %IconSizeSlider.value_changed.connect(func(value): Settings.icon_size = value)
    %IconSizeLabel.gui_input.connect(_reset_icon_size_on_double_click)

    # Connect font size label and spinbox
    %FontSizeSpinBox.value_changed.connect(func(value):
        ThemeDB.get_project_theme().default_font_size = value
    )
    %FontSizeLabel.gui_input.connect(_reset_font_size_on_double_click)

    # Connect external editor select button and file picker
    %SelectEditorButton.pressed.connect(%ExtEditPathPicker.show)
    %ExtEditPathPicker.file_selected.connect(_update_ext_edit_path)

    _display_app_version()
    _fetch_settings()


func _on_hide() -> void:
    _apply_settings()
    request_hide_settings.emit()

## Displays the app version in the corresponding label.
func _display_app_version() -> void:
    $AppVersionLabel.text = \
            "Version " + ProjectSettings.get_setting("application/config/version")

## Updates the external editor path when the user selects one.
func _update_ext_edit_path(path: String) -> void:
    Settings.ext_edit_path = path
    %ExtEditPathLabel.text = path

#region Apply/fetch settings

func _apply_settings() -> void:
    Settings.full_search = %FullSearchToggle.button_pressed
    Settings.always_ext_edit = %ExtEditToggle.button_pressed

func _fetch_settings() -> void:
    %FullSearchToggle.button_pressed = Settings.full_search
    %IconSizeSlider.value = Settings.icon_size
    %FontSizeSpinBox.value = Settings.font_size
    %ExtEditToggle.button_pressed = Settings.always_ext_edit
    %ExtEditPathLabel.text = Settings.ext_edit_path

#endregion

#region Reset UI

func _reset_icon_size_on_double_click(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.double_click:
        Settings.reset_icon_size()
        # Deferring avoids the mouse moving the slider after value changed
        %IconSizeSlider.set_deferred("value", Settings.icon_size)

func _reset_font_size_on_double_click(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.double_click:
        Settings.reset_font_size()
        %FontSizeSpinBox.set_deferred("value", Settings.font_size)

#endregion
