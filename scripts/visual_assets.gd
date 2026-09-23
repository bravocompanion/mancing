extends Node

# Kail Kampung visual integration layer.
# Generated art can live as normal WebP files OR as small binary fragments
# under assets/generated/packed/. Packed fragments are joined in memory, which
# lets the GitHub-connected project ship the art without a manual copy step.

const ASSET_ROOT := "res://assets/generated/"
const PACK_ROOT := ASSET_ROOT + "packed/"
const MC_ROOT := ASSET_ROOT + "sliced/mc/"
const UI_ROOT := ASSET_ROOT + "sliced/ui/"
const ITEM_ROOT := ASSET_ROOT + "sliced/items/"
const WORLD_ROOT := ASSET_ROOT + "sliced/world/"
const MASTER_SIZE := Vector2(1448.0, 1086.0)

const MC_COUNTS := {
    "idle": 4, "walk": 8, "run": 8, "cast": 6,
    "reel": 6, "caught": 4, "tired": 4, "wait": 4
}

const MC_FALLBACK := {
    "idle": [Rect2(205,0,145,165),Rect2(355,0,145,165),Rect2(505,0,145,165),Rect2(655,0,145,165)],
    "walk": [Rect2(195,155,145,150),Rect2(340,155,145,150),Rect2(485,155,145,150),Rect2(630,155,145,150),Rect2(775,155,145,150),Rect2(920,155,145,150),Rect2(1065,155,145,150),Rect2(1210,155,145,150)],
    "run": [Rect2(195,300,150,150),Rect2(345,300,150,150),Rect2(495,300,150,150),Rect2(645,300,150,150),Rect2(795,300,150,150),Rect2(945,300,150,150),Rect2(1095,300,150,150),Rect2(1245,300,150,150)],
    "cast": [Rect2(185,445,190,150),Rect2(375,445,190,150),Rect2(565,445,190,150),Rect2(755,445,190,150),Rect2(945,445,190,150),Rect2(1135,445,250,150)],
    "reel": [Rect2(190,590,180,150),Rect2(370,590,180,150),Rect2(550,590,180,150),Rect2(730,590,180,150),Rect2(910,590,180,150),Rect2(1090,590,240,150)],
    "caught": [Rect2(200,735,165,145),Rect2(365,735,165,145),Rect2(530,735,165,145),Rect2(695,735,165,145)],
    "tired": [Rect2(200,865,165,120),Rect2(365,865,165,120),Rect2(530,865,210,120),Rect2(740,865,210,120)],
    "wait": [Rect2(200,970,200,115),Rect2(400,970,200,115),Rect2(600,970,200,115),Rect2(800,970,230,115)]
}

const UI_REGIONS := {
    "inventory":Rect2(13,69,190,213), "quest":Rect2(205,68,157,214), "map":Rect2(361,71,192,211), "settings":Rect2(563,83,155,199),
    "home":Rect2(723,67,181,215), "shop":Rect2(908,70,193,212), "coin":Rect2(1116,99,144,183), "gem":Rect2(1276,103,151,137),
    "energy":Rect2(45,309,114,143), "level_up":Rect2(223,315,123,133), "exp":Rect2(389,309,144,139), "chat":Rect2(561,317,159,127),
    "warning":Rect2(742,309,158,137), "check":Rect2(935,311,150,182), "locked":Rect2(1123,304,129,189), "unlocked":Rect2(1289,305,134,188),
    "reward":Rect2(18,513,162,193), "trophy":Rect2(194,514,211,192), "hook_meter":Rect2(420,529,311,126), "cast":Rect2(759,505,195,197),
    "reel":Rect2(992,507,191,195), "bait_select":Rect2(1227,517,191,187),
    "weather_sun":Rect2(21,719,153,164), "weather_rain":Rect2(201,721,138,81), "weather_cloud":Rect2(374,730,149,98), "weather_storm":Rect2(556,715,150,129),
    "time_day":Rect2(751,754,150,129), "time_night":Rect2(930,726,149,118), "location":Rect2(1111,716,140,168), "mission":Rect2(1270,720,152,164),
    "fish_encyclopedia":Rect2(15,894,165,166), "leaderboard":Rect2(190,894,154,123), "sound_on":Rect2(350,900,150,120), "sound_off":Rect2(500,900,140,120),
    "pause":Rect2(640,905,120,155), "common":Rect2(774,913,96,101), "uncommon":Rect2(877,911,105,144), "rare":Rect2(991,911,100,144),
    "epic":Rect2(1102,912,101,144), "legendary":Rect2(1211,912,103,144), "mythic":Rect2(1322,911,105,145)
}

