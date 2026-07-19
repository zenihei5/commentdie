class_name PowerUpShopScreen
extends Control

signal closed(origin: String)

const PowerUpShopManager := preload("res://scripts/systems/power_up_shop_manager.gd")
const CardScene := preload("res://scripts/ui/power_up_shop_card.tscn")
const UiState := preload("res://scripts/ui/power_up_shop_ui_state.gd")
const VisualStyle := preload("res://scripts/ui/power_up_shop_visual_style.gd")

const CATEGORIES := ["combat", "support"]
const CARD_COLUMNS := 2
const STICK_DEADZONE := 0.55
const STICK_REPEAT_DELAY := 0.24
const STICK_REPEAT_INTERVAL := 0.14

enum FocusArea {
	CARDS,
	RESET,
	RESET_DIALOG,
	CATEGORY_TABS,
}

enum DialogChoice {
	CONFIRM,
	CANCEL,
}

enum FooterChoice {
	BACK,
	RESET,
}

@onready var background: TextureRect = $FullScreenBackground
@onready var shop_content: VBoxContainer = $SafeAreaMargin/MainCenter/ShopContent
@onready var header: HBoxContainer = $SafeAreaMargin/MainCenter/ShopContent/Header
@onready var english_title: Label = $SafeAreaMargin/MainCenter/ShopContent/Header/TitleArea/EnglishTitle
@onready var title_label: Label = $SafeAreaMargin/MainCenter/ShopContent/Header/TitleArea/Title
@onready var progress_row: HBoxContainer = $SafeAreaMargin/MainCenter/ShopContent/Header/TitleArea/TotalProgressRow
@onready var progress_caption: Label = $SafeAreaMargin/MainCenter/ShopContent/Header/TitleArea/TotalProgressRow/Caption
@onready var progress_value: Label = $SafeAreaMargin/MainCenter/ShopContent/Header/TitleArea/TotalProgressRow/Value
@onready var progress_bar: ProgressBar = $SafeAreaMargin/MainCenter/ShopContent/Header/TitleArea/TotalProgressRow/ProgressBar
@onready var back_button: Button = $SafeAreaMargin/MainCenter/ShopContent/Footer/FooterRow/BackButton
@onready var pp_capsule: PanelContainer = $SafeAreaMargin/MainCenter/ShopContent/Header/PpCapsule
@onready var pp_icon: TextureRect = $SafeAreaMargin/MainCenter/ShopContent/Header/PpCapsule/PpRow/Icon
@onready var pp_value: Label = $SafeAreaMargin/MainCenter/ShopContent/Header/PpCapsule/PpRow/Value
@onready var combat_tab: Button = $SafeAreaMargin/MainCenter/ShopContent/CategoryTabs/CombatTab
@onready var support_tab: Button = $SafeAreaMargin/MainCenter/ShopContent/CategoryTabs/SupportTab
@onready var card_grid: GridContainer = $SafeAreaMargin/MainCenter/ShopContent/Body/CardSection/CardGrid
@onready var detail_panel: PanelContainer = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel
@onready var detail_margin: Control = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin
@onready var detail_accent_band: ColorRect = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/DetailAccentBand
@onready var hero_section: Control = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/HeroSection
@onready var combat_hero_background: ColorRect = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/HeroSection/CombatHeroBackground
@onready var support_hero_background: ColorRect = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/HeroSection/SupportHeroBackground
@onready var hero_pattern: Control = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/HeroSection/HeroPattern
@onready var information_section: PanelContainer = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/InformationSection
@onready var information_margin: Control = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/InformationSection/InformationMargin
@onready var detail_content: VBoxContainer = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/InformationSection/InformationMargin/DetailContent
@onready var detail_category_tag: PanelContainer = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/HeroSection/HeroRow/HeroCopy/CategoryTag
@onready var detail_category_label: Label = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/HeroSection/HeroRow/HeroCopy/CategoryTag/Label
@onready var detail_icon_plate: PanelContainer = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/HeroSection/HeroRow/IconStage/IconSlotLarge/IconPlateLarge
@onready var detail_icon: TextureRect = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/HeroSection/HeroRow/IconStage/IconSlotLarge/IconPlateLarge/LargeIcon
@onready var icon_glow_plate: PanelContainer = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/HeroSection/HeroRow/IconStage/IconGlowPlate
@onready var detail_name: Label = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/HeroSection/HeroRow/HeroCopy/Name
@onready var detail_level: Label = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/HeroSection/HeroRow/HeroCopy/Level
@onready var detail_level_gauge: HBoxContainer = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/HeroSection/HeroRow/HeroCopy/DetailLevelGauge
@onready var detail_hero_row: HBoxContainer = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/HeroSection/HeroRow
@onready var detail_icon_stage: CenterContainer = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/HeroSection/HeroRow/IconStage
@onready var detail_description: Label = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/InformationSection/InformationMargin/DetailContent/Description
@onready var target_tags: HFlowContainer = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/InformationSection/InformationMargin/DetailContent/TargetTags
@onready var comparison_current: Label = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/InformationSection/InformationMargin/DetailContent/EffectComparison/CurrentEffectBox/CurrentContent/Value
@onready var comparison_next: Label = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/InformationSection/InformationMargin/DetailContent/EffectComparison/NextEffectBox/NextContent/Value
@onready var comparison_current_box: PanelContainer = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/InformationSection/InformationMargin/DetailContent/EffectComparison/CurrentEffectBox
@onready var comparison_next_box: PanelContainer = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/InformationSection/InformationMargin/DetailContent/EffectComparison/NextEffectBox
@onready var required_point_row: HBoxContainer = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/InformationSection/InformationMargin/DetailContent/RequiredPointRow
@onready var required_point_caption: Label = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/InformationSection/InformationMargin/DetailContent/RequiredPointRow/RequiredCaption
@onready var required_point_value: Label = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/InformationSection/InformationMargin/DetailContent/RequiredPointRow/RequiredValue
@onready var owned_or_shortage: Label = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/InformationSection/InformationMargin/DetailContent/RequiredPointRow/OwnedOrShortage
@onready var purchase_button: Button = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/InformationSection/InformationMargin/DetailContent/PurchaseAndMascotRow/PurchaseButton
@onready var purchase_and_mascot_row: HBoxContainer = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/InformationSection/InformationMargin/DetailContent/PurchaseAndMascotRow
@onready var mascot_presentation: Control = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/InformationSection/InformationMargin/MascotPresentation
@onready var mascot: TextureRect = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/InformationSection/InformationMargin/MascotPresentation/Mascot
@onready var mascot_glow: ColorRect = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/InformationSection/InformationMargin/MascotPresentation/MascotGlow
@onready var speech_bubble: PanelContainer = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/InformationSection/InformationMargin/MascotPresentation/SpeechBubble
@onready var mascot_message: Label = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/InformationSection/InformationMargin/MascotPresentation/SpeechBubble/Message
@onready var mascot_state_decoration: Label = $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/InformationSection/InformationMargin/MascotPresentation/MascotStateDecoration
@onready var room_decoration_layer: Control = $BackgroundDecoration/RoomDecorationLayer
@onready var category_background: Control = $BackgroundDecoration/RoomDecorationLayer
@onready var combat_decoration: Control = $BackgroundDecoration/RoomDecorationLayer/CombatRoomDecoration
@onready var support_decoration: Control = $BackgroundDecoration/RoomDecorationLayer/SupportRoomDecoration
@onready var purchase_light: TextureRect = $PurchaseLight
@onready var reset_button: Button = $SafeAreaMargin/MainCenter/ShopContent/Footer/FooterRow/ResetButton
@onready var input_hints: Label = $SafeAreaMargin/MainCenter/ShopContent/Footer/FooterRow/InputHints
@onready var toast_panel: PanelContainer = $ToastLayer/ToastPanel
@onready var toast_label: Label = $ToastLayer/ToastPanel/Label
@onready var dialog_layer: Control = $DialogLayer
@onready var reset_dialog: PanelContainer = $DialogLayer/ResetDialog
@onready var reset_confirm_button: Button = $DialogLayer/ResetDialog/Content/Buttons/Confirm
@onready var reset_cancel_button: Button = $DialogLayer/ResetDialog/Content/Buttons/Cancel
@onready var cursor_se: AudioStreamPlayer = $UiSeGroup/CursorSe
@onready var purchase_se: AudioStreamPlayer = $UiSeGroup/PurchaseSe
@onready var error_se: AudioStreamPlayer = $UiSeGroup/ErrorSe
@onready var max_se: AudioStreamPlayer = $UiSeGroup/MaxSe

