class_name FieldPickupVisualSystem
extends RefCounted

const ICON_DIR := "res://assets/generated/field_pickup_icons_v1/icons"

const CARE_PACKAGE_BOX_ICON := ICON_DIR + "/care_package_box.png"

const DROP_ICON_PATHS := {
	"heal_drink": ICON_DIR + "/heal_drink.png",
	"heart_drop": ICON_DIR + "/heart_drop.png",
	"viewer_boost": ICON_DIR + "/viewer_boost.png"
}

static func care_package_box_icon_path() -> String:
	return CARE_PACKAGE_BOX_ICON

static func drop_item_icon_path(id: String) -> String:
	return String(DROP_ICON_PATHS.get(id, ""))
