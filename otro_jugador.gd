extends CharacterBody2D

var velocidad = 200
var ultima_posicion_enviada: Vector2 = Vector2.ZERO

var tiempo_acumulado: float = 0.0
var intervalo_envio: float = 0.01

func _process(delta):
	# Si NO somos Luigi en esta ventana, ignoramos la entrada de teclas
	if get_parent().mi_rol != "luigi":
		return
	
	var movimiento = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"): movimiento.x += 1
	if Input.is_action_pressed("ui_left"): movimiento.x -= 1
	if Input.is_action_pressed("ui_down"): movimiento.y += 1
	if Input.is_action_pressed("ui_up"): movimiento.y -= 1
	
	if movimiento != Vector2.ZERO:
		position += movimiento.normalized() * velocidad * delta
	
	tiempo_acumulado += delta
	if tiempo_acumulado >= intervalo_envio:
		tiempo_acumulado = 0.0
		if position != ultima_posicion_enviada:
			get_parent().enviar_posicion("luigi", position)
			ultima_posicion_enviada = position