var manager
var origin := "title"
var category_index := 0
var selected_index := 0
var category_last_indices := [0, 0]
var reset_confirm_visible := false
var focus_area := FocusArea.CARDS
var dialog_choice := DialogChoice.CANCEL
var footer_choice := FooterChoice.BACK
var reset_return_index := 2
var last_input_device := "keyboard"
var _purchase_lock_remaining := 0.0
var _purchase_cooldown := 0.0
var _stick_direction := Vector2i.ZERO
var _stick_repeat_remaining := 0.0
var _active_tweens: Array = []
var _toast_tween: Tween
var _cards: Array = []
var _cards_by_category: Dictionary = {"combat": [], "support": []}
var _cards_by_id: Dictionary = {}
var _database_upgrades: Array = []
var _purchase_views_by_id: Dictionary = {}
var _selected_purchase_view: Dictionary = {}
var _detail_lamps: Array[PanelContainer] = []
var _pending_upgrade_id := ""
var _pending_new_level := -1
var _pending_card: PowerUpShopCard
var _pending_previous_view: Dictionary = {}
var _purchase_input_lock_remaining := 0.0
var _purchase_light_tween: Tween
var _mascot_tween: Tween
var _mascot_message_tween: Tween
var _mascot_default_texture: Texture2D
var _mascot_upgrade_id := ""
var _mascot_generation := 0
var _mascot_presentation_state := UiState.MascotState.IDLE
var _mascot_messages: Dictionary = {}
var purchase_api_call_count := 0

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	background.texture = VisualStyle.background_texture()
	for child in detail_level_gauge.get_children():
		var lamp: PanelContainer = child as PanelContainer
		if lamp != null:
			_detail_lamps.append(lamp)
	_mascot_default_texture = load("res://assets/generated/weapon_fx_v1/listener_summon.png") as Texture2D
	mascot.texture = _mascot_default_texture
	_mascot_messages = manager.database.mascot_messages.duplicate(true) if manager != null and manager.database != null else {}
	purchase_light.texture = load("res://assets/generated/gameplay_event_objects_v1/coin.png") as Texture2D
	combat_decoration.modulate = Color.WHITE
	support_decoration.modulate = Color(1, 1, 1, 0)
	_apply_static_styles()
	_connect_ui()
	_hide_dialog()
	_hide_toast()
	dialog_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	hide()
	call_deferred("_layout_responsive")

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_node_ready():
		call_deferred("_layout_responsive")

func _process(delta: float) -> void:
	if not visible:
		return
	var was_locked := _purchase_lock_remaining > 0.0
	var was_input_locked := _purchase_input_lock_remaining > 0.0
	_purchase_lock_remaining = maxf(0.0, _purchase_lock_remaining - delta)
	_purchase_input_lock_remaining = maxf(0.0, _purchase_input_lock_remaining - delta)
	_purchase_cooldown = maxf(0.0, _purchase_cooldown - delta)
	if _stick_direction != Vector2i.ZERO:
		_stick_repeat_remaining = maxf(0.0, _stick_repeat_remaining - delta)
		if _stick_repeat_remaining <= 0.0 and _purchase_input_lock_remaining <= 0.0:
			_move_cursor(_stick_direction, "gamepad")
			_stick_repeat_remaining = STICK_REPEAT_INTERVAL
	if was_locked and _purchase_lock_remaining <= 0.0:
		_update_detail()
	if was_input_locked and _purchase_input_lock_remaining <= 0.0:
		_refresh_focus_visuals()

func bind_manager(value) -> void:
	manager = value
	if manager == null:
		return
	_mascot_messages = manager.database.mascot_messages.duplicate(true) if manager.database != null else {}
	if not manager.points_changed.is_connected(_on_manager_changed):
		manager.points_changed.connect(_on_manager_changed)
	if not manager.upgrade_purchased.is_connected(_on_upgrade_purchased):
		manager.upgrade_purchased.connect(_on_upgrade_purchased)
	if not manager.upgrades_reset.is_connected(_on_reset):
		manager.upgrades_reset.connect(_on_reset)
	if not manager.purchase_failed.is_connected(_on_purchase_failed):
		manager.purchase_failed.connect(_on_purchase_failed)
	if is_node_ready():
		_refresh_view()

func open_shop(new_origin: String, value) -> bool:
	bind_manager(value)
	if manager == null or not manager.is_available():
		return false
	origin = new_origin
	category_index = 0
	selected_index = category_last_indices[category_index]
	_reset_transient_state()
	focus_area = FocusArea.CARDS
	last_input_device = "keyboard"
	show()
	_layout_responsive()
	_refresh_view()
	grab_focus()
	_animate_show()
	return true

func close_shop() -> void:
	if not visible:
		return
	_reset_transient_state()
	hide()
	closed.emit(origin)

func _connect_ui() -> void:
	back_button.pressed.connect(close_shop)
	combat_tab.pressed.connect(_on_category_pressed.bind(0))
	support_tab.pressed.connect(_on_category_pressed.bind(1))
	purchase_button.pressed.connect(_on_purchase_pressed)
	reset_button.pressed.connect(_show_reset_dialog)
	reset_confirm_button.pressed.connect(_on_reset_confirm_button_pressed)
	reset_cancel_button.pressed.connect(_on_reset_cancel_button_pressed)
	VisualStyle.apply_button_theme(back_button, VisualStyle.PRIMARY, VisualStyle.SECONDARY)
	VisualStyle.apply_button_theme(purchase_button, VisualStyle.PRIMARY, VisualStyle.SECONDARY)
	VisualStyle.apply_button_theme(reset_button, VisualStyle.PRIMARY, VisualStyle.SECONDARY)
	VisualStyle.apply_button_theme(reset_confirm_button, VisualStyle.COMBAT_DARK, VisualStyle.COMBAT)
	VisualStyle.apply_button_theme(reset_cancel_button, VisualStyle.SECONDARY, VisualStyle.CARD_SUBTLE)

func _apply_static_styles() -> void:
	VisualStyle.apply_font(english_title, 14, true, VisualStyle.COMBAT)
	VisualStyle.apply_font(title_label, 30, true, VisualStyle.TEXT_LIGHT)
	VisualStyle.apply_font(progress_caption, 12, true, VisualStyle.TEXT_LIGHT)
	VisualStyle.apply_font(progress_value, 15, true, VisualStyle.PP)
	VisualStyle.apply_font(pp_value, 28, true, VisualStyle.PP)
	VisualStyle.apply_font($SafeAreaMargin/MainCenter/ShopContent/Header/PpCapsule/PpRow/Caption, 17, true, VisualStyle.TEXT_LIGHT)
	VisualStyle.apply_font(combat_tab, 17, true, VisualStyle.TEXT_LIGHT)
	VisualStyle.apply_font(support_tab, 17, true, VisualStyle.TEXT_LIGHT)
	VisualStyle.apply_font(detail_category_label, 14, true, VisualStyle.COMBAT_DARK)
	VisualStyle.apply_font(detail_name, 22, true, VisualStyle.TEXT_DARK)
	VisualStyle.apply_font(detail_level, 15, false, VisualStyle.SECONDARY)
	VisualStyle.apply_font(detail_description, 15, false, VisualStyle.SECONDARY)
	VisualStyle.apply_font(comparison_current, 22, true, VisualStyle.TEXT_DARK)
	VisualStyle.apply_font(comparison_next, 24, true, VisualStyle.COMBAT_DARK)
	VisualStyle.apply_font(comparison_current_box.get_node("CurrentContent/Caption") as Label, 13, false, VisualStyle.SECONDARY)
	VisualStyle.apply_font(comparison_next_box.get_node("NextContent/Caption") as Label, 13, false, VisualStyle.COMBAT_DARK)
	VisualStyle.apply_font(detail_content.get_node("EffectComparison/Arrow") as Label, 20, true, VisualStyle.SECONDARY)
	VisualStyle.apply_font(required_point_caption, 14, false, VisualStyle.SECONDARY)
	VisualStyle.apply_font(required_point_value, 15, true, VisualStyle.PP_DARK)
	VisualStyle.apply_font(owned_or_shortage, 15, true, VisualStyle.SECONDARY)
	VisualStyle.apply_font(mascot_message, 14, true, VisualStyle.TEXT_DARK)
	VisualStyle.apply_font(mascot_state_decoration, 24, true, VisualStyle.PP_DARK)
	VisualStyle.apply_font(input_hints, 13, false, VisualStyle.TEXT_LIGHT)
	VisualStyle.apply_font(toast_label, 16, true, VisualStyle.TEXT_LIGHT)
	detail_panel.add_theme_stylebox_override("panel", VisualStyle.rounded_panel(VisualStyle.DETAIL, VisualStyle.SECONDARY, 1, 10))
	information_section.add_theme_stylebox_override("panel", VisualStyle.rounded_panel(VisualStyle.DETAIL, Color("#E6DFF0"), 1, 8))
	detail_icon_plate.add_theme_stylebox_override("panel", VisualStyle.compact_panel(VisualStyle.CARD_SUBTLE, VisualStyle.COMBAT, 2, 20, 0, 0))
	icon_glow_plate.add_theme_stylebox_override("panel", VisualStyle.compact_panel(Color("#FFF5D0"), VisualStyle.PP, 2, 40, 0, 0))
	detail_category_tag.add_theme_stylebox_override("panel", VisualStyle.compact_panel(Color("#FFFFFF"), VisualStyle.COMBAT, 1, 12, 8, 3))
	speech_bubble.add_theme_stylebox_override("panel", VisualStyle.rounded_panel(Color("#FFFFFF"), VisualStyle.COMBAT, 2, 14))
	detail_accent_band.color = VisualStyle.COMBAT
	comparison_current_box.add_theme_stylebox_override("panel", VisualStyle.rounded_panel(VisualStyle.CARD_SUBTLE, Color("#D5CAE5"), 1, 14))
	comparison_next_box.add_theme_stylebox_override("panel", VisualStyle.rounded_panel(VisualStyle.PRICE_FILL, VisualStyle.PP, 1, 14))
	pp_capsule.add_theme_stylebox_override("panel", VisualStyle.rounded_panel(VisualStyle.PRIMARY, VisualStyle.PP_DARK, 2, 24))
	progress_bar.add_theme_stylebox_override("background", VisualStyle.progress_style(VisualStyle.PROGRESS_TRACK, Color.TRANSPARENT))
	progress_bar.add_theme_stylebox_override("fill", VisualStyle.progress_style(VisualStyle.COMBAT, VisualStyle.COMBAT))
	$SafeAreaMargin/MainCenter/ShopContent/Footer.add_theme_stylebox_override("panel", VisualStyle.rounded_panel(Color("#1D1838"), VisualStyle.SECONDARY, 1, 12))
	toast_panel.add_theme_stylebox_override("panel", VisualStyle.rounded_panel(VisualStyle.PRIMARY, VisualStyle.PP, 2, 20))
	reset_dialog.add_theme_stylebox_override("panel", VisualStyle.rounded_panel(VisualStyle.DETAIL, VisualStyle.COMBAT, 3, 18))
	detail_content.get_node("RequiredPointRow/PpIcon").texture = load("res://assets/generated/gameplay_event_objects_v1/coin.png") as Texture2D
	pp_icon.texture = load("res://assets/generated/gameplay_event_objects_v1/coin.png") as Texture2D
	VisualStyle.apply_tab_theme(combat_tab, true, VisualStyle.COMBAT, VisualStyle.COMBAT_DARK)
	VisualStyle.apply_tab_theme(support_tab, false, VisualStyle.SUPPORT, VisualStyle.SUPPORT_DARK)

