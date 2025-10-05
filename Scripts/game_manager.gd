# creates instances of collectibles
extends Node

@export var player_path : NodePath
@onready var player_node: Node = get_node(player_path)

var placeholder : Object
var collectibles : PackedScene = load("res://Objects/Collectibles/collectibles.tscn")
var enemies : PackedScene = load("res://Entities/Enemy/Enemy.tscn")
var enemy_instance_id = 0
var collectible_instance_id = 0

var collectibles_instances = [
#	[Pointer Klon, Position beim Erstellen, Typ, Parameter]
	[placeholder, Vector2(50,150), "heal", -1], #-1 ist complete heal, alles andere nur amount
	[placeholder , Vector2(100,150), "speed", [2,20]], #speedmulti, duration
	[placeholder, Vector2(-50,150), "heal", 5],
	[placeholder, Vector2(-100,150), "haste", [0.01,10]], #changes attack_cooldown [how fast (NIE 0), duration] -> for 0 < fastness < 1 faster; above 1 slower
	[placeholder, Vector2(-150,150), "armor", [3,10]], 
	[placeholder, Vector2(-200,150), "knockback", [10,10]],
	[placeholder, Vector2(-250,150), "knockback_resistance", [0.2,10]],
	[placeholder, Vector2(-300,150), "regeneration", [1,10]]
	
]

#var enemy_location = [
	#Vector2(-100, -50), 
	#Vector2(100, -100)
	#]


func _ready() -> void:
	pass
	#for clone in collectibles_instances: #instantiate collectibles
		#var dup = collectibles.instantiate()
		#add_child(dup)
		#clone[0] = get_node(dup.get_path())
		#clone[0].position = clone[1]
		#clone[0].posy = clone[1][1]
		#clone[0].type = clone[2]
		#clone[0].parameter = clone[3]
		#clone[0].offset = randf()
		
	#for e in range(enemy_location.size()): 
		#var parent_of_player = player_node.get_parent()
		#if parent_of_player == null: print("Alarm")
		#var enemy = enemies.instantiate()
		#enemy.name = str(enemy) + str(e)
		#player_node.add_sibling.call_deferred(enemy)
		#enemy.position = enemy_location[e]
		##get_node(%player.get_path()).add_sibling.call_deferred(enemy)
		##print( str(enemy.get_path()) + "     " + str(enemy.get_parent()) + "     " + enemy.name + "     " + str(%player.get_parent()) + "     " + str(get_node(%player.get_path()) ))
		##enemy = get_node(enemy.get_path())
		##enemy.position = enemy_location[e]
	#spawn_enemy(Vector2(-100,-50),Direction.DOWN,"standard",[["health", 20], ["max_health", 20]])
	#spawn_enemy(Vector2(100,50),Direction.LEFT,"standard", [["knockback_base", 250]] ) #doppelte [[]] sind wichtig,sonst crash


func _process(delta: float) -> void:
	z_indexing()

enum Direction {LEFT, RIGHT, UP, DOWN}
func spawn_enemy(pos : Vector2, direction : Direction, type : String, spawn_parameters : Array):#, anchor_node: Node2D) :
	#parameters sind optional, wenn man vom Typ abweichende Werte wie health, speed, knockback, knockback_resistance... setzen möchte
	#if anchor_node.get_parent() == null: print("Alarm") #DEBUG
	var enemy : CharacterBody2D = enemies.instantiate()
	#anchor_node.add_sibling.call_deferred(enemy)
	enemy_instance_id += 1
	enemy.name = str(enemy) + str(enemy_instance_id)
	enemy.position = pos
	enemy.direction = Direction.DOWN
	enemy.type = type
	enemy.spawn_parameters = spawn_parameters
	print("spawned")
	print_tree()

func spawn_collectible(pos : Vector2, type : String, spawn_parameters : Array, anchor_node : Node2D) : #nur eine Methode verwenden, onready raushauen
	#anchor_node soll player_node sein
	# Fallback: falls player_path falsch ist, suche dynamisch nach Node mit Namen "Player"
	#if player_node == null:
		#player_node = get_tree().get_current_scene().find_node("Player", true, false)
	#if player_node == null:
		#push_warning("player_node nicht gefunden! player_path korrekt setzen oder Player in Scene vorhanden?")
	var col = collectibles.instantiate()
	if anchor_node.get_parent() == null: print("Alarm") #DEBUG
	anchor_node.add_sibling(col)
	#col = get_node(col.get_path())
	col.position = pos
	print("collectible spawned    " + str(col.position) + "   Type:" + str(type))
	col.posy = pos.y
	col.type = type
	col.parameter = spawn_parameters
	col.offset = randf()

# z indexing
func z_indexing() -> void: 
	var characters : Array = []
	for child in get_children():
		if child is CharacterBody2D:
			characters.append([child, child.position.y])
	characters.sort_custom(sort_ascending)
	#print(characters)
	
	var z = 100 #0 bis 100 ist immer ganz unten, danach bitt mit 1000 weitermachen
	for c in characters:
		c[0].z_index = z
		z += 1
	
func sort_ascending(a, b): #Für custom sorting
	if a[1] < b[1]:
		return true
	return false

#func z_indexing() -> void: 
	#var zlist : Array = get_parent().get_children()
	#var n = 0
	# var zlist_size = zlist.size()
	#for i in range(zlist_size): #alle nicht sichtbaren dinge, deren z index angepasst werden muss, löschen
		#if zlist[n].get_class() != "CharacterBody2D":
			#zlist.pop_at(n)
			#n -= 1
		#else: 
			#zlist[n] = 1 #[zlist[n].position.y, zlist[n]]
			##print(zlist[n])
		#n += 1
	##for i in range(zlist.size()):
		##zlist[i] = 1#[zlist[i].position.y, zlist[i]]
	##var zlist_y = []
	##for i in range(zlist.size()):
		##zlist_y.append(zlist[i][0])
	##for i in range(zlist.size()):
		##zlist_y.find(max(zlist_y))
	#print(zlist)
	#pass
