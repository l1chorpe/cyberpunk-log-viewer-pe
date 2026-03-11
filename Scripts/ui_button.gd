@tool
extends TextureButton

enum Type { CLOSE, BACK, REFRESH, SETTINGS }
@export var type := Type.CLOSE:
    set(t):
        type = t
        _apply_svgs()

# Holds SVGs as byte arrays to avoid unnecessary file loading.
static var _svg_data_normal: Array[PackedByteArray]
static var _svg_data_hover: Array[PackedByteArray]
static var _svg_data_pressed: Array[PackedByteArray]


## Loads all SVG variants
static func _static_init() -> void:
    _load_normal_svgs()
    _load_hover_svgs()
    _load_pressed_svgs()

func _ready() -> void:
    _apply_svgs()

    # Reflect changes to the icon size
    # Checking the hint avoids irrelevant errors in the editor
    if not Engine.is_editor_hint():
        Settings.icon_size_changed.connect(_apply_svgs)

#region SVG variants loading

## Loads "normal" SVG icons.
static func _load_normal_svgs() -> void:
    _svg_data_normal.resize(Type.size())
    
    _svg_data_normal[Type.CLOSE] = FileAccess.get_file_as_bytes("res://icons/close/close-normal.svg")
    _svg_data_normal[Type.BACK] = FileAccess.get_file_as_bytes("res://icons/arrow-left/arrow-left-normal.svg")
    _svg_data_normal[Type.REFRESH] = FileAccess.get_file_as_bytes("res://icons/refresh/refresh-normal.svg")
    _svg_data_normal[Type.SETTINGS] = FileAccess.get_file_as_bytes("res://icons/cog/cog-normal.svg")

## Loads "hover" SVG icons.
static func _load_hover_svgs() -> void:
    _svg_data_hover.resize(Type.size())
    
    _svg_data_hover[Type.CLOSE] = FileAccess.get_file_as_bytes("res://icons/close/close-hover.svg")
    _svg_data_hover[Type.BACK] = FileAccess.get_file_as_bytes("res://icons/arrow-left/arrow-left-hover.svg")
    _svg_data_hover[Type.REFRESH] = FileAccess.get_file_as_bytes("res://icons/refresh/refresh-hover.svg")
    _svg_data_hover[Type.SETTINGS] = FileAccess.get_file_as_bytes("res://icons/cog/cog-hover.svg")

## Loads "pressed" SVG icons.
static func _load_pressed_svgs() -> void:
    _svg_data_pressed.resize(Type.size())
    
    _svg_data_pressed[Type.CLOSE] = FileAccess.get_file_as_bytes("res://icons/close/close-pressed.svg")
    _svg_data_pressed[Type.BACK] = FileAccess.get_file_as_bytes("res://icons/arrow-left/arrow-left-pressed.svg")
    _svg_data_pressed[Type.REFRESH] = FileAccess.get_file_as_bytes("res://icons/refresh/refresh-pressed.svg")
    _svg_data_pressed[Type.SETTINGS] = FileAccess.get_file_as_bytes("res://icons/cog/cog-pressed.svg")

#endregion

## Applies the chosen SVG's variants to the corresponding texture variables.
func _apply_svgs() -> void:
    var image := Image.new()

    # Checking the hint avoids irrelevant errors in the editor
    var icon_size := Settings.DEFAULT_ICON_SIZE if Engine.is_editor_hint() else Settings.icon_size
    
    image.load_svg_from_buffer(_svg_data_normal[type], icon_size)
    texture_normal = ImageTexture.create_from_image(image)

    image.load_svg_from_buffer(_svg_data_hover[type], icon_size)
    texture_hover = ImageTexture.create_from_image(image)

    image.load_svg_from_buffer(_svg_data_pressed[type], icon_size)
    texture_pressed = ImageTexture.create_from_image(image)
    