extends Node

var weapons: Array = []
var player_weapons: Array = []
var current_character: Dictionary = {}
var current_character_id: String = ""
var current_weapon: Dictionary = {}
var current_weapon_id: String = ""
var exp_level: int = 1
var equipment_weapon_timers: Dictionary = {}
var hit_fx: Array = []
var enemies: Array = []
var lastWeaponRuntimeCleanupReason: String = ""
