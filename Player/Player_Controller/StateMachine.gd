## ------------------------------------------------------------------
## StateMachine.gd — Orquestador de estados del Player
##
## Responsabilidad:
##   - Mantener UN estado activo del jugador y orquestar transiciones.
##   - Delegar input y física SOLO al estado activo (encendido/apagado).
##   - Validar transiciones en dos niveles:
##       (1) Local: allowed_transitions() del estado actual.
##       (2) Global: TransitionPolicy.can_transition(from, to, ctx).
##   - Mantener aislado al controller de temas de UI (la UI captura antes).
##
## Flujo de ejecución (orden típico en Godot por frame):
##   1) Entrada de usuario:
##        - _input(event) de nodos con foco (UI primero).
##        - _unhandled_input(event) de nodos si la UI NO consumió el evento.
##        → Aquí delegamos al estado ACTIVO: current.handle_input(event)
##
##   2) Lógica de juego en tiempo fijo:
##        - _physics_process(delta) (60 Hz por defecto)
##        → Aquí llamamos current.update(delta) del estado ACTIVO.
##        → El estado ajusta actor.velocity, flags, y puede pedir transiciones.
##
##   3) Movimiento del cuerpo:
##        - En PlayerController (padre) se invoca move_and_slide().
##        → Usa la velocity que setearon los estados en el paso 2.
##
## Decisiones de diseño:
##   - Encender/apagar _physics_process del estado evita trabajo innecesario
##     y hace trazas más limpias para docencia.
##   - Validar transiciones en dos pasos separa reglas LOCALES (propias del
##     comportamiento) de políticas GLOBALES (stun, locks, contexto del juego).
##   - La UI no toca este nodo: si la UI tiene foco, los eventos nunca llegan.
## ------------------------------------------------------------------
class_name StateMachine
extends Node

@export var policy: NodePath            ## → TransitionPolicy (opcional). Valida reglas globales.
@export var animation_manager: NodePath ## → AnimationManager (contrato abstracto). Inyectado a cada State.

@onready var actor := get_parent() as CharacterBody2D  ## PlayerController (padre). El State lo manipula.
@onready var animation := get_parent() as AnimatedSprite2D  ## PlayerController (padre). El State lo manipula.
@onready var _states_root := $States                   ## Carpeta de hijos-estado por convención.
var _policy_ref: Node = null
var _anim_ref: Node = null

var current: State = null  ## Referencia al estado ACTIVO (único que procesa input y update).

func _ready():
	## _ready() se ejecuta una vez cuando el nodo entra al árbol de escenas.
	## Objetivo: resolver dependencias, inyectarlas en estados y definir el estado inicial.

	# 1) Resolver referencias exportadas (si las configuró el diseñador)
	if policy != NodePath():
		_policy_ref = get_node_or_null(policy)
	if animation_manager != NodePath():
		_anim_ref = get_node_or_null(animation_manager)

	# 2) Inyectar dependencias a TODOS los estados y apagarlos (sin física)
	#    - machine: esta StateMachine (para request/can_request)
	#    - actor:   el CharacterBody2D (donde se escribe velocity, etc.)
	#    - anim:    AnimationManager (puede ser null; controller es agnóstico)
	for child in _states_root.get_children():
		if child is State:
			child.machine = self
			child.actor = actor
			child.anim = _anim_ref
			# Importante: solo el estado ACTIVO debe procesar física.
			child.set_physics_process(false)

	# 3) Elegir estado inicial (convención: un hijo llamado "Idle")
	var initial: State = _get_state_node(&"Idle")
	if initial == null:
		# Si no existe "Idle", toma el primer estado disponible.
		# (Mensaje educativo para detectar configuración incompleta).
		push_warning("StateMachine: No se encontró estado inicial 'Idle'. Usando el primero disponible.")
		initial = _first_state_or_null()

	# 4) Activar estado inicial: llama enter(), enciende su _physics_process
	if initial:
		_set_state(initial, {})