const ITEM_REGIONS := {
    "basic_rod":Rect2(19,9,216,207), "pro_rod":Rect2(233,15,211,201), "golden_rod":Rect2(442,14,216,202), "bait_bucket":Rect2(656,30,192,186),
    "worm_bait":Rect2(864,69,172,147), "shrimp_bait":Rect2(1048,75,177,141), "lure":Rect2(1237,43,186,173),
    "hook":Rect2(28,267,134,183), "bobber":Rect2(208,269,158,177), "fishing_net":Rect2(389,265,195,185), "tackle_box":Rect2(592,291,212,159),
    "fish_basket":Rect2(821,264,225,186), "lantern":Rect2(1074,216,154,234), "village_sandals":Rect2(1238,304,196,146),
    "fisher_hat":Rect2(20,513,220,175), "raincoat":Rect2(246,496,207,176), "energy_drink":Rect2(462,496,153,176), "rice_packet":Rect2(650,505,175,167),
    "coin_stack":Rect2(855,513,193,159), "gem":Rect2(1082,525,129,147), "map":Rect2(1239,503,189,169),
    "compass":Rect2(20,714,200,195), "old_key":Rect2(242,726,130,144), "wood_plank":Rect2(424,725,218,145), "rope_bundle":Rect2(669,727,223,143),
    "boat_paddle":Rect2(930,719,266,151), "trophy":Rect2(1212,716,216,154),
    "catfish":Rect2(10,919,174,124), "tilapia":Rect2(191,923,162,120), "carp":Rect2(355,914,190,129), "snakehead":Rect2(549,942,203,101),
    "eel":Rect2(758,933,172,110), "shrimp":Rect2(928,914,158,129), "crab":Rect2(1086,922,169,121), "golden_fish":Rect2(1258,913,183,130)
}

const WORLD_REGIONS := {
    "dock":Rect2(17,14,644,295), "stool":Rect2(681,103,208,176), "fish_crate":Rect2(907,62,276,211), "basket":Rect2(1199,103,231,184),
    "bait_bucket":Rect2(37,328,188,204), "signpost":Rect2(253,309,196,243), "reeds":Rect2(471,289,279,254), "rocks":Rect2(765,343,340,196),
    "water_lily":Rect2(1115,353,309,180), "bamboo_fence":Rect2(23,556,278,233), "lantern_post":Rect2(292,565,160,244), "canoe":Rect2(481,600,311,199),
    "mooring_pole":Rect2(790,563,156,217), "cooler":Rect2(950,618,232,175), "market_basket":Rect2(1198,564,234,231), "campfire":Rect2(28,784,275,184),
    "splash_small":Rect2(395,860,106,61), "splash_large":Rect2(561,800,214,127), "ripple_1":Rect2(808,860,148,50), "ripple_2":Rect2(973,859,119,44),
    "ripple_3":Rect2(1107,860,128,46), "bobber_splash":Rect2(1263,794,153,125), "line_swoosh":Rect2(22,951,377,120), "catch_sparkle":Rect2(421,921,190,150),
    "exclamation_pop":Rect2(648,940,120,130), "dust_puff":Rect2(782,966,154,105), "sweat_drop":Rect2(975,978,43,74), "happy_sparkle":Rect2(1075,944,120,120),
    "celebration_burst":Rect2(1240,925,190,150)
}

var game: Node2D
var mc_sprite: Sprite2D
var mc_shadow: Sprite2D
var mc_sheet: Texture2D
var ui_sheet: Texture2D
var item_sheet: Texture2D
var world_sheet: Texture2D
var visual_ready := false
var last_player := Vector2.ZERO
var last_phase := ""
var last_zone := ""
var last_fish_count := 0
var anim_time := 0.0
var frame_index := 0
var current_anim := "idle"
var catch_anim_until := 0.0
var ui_sync_timer := 0.0
var world_nodes: Array[Node] = []
var texture_cache := {}

func _ready() -> void:
    process_priority = 90
    call_deferred("_late_ready")

