extends Node

var scenes = {
	"lobby" : load("res://src/Scenes/Lobby/LobbyScene.tscn"),
	"battle" : load("res://src/Scenes/Battle/BattleScene.tscn")
}

func LoadScene(sceneId : String):
	
	if scenes.has(sceneId):
		
		for child in $CurrentScene.get_children():
			$CurrentScene.remove_child(child)
			child.queue_free()
		
		var newScene = scenes[sceneId].instance()
		
		$CurrentScene.add_child(newScene)
		
		newScene.connect("changeScene", self, "LoadScene")
		
	

func _ready():
	LoadScene("lobby")
