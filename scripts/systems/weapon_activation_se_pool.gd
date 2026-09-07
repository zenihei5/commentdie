class_name WeaponActivationSePool
extends Node

var _players: Array[AudioStreamPlayer] = []
var _slot_paths: Array[String] = []
var _slot_volume_offsets: Array[float] = []
var _slot_reserved: Array[bool] = []
var _stream_cache: Dictionary = {}
var _stream_loader: Callable
var _base_volume_db := 0.0
var _output_bus: StringName = &"Master"
var _request_count := 0
var _started_count := 0
var _skipped_count := 0
var _load_failure_count := 0
var _natural_release_count := 0
var _explicit_stop_count := 0
var _peak_active_count := 0
var _started_by_path: Dictionary = {}
var _skipped_by_path: Dictionary = {}


func configure(slot_count: int, base_volume_db: float, stream_loader: Callable = Callable(), output_bus: StringName = &"Master") -> void:
	_clear_slots()
	_stream_cache.clear()
	_stream_loader = stream_loader
	_base_volume_db = base_volume_db
	_output_bus = output_bus
	for slot_index in range(maxi(1, slot_count)):
		var player := AudioStreamPlayer.new()
		player.name = "WeaponActivationSeSlot%02d" % (slot_index + 1)
		player.volume_db = _base_volume_db
		player.pitch_scale = 1.0
		player.bus = _output_bus
		player.finished.connect(_on_slot_finished.bind(slot_index))
		add_child(player)
		_players.append(player)
		_slot_paths.append("")
		_slot_volume_offsets.append(0.0)
		_slot_reserved.append(false)
	reset_debug_counters()


func request_play(path: String, volume_db_offset: float = 0.0) -> Dictionary:
	_request_count += 1
	if path == "":
		return {"started": false, "slot": -1, "reason": "empty_path"}
	_reclaim_finished_slots()
	var slot_index := _first_free_slot()
	if slot_index < 0:
		_skipped_count += 1
		_skipped_by_path[path] = int(_skipped_by_path.get(path, 0)) + 1
		return {"started": false, "slot": -1, "reason": "capacity"}
	var stream := _stream_for_path(path)
	if stream == null:
		_load_failure_count += 1
		return {"started": false, "slot": -1, "reason": "load_failed"}
	var player := _players[slot_index]
	if player.stream != stream:
		player.stream = stream
	_slot_paths[slot_index] = path
	_slot_volume_offsets[slot_index] = volume_db_offset
	_slot_reserved[slot_index] = true
	player.volume_db = _base_volume_db + volume_db_offset
	player.play()
	if not player.playing:
		_release_slot(slot_index, false)
		_load_failure_count += 1
		return {"started": false, "slot": slot_index, "reason": "playback_failed"}
	_started_count += 1
	_started_by_path[path] = int(_started_by_path.get(path, 0)) + 1
	_peak_active_count = maxi(_peak_active_count, _reserved_count())
	return {"started": true, "slot": slot_index, "reason": "started"}


func stop(path: String = "") -> int:
	var stopped_count := 0
	for slot_index in range(_players.size()):
		if not _slot_reserved[slot_index]:
			continue
		if path != "" and _slot_paths[slot_index] != path:
			continue
		_slot_reserved[slot_index] = false
		_slot_paths[slot_index] = ""
		_slot_volume_offsets[slot_index] = 0.0
		var player := _players[slot_index]
		if player.playing:
			player.stop()
		player.stream_paused = false
		stopped_count += 1
	_explicit_stop_count += stopped_count
	return stopped_count


func stop_all() -> int:
	return stop("")


func set_base_volume_db(value: float) -> void:
	_base_volume_db = value
	for slot_index in range(_players.size()):
		_players[slot_index].volume_db = _base_volume_db + _slot_volume_offsets[slot_index]


func set_output_bus(value: StringName) -> void:
	_output_bus = value
	for player in _players:
		player.bus = _output_bus