func _late_ready() -> void:
    game = get_parent() as Node2D
    if game == null:
        return

    mc_sheet = _load_master("mc_animations")
    ui_sheet = _load_master("ui_icons")
    item_sheet = _load_master("inventory_icons")
    world_sheet = _load_master("world_vfx")

    if not _has_mc_frame("idle", 0) and mc_sheet == null:
        push_warning("Kail Kampung visual pack tidak ditemukan. Renderer lama tetap dipakai.")
        return

    _install_mc()
    last_player = game.player
    last_zone = str(game.zone)
    last_fish_count = int(game.state.stats.get("fish_caught", 0))
    _refresh_world_props()
    _sync_ui_buttons()
    visual_ready = true

func _load_master(stem: String) -> Texture2D:
    var direct_path := ASSET_ROOT + stem + ".webp"
    if ResourceLoader.exists(direct_path):
        return load(direct_path) as Texture2D
    return _load_packed_webp(stem)

func _load_packed_webp(stem: String) -> Texture2D:
    var combined := PackedByteArray()
    var found := false
    for i in range(64):
        var path := PACK_ROOT + "%s.part%03d" % [stem, i]
        if not FileAccess.file_exists(path):
            break
        var file := FileAccess.open(path, FileAccess.READ)
        if file == null:
            break
        combined.append_array(file.get_buffer(file.get_length()))
        found = true
    if not found or combined.is_empty():
        return null
    var image := Image.new()
    if image.load_webp_from_buffer(combined) != OK:
        push_warning("Gagal merakit asset WebP: " + stem)
        return null
    return ImageTexture.create_from_image(image)

func _install_mc() -> void:
    mc_shadow = Sprite2D.new()
    mc_shadow.z_index = 40
    mc_shadow.texture = _make_ellipse_texture(110, 34)
    mc_shadow.modulate = Color(1, 1, 1, 0.28)
    game.add_child(mc_shadow)

    mc_sprite = Sprite2D.new()
    mc_sprite.z_index = 50
    mc_sprite.centered = true
    mc_sprite.scale = Vector2(1.35, 1.35) if mc_sheet != null and mc_sheet.get_width() < 1000 else Vector2(0.72, 0.72)
    game.add_child(mc_sprite)
    _set_frame("idle", 0)

func _process(delta: float) -> void:
    if not visual_ready or game == null or mc_sprite == null:
        return

    ui_sync_timer -= delta
    if ui_sync_timer <= 0.0:
        ui_sync_timer = 0.35
        _sync_ui_buttons()

    if str(game.zone) != last_zone:
        last_zone = str(game.zone)
        _refresh_world_props()

    var p: Vector2 = game.player
    var delta_pos := p - last_player
    var moved := delta_pos.length()
    mc_sprite.position = p + Vector2(0, -28)
    mc_shadow.position = p + Vector2(0, 18)

    _detect_fishing_events()
    _detect_catch()

    var next_anim := "idle"
    var now := Time.get_ticks_msec() / 1000.0
    if now < catch_anim_until:
        next_anim = "caught"
    elif not game.fishing.is_empty():
        var phase := str(game.fishing.get("phase", ""))
        if phase == "wait": next_anim = "wait"
        elif phase == "bite": next_anim = "cast"
        elif phase == "fight": next_anim = "reel"
    elif float(game.state.get("stamina", 100.0)) <= 4.0:
        next_anim = "tired"
    elif moved > 1.0:
        next_anim = "walk"

    if next_anim != current_anim:
        current_anim = next_anim
        frame_index = 0
        anim_time = 0.0
        _set_frame(current_anim, 0)

    var fps := 6.0
    if current_anim == "walk": fps = 10.0
    elif current_anim in ["cast", "reel"]: fps = 8.0
    elif current_anim == "caught": fps = 7.0

    anim_time += delta
    if anim_time >= 1.0 / fps:
        anim_time = 0.0
        var count := int(MC_COUNTS.get(current_anim, 4))
        frame_index = (frame_index + 1) % maxi(1, count)
        _set_frame(current_anim, frame_index)

    if abs(delta_pos.x) > 0.3:
        mc_sprite.flip_h = delta_pos.x < 0.0
    last_player = p

