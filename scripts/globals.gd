extends Node

var savePath = "user://desktopFrog.json"

var data := {
	"scale": 5
}

func _ready() -> void:
	loadData()
	resetData()
	saveData()

func saveData():
	var frogData = {
		"data": data
	}
	
	var file = FileAccess.open(savePath, FileAccess.WRITE)
	file.store_string(JSON.stringify(frogData))
	file.close()

func loadData():
	if FileAccess.file_exists(savePath):
		var file = FileAccess.open(savePath, FileAccess.READ)
		var content = file.get_as_text()
		file.close()

		var loadedData = JSON.parse_string(content)
		if typeof(loadedData) == TYPE_DICTIONARY:
			data = loadedData.get("data", {
					"scale": 5
				}
			)

func resetData():
	data["scale"] = 5
