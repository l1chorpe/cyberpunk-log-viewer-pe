## Holds info related to log files, namely the path to the folder_path, the file name
## and the full file path.
class_name Log extends RefCounted

var folder_path: String
var filename: String
var full_path: String


func _init(new_folder: String, new_filename: String) -> void:
    folder_path = new_folder
    filename = new_filename
    full_path = new_folder + "/" + new_filename
    