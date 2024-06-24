extends Node3D

@onready var animationPlayer = get_node("FPSRig/AnimationPlayer")
@onready var pistol = $FPSRig/Pistol
@onready var assault_rifle = $FPSRig/AssaultRifle
@onready var shotgun = $FPSRig/Shotgun

var currentWeapon = null

@export var _weaponResources: Array[Weapon_Resource]

@export var _starterWeapon: Weapon_Resource

func _ready():
	Initialize()
	
func _input(event):
	
	if event.is_action_pressed("shoot") and (animationPlayer.current_animation != currentWeapon.Shoot_Anim) \
	and currentWeapon == _weaponResources[0]:
		animationPlayer.queue(currentWeapon.Shoot_Anim)
	
	if event.is_action_pressed("get_pistol") and currentWeapon != _weaponResources[0]:
			ChangeWeapon("pistol")
	
	if event.is_action_pressed("get_rifle") and currentWeapon != _weaponResources[1]:
			ChangeWeapon("rifle")
	
	if event.is_action_pressed("get_shotgun") and currentWeapon != _weaponResources[2]:
			ChangeWeapon("shotgun")

func Initialize():
	currentWeapon = _weaponResources[0]
	pistol.show()
	assault_rifle.hide()
	shotgun.hide()
	gotWeapon()

func gotWeapon():
	animationPlayer.play(currentWeapon.Pickup_Anim)

func switchedWeapon():
	animationPlayer.play_backwards(currentWeapon.Switch_Anim)

func ChangeWeapon(newWeapon: String):
	match newWeapon:
		"shotgun":
			switchedWeapon()
			currentWeapon = _weaponResources[2]
			pistol.hide()
			assault_rifle.hide()
			shotgun.show()
			gotWeapon()
		"rifle":
			switchedWeapon()
			currentWeapon = _weaponResources[1]
			pistol.hide()
			assault_rifle.show()
			shotgun.hide()
			gotWeapon()
		"pistol":
			switchedWeapon()
			currentWeapon = _weaponResources[0]
			pistol.show()
			assault_rifle.hide()
			shotgun.hide()
			gotWeapon()
