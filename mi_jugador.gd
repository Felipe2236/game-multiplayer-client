extends CharacterBody2D

var velocidad = 200
var ultima_posicion_enviada := Vector2.ZERO

# Control de Tiempo (Tick Rate)
var tiempo_acumulado := 0.0
var intervalo_envio := 0.01 # 0.05s = 20 paquetes por segundo

func _process(delta):
	# Si NO somos Mario en esta ventana, ignoramos la entrada de teclas
	if get_parent().mi_rol != "mario":
		return
	
	var movimiento = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"): movimiento.x += 1
	if Input.is_action_pressed("ui_left"): movimiento.x -= 1
	if Input.is_action_pressed("ui_down"): movimiento.y += 1
	if Input.is_action_pressed("ui_up"): movimiento.y -= 1
	
	if movimiento != Vector2.ZERO:
		position += movimiento.normalized() * velocidad * delta
		
	# Lógica de optimización de red
	tiempo_acumulado += delta
	if tiempo_acumulado >= intervalo_envio:
		tiempo_acumulado = 0.0
		# Solo enviamos si el personaje se ha movido desde el último envío
		if position != ultima_posicion_enviada:
			get_parent().enviar_posicion("mario", position) # o self, o un ID
			ultima_posicion_enviada = position
