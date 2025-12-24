## Stores all settings during runtime and saves/retrieves them.
class_name Settings extends Node

static var _settings := ConfigFile.new()
const _SETTINGS_FILE_PATH := "user://clv-settings.cfg"

# Assigning a default value avoids having to deal with the file not opening
static var game_folder := ""
static var full_search := true


## Loads settings if the file is present/accessible.
static func _static_init() -> void:
    if _settings.load(_SETTINGS_FILE_PATH) != OK:
        return
    
    _load_from_file()

#region Load/save

static func _load_from_file() -> void:
    game_folder = _settings.get_value("Main", "game_path", "")
    full_search = _settings.get_value("Main", "search_mode", true)

static func save_to_file() -> void:
    _settings.set_value("Main", "game_path", game_folder)
    _settings.set_value("Main", "search_mode", full_search)

    _settings.save(_SETTINGS_FILE_PATH)

#endregion
