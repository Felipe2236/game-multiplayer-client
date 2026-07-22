extends Node

var socket = WebSocketPeer.new()
var websocket_url = "ws://localhost:8080"

@onready var mi_jugador = $MiJugador
@onready var otro_jugador = $OtroJugador

var mi_rol := ""

# Variables para guradar las posiciones objetivo (hacia donde deben deslizarse)
var pos_objetivo_mario: Vector2
var pos_objetivo_luigi: Vector2

func _ready():
	socket.connect_to_url(websocket_url)
	pos_objetivo_mario = mi_jugador.position
	pos_objetivo_luigi = otro_jugador.position

func _process(delta):
	socket.poll()
	var state = socket.get_ready_state()
	
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count() > 0:
			var packet = socket.get_packet()
			var json_string = packet.get_string_from_utf8()
			
			# Parsear la información recibida como JSON
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			if parse_result == OK:
				var datos = json.data
				
				# CASO 1: El servidor nos asigna un rol
				print(datos)
				if datos.has("tipo") and datos.tipo == "asignar_rol":
					mi_rol = datos.rol
					print("¡Soy el jugador: ", mi_rol, "!")
				
				elif datos.has("jugador"):
					actualizar_posicion_remota(datos)
	
	# INTERPOLACIÓN SUAVE: Mueve progresivamente al personaje remoto hacia su destino
	# Ajusta el valor 15.0 para hacer la transición más rápida o más lenta
	if mi_rol != "mario":
		mi_jugador.position = mi_jugador.position.lerp(pos_objetivo_mario, 15.0 * delta)
	
	if mi_rol != "luigi":
		otro_jugador.position = otro_jugador.position.lerp(pos_objetivo_luigi, 15.0 * delta)


func enviar_posicion(jugador, nueva_posicion):
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		var datos = {
			"jugador": jugador,
			"x": nueva_posicion.x,
			"y": nueva_posicion.y
		}
		var json_string = JSON.stringify(datos)
		socket.send_text(json_string)

# 2. Actualizar el personaje en pantalla cuando LLEGAN datos del servidor
func actualizar_posicion_remota(datos: Dictionary):
	if datos.has("jugador") and datos.has("x") and datos.has("y"):
		var pos = Vector2(datos.x, datos.y)
		
		# En lugar de cambiar la posición de golpe, actualizamos el objetivo
		if datos.jugador == "mario" and mi_rol != "mario":
			pos_objetivo_mario = pos
		elif datos.jugador == "luigi" and mi_rol != "luigi":
			pos_objetivo_luigi = pos
