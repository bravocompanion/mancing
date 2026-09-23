extends Node

# Kail Kampung visual integration layer.
# Generated assets are kept separate from gameplay logic so the original
# procedural renderer remains a safe fallback if an image is unavailable.

const ASSET_ROOT := "res://assets/generated/"
const MC_ROOT := ASSET_ROOT + "sliced/mc/"
const UI_ROOT := ASSET_ROOT + "sliced/ui/"
const ITEM_ROOT := ASSET_ROOT + "sliced/items/"
const WORLD_ROOT := ASSET_ROOT + "sliced/world/"
const MC_SHEET := ASSET_ROOT + "mc_animations.webp"

const MC_COUNTS := {
    "idle": 4,
    "walk": 8,
    "run": 8,
    "cast": 6,
    "reel": 6,
    "caught": 4,
    "tired": 4,
    "wait": 4
}

# Fallback regions on the generated 1448x1086 master sprite sheet.
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

var game: Node2D
var mc_sprite: Sprite2D
var mc_shadow: Sprite2D
var mc_sheet: Texture2D
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

    if ResourceLoader.exists(MC_SHEET):
        mc_sheet = load(MC_SHEET) as Texture2D

    if not _has_mc_frame("idle", 0) and mc_sheet == null:
        push_warning("Kail Kampung visual pack belum ada di res://assets/generated/. Gameplay fallback tetap aktif.")
        return

    _install_mc()
    last_player = game.player
    last_zone = str(game.zone)
    last_fish_count = int(game.state.stats.get("fish_caught", 0))
    _refresh_world_props()
    _sync_ui_buttons()
    visual_ready = true

func _install_mc() -> void:
    mc_shadow = Sprite2D.new()
    mc_shadow.z_index = 40
    mc_shadow.texture = _make_ellipse_texture(110, 34)
    mc_shadow.modulate = Color(1, 1, 1, 0.28)
    game.add_child(mc_shadow)

    mc_sprite = Sprite2D.new()
    mc_sprite.z_index = 50
    mc_sprite.centered = true
    mc_sprite.scale = Vector2(0.72, 0.72)
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
        if phase == "wait":
            next_anim = "wait"
        elif phase == "bite":
            next_anim = "cast"
        elif phase == "fight":
            next_anim = "reel"
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
    if current_anim == "walk":
        fps = 10.0
    elif current_anim in ["cast", "reel"]:
        fps = 8.0
    elif current_anim == "caught":
        fps = 7.0

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
    if tex == null:
        return
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
        if is_instance_valid(n):
            n.queue_free()
    world_nodes.clear()

    if str(game.zone) == "village":
        _add_prop("dock", Vector2(360, 955), 0.46, 8)
        _add_prop("signpost", Vector2(635, 720), 0.27, 6)
        _add_prop("reeds", Vector2(92, 845), 0.22, 4)
        _add_prop("rocks", Vector2(615, 850), 0.18, 4)
        _add_prop("lantern_post", Vector2(275, 815), 0.23, 7)
        _add_prop("fish_crate", Vector2(257, 430), 0.20, 4)
        _add_prop("market_basket", Vector2(315, 460), 0.18, 4)
        _add_prop("canoe", Vector2(555, 1015), 0.25, 5)
        _add_prop("cooler", Vector2(125, 1005), 0.22, 5)
    else:
        _add_prop("dock", Vector2(360, 925), 0.38, 8)
        _add_prop("reeds", Vector2(95, 820), 0.27, 4)
        _add_prop("reeds", Vector2(625, 790), 0.23, 4)
        _add_prop("rocks", Vector2(590, 840), 0.20, 4)
        _add_prop("water_lily", Vector2(165, 980), 0.26, 4)
        _add_prop("bamboo_fence", Vector2(115, 610), 0.22, 3)
        _add_prop("canoe", Vector2(535, 995), 0.24, 5)
        _add_prop("mooring_pole", Vector2(430, 930), 0.25, 6)
        _add_prop("campfire", Vector2(555, 550), 0.20, 5)
        _add_prop("basket", Vector2(130, 505), 0.18, 4)
        _add_prop("bait_bucket", Vector2(585, 650), 0.18, 4)