func _layout_responsive() -> void:
	if not is_node_ready():
		return
	var viewport_size := size if size.x > 0.0 and size.y > 0.0 else get_viewport_rect().size
	var content_width := clampf(viewport_size.x - 48.0, 1180.0, 1360.0)
	var content_height := clampf(viewport_size.y - 40.0, 648.0, 900.0)
	shop_content.custom_minimum_size = Vector2(content_width, content_height)
	var compact := viewport_size.x < 1440.0 or viewport_size.y < 820.0
	var header_height := 68.0 if compact else 80.0
	var header_gap := 12.0 if compact else 20.0
	var tabs_gap := 20.0 if compact else 24.0
	var body_height := 466.0 if compact else 560.0
	var footer_gap := 8.0 if compact else 12.0
	var footer_height := 60.0 if compact else 64.0
	header.custom_minimum_size.y = header_height
	$SafeAreaMargin/MainCenter/ShopContent/HeaderToTabsGap.custom_minimum_size.y = header_gap
	$SafeAreaMargin/MainCenter/ShopContent/TabsToBodyGap.custom_minimum_size.y = tabs_gap
	$SafeAreaMargin/MainCenter/ShopContent/Body.custom_minimum_size.y = body_height
	$SafeAreaMargin/MainCenter/ShopContent/BodyToFooterGap.custom_minimum_size.y = footer_gap
	$SafeAreaMargin/MainCenter/ShopContent/Footer.custom_minimum_size.y = footer_height
	var body := $SafeAreaMargin/MainCenter/ShopContent/Body as HBoxContainer
	var card_section := $SafeAreaMargin/MainCenter/ShopContent/Body/CardSection as VBoxContainer
	var grid := $SafeAreaMargin/MainCenter/ShopContent/Body/CardSection/CardGrid as GridContainer
	var detail := $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel as PanelContainer
	var detail_content := $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/InformationSection/InformationMargin/DetailContent as VBoxContainer
	var hero_row := $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/HeroSection/HeroRow as HBoxContainer
	var icon_slot_large := $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/HeroSection/HeroRow/IconStage/IconSlotLarge as CenterContainer
	var icon_plate_large := $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/HeroSection/HeroRow/IconStage/IconSlotLarge/IconPlateLarge as PanelContainer
	var large_icon := $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/HeroSection/HeroRow/IconStage/IconSlotLarge/IconPlateLarge/LargeIcon as TextureRect
	var icon_stage := $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/HeroSection/HeroRow/IconStage as CenterContainer
	var icon_glow := $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/HeroSection/HeroRow/IconStage/IconGlowPlate as PanelContainer
	var gauge := $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/HeroSection/HeroRow/HeroCopy/DetailLevelGauge as HBoxContainer
	var effect_comparison := $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/InformationSection/InformationMargin/DetailContent/EffectComparison as HBoxContainer
	var current_effect_box := $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/InformationSection/InformationMargin/DetailContent/EffectComparison/CurrentEffectBox as PanelContainer
	var next_effect_box := $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/InformationSection/InformationMargin/DetailContent/EffectComparison/NextEffectBox as PanelContainer
	var description := $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/InformationSection/InformationMargin/DetailContent/Description as Label
	var tags := $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/InformationSection/InformationMargin/DetailContent/TargetTags as HFlowContainer
	var required_row := $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/InformationSection/InformationMargin/DetailContent/RequiredPointRow as HBoxContainer
	var detail_purchase := $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/InformationSection/InformationMargin/DetailContent/PurchaseAndMascotRow/PurchaseButton as Button
	var purchase_row := $SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/InformationSection/InformationMargin/DetailContent/PurchaseAndMascotRow as HBoxContainer
	body.add_theme_constant_override("separation", 28)
	card_section.custom_minimum_size.x = 580.0 if compact else 665.0
	detail.custom_minimum_size.x = 605.0 if compact else minf(650.0, content_width - 693.0)
	grid.add_theme_constant_override("h_separation", 16 if compact else 18)
	grid.add_theme_constant_override("v_separation", 16 if compact else 18)
	detail_content.add_theme_constant_override("separation", 5 if compact else 8)
	var hero_height := 184.0 if compact else 214.0
	var info_height := 282.0 if compact else 346.0
	$SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/HeroSection.offset_bottom = hero_height
	$SafeAreaMargin/MainCenter/ShopContent/Body/DetailPanel/DetailMargin/InformationSection.offset_top = -info_height
	icon_stage.custom_minimum_size = Vector2(136, 136) if compact else Vector2(176, 176)
	icon_glow.custom_minimum_size = Vector2(128, 128) if compact else Vector2(166, 166)
	icon_slot_large.custom_minimum_size = Vector2(88, 88) if compact else Vector2(104, 104)
	icon_plate_large.custom_minimum_size = Vector2(88, 88) if compact else Vector2(104, 104)
	large_icon.custom_minimum_size = Vector2(80, 80) if compact else Vector2(96, 96)
	description.custom_minimum_size.y = 36.0 if compact else 44.0
	tags.custom_minimum_size.y = 22.0 if compact else 26.0
	effect_comparison.custom_minimum_size.y = 58.0 if compact else 72.0
	current_effect_box.custom_minimum_size.y = 58.0 if compact else 72.0
	next_effect_box.custom_minimum_size.y = 58.0 if compact else 72.0
	required_row.custom_minimum_size.y = 28.0 if compact else 32.0
	detail_purchase.custom_minimum_size.y = 52.0 if compact else 58.0
	purchase_row.custom_minimum_size.y = 56.0 if compact else 62.0
	hero_row.custom_minimum_size.y = hero_height - 28.0
	gauge.custom_minimum_size.y = 16.0 if compact else 18.0
	for lamp in _detail_lamps:
		lamp.custom_minimum_size = Vector2(16, 16) if compact else Vector2(20, 18)
	information_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	information_margin.get_node("DetailContent").offset_left = 16.0 if compact else 20.0
	information_margin.get_node("DetailContent").offset_top = 12.0 if compact else 16.0
	# Reserve the lower-right mascot column so it never covers price/comparison/button text.
	information_margin.get_node("DetailContent").offset_right = -214.0 if compact else -230.0
	information_margin.get_node("DetailContent").offset_bottom = -12.0 if compact else -14.0
	mascot_presentation.custom_minimum_size.y = 120.0 if compact else 150.0
	progress_row.custom_minimum_size.y = 22.0

