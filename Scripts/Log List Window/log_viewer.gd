## Displays log contents in a separate window from the main app.
extends Window

var _search_offset := Vector2i.ZERO


func _ready() -> void:
    close_requested.connect(queue_free)

    %SearchButton.pressed.connect(_search_log)
    %SearchInput.text_submitted.connect(_search_log)
    %SearchInput.text_edited.connect(func(_ignored): _search_offset = Vector2i.ZERO)

    # Avoids overlapping the log viewer with the main window
    position = get_tree().root.position * 1.1

func _input(event: InputEvent) -> void:
    # is_released() avoids double triggers
    if not (event is InputEventKey and event.is_released()):
        return
    
    event = event as InputEventKey
    # Show/hide the search bar
    if event.ctrl_pressed and event.keycode == Key.KEY_F:
        if %SearchBar.visible:
            %SearchBar.hide()
        else:
            %SearchBar.show()
            %SearchInput.grab_focus()
    if event.keycode == Key.KEY_ESCAPE:
        %SearchBar.hide()

    
## Sets the file name as the title and displays the file contents.
func with(window_title: String, file_path: String) -> Window:
    self.title = window_title
    %LogContents.text = FileAccess.open(file_path, FileAccess.READ).get_as_text()
    return self

## Searches the log for the given search term.
func _search_log(_ignored: String = "") -> void:
    # Don't search if the log or the search term is empty
    var search_term: String = %SearchInput.text
    if search_term.is_empty() or %LogContents.text.is_empty():
        return
    
    # Set search flags
    var search_flags := 0
    if %MatchCaseToggle.button_pressed:
        search_flags |= TextEdit.SEARCH_MATCH_CASE
    if %MatchWordsToggle.button_pressed:
        search_flags |= TextEdit.SEARCH_WHOLE_WORDS

    # Check offset
    if _search_offset.y > %LogContents.get_total_visible_line_count():
        _search_offset = Vector2i.ZERO
    
    # Get the position of the search term's next occurence starting at the given offset
    var term_pos: Vector2i = %LogContents.search(
            search_term,
            search_flags,
            _search_offset.y,
            _search_offset.x
    )
    if term_pos.x == -1:
        # Search term not found in the whole log: notify
        if _search_offset == Vector2i.ZERO:
            %NoMatchNotification.trigger()
        # Search term not found in limited section: search again from the top
        else:
            _search_offset = Vector2i.ZERO
            _search_log()
        return
    
    # Search term found: select it and scroll to it
    %LogContents.select(
            term_pos.y,
            term_pos.x,
            term_pos.y,
            term_pos.x + search_term.length()
    )
    %LogContents.center_viewport_to_caret()
    # Allows using the enter key repeatedly
    %SearchInput.grab_focus()

    # Update the offset
    _search_offset.x = term_pos.x + search_term.length()
    _search_offset.y = term_pos.y
