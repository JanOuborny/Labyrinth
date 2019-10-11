extends Control

const DEFAULT_PORT = 8910 # Random port number
const MAX_PLAYER_COUNT = 10

func _on_Host_pressed():
	var success = create_host()
	if success:
		start_game()

func start_game():
	var labyrinth = load("res://Main.tscn").instance()
	get_tree().get_root().add_child(labyrinth)
	hide()

func create_host() -> bool:
	var host = NetworkedMultiplayerENet.new()
	host.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER) # Is this needed?
	var err = host.create_server(DEFAULT_PORT, MAX_PLAYER_COUNT - 1)
	if err != OK:
		# Is another server running?
		_set_Status("Can't host, address in use.")
		return false
	return true

func _on_Join_pressed():	
	var ip = get_node("panel/address").get_text()
	if not ip.is_valid_ip_address():
		#_set_status("IP address is invalid", false)
		return
	
	var host = NetworkedMultiplayerENet.new()
	host.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	host.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(host)
	
	start_game()

func _set_Status(text):
	get_node("Panel/Status").set_text(text)
	