func _reset_transient_state() -> void:
	_kill_tweens()
	_clear_mascot()
	_purchase_lock_remaining = 0.0
	_purchase_input_lock_remaining = 0.0
	_purchase_cooldown = 0.0
	_pending_upgrade_id = ""
	_pending_new_level = -1
	_pending_card = null
	_pending_previous_view.clear()
	reset_confirm_visible = false
	focus_area = FocusArea.CARDS
	dialog_choice = DialogChoice.CANCEL
	footer_choice = FooterChoice.BACK
	reset_return_index = clampi(selected_index, 0, 3)
	_stick_direction = Vector2i.ZERO
	_stick_repeat_remaining = 0.0
	_hide_dialog()
	_hide_toast()
	var cards_to_stop: Array = _cards_by_id.values() if not _cards_by_id.is_empty() else _cards
	for item in cards_to_stop:
		var card: PowerUpShopCard = item as PowerUpShopCard
		if card != null and is_instance_valid(card):
			card.stop_animations()
	if is_node_ready():
		header.modulate = Color.WHITE
		$SafeAreaMargin/MainCenter/ShopContent/CategoryTabs.modulate = Color.WHITE
		$SafeAreaMargin/MainCenter/ShopContent/Body.modulate = Color.WHITE
		$SafeAreaMargin/MainCenter/ShopContent/Footer.modulate = Color.WHITE
		pp_capsule.modulate = Color.WHITE
		pp_value.scale = Vector2.ONE
		purchase_button.modulate = Color.WHITE
		purchase_button.scale = Vector2.ONE
		purchase_button.position = Vector2.ZERO
		purchase_button.disabled = false
		purchase_light.hide()
		combat_decoration.modulate = Color.WHITE
		support_decoration.modulate = Color(1, 1, 1, 0)
		combat_hero_background.modulate = Color.WHITE
		support_hero_background.modulate = Color(1, 1, 1, 0)
		detail_accent_band.color = VisualStyle.COMBAT
		detail_accent_band.modulate = Color.WHITE
		_refresh_focus_visuals()

func _refresh_view(keep_category_background: bool = false) -> void:
	if not is_node_ready() or manager == null:
		return
	var points: int = int(manager.current_points())
	pp_value.text = "%d" % points
	_build_purchase_views(points)
	_ensure_card_pool()
	_refresh_cards()
	_update_total_progress()
	_update_category_styles()
	_update_detail()
	if not keep_category_background:
		_update_category_background(false)

func _build_purchase_views(points: int) -> void:
	_purchase_views_by_id.clear()
	_database_upgrades = manager.database.upgrades if manager != null and manager.database != null else []
	for item in _database_upgrades:
		var data: Dictionary = item as Dictionary
		var id := String(data.get("id", ""))
		_purchase_views_by_id[id] = UiState.build(data, int(manager.get_upgrade_level(id)), points)

func _ensure_card_pool() -> void:
	if not _cards_by_id.is_empty():
		return
	for child in card_grid.get_children():
		child.queue_free()
	_cards.clear()
	_cards_by_category = {"combat": [], "support": []}
	_cards_by_id.clear()
	for item in _database_upgrades:
		var data: Dictionary = item as Dictionary
		var category: String = String(data.get("category", "combat"))
		var card: PowerUpShopCard = CardScene.instantiate() as PowerUpShopCard
		card_grid.add_child(card)
		var category_cards: Array = _cards_by_category.get(category, []) as Array
		var index: int = category_cards.size()
		category_cards.append(card)
		_cards_by_category[category] = category_cards
		_cards_by_id[String(data.get("id", ""))] = card
		card.card_selected.connect(_on_card_selected)
		card.hover_changed.connect(_on_card_hover_changed)
	# Card pool creation is deliberately one-time; category switches only toggle visibility.

func _refresh_cards() -> void:
	var current_category: String = CATEGORIES[category_index]
	var current_cards: Array = _cards_by_category.get(current_category, []) as Array
	selected_index = clampi(selected_index, 0, maxi(0, current_cards.size() - 1))
	_cards = current_cards.duplicate()
	for item in _database_upgrades:
		var data: Dictionary = item as Dictionary
		var id: String = String(data.get("id", ""))
		var card: PowerUpShopCard = _cards_by_id.get(id) as PowerUpShopCard
		if card == null or not is_instance_valid(card):
			continue
		var category: String = String(data.get("category", "combat"))
		var category_cards: Array = _cards_by_category.get(category, []) as Array
		var index: int = category_cards.find(card)
		var is_visible: bool = category == current_category
		card.visible = is_visible
		card.mouse_filter = Control.MOUSE_FILTER_STOP if is_visible else Control.MOUSE_FILTER_IGNORE
		card.configure(data, index, _purchase_views_by_id.get(id, {}) as Dictionary, is_visible and index == selected_index)
		card.set_logical_focus(is_visible and focus_area == FocusArea.CARDS and index == selected_index)

func _rebuild_cards() -> void:
	_ensure_card_pool()
	_refresh_cards()

func _update_category_styles() -> void:
	VisualStyle.apply_tab_theme(combat_tab, category_index == 0, VisualStyle.COMBAT, VisualStyle.COMBAT_DARK)
	VisualStyle.apply_tab_theme(support_tab, category_index == 1, VisualStyle.SUPPORT, VisualStyle.SUPPORT_DARK)

func _update_category_background(animated: bool) -> void:
	if not is_node_ready():
		return
	var combat_alpha := 1.0 if category_index == 0 else 0.0
	var support_alpha := 1.0 if category_index == 1 else 0.0
	if not animated:
		combat_decoration.modulate = Color(1, 1, 1, combat_alpha)
		support_decoration.modulate = Color(1, 1, 1, support_alpha)
		combat_hero_background.modulate = Color(1, 1, 1, combat_alpha)
		support_hero_background.modulate = Color(1, 1, 1, support_alpha)
		return
	var tween := create_tween()
	_track_tween(tween)
	tween.set_parallel()
	tween.tween_property(combat_decoration, "modulate:a", combat_alpha, 0.25)
	tween.tween_property(support_decoration, "modulate:a", support_alpha, 0.25)
	tween.tween_property(combat_hero_background, "modulate:a", combat_alpha, 0.25)
	tween.tween_property(support_hero_background, "modulate:a", support_alpha, 0.25)

func _update_detail() -> void:
	if manager == null:
		return
	var list := _upgrades()
	if list.is_empty():
		return
	selected_index = clampi(selected_index, 0, list.size() - 1)
	var data: Dictionary = list[selected_index] as Dictionary
	var id := String(data.get("id", ""))
	_selected_purchase_view = _purchase_views_by_id.get(id, {}) as Dictionary
	var level: int = int(_selected_purchase_view.get("level", manager.get_upgrade_level(id)))
	var max_level: int = int(_selected_purchase_view.get("maxLevel", data.get("maxLevel", 5)))
	var purchase_state: int = int(_selected_purchase_view.get("state", UiState.PurchaseState.PURCHASABLE))
	var maxed: bool = purchase_state == UiState.PurchaseState.MAX_LEVEL
	detail_icon.texture = load(String(data.get("iconPath", ""))) as Texture2D
	detail_category_label.text = _category_detail_tag(String(data.get("category", CATEGORIES[category_index])))
	detail_name.text = String(data.get("displayName", id))
	detail_level.text = "Lv %d / %d" % [level, max_level]
	detail_description.text = String(data.get("description", ""))
	_update_target_tags(data)
	comparison_current.text = String(_selected_purchase_view.get("currentEffectText", "なし"))
	comparison_next.text = "MAX" if maxed else String(_selected_purchase_view.get("nextEffectText", "なし"))
	_update_detail_level_gauge(level, max_level, String(data.get("category", CATEGORIES[category_index])))
	_refresh_purchase_visuals(data, _selected_purchase_view)
	for index in range(_cards.size()):
		var card: PowerUpShopCard = _cards[index] as PowerUpShopCard
		if card != null and is_instance_valid(card):
			var card_data: Dictionary = list[index] as Dictionary
			card.update_state(_purchase_views_by_id.get(String(card_data.get("id", "")), {}) as Dictionary, index == selected_index)
	_refresh_focus_visuals()
	_update_mascot(_selected_purchase_view)

func _update_detail_level_gauge(level: int, max_level: int, category: String) -> void:
	var accent := VisualStyle.COMBAT if category == "combat" else VisualStyle.SUPPORT
	for index in range(_detail_lamps.size()):
		var lamp: PanelContainer = _detail_lamps[index]
		var lit: bool = index < level
		var fill := accent if lit else VisualStyle.LAMP_OFF
		var border := accent.darkened(0.12) if lit else VisualStyle.LAMP_BORDER
		if lit and level >= max_level and index == _detail_lamps.size() - 1:
			fill = VisualStyle.PP
			border = VisualStyle.PP_DARK
		lamp.add_theme_stylebox_override("panel", VisualStyle.lamp_style(fill, border))

func _update_total_progress() -> void:
	var total_level: int = 0
	var total_max_level: int = 0
	for item in _database_upgrades:
		var data: Dictionary = item as Dictionary
		var id: String = String(data.get("id", ""))
		total_level += int(manager.get_upgrade_level(id))
		total_max_level += int(data.get("maxLevel", 5))
	progress_value.text = "%d / %d" % [total_level, total_max_level]
	progress_bar.max_value = float(maxi(1, total_max_level))
	progress_bar.value = float(total_level)
	progress_bar.add_theme_stylebox_override("fill", VisualStyle.progress_style(VisualStyle.COMBAT if category_index == 0 else VisualStyle.SUPPORT, VisualStyle.COMBAT if category_index == 0 else VisualStyle.SUPPORT))