func _add_prop(asset_id: String, pos: Vector2, scale_value: float, z: int) -> void:
    var tex := get_world_texture(asset_id)
    if tex == null:
        return
    var sprite := Sprite2D.new()
    sprite.texture = tex
    sprite.position = pos
    sprite.scale = Vector2.ONE * scale_value
    sprite.z_index = z
    game.add_child(sprite)
    world_nodes.append(sprite)

func _sync_ui_buttons() -> void:
    if game == null:
        return

    var interact_button = game.touch_buttons.get("interact")
    if interact_button is Button:
        _apply_button_icon(interact_button as Button, "chat")

    var status_button = game.touch_buttons.get("status")
    if status_button is Button:
        _apply_button_icon(status_button as Button, "inventory")

    _sync_fish_button_icon()

    var ext := game.get_node_or_null("V05Extension")
    if ext != null:
        var mission = ext.get("mission_button")
        if mission is Button:
            _apply_button_icon(mission as Button, "mission")
        var gear = ext.get("gear_button")
        if gear is Button:
            _apply_button_icon(gear as Button, "settings")

func _sync_fish_button_icon() -> void:
    if game == null:
        return
    var fish_button = game.touch_buttons.get("fish")
    if not (fish_button is Button):
        return
    var id := "cast"
    if not game.fishing.is_empty() and str(game.fishing.get("phase", "")) == "fight":
        id = "reel"
    _apply_button_icon(fish_button as Button, id)

func _apply_button_icon(button: Button, asset_id: String) -> void:
    var tex := get_ui_texture(asset_id)
    if tex == null:
        return
    if button.icon != tex:
        button.icon = tex
        button.expand_icon = true
        button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _set_frame(anim: String, index: int) -> void:
    if mc_sprite == null:
        return
    var direct := get_mc_texture(anim, index)
    if direct != null:
        mc_sprite.texture = direct
        return

    if mc_sheet == null:
        return
    var regions: Array = MC_FALLBACK.get(anim, MC_FALLBACK["idle"])
    if regions.is_empty():
        return
    var atlas := AtlasTexture.new()
    atlas.atlas = mc_sheet
    atlas.region = regions[index % regions.size()]
    mc_sprite.texture = atlas

func _has_mc_frame(anim: String, index: int) -> bool:
    return ResourceLoader.exists(MC_ROOT + "%s_%d.webp" % [anim, index])

func get_mc_texture(anim: String, index: int) -> Texture2D:
    return _load_texture(MC_ROOT + "%s_%d.webp" % [anim, index])

func get_ui_texture(asset_id: String) -> Texture2D:
    return _load_texture(UI_ROOT + asset_id + ".webp")

func get_item_texture(asset_id: String) -> Texture2D:
    return _load_texture(ITEM_ROOT + asset_id + ".webp")

func get_world_texture(asset_id: String) -> Texture2D:
    return _load_texture(WORLD_ROOT + asset_id + ".webp")

func get_asset_texture(group: String, asset_id: String = "") -> Texture2D:
    match group:
        "ui": return get_ui_texture(asset_id)
        "item": return get_item_texture(asset_id)
        "world", "vfx": return get_world_texture(asset_id)
        "mc": return get_mc_texture(asset_id, 0)
        _:
            return null

func _load_texture(path: String) -> Texture2D:
    if texture_cache.has(path):
        return texture_cache[path]
    if not ResourceLoader.exists(path):
        return null
    var tex := load(path) as Texture2D
    texture_cache[path] = tex
    return tex

func _make_ellipse_texture(w: int, h: int) -> Texture2D:
    var image := Image.create(w, h, false, Image.FORMAT_RGBA8)
    image.fill(Color(0, 0, 0, 0))
    var cx := w / 2.0
    var cy := h / 2.0
    for y in range(h):
        for x in range(w):
            var nx := (x - cx) / maxf(1.0, cx)
            var ny := (y - cy) / maxf(1.0, cy)
            if nx * nx + ny * ny <= 1.0:
                image.set_pixel(x, y, Color(0.03, 0.05, 0.04, 0.7))
    return ImageTexture.create_from_image(image)
