## Stores all settings during runtime and saves/loads them. Is an autoload.
extends Node

signal icon_size_changed

static var _settings := ConfigFile.new()
const _SETTINGS_FILE_PATH := "user://clv-settings.cfg"

#region Defaults

const DEFAULT_GAME_FOLDER = ""
const DEFAULT_FULL_SEARCH = true
const DEFAULT_ICON_SIZE = 2.0

#endregion

# Assigning a default value avoids having to deal with the file not opening
var game_folder := DEFAULT_GAME_FOLDER
var full_search := DEFAULT_FULL_SEARCH
var icon_size := DEFAULT_ICON_SIZE:
    set(s):
        icon_size = s
        icon_size_changed.emit()


## Loads settings if the file is present/accessible.
func _init() -> void:
    if _settings.load(_SETTINGS_FILE_PATH) != OK:
        return
    
    _load_from_file()

## Resets the icon size to the default value.
func reset_icon_size() -> void:
    icon_size = DEFAULT_ICON_SIZE

#region Load/save

func _load_from_file() -> void:
    game_folder = _settings.get_value("Main", "game_path", "")
    full_search = _settings.get_value("Main", "search_mode", true)
    icon_size = _settings.get_value("Main", "icon_size", 2.0)

func save_to_file() -> void:
    _settings.set_value("Main", "game_path", game_folder)
    _settings.set_value("Main", "search_mode", full_search)
    _settings.set_value("Main", "icon_size", icon_size)

    _settings.save(_SETTINGS_FILE_PATH)

#endregion
