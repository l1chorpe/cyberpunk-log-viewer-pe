## Displays log contents in a separate window from the main app.
extends Window


func _ready() -> void:
    close_requested.connect(queue_free)

    # Avoids overlapping the log viewer with the main window
    position = get_tree().root.position * 1.1
    
## Sets the file name as the title and displays the file contents.
func with(window_title: String, file_path: String) -> Window:
    self.title = window_title
    $LogContents.text = FileAccess.open(file_path, FileAccess.READ).get_as_text()
    return self
