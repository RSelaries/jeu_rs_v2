## This Autoload is used to manage multiplayer server hosting and joining.
##
## To host a server, call the method [method MultiplayerManager.host_game].[br]
## To join a server, call the method [method MultiplayerManager.join_game].[br]
## You can discover servers on the network using the method [method MultiplayerManager.start_discovery].
extends Node


signal server_list_updated
signal logs_updated(new_log: String)


## The PORT of the game server
const GAME_PORT = 7000
## The PORT on wich the broadcast will be sent
const DISCOVERY_PORT = 7001
## Number max of players on a server
const MAX_CONNECTIONS = 20
const BROADCAST_INTERVAL = 1.0
const SERVER_TIMEOUT = 3.0
const PACKET_GAME_ID = "JEU_RS"


var host_server_name: String
var udp_broadcast: PacketPeerUDP
var udp_listener: PacketPeerUDP
var broadcast_timer: Timer
## A dictionnary of game servers discovered on the network.
## It takes the form [code][ip_adress: String, server_infos: Dict][/code] with [code]server_infos[/code]
## being a dictionnary withs keys [code]name: String[/code] (the name of the server),
## [code]port: int[/code] (the server PORT, typically 7000) and
## [code]last_seen: float[/code] (the time in seconds since the server has been discovered).
var discovered_servers: Dictionary = {} # ip -> {name, port, last_seen}

var logs: PackedStringArray = []


func _process(_delta: float) -> void:
	_poll_discovery()
	_clean_up_old_servers()


# ================== JOIN ==================

## Call this function to join a server game at adress [param server_adress].
func join_server(server_adress: String) -> Error:
	if server_adress == "":
		return ERR_INVALID_DATA
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(server_adress, GAME_PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	log_message.rpc("Joined game server at adress %s and port %s." % [server_adress, GAME_PORT])
	stop_discovery_listener()
	connect_multiplayer_signals()
	return OK


# ================== HOST ==================

## Call this function to host a game on this device.
## Optionnally, pass a [param server_name] to be visible on [member discovered_servers].
func host_game(server_name: String = "") -> Error:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(GAME_PORT, MAX_CONNECTIONS)
	if error:
		printerr("Could not create server on port %s" % GAME_PORT)
		return error
	host_server_name = server_name
	multiplayer.multiplayer_peer = peer
	print("Created server on port %s" % GAME_PORT)
	log_message.rpc("Game hosted on port %s." % GAME_PORT)
	connect_multiplayer_signals()
	stop_discovery_listener()
	start_broadcasting()
	return OK


# ================== BROADCAST ==================

## This function makes the device broadcast its server on the network.
func start_broadcasting() -> void:
	if udp_broadcast != null:
		return
	
	udp_broadcast = PacketPeerUDP.new()
	udp_broadcast.set_broadcast_enabled(true)
	udp_broadcast.set_dest_address("255.255.255.255", DISCOVERY_PORT)
	
	broadcast_timer = Timer.new()
	broadcast_timer.wait_time = BROADCAST_INTERVAL
	broadcast_timer.timeout.connect(_on_broadcast_timeout)
	add_child(broadcast_timer)
	broadcast_timer.start()
	_on_broadcast_timeout()
	print("Device started broadcasting server's infos on port %s" % DISCOVERY_PORT)


func _on_broadcast_timeout() -> void:
	var message_to_broadcast := "%s|%s|%d" % [PACKET_GAME_ID, host_server_name, GAME_PORT]
	udp_broadcast.put_packet(message_to_broadcast.to_utf8_buffer())


## This function makes the device stop broadcasting on the network.
func stop_broadcasting() -> void:
	if broadcast_timer:
		broadcast_timer.stop()
		broadcast_timer.queue_free()
		broadcast_timer = null
	if udp_broadcast:
		udp_broadcast.close()
		udp_broadcast = null
		print("Device stoped broadcasting server's infos")


# ================== DISCOVERY ==================

## This function makes the device listen for servers broadcasts on the network.
func start_discovery_listener() -> Error:
	if udp_listener:
		return OK
	udp_listener = PacketPeerUDP.new()
	var error = udp_listener.bind(DISCOVERY_PORT)
	if error:
		log_message.rpc("Could not listen to LAN broadcast. (%s)" % error)
		udp_listener = null
	print("Device started listening to servers broadcasts")
	return OK


## This function makes the device stop listening for servers broadcasts on the network.
func stop_discovery_listener() -> void:
	if udp_listener:
		udp_listener.close()
		udp_listener = null
		print("Device stopped listening to servers broadcasts")


func _poll_discovery() -> void:
	if not udp_listener:
		return
	
	while udp_listener.get_available_packet_count() > 0:
		var packet := udp_listener.get_packet()
		var sender_ip := udp_listener.get_packet_ip()
		var parts := packet.get_string_from_utf8().split("|")
		if parts.size() == 3 and parts[0] == PACKET_GAME_ID:
			var is_new := not discovered_servers.has(sender_ip)
			discovered_servers[sender_ip] = {
				"name": parts[1],
				"port": int(parts[2]),
				"last_seen": Time.get_ticks_msec() / 1000.0
			}
			if is_new:
				server_list_updated.emit()


func _clean_up_old_servers() -> void:
	var now := Time.get_ticks_msec() / 1000.0
	var changed := false
	for ip in discovered_servers.keys():
		if now - discovered_servers[ip].last_scene > SERVER_TIMEOUT:
			discovered_servers.erase(ip)
			changed = true
	if changed:
		server_list_updated.emit()


# ================== SIGNALS ==================

func connect_multiplayer_signals() -> void:
	multiplayer.peer_connected.connect(func(id): print("peer_connected, id: %s" % id))
	multiplayer.peer_disconnected.connect(func(id): print("peer_disconnected, id: %s" % id))
	multiplayer.connected_to_server.connect(func(): print("connected to server"))
	multiplayer.connection_failed.connect(func(): print("connected failed"))


@rpc("any_peer", "call_local")
func log_message(message: String) -> void:
	logs.append(message)
	logs_updated.emit(message)