func _unhandled_input(event: InputEvent) -> void:
	## _unhandled_input sucede DESPUÉS de que la UI tuvo oportunidad de consumir el evento.
	## Si la UI está activa, los eventos no llegan aquí (aislamiento Controller/UI).
	## Si llegan, son "input de avatar". Delegamos al estado ACTIVO para interpretación contextual.
	if current:
		current.handle_input(event)

func _physics_process(delta: float) -> void:
	## _physics_process corre en timestep fijo (por defecto 60 Hz).
	## Delegamos al estado ACTIVO su lógica de física (aceleración, saltos, timers),
	## que usualmente ajusta actor.velocity y puede solicitar transiciones.
	if current:
		current.update(delta)

## --------------------------------------------------------------
## API de transición
## --------------------------------------------------------------
func can_transition_to(to_id: StringName, ctx: Dictionary = {}) -> bool:
	## Consulta NO-destructiva: "¿sería válido ir al estado 'to_id'?"
	## Uso típico: un State puede chequear ventanas/cancel sin provocar cambios.
	##
	## Orden de validación:
	##   (1) Regla LOCAL del estado actual: allowed_transitions()
	##       → Mantiene el grafo claro por archivo/estado (didáctico).
	##   (2) Regla GLOBAL: TransitionPolicy (si existe)
	##       → Aplica locks/prioridades contextuales (stun, cutscene, tags).
	if current == null:
		return true  # En bootstrap (sin estado), permitir.

	# (1) Local
	if to_id not in current.allowed_transitions():
		return false

	# (2) Global
	if _policy_ref and _policy_ref.has_method("can_transition"):
		return _policy_ref.can_transition(current.id(), to_id, ctx)

	return true  # Sin política global, aceptar.

func request_transition(to_id: StringName, ctx: Dictionary = {}) -> bool:
	## Solicitud EFECTIVA de transición. La invocan los States cuando quieren cambiar.
	## Pasos:
	##   A) Evitar no-ops (solicitar el mismo estado).
	##   B) Validar con can_transition_to() (local + global).
	##   C) Resolver el nodo destino y aplicar el cambio con _set_state().
	##
	## Devuelve true si la transición se realizó; false si fue rechazada.
	if current and to_id == current.id():
		return false  # Nada que hacer: ya estamos en ese estado.

	if !can_transition_to(to_id, ctx):
		# Log didáctico: ayuda a depurar por qué no se pudo transicionar
		# (regla local no permite / política global lo bloqueó).
		push_warning("Transición rechazada: %s -> %s (por reglas local/global)" % [current and current.id() or "<null>", to_id])
		return false

	var target: State = _get_state_node(to_id)
	if target == null:
		# Error de configuración: nombre mal escrito o nodo faltante.
		push_error("StateMachine: Estado destino no encontrado: %s" % to_id)
		return false

	_set_state(target, ctx)
	return true

## --------------------------------------------------------------
## Internals — Cambios de estado y utilidades privadas
## --------------------------------------------------------------
func _set_state(next: State, msg: Dictionary) -> void:
	## Aplica la transición:
	##   1) Apaga física del estado saliente y llama exit() (orden de limpieza).
	##   2) Cambia current.
	##   3) Enciende física del entrante y llama enter(msg) (orden de inicialización).
	##
	## Importante:
	##   - Mantener este orden evita frames "a caballo" entre estados.
	##   - enter()/exit() son los lugares correctos para side-effects (p. ej. activar/desactivar hitboxes).
	if current:
		current.set_physics_process(false)
		current.exit()

	current = next

	current.set_physics_process(true)
	current.enter(msg)

func _get_state_node(id_name: StringName) -> State:
	## Busca un hijo bajo "States" cuyo nombre coincida con id_name.
	## Requisito: los estados deben llamarse por su nombre de nodo (Idle, Walk, Jump, etc.).
	var node = _states_root.get_node_or_null(String(id_name))
	if node is State:
		return node
	return null

func _first_state_or_null() -> State:
	## Fallback educativo: devuelve el primer hijo que sea State.
	## Útil para prototipos si aún no existe un "Idle" formal.
	for child in _states_root.get_children():
		if child is State:
			return child
	return null