func _update_mascot(view: Dictionary) -> void:
	if view.is_empty():
		return
	var upgrade_id := String(view.get("id", ""))
	if upgrade_id != _mascot_upgrade_id:
		_mascot_upgrade_id = upgrade_id
		_mascot_generation += 1
		if _mascot_message_tween != null and is_instance_valid(_mascot_message_tween):
			_mascot_message_tween.kill()
			_mascot_message_tween = null
	var token := _mascot_generation
	_show_mascot_state(int(view.get("mascotBaseState", UiState.MascotState.IDLE)), view, token)

func _mascot_message_key(state: int) -> String:
	match state:
		UiState.MascotState.PURCHASABLE:
			return "purchasable"
		UiState.MascotState.SHORTAGE:
			return "shortage"
		UiState.MascotState.PURCHASE_SUCCESS:
			return "purchaseSuccess"
		UiState.MascotState.MAX_LEVEL:
			return "maxLevel"
		_:
			return "idle"

func _mascot_text(state: int, view: Dictionary) -> String:
	var key := _mascot_message_key(state)
	var fallback := "応援を力に変えよう！"
	var message := String(_mascot_messages.get(key, fallback))
	if state == UiState.MascotState.SHORTAGE:
		message = message % int(view.get("shortage", 0))
	return message

func _show_mascot_state(state: int, view: Dictionary, token: int) -> void:
	if token != _mascot_generation or not is_node_ready():
		return
	if _mascot_message_tween != null and is_instance_valid(_mascot_message_tween):
		_mascot_message_tween.kill()
		_mascot_message_tween = null
	_mascot_presentation_state = state
	mascot.texture = _mascot_default_texture
	mascot.modulate = VisualStyle.MASCOT_DIM if state == UiState.MascotState.IDLE else Color.WHITE
	mascot_message.text = _mascot_text(state, view)
	speech_bubble.show()
	var accent := VisualStyle.COMBAT if String(view.get("category", "combat")) == "combat" else VisualStyle.SUPPORT
	speech_bubble.add_theme_stylebox_override("panel", VisualStyle.rounded_panel(Color.WHITE, accent, 2, 14))
	mascot_glow.color = VisualStyle.PP if state in [UiState.MascotState.PURCHASE_SUCCESS, UiState.MascotState.MAX_LEVEL] else accent
	mascot_glow.modulate = Color(1, 1, 1, 0.20 if state in [UiState.MascotState.PURCHASE_SUCCESS, UiState.MascotState.MAX_LEVEL] else 0.10)
	mascot_state_decoration.visible = state in [UiState.MascotState.PURCHASE_SUCCESS, UiState.MascotState.MAX_LEVEL]
	mascot_state_decoration.text = "MAX" if state == UiState.MascotState.MAX_LEVEL else "✦"
	mascot.scale = Vector2.ONE
	if state == UiState.MascotState.PURCHASE_SUCCESS:
		_mascot_message_tween = create_tween()
		_track_tween(_mascot_message_tween)
		_mascot_message_tween.tween_property(mascot, "scale", Vector2(1.08, 1.08), 0.12)
		_mascot_message_tween.tween_property(mascot, "scale", Vector2.ONE, 0.18)
		_mascot_message_tween.tween_interval(1.0)
		_mascot_message_tween.tween_callback(_mascot_success_timeout.bind(token, view.duplicate(true)))
	elif state == UiState.MascotState.MAX_LEVEL:
		_mascot_message_tween = create_tween()
		_track_tween(_mascot_message_tween)
		_mascot_message_tween.tween_property(mascot, "scale", Vector2(1.05, 1.05), 0.14)
		_mascot_message_tween.tween_property(mascot, "scale", Vector2.ONE, 0.18)
		_mascot_message_tween.tween_interval(1.5)
		_mascot_message_tween.tween_callback(_mascot_temporary_timeout.bind(token, view.duplicate(true)))

func _mascot_success_timeout(token: int, view: Dictionary) -> void:
	if token != _mascot_generation:
		return
	var level := int(view.get("level", 0))
	var max_level := int(view.get("maxLevel", 5))
	_show_mascot_state(UiState.MascotState.MAX_LEVEL if level >= max_level else int(view.get("mascotBaseState", UiState.MascotState.PURCHASABLE)), view, token)

func _mascot_temporary_timeout(token: int, view: Dictionary) -> void:
	if token != _mascot_generation:
		return
	_show_mascot_state(int(view.get("mascotBaseState", UiState.MascotState.IDLE)), view, token)

func _clear_mascot() -> void:
	_mascot_generation += 1
	_mascot_upgrade_id = ""
	_mascot_presentation_state = UiState.MascotState.IDLE
	if _mascot_message_tween != null and is_instance_valid(_mascot_message_tween):
		_mascot_message_tween.kill()
	_mascot_message_tween = null
	if not is_node_ready():
		return
	mascot.texture = _mascot_default_texture
	mascot.modulate = Color.WHITE
	mascot.scale = Vector2.ONE
	mascot_glow.modulate = Color(1, 1, 1, 0)
	mascot_state_decoration.hide()
	speech_bubble.hide()
	mascot_message.text = ""

func _category_detail_tag(category: String) -> String:
	if manager == null or manager.database == null:
		return category
	for item in manager.database.categories:
		var category_data: Dictionary = item as Dictionary
		if String(category_data.get("id", "")) == category:
			return String(category_data.get("detailTag", category_data.get("displayName", category)))
	return category

func _update_target_tags(data: Dictionary) -> void:
	for child in target_tags.get_children():
		child.free()
	var tag_count := 0
	for tag_value in data.get("effectTags", []) as Array:
		if tag_count >= 3:
			break
		var tag_panel := PanelContainer.new()
		tag_panel.add_theme_stylebox_override("panel", VisualStyle.compact_panel(VisualStyle.TAG_FILL, Color.TRANSPARENT, 0, 10, 8, 3))
		var tag := Label.new()
		tag.text = String(tag_value)
		VisualStyle.apply_font(tag, 13, false, VisualStyle.TAG_TEXT)
		tag.add_theme_constant_override("margin_left", 8)
		tag.add_theme_constant_override("margin_right", 8)
		tag.add_theme_constant_override("margin_top", 3)
		tag.add_theme_constant_override("margin_bottom", 3)
		tag_panel.add_child(tag)
		target_tags.add_child(tag_panel)
		tag_count += 1

func _refresh_purchase_visuals(data: Dictionary, view: Dictionary) -> void:
	var category := String(data.get("category", CATEGORIES[category_index]))
	var accent := VisualStyle.COMBAT if category == "combat" else VisualStyle.SUPPORT
	var accent_dark := VisualStyle.COMBAT_DARK if category == "combat" else VisualStyle.SUPPORT_DARK
	var visual_style: Dictionary = (view.get("visualStyle", data.get("visualStyle", {})) as Dictionary)
	var base_color := Color(String(visual_style.get("baseColor", "#FCF9FF")))
	var card_accent := Color(String(visual_style.get("accentColor", accent.to_html(false))))
	var tier: int = int(view.get("visualTier", UiState.UpgradeVisualTier.UNPURCHASED))
	detail_panel.add_theme_stylebox_override("panel", VisualStyle.rounded_panel(VisualStyle.DETAIL, card_accent, 2, 18))
	detail_accent_band.color = accent
	detail_icon_plate.add_theme_stylebox_override("panel", VisualStyle.compact_panel(base_color.lerp(VisualStyle.tier_fill(tier, accent), 0.28), VisualStyle.tier_border(tier, card_accent), 2, 20, 0, 0))
	icon_glow_plate.add_theme_stylebox_override("panel", VisualStyle.compact_panel(base_color.lightened(0.03), card_accent, 2, 40, 0, 0))
	detail_category_tag.add_theme_stylebox_override("panel", VisualStyle.compact_panel(Color.WHITE, accent, 1, 12, 8, 3))
	detail_category_label.add_theme_color_override("font_color", accent_dark)
	combat_hero_background.color = VisualStyle.COMBAT.darkened(0.04)
	support_hero_background.color = VisualStyle.SUPPORT.darkened(0.04)
	hero_pattern.modulate = Color(card_accent, 0.18)
	var state := int(view.get("state", UiState.PurchaseState.PURCHASABLE))
	match state:
		UiState.PurchaseState.PURCHASABLE:
			purchase_button.text = "パワーアップする\n%d PP" % int(view.get("price", 0))
			purchase_button.disabled = _purchase_lock_remaining > 0.0 or _pending_upgrade_id != ""
			VisualStyle.apply_button_theme(purchase_button, accent_dark, accent, VisualStyle.TEXT_LIGHT)
		UiState.PurchaseState.NOT_ENOUGH_PP:
			purchase_button.text = "PPが足りません\nあと%d PP" % int(view.get("shortage", 0))
			purchase_button.disabled = false
			var insufficient := VisualStyle.button_style(VisualStyle.BUTTON_DISABLED_FILL, VisualStyle.BUTTON_DISABLED_BORDER, 1, 12)
			for state_name in ["normal", "hover", "pressed", "focus"]:
				purchase_button.add_theme_stylebox_override(state_name, insufficient)
			VisualStyle.apply_font(purchase_button, 17, true, VisualStyle.BUTTON_DISABLED_TEXT)
		UiState.PurchaseState.MAX_LEVEL:
			purchase_button.text = "強化完了\nMAX"
			purchase_button.disabled = true
			var max_style := VisualStyle.button_style(VisualStyle.MAX_FILL, VisualStyle.PP, 2, 12)
			for state_name in ["normal", "hover", "pressed", "focus"]:
				purchase_button.add_theme_stylebox_override(state_name, max_style)
			VisualStyle.apply_font(purchase_button, 17, true, VisualStyle.PP_DARK)
	detail_level_gauge.modulate = Color.WHITE if state != UiState.PurchaseState.MAX_LEVEL else Color(1.0, 0.96, 0.76, 1.0)
	var price: int = int(view.get("price", 0))
	var points: int = int(view.get("points", 0))
	if state == UiState.PurchaseState.MAX_LEVEL:
		required_point_value.text = "-"
		owned_or_shortage.text = "所持PP %d" % points
		required_point_value.add_theme_color_override("font_color", VisualStyle.SECONDARY)
		owned_or_shortage.add_theme_color_override("font_color", VisualStyle.SECONDARY)
	else:
		required_point_value.text = "必要PP %d" % price
		owned_or_shortage.text = "所持PP %d" % points if state == UiState.PurchaseState.PURCHASABLE else "あと%d PP" % int(view.get("shortage", 0))
		required_point_value.add_theme_color_override("font_color", VisualStyle.PP_DARK)
		owned_or_shortage.add_theme_color_override("font_color", VisualStyle.SECONDARY if state == UiState.PurchaseState.PURCHASABLE else VisualStyle.WARNING)
	_update_mascot(view)