func active_count() -> int:
	_reclaim_finished_slots()
	return _reserved_count()


func slot_count() -> int:
	return _players.size()


func reset_debug_counters() -> void:
	_request_count = 0
	_started_count = 0
	_skipped_count = 0
	_load_failure_count = 0
	_natural_release_count = 0
	_explicit_stop_count = 0
	_peak_active_count = _reserved_count()
	_started_by_path.clear()
	_skipped_by_path.clear()


func debug_snapshot() -> Dictionary:
	_reclaim_finished_slots()
	var slots: Array = []
	for slot_index in range(_players.size()):
		var player := _players[slot_index]
		var stream := player.stream
		slots.append({
			"index": slot_index,
			"reserved": _slot_reserved[slot_index],
			"playing": player.playing,
			"path": _slot_paths[slot_index],
			"playerInstanceId": player.get_instance_id(),
			"streamInstanceId": stream.get_instance_id() if stream != null else 0,
			"streamType": stream.get_class() if stream != null else "",
			"playbackPosition": player.get_playback_position() if player.playing else -1.0,
			"volumeDb": player.volume_db,
			"pitchScale": player.pitch_scale,
			"bus": String(player.bus),
			"streamPaused": player.stream_paused,
			"processMode": player.process_mode,
		})
	return {
		"capacity": _players.size(),
		"activeCount": _reserved_count(),
		"queueLength": 0,
		"baseVolumeDb": _base_volume_db,
		"outputBus": String(_output_bus),
		"requestCount": _request_count,
		"startedCount": _started_count,
		"skippedCount": _skipped_count,
		"loadFailureCount": _load_failure_count,
		"naturalReleaseCount": _natural_release_count,
		"explicitStopCount": _explicit_stop_count,
		"peakActiveCount": _peak_active_count,
		"startedByPath": _started_by_path.duplicate(true),
		"skippedByPath": _skipped_by_path.duplicate(true),
		"slots": slots,
	}


func _stream_for_path(path: String) -> AudioStream:
	var cached_value: Variant = _stream_cache.get(path)
	if cached_value is AudioStream:
		return cached_value as AudioStream
	var stream: AudioStream = null
	if _stream_loader.is_valid():
		stream = _stream_loader.call(path, false) as AudioStream
	else:
		stream = ResourceLoader.load(path) as AudioStream
	if stream != null:
		_stream_cache[path] = stream
	return stream


func _first_free_slot() -> int:
	for slot_index in range(_slot_reserved.size()):
		if not _slot_reserved[slot_index]:
			return slot_index
	return -1


func _reserved_count() -> int:
	var count := 0
	for reserved in _slot_reserved:
		if reserved:
			count += 1
	return count


func _reclaim_finished_slots() -> void:
	for slot_index in range(_players.size()):
		if _slot_reserved[slot_index] and not _players[slot_index].playing:
			_release_slot(slot_index, true)


func _on_slot_finished(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= _slot_reserved.size() or not _slot_reserved[slot_index]:
		return
	# A completion notification from an older playback must not release this
	# slot after it has already been reclaimed and started again.
	if _players[slot_index].playing:
		return
	_release_slot(slot_index, true)


func _release_slot(slot_index: int, natural_finish: bool) -> void:
	if slot_index < 0 or slot_index >= _slot_reserved.size() or not _slot_reserved[slot_index]:
		return
	_slot_reserved[slot_index] = false
	_slot_paths[slot_index] = ""
	_slot_volume_offsets[slot_index] = 0.0
	if natural_finish:
		_natural_release_count += 1


func _clear_slots() -> void:
	for player in _players:
		if not is_instance_valid(player):
			continue
		if player.playing:
			player.stop()
		if player.get_parent() == self:
			remove_child(player)
		player.free()
	_players.clear()
	_slot_paths.clear()
	_slot_volume_offsets.clear()
	_slot_reserved.clear()


func _exit_tree() -> void:
	stop_all()
