extends Node

var weapons: Array = []
var gifts: Array = []
var player_weapons: Array = []
var player_accessories: Array = []
var current_character: Dictionary = {
	"id": "ban_chan",
	"baseStats": {"hp": 100, "moveSpeed": 5.0, "dashCooldown": 1.2, "pickupRange": 1.0}
}
var current_character_id := "ban_chan"
var current_weapon: Dictionary = {}
var current_weapon_id := "ban_hammer"
var exp_level := 1
var player_max_hp := 100
var player_hp := 100
var permanent_upgrade_snapshot = null
var mini_humidifier_level := 0
var mini_humidifier_timer := 0.0
var mini_humidifier_hurt_cooldown := 0.0
var equipment_damage_rate := 1.0
var equipment_range_rate := 1.0
var equipment_interval_rate := 1.0
var equipment_bullet_support_level := 0
var notification_bell_level := 0
var hammer_damage := 12.0
var hammer_range := 180.0
var hammer_interval := 0.85
var knockback_power := 27.0
var player_speed := 255.0
var dash_cooldown := 1.2
var comment_radar_level := 0
var comment_radar_range_bonus := 0.0
var item_magnet_speed_rate := 1.0
var magnet_range := 95.0
var sweet_tooth_level := 0
var superchat_level := 0
var boomerang_level := 0

var player_bullets: Array = []
var enemy_bullets: Array = []
var enemies: Array = []
var destructibles: Array = []
var hit_fx: Array = []
var equipment_weapon_timers: Dictionary = {}
var boomerang_hits: Dictionary = {}
var lastWeaponRuntimeCleanupReason := ""

var active_effects: Array = []
var active_effect_rates: Dictionary = {}
var modifier_sources: Dictionary = {}
