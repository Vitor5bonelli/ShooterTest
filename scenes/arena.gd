extends Node

@onready var main_menu = $CanvasLayer/MainMenu
@onready var addr_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressEntry
@onready var name_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/NameEntry

const Player = preload("res://scenes/player.tscn")
const PORT = 9999

var enet_peer = ENetMultiplayerPeer.new()

func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func _on_host_btn_pressed():
	main_menu.hide()
	
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	add_player(multiplayer.get_unique_id())
	
	upnp_setup()


func _on_join_btn_pressed():
	main_menu.hide()
	
	enet_peer.create_client(addr_entry.text, PORT)
	multiplayer.multiplayer_peer = enet_peer


func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)


func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	
	if player:
		player.queue_free()
	

func upnp_setup():
	var upnp = UPNP.new()
	var discover_result = upnp.discover()
	
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
	"UPNP discover FAILED! Error %s" % discover_result)
	
	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP Invalid Gateway!")

	var map_result = upnp.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port Mapping Failed! Error %s" % map_result)
	
	print("Success! Join Address: %s" % upnp.query_external_address())