func _refresh_focus_visuals() -> void:
	for index in range(_cards.size()):
		var card = _cards[index]
		if card == null or not is_instance_valid(card):
			continue
		card.set_input_device(last_input_device)
		card.set_logical_focus(focus_area == FocusArea.CARDS and index == selected_index)
	var footer_back_active := focus_area == FocusArea.RESET and footer_choice == FooterChoice.BACK
	var footer_reset_active := focus_area == FocusArea.RESET and footer_choice == FooterChoice.RESET
	_apply_footer_button_focus(back_button, footer_back_active)
	_apply_footer_button_focus(reset_button, footer_reset_active)
	_refresh_category_tab_focus()
	var dialog_confirm_active := focus_area == FocusArea.RESET_DIALOG and dialog_choice == DialogChoice.CONFIRM
	var dialog_cancel_active := focus_area == FocusArea.RESET_DIALOG and dialog_choice == DialogChoice.CANCEL
	_apply_dialog_button_focus(reset_confirm_button, dialog_confirm_active, VisualStyle.COMBAT)
	_apply_dialog_button_focus(reset_cancel_button, dialog_cancel_active, VisualStyle.SUPPORT)

func _apply_footer_button_focus(button: Button, active: bool) -> void:
	var fill := VisualStyle.COMBAT_DARK if active else VisualStyle.PRIMARY
	var border := VisualStyle.COMBAT if active else VisualStyle.SECONDARY
	var text_color := VisualStyle.TEXT_LIGHT if active else VisualStyle.CARD_SUBTLE
	VisualStyle.apply_button_theme(button, fill, border, text_color)
	button.add_theme_stylebox_override("normal", VisualStyle.button_style(fill, border, 4 if active else 1, 12))
	if not active:
		button.add_theme_stylebox_override("hover", VisualStyle.button_style(VisualStyle.PRIMARY.lightened(0.06), VisualStyle.SECONDARY, 2, 12))

func _refresh_category_tab_focus() -> void:
	var tab_focus := focus_area == FocusArea.CATEGORY_TABS
	VisualStyle.apply_tab_theme(combat_tab, category_index == 0, VisualStyle.COMBAT, VisualStyle.COMBAT_DARK)
	VisualStyle.apply_tab_theme(support_tab, category_index == 1, VisualStyle.SUPPORT, VisualStyle.SUPPORT_DARK)
	if not tab_focus:
		return
	var active_tab := combat_tab if category_index == 0 else support_tab
	var accent := VisualStyle.COMBAT if category_index == 0 else VisualStyle.SUPPORT
	var accent_dark := VisualStyle.COMBAT_DARK if category_index == 0 else VisualStyle.SUPPORT_DARK
	active_tab.add_theme_stylebox_override("normal", VisualStyle.button_style(accent_dark, accent, 4, 14))
	active_tab.add_theme_stylebox_override("hover", VisualStyle.button_style(accent_dark.lightened(0.08), accent, 4, 14))
	active_tab.add_theme_stylebox_override("focus", VisualStyle.button_style(accent_dark, accent, 4, 14))

func _apply_dialog_button_focus(button: Button, active: bool, accent: Color) -> void:
	var fill := accent.darkened(0.30) if active else VisualStyle.SECONDARY
	var border := VisualStyle.PP if active else VisualStyle.CARD_SUBTLE
	button.add_theme_stylebox_override("normal", VisualStyle.button_style(fill, border, 4 if active else 2, 12))
	button.add_theme_stylebox_override("hover", VisualStyle.button_style(fill.lightened(0.08), accent, 4, 12))

func _format_effect(data: Dictionary, value: Variant, level: int) -> String:
	if String(data.get("id", "")) == "gift_luck":
		var luck: Dictionary = data.get("giftLuck", {}) as Dictionary
		var hit: Array = luck.get("hitWeightMultipliers", []) as Array
		var jackpot: Array = luck.get("jackpotWeightMultipliers", []) as Array
		var index := clampi(level, 0, maxi(0, hit.size() - 1))
		return "Hit x%.2f / Jackpot x%.2f" % [float(hit[index]), float(jackpot[index])]
	var number := float(value)
	if is_zero_approx(number):
		return "なし"
	var prefix := "-" if String(data.get("id", "")) == "damage_reduction" else "+"
	return "%s%d%%" % [prefix, roundi(absf(number) * 100.0)]

func _upgrades() -> Array:
	return manager.database.upgrades_for_category(CATEGORIES[category_index]) if manager != null and manager.database != null else []

func _on_category_pressed(next_category: int) -> void:
	if focus_area == FocusArea.RESET_DIALOG or _purchase_input_lock_remaining > 0.0:
		return
	if next_category == category_index:
		return
	var keep_tab_focus := focus_area == FocusArea.CATEGORY_TABS
	category_last_indices[category_index] = selected_index
	category_index = next_category
	selected_index = category_last_indices[category_index]
	focus_area = FocusArea.CATEGORY_TABS if keep_tab_focus else FocusArea.CARDS
	_refresh_view(true)
	_animate_category_switch()
	_play_se(cursor_se)

func _on_card_selected(index: int) -> void:
	if _purchase_input_lock_remaining > 0.0 or index < 0 or index >= _upgrades().size():
		return
	_set_input_device("mouse")
	focus_area = FocusArea.CARDS
	selected_index = index
	_update_detail()
	_play_se(cursor_se)

func _on_card_hover_changed(_index: int, _hovering: bool) -> void:
	_set_input_device("mouse")

func _on_purchase_pressed() -> void:
	if manager == null or _purchase_lock_remaining > 0.0 or _purchase_cooldown > 0.0 or _pending_upgrade_id != "":
		return
	var id := _selected_upgrade_id()
	if id == "":
		return
	var view := _selected_purchase_view
	var state := int(view.get("state", UiState.PurchaseState.PURCHASABLE))
	if state == UiState.PurchaseState.MAX_LEVEL:
		return
	if state == UiState.PurchaseState.NOT_ENOUGH_PP:
		_on_purchase_failed(PowerUpShopManager.Result.NOT_ENOUGH_POINTS)
		return
	_pending_upgrade_id = id
	_pending_new_level = int(view.get("level", 0)) + 1
	_pending_previous_view = view.duplicate(true)
	_pending_card = _cards_by_id.get(id) as PowerUpShopCard
	purchase_api_call_count += 1
	manager.purchase_upgrade(id)

func _selected_upgrade_id() -> String:
	var list := _upgrades()
	return String((list[selected_index] as Dictionary).get("id", "")) if selected_index < list.size() else ""

func _show_reset_dialog() -> void:
	if _purchase_lock_remaining > 0.0 or _purchase_input_lock_remaining > 0.0:
		return
	reset_confirm_visible = true
	focus_area = FocusArea.RESET_DIALOG
	dialog_choice = DialogChoice.CANCEL
	footer_choice = FooterChoice.RESET
	dialog_layer.show()
	reset_dialog.show()
	dialog_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	_refresh_focus_visuals()
	reset_dialog.modulate = Color(1, 1, 1, 0)
	var tween := create_tween()
	_track_tween(tween)
	tween.tween_property(reset_dialog, "modulate", Color.WHITE, 0.16)

func _hide_dialog() -> void:
	reset_confirm_visible = false
	if is_node_ready():
		reset_dialog.hide()
		dialog_layer.hide()
		dialog_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _close_dialog_to_reset() -> void:
	_hide_dialog()
	focus_area = FocusArea.RESET
	footer_choice = FooterChoice.RESET
	_refresh_focus_visuals()

func _on_reset_confirm_button_pressed() -> void:
	dialog_choice = DialogChoice.CONFIRM
	_on_reset_confirmed()

