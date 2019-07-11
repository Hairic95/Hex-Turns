extends Control

func _on_HostMatch_pressed():
	NETWORKING.become_host(int($ConnectionPanel/Port.text))

func _on_JoinMatch_pressed():
	NETWORKING.join_host($ConnectionPanel/IPAddress.text, int($ConnectionPanel/Port.text))