func _detect_fishing_events() -> void:
    var phase := ""
    if not game.fishing.is_empty():
        phase = str(game.fishing.get("phase", ""))
    if phase != last_phase:
        if phase == "wait":
            _spawn_vfx("line_swoosh", game.player + Vector2(35, 50), 0.42, 0.55)
            _spawn_vfx("bobber_splash", _nearest_spot_position(), 0.42, 0.70)
        elif phase == "bite":
            _spawn_vfx("exclamation_pop", game.player + Vector2(0, -95), 0.34, 0.65)
        elif phase == "fight":
            _spawn_vfx("splash_small", _nearest_spot_position(), 0.52, 0.55)
        last_phase = phase
        _sync_fish_button_icon()

func _detect_catch() -> void:
    var fish_count := int(game.state.stats.get("fish_caught", 0))
    if fish_count > last_fish_count:
        catch_anim_until = Time.get_ticks_msec() / 1000.0 + 1.15
        _spawn_vfx("catch_sparkle", game.player + Vector2(0, -85), 0.55, 1.0)
        _spawn_vfx("celebration_burst", game.player + Vector2(0, -120), 0.42, 0.9)
    last_fish_count = fish_count

func _nearest_spot_position() -> Vector2:
    var best := game.player + Vector2(0, 120)
    var best_d := 99999.0
    var spots: Array = game.fishing_spots.get(game.zone, [])
    for s in spots:
        var pos: Vector2 = s
        var d := game.player.distance_to(pos)
        if d < best_d:
            best_d = d
            best = pos
    return best

func _spawn_vfx(asset_id: String, pos: Vector2, scale_value: float, duration: float) -> void:
    var tex := get_world_texture(asset_id)
    if tex == null: return
    var sprite := Sprite2D.new()
    sprite.texture = tex
    sprite.position = pos
    sprite.scale = Vector2.ONE * scale_value
    sprite.z_index = 75
    game.add_child(sprite)
    var tween := create_tween()
    tween.set_parallel(true)
    tween.tween_property(sprite, "scale", sprite.scale * 1.18, duration)
    tween.tween_property(sprite, "modulate:a", 0.0, duration)
    tween.set_parallel(false)
    tween.tween_callback(Callable(sprite, "queue_free"))

func _refresh_world_props() -> void:
    for n in world_nodes:
        if is_instance_valid(n): n.queue_free()
    world_nodes.clear()
    if str(game.zone) == "village":
        _add_prop("dock", Vector2(360,955), 0.46, 8)
        _add_prop("signpost", Vector2(635,720), 0.27, 6)
        _add_prop("reeds", Vector2(92,845), 0.22, 4)
        _add_prop("rocks", Vector2(615,850), 0.18, 4)
        _add_prop("lantern_post", Vector2(275,815), 0.23, 7)
        _add_prop("fish_crate", Vector2(257,430), 0.20, 4)
        _add_prop("market_basket", Vector2(315,460), 0.18, 4)
        _add_prop("canoe", Vector2(555,1015), 0.25, 5)
        _add_prop("cooler", Vector2(125,1005), 0.22, 5)
    else:
        _add_prop("dock", Vector2(360,925), 0.38, 8)
        _add_prop("reeds", Vector2(95,820), 0.27, 4)
        _add_prop("reeds", Vector2(625,790), 0.23, 4)
        _add_prop("rocks", Vector2(590,840), 0.20, 4)
        _add_prop("water_lily", Vector2(165,980), 0.26, 4)
        _add_prop("bamboo_fence", Vector2(115,610), 0.22, 3)
        _add_prop("canoe", Vector2(535,995), 0.24, 5)
        _add_prop("mooring_pole", Vector2(430,930), 0.25, 6)
        _add_prop("campfire", Vector2(555,550), 0.20, 5)
        _add_prop("basket", Vector2(130,505), 0.18, 4)
        _add_prop("bait_bucket", Vector2(585,650), 0.18, 4)

func _add_prop(asset_id: String, pos: Vector2, scale_value: float, z: int) -> void:
    var tex := get_world_texture(asset_id)
    if tex == null: return
    var sprite := Sprite2D.new()
    sprite.texture = tex
    sprite.position = pos
    var quality_scale := 2.7 if world_sheet != null and world_sheet.get_width() < 1000 else 1.0
    sprite.scale = Vector2.ONE * scale_value * quality_scale
    sprite.z_index = z
    game.add_child(sprite)
    world_nodes.append(sprite)