func _on_reset_cancel_button_pressed() -> void:
	dialog_choice = DialogChoice.CANCEL
	_close_dialog_to_reset()

func _on_reset_confirmed() -> void:
	_close_dialog_to_reset()
	if manager != null:
		manager.reset_all_upgrades()

func _on_manager_changed(_previous: int, current: int) -> void:
	if not is_node_ready():
		return
	pp_value.text = "%d" % current
	if _pending_upgrade_id == "":
		_refresh_view()
	var tween := create_tween()
	_track_tween(tween)
	pp_value.scale = Vector2.ONE
	tween.tween_property(pp_value, "scale", Vector2(1.08, 1.08), 0.12)
	tween.tween_property(pp_value, "scale", Vector2.ONE, 0.18)

func _on_upgrade_purchased(_id: String, level: int, _price: int) -> void:
	if _pending_upgrade_id != "" and _id != _pending_upgrade_id:
		return
	if _pending_upgrade_id == "":
		_refresh_view()
		return
	_pending_new_level = level
	_purchase_lock_remaining = 0.58
	_purchase_input_lock_remaining = 0.35
	purchase_button.disabled = true
	_play_purchase_light()

func _play_purchase_light() -> void:
	if _purchase_light_tween != null and is_instance_valid(_purchase_light_tween):
		_purchase_light_tween.kill()
	purchase_light.visible = true
	purchase_light.modulate = Color.WHITE
	purchase_light.scale = Vector2(0.65, 0.65)
	purchase_light.global_position = pp_capsule.global_position + pp_capsule.size * 0.5 - purchase_light.size * 0.5
	var target_position := detail_icon.global_position + detail_icon.size * 0.5 - purchase_light.size * 0.5
	_purchase_light_tween = create_tween()
	_track_tween(_purchase_light_tween)
	_purchase_light_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	_purchase_light_tween.tween_property(purchase_light, "global_position", target_position, 0.35)
	_purchase_light_tween.parallel().tween_property(purchase_light, "scale", Vector2(1.25, 1.25), 0.35)
	_purchase_light_tween.tween_callback(_complete_purchase_visual_update)

func _complete_purchase_visual_update() -> void:
	if not is_node_ready() or _pending_upgrade_id == "":
		return
	var purchased_level: int = _pending_new_level
	var purchased_card: PowerUpShopCard = _pending_card
	_pending_upgrade_id = ""
	_pending_new_level = -1
	_pending_card = null
	_pending_previous_view.clear()
	purchase_light.hide()
	_refresh_view()
	if purchased_card != null and is_instance_valid(purchased_card):
		purchased_card.play_purchase_success(purchased_level)
	var accent_tween := create_tween()
	_track_tween(accent_tween)
	detail_accent_band.modulate = Color(1, 1, 1, 0.45)
	accent_tween.tween_property(detail_accent_band, "modulate:a", 1.0, 0.14)
	_show_mascot_state(UiState.MascotState.PURCHASE_SUCCESS, _selected_purchase_view, _mascot_generation)
	_play_se(max_se if purchased_level >= 5 else purchase_se)
	_show_toast("購入しました", 1.0)

func _on_reset(_refund: int) -> void:
	focus_area = FocusArea.RESET
	footer_choice = FooterChoice.RESET
	_refresh_view()
	_play_se(purchase_se)
	_show_toast("全強化をリセットしました", 1.0)

func _on_purchase_failed(reason: int) -> void:
	_pending_upgrade_id = ""
	_pending_new_level = -1
	_pending_card = null
	_pending_previous_view.clear()
	purchase_light.hide()
	var message := "購入できません"
	match reason:
		PowerUpShopManager.Result.MAX_LEVEL:
			return
		PowerUpShopManager.Result.NOT_ENOUGH_POINTS:
			message = "PPが不足しています"
			_purchase_cooldown = 0.5
			_play_se(error_se)
			_animate_insufficient_feedback()
		PowerUpShopManager.Result.SAVE_FAILED:
			message = "保存に失敗しました"
			_play_se(error_se)
		PowerUpShopManager.Result.LOCKED:
			message = "初回プレイ後に解禁されます"
			_play_se(error_se)
		PowerUpShopManager.Result.BUSY:
			message = "処理中です"
			_play_se(error_se)
		PowerUpShopManager.Result.NOTHING_TO_RESET:
			message = "リセットする強化がありません"
			_play_se(error_se)
	_show_toast(message, 1.0)
	if reason != PowerUpShopManager.Result.MAX_LEVEL:
		_refresh_view()

func _animate_insufficient_feedback() -> void:
	var base_position := purchase_button.position
	var tween := create_tween()
	_track_tween(tween)
	tween.set_loops(2)
	tween.tween_property(purchase_button, "position", base_position + Vector2(8, 0), 0.06)
	tween.tween_property(purchase_button, "position", base_position - Vector2(8, 0), 0.06)
	tween.tween_property(purchase_button, "position", base_position, 0.06)
	var pp_tween := create_tween()
	_track_tween(pp_tween)
	pp_tween.tween_method(_set_pp_capsule_warning, 0.0, 1.0, 0.08)
	pp_tween.tween_method(_set_pp_capsule_warning, 1.0, 0.0, 0.16)

func _set_pp_capsule_warning(warning_value: float) -> void:
	var border := VisualStyle.WARNING if warning_value > 0.5 else VisualStyle.PP_DARK
	pp_capsule.add_theme_stylebox_override("panel", VisualStyle.rounded_panel(VisualStyle.PRIMARY, border, 2, 24))

func _animate_max_feedback() -> void:
	for card in _cards:
		if card != null and is_instance_valid(card) and card.upgrade_index == selected_index:
			card.play_purchase_success()
	_show_toast("MAXレベルです", 0.8)

func _show_toast(message: String, duration: float) -> void:
	if _toast_tween != null and is_instance_valid(_toast_tween):
		_toast_tween.kill()
	toast_label.text = message
	toast_panel.visible = true
	toast_panel.modulate = Color(1, 1, 1, 0)
	_toast_tween = create_tween()
	_track_tween(_toast_tween)
	_toast_tween.tween_property(toast_panel, "modulate", Color.WHITE, 0.12)
	_toast_tween.tween_interval(duration)
	_toast_tween.tween_property(toast_panel, "modulate", Color(1, 1, 1, 0), 0.18)
	_toast_tween.tween_callback(_hide_toast)

func _hide_toast() -> void:
	if _toast_tween != null and is_instance_valid(_toast_tween):
		_toast_tween.kill()
	_toast_tween = null
	if is_node_ready():
		toast_panel.hide()
		toast_label.text = ""

func _animate_show() -> void:
	_kill_tweens()
	var tabs := $SafeAreaMargin/MainCenter/ShopContent/CategoryTabs as Control
	var body := $SafeAreaMargin/MainCenter/ShopContent/Body as Control
	var footer := $SafeAreaMargin/MainCenter/ShopContent/Footer as Control
	for node in [header, tabs, body, footer]:
		node.modulate = Color(1, 1, 1, 0)
	var tween := create_tween()
	_track_tween(tween)
	tween.set_parallel()
	tween.tween_property(header, "modulate", Color.WHITE, 0.22).set_delay(0.08)
	tween.tween_property(tabs, "modulate", Color.WHITE, 0.22).set_delay(0.12)
	tween.tween_property(body, "modulate", Color.WHITE, 0.24).set_delay(0.18)
	tween.tween_property(footer, "modulate", Color.WHITE, 0.20).set_delay(0.24)

func _animate_category_switch() -> void:
	var visible_cards: Array = _cards_by_category.get(CATEGORIES[category_index], []) as Array
	for item in visible_cards:
		var card: Control = item as Control
		if card != null and is_instance_valid(card):
			card.modulate = Color(1, 1, 1, 0.35)
	_update_category_background(true)
	var tween := create_tween()
	_track_tween(tween)
	detail_accent_band.modulate = Color(1, 1, 1, 0.55)
	tween.parallel().tween_property(detail_accent_band, "modulate:a", 1.0, 0.25)
	for item in visible_cards:
		var card: Control = item as Control
		if card != null and is_instance_valid(card):
			tween.parallel().tween_property(card, "modulate", Color.WHITE, 0.2)

func _play_se(player: AudioStreamPlayer) -> void:
	if player != null and player.stream != null:
		if player == cursor_se and player.playing:
			player.stop()
		player.play()

func _track_tween(tween: Tween) -> void:
	_active_tweens.append(tween)