func _sync_ui_buttons() -> void:
    if game == null: return
    var interact_button = game.touch_buttons.get("interact")
    if interact_button is Button: _apply_button_icon(interact_button as Button, "chat")
    var status_button = game.touch_buttons.get("status")
    if status_button is Button: _apply_button_icon(status_button as Button, "inventory")
    _sync_fish_button_icon()
    var ext := game.get_node_or_null("V05Extension")
    if ext != null:
        var mission = ext.get("mission_button")
        if mission is Button: _apply_button_icon(mission as Button, "mission")
        var gear = ext.get("gear_button")
        if gear is Button: _apply_button_icon(gear as Button, "settings")

func _sync_fish_button_icon() -> void:
    if game == null: return
    var fish_button = game.touch_buttons.get("fish")
    if not (fish_button is Button): return
    var id := "cast"
    if not game.fishing.is_empty() and str(game.fishing.get("phase", "")) == "fight": id = "reel"
    _apply_button_icon(fish_button as Button, id)

func _apply_button_icon(button: Button, asset_id: String) -> void:
    var tex := get_ui_texture(asset_id)
    if tex == null: return
    button.icon = tex
    button.expand_icon = true
    button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _set_frame(anim: String, index: int) -> void:
    if mc_sprite == null: return
    var direct := get_mc_texture(anim, index)
    if direct != null:
        mc_sprite.texture = direct
        return
    if mc_sheet == null: return
    var regions: Array = MC_FALLBACK.get(anim, MC_FALLBACK["idle"])
    if regions.is_empty(): return
    mc_sprite.texture = _atlas(mc_sheet, regions[index % regions.size()])

func _has_mc_frame(anim: String, index: int) -> bool:
    return ResourceLoader.exists(MC_ROOT + "%s_%d.webp" % [anim, index])

func get_mc_texture(anim: String, index: int) -> Texture2D:
    return _load_texture(MC_ROOT + "%s_%d.webp" % [anim, index])

func get_ui_texture(asset_id: String) -> Texture2D:
    var direct := _load_texture(UI_ROOT + asset_id + ".webp")
    if direct != null: return direct
    if ui_sheet != null and UI_REGIONS.has(asset_id): return _atlas(ui_sheet, UI_REGIONS[asset_id])
    return null

func get_item_texture(asset_id: String) -> Texture2D:
    var direct := _load_texture(ITEM_ROOT + asset_id + ".webp")
    if direct != null: return direct
    if item_sheet != null and ITEM_REGIONS.has(asset_id): return _atlas(item_sheet, ITEM_REGIONS[asset_id])
    return null

func get_world_texture(asset_id: String) -> Texture2D:
    var direct := _load_texture(WORLD_ROOT + asset_id + ".webp")
    if direct != null: return direct
    if world_sheet != null and WORLD_REGIONS.has(asset_id): return _atlas(world_sheet, WORLD_REGIONS[asset_id])
    return null

func get_asset_texture(group: String, asset_id: String = "") -> Texture2D:
    match group:
        "ui": return get_ui_texture(asset_id)
        "item": return get_item_texture(asset_id)
        "world", "vfx": return get_world_texture(asset_id)
        _:
            return null

func _atlas(sheet: Texture2D, original_region: Rect2) -> Texture2D:
    var sx := float(sheet.get_width()) / MASTER_SIZE.x
    var sy := float(sheet.get_height()) / MASTER_SIZE.y
    var atlas := AtlasTexture.new()
    atlas.atlas = sheet
    atlas.region = Rect2(original_region.position.x * sx, original_region.position.y * sy, original_region.size.x * sx, original_region.size.y * sy)
    return atlas

func _load_texture(path: String) -> Texture2D:
    if texture_cache.has(path): return texture_cache[path]
    if not ResourceLoader.exists(path): return null
    var tex := load(path) as Texture2D
    texture_cache[path] = tex
    return tex

func _make_ellipse_texture(w: int, h: int) -> Texture2D:
    var image := Image.create(w, h, false, Image.FORMAT_RGBA8)
    image.fill(Color(0,0,0,0))
    var cx := w / 2.0
    var cy := h / 2.0
    for y in range(h):
        for x in range(w):
            var nx := (x - cx) / maxf(1.0, cx)
            var ny := (y - cy) / maxf(1.0, cy)
            if nx * nx + ny * ny <= 1.0:
                image.set_pixel(x, y, Color(0.03,0.05,0.04,0.7))
    return ImageTexture.create_from_image(image)