func _kill_tweens() -> void:
	for tween in _active_tweens:
		if tween != null and is_instance_valid(tween):
			tween.kill()
	_active_tweens.clear()
	if _toast_tween != null and is_instance_valid(_toast_tween):
		_toast_tween.kill()
		_toast_tween = null
	if _purchase_light_tween != null and is_instance_valid(_purchase_light_tween):
		_purchase_light_tween.kill()
	_purchase_light_tween = null
	if _mascot_tween != null and is_instance_valid(_mascot_tween):
		_mascot_tween.kill()
		_mascot_tween = null
	if _mascot_message_tween != null and is_instance_valid(_mascot_message_tween):
		_mascot_message_tween.kill()
		_mascot_message_tween = null
	if is_node_ready():
		purchase_light.hide()
		mascot.scale = Vector2.ONE
	var cards_to_stop: Array = _cards_by_id.values() if not _cards_by_id.is_empty() else _cards
	for item in cards_to_stop:
		var card: PowerUpShopCard = item as PowerUpShopCard
		if card != null and is_instance_valid(card):
			card.stop_animations()

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventMouseMotion:
		_set_input_device("mouse")
		return
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		_set_input_device("mouse")
		return
	if event is InputEventJoypadMotion:
		var stick_direction := _joypad_motion_direction(event as InputEventJoypadMotion)
		if stick_direction == Vector2i.ZERO:
			_stick_direction = Vector2i.ZERO
			_stick_repeat_remaining = 0.0
			return
		if not _accept_stick_direction(stick_direction):
			return
		_move_cursor(stick_direction, "gamepad")
		get_viewport().set_input_as_handled()
		return
	if not (event is InputEventKey or event is InputEventJoypadButton):
		return
	if not _is_press_event(event):
		return
	var action := _action_for_event(event)
	if action == "":
		return
	var device := "gamepad" if event is InputEventJoypadButton else "keyboard"
	_handle_action(action, device)
	get_viewport().set_input_as_handled()

func _is_press_event(event: InputEvent) -> bool:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		return key_event.pressed and not key_event.echo
	if event is InputEventJoypadButton:
		return (event as InputEventJoypadButton).pressed
	return false

func _action_for_event(event: InputEvent) -> String:
	var standard_actions := [
		{"action": "ui_left", "value": "left"},
		{"action": "ui_right", "value": "right"},
		{"action": "ui_up", "value": "up"},
		{"action": "ui_down", "value": "down"},
		{"action": "ui_accept", "value": "confirm"},
		{"action": "ui_cancel", "value": "back"},
	]
	for entry in standard_actions:
		if event.is_action_pressed(String(entry["action"])):
			return String(entry["value"])
	if event is InputEventKey:
		match (event as InputEventKey).keycode:
			KEY_LEFT, KEY_A: return "left"
			KEY_RIGHT, KEY_D: return "right"
			KEY_UP, KEY_W: return "up"
			KEY_DOWN, KEY_S: return "down"
			KEY_ENTER, KEY_SPACE, KEY_Z: return "confirm"
			KEY_ESCAPE, KEY_X, KEY_BACKSPACE: return "back"
			KEY_Q: return "category_left"
			KEY_E: return "category_right"
	if event is InputEventJoypadButton:
		match (event as InputEventJoypadButton).button_index:
			JOY_BUTTON_DPAD_LEFT: return "left"
			JOY_BUTTON_DPAD_RIGHT: return "right"
			JOY_BUTTON_DPAD_UP: return "up"
			JOY_BUTTON_DPAD_DOWN: return "down"
			JOY_BUTTON_A: return "confirm"
			JOY_BUTTON_B: return "back"
			JOY_BUTTON_LEFT_SHOULDER: return "category_left"
			JOY_BUTTON_RIGHT_SHOULDER: return "category_right"
	return ""

func _joypad_motion_direction(event: InputEventJoypadMotion) -> Vector2i:
	if event.axis == JOY_AXIS_LEFT_X:
		if absf(event.axis_value) < STICK_DEADZONE:
			return Vector2i.ZERO
		return Vector2i.RIGHT if event.axis_value > 0.0 else Vector2i.LEFT
	if event.axis == JOY_AXIS_LEFT_Y:
		if absf(event.axis_value) < STICK_DEADZONE:
			return Vector2i.ZERO
		return Vector2i.DOWN if event.axis_value > 0.0 else Vector2i.UP
	return Vector2i.ZERO

func _accept_stick_direction(direction: Vector2i) -> bool:
	if direction == Vector2i.ZERO:
		_stick_direction = Vector2i.ZERO
		_stick_repeat_remaining = 0.0
		return false
	if direction != _stick_direction:
		_stick_direction = direction
		_stick_repeat_remaining = STICK_REPEAT_DELAY
		return true
	return false

func _handle_action(action: String, device: String = "keyboard") -> void:
	_set_input_device(device)
	if _purchase_input_lock_remaining > 0.0 and action != "back":
		return
	if action == "back":
		_cancel_current_layer()
	elif action == "category_left":
		if focus_area != FocusArea.RESET_DIALOG:
			_on_category_pressed(posmod(category_index - 1, CATEGORIES.size()))
	elif action == "category_right":
		if focus_area != FocusArea.RESET_DIALOG:
			_on_category_pressed(posmod(category_index + 1, CATEGORIES.size()))
	elif action == "left":
		_move_cursor(Vector2i.LEFT, device)
	elif action == "right":
		_move_cursor(Vector2i.RIGHT, device)
	elif action == "up":
		_move_cursor(Vector2i.UP, device)
	elif action == "down":
		_move_cursor(Vector2i.DOWN, device)
	elif action == "confirm":
		_activate_focused_target()

func _move_cursor(direction: Vector2i, device: String) -> void:
	_set_input_device(device)
	if _purchase_input_lock_remaining > 0.0:
		return
	if focus_area == FocusArea.RESET_DIALOG:
		_move_dialog_choice(direction)
		return
	if focus_area == FocusArea.CATEGORY_TABS:
		_move_category_cursor(direction)
		return
	if focus_area == FocusArea.RESET:
		if direction == Vector2i.UP:
			var previous_index := selected_index
			focus_area = FocusArea.CARDS
			selected_index = clampi(reset_return_index, 0, maxi(0, _upgrades().size() - 1))
			_refresh_focus_visuals()
			if previous_index != selected_index:
				_update_detail()
			_play_se(cursor_se)
		elif direction.x != 0:
			_set_footer_choice(FooterChoice.RESET if direction.x > 0 else FooterChoice.BACK)
		return
	_move_card_cursor(direction)

func _move_category_cursor(direction: Vector2i) -> void:
	if direction.y > 0:
		focus_area = FocusArea.CARDS
		_refresh_focus_visuals()
		_play_se(cursor_se)
		return
	if direction.x == 0:
		return
	var next_category := posmod(category_index + direction.x, CATEGORIES.size())
	if next_category == category_index:
		return
	_on_category_pressed(next_category)

func _move_card_cursor(direction: Vector2i) -> void:
	var list_size := _upgrades().size()
	if list_size <= 0:
		return
	var current := clampi(selected_index, 0, list_size - 1)
	var row: int = int(current / CARD_COLUMNS)
	var column: int = current % CARD_COLUMNS
	var next_index := current
	if direction.x != 0:
		var next_column := clampi(column + direction.x, 0, CARD_COLUMNS - 1)
		var horizontal_index := row * CARD_COLUMNS + next_column
		if horizontal_index < list_size:
			next_index = horizontal_index
	elif direction.y < 0:
		if current >= CARD_COLUMNS:
			next_index = current - CARD_COLUMNS
		else:
			focus_area = FocusArea.CATEGORY_TABS
			_refresh_focus_visuals()
			_play_se(cursor_se)
			return
	else:
		var vertical_index := current + CARD_COLUMNS
		if vertical_index < list_size:
			next_index = vertical_index
		else:
			reset_return_index = current if current >= CARD_COLUMNS else mini(current + CARD_COLUMNS, list_size - 1)
			focus_area = FocusArea.RESET
			footer_choice = FooterChoice.BACK
			_refresh_focus_visuals()
			_play_se(cursor_se)
			return
	if next_index == current:
		return
	selected_index = next_index
	_update_detail()
	_play_se(cursor_se)

func _set_dialog_choice(next_choice: int) -> void:
	if next_choice == dialog_choice:
		return
	dialog_choice = next_choice
	_refresh_focus_visuals()
	_play_se(cursor_se)

func _set_footer_choice(next_choice: int) -> void:
	if footer_choice == next_choice:
		return
	footer_choice = next_choice
	_refresh_focus_visuals()
	_play_se(cursor_se)

func _move_dialog_choice(direction: Vector2i) -> void:
	if direction.x < 0:
		_set_dialog_choice(DialogChoice.CONFIRM)
	elif direction.x > 0:
		_set_dialog_choice(DialogChoice.CANCEL)

func _activate_focused_target() -> void:
	match focus_area:
		FocusArea.CARDS:
			_on_purchase_pressed()
		FocusArea.RESET:
			if footer_choice == FooterChoice.BACK:
				close_shop()
			else:
				_show_reset_dialog()
		FocusArea.CATEGORY_TABS:
			focus_area = FocusArea.CARDS
			_refresh_focus_visuals()
			_play_se(cursor_se)
		FocusArea.RESET_DIALOG:
			if dialog_choice == DialogChoice.CONFIRM:
				_on_reset_confirmed()
			else:
				_close_dialog_to_reset()

func _cancel_current_layer() -> void:
	if focus_area == FocusArea.RESET_DIALOG:
		_close_dialog_to_reset()
	else:
		close_shop()

func _set_input_device(device: String) -> void:
	if last_input_device == device:
		return
	last_input_device = device
	_refresh_focus_visuals()
