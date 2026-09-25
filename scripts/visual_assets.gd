extends Node

# Kail Kampung runtime visual pack. One compact atlas keeps Git pulls/mobile imports small.
const ATLAS_PATH := "res://assets/generated/kail_runtime_atlas.webp"
const SHEET_SCALE := 128.0 / 1448.0
const MC_OFFSET := Vector2(0, 0)
const INV_OFFSET := Vector2(128, 0)
const UI_OFFSET := Vector2(0, 96)
const WORLD_OFFSET := Vector2(128, 96)

var game: Node2D
var atlas: Texture2D
var mc: Sprite2D
var shadow: Sprite2D
var last_player := Vector2.ZERO
var current_anim := "idle"
var frame_index := 0
var anim_clock := 0.0
var catch_clock := 0.0

const MC_FRAMES := {
    "idle":[Rect2(205,0,145,165),Rect2(355,0,145,165),Rect2(505,0,145,165),Rect2(655,0,145,165)],
    "walk":[Rect2(195,155,145,150),Rect2(340,155,145,150),Rect2(485,155,145,150),Rect2(630,155,145,150),Rect2(775,155,145,150),Rect2(920,155,145,150),Rect2(1065,155,145,150),Rect2(1210,155,145,150)],
    "run":[Rect2(195,300,150,150),Rect2(345,300,150,150),Rect2(495,300,150,150),Rect2(645,300,150,150),Rect2(795,300,150,150),Rect2(945,300,150,150),Rect2(1095,300,150,150),Rect2(1245,300,150,150)],
    "cast":[Rect2(185,445,190,150),Rect2(375,445,190,150),Rect2(565,445,190,150),Rect2(755,445,190,150),Rect2(945,445,190,150),Rect2(1135,445,250,150)],
    "reel":[Rect2(190,590,180,150),Rect2(370,590,180,150),Rect2(550,590,180,150),Rect2(730,590,180,150),Rect2(910,590,180,150),Rect2(1090,590,240,150)],
    "caught":[Rect2(200,735,165,145),Rect2(365,735,165,145),Rect2(530,735,165,145),Rect2(695,735,165,145)],
    "tired":[Rect2(200,865,165,120),Rect2(365,865,165,120),Rect2(530,865,210,120),Rect2(740,865,210,120)],
    "wait":[Rect2(200,970,200,115),Rect2(400,970,200,115),Rect2(600,970,200,115),Rect2(800,970,230,115)]
}

const UI_RECTS := {
    "inventory":Rect2(20,20,170,230), "quest":Rect2(190,20,170,230), "map":Rect2(365,20,180,230),
    "settings":Rect2(545,20,175,230), "home":Rect2(720,20,175,230), "shop":Rect2(895,20,175,230),
    "coin":Rect2(1070,20,165,230), "gem":Rect2(1230,20,180,230), "energy":Rect2(20,275,160,205),
    "chat":Rect2(530,275,180,205), "warning":Rect2(710,275,180,205), "check":Rect2(890,275,170,205),
    "reward":Rect2(20,490,180,210), "trophy":Rect2(200,490,185,210), "hook_meter":Rect2(385,490,340,210),
    "cast":Rect2(730,490,190,210), "reel":Rect2(920,490,190,210), "bait":Rect2(1110,490,260,210),
    "sun":Rect2(20,710,170,175), "rain":Rect2(190,710,170,175), "cloud":Rect2(360,710,170,175),
    "storm":Rect2(530,710,170,175), "day":Rect2(700,710,175,175), "night":Rect2(875,710,175,175),
    "location":Rect2(1050,710,175,175), "mission":Rect2(1225,710,180,175), "fish_book":Rect2(20,885,190,190),
    "leaderboard":Rect2(210,885,190,190), "sound_on":Rect2(400,885,180,190), "sound_off":Rect2(580,885,180,190),
    "pause":Rect2(760,885,160,190)
}

const INV_RECTS := {
    "basic_rod":Rect2(25,20,180,230), "pro_rod":Rect2(205,20,180,230), "golden_rod":Rect2(385,20,180,230),
    "bait_bucket":Rect2(565,20,180,230), "worm":Rect2(745,20,170,230), "shrimp_bait":Rect2(915,20,175,230),
    "lure":Rect2(1090,20,300,230), "hook":Rect2(20,255,165,220), "bobber":Rect2(185,255,170,220),
    "net":Rect2(355,255,190,220), "tackle":Rect2(545,255,195,220), "fish_basket":Rect2(740,255,190,220),
    "lantern":Rect2(930,255,175,220), "sandals":Rect2(1105,255,285,220), "hat":Rect2(20,485,190,215),
    "raincoat":Rect2(210,485,190,215), "energy_drink":Rect2(400,485,170,215), "rice":Rect2(570,485,190,215),
    "coins":Rect2(760,485,190,215), "gem":Rect2(950,485,170,215), "map":Rect2(1120,485,270,215),
    "compass":Rect2(20,705,190,190), "key":Rect2(210,705,175,190), "wood":Rect2(385,705,210,190),
    "rope":Rect2(595,705,230,190), "paddle":Rect2(825,705,250,190), "trophy":Rect2(1075,705,315,190),
    "catfish":Rect2(10,895,185,180), "tilapia":Rect2(195,895,185,180), "carp":Rect2(380,895,185,180),
    "snakehead":Rect2(565,895,220,180), "eel":Rect2(785,895,180,180), "shrimp":Rect2(965,895,165,180),
    "crab":Rect2(1130,895,145,180), "golden_fish":Rect2(1275,895,165,180)
}

const WORLD_RECTS := {
    "dock":Rect2(0,0,560,300), "stool":Rect2(540,20,300,250), "fish_crate":Rect2(825,20,350,250),
    "basket":Rect2(1170,20,270,250), "bait_bucket":Rect2(0,285,240,250), "sign":Rect2(240,285,280,250),
    "reeds":Rect2(520,285,300,250), "rocks":Rect2(820,285,300,250), "lilies":Rect2(1110,285,330,250),
    "fence":Rect2(0,535,430,260), "lantern_post":Rect2(430,535,260,270), "canoe":Rect2(460,535,385,270),
    "mooring":Rect2(800,535,220,270), "cooler":Rect2(1010,535,250,270), "market_basket":Rect2(1240,535,200,270),
    "campfire":Rect2(0,790,300,290), "splash":Rect2(370,820,420,240), "ripple":Rect2(790,810,390,180),
    "catch":Rect2(360,900,300,185), "alert":Rect2(650,900,150,180), "sparkle":Rect2(1030,900,180,180)
}

func _ready() -> void:
    process_priority = 90
    call_deferred("_late_ready")

func _late_ready() -> void:
    game = get_parent() as Node2D
    if game == null or not ResourceLoader.exists(ATLAS_PATH):
        push_warning("Kail Kampung runtime atlas tidak ditemukan.")
        return
    atlas = load(ATLAS_PATH) as Texture2D
    _install_mc()
    await get_tree().process_frame
    _decorate_buttons()
    _install_world_props()

func _process(delta: float) -> void:
    if game == null or mc == null:
        return
    var p: Vector2 = game.player
    var movement := p - last_player
    mc.position = p + Vector2(0, -30)
    shadow.position = p + Vector2(0, 20)
    if abs(movement.x) > 0.2:
        mc.flip_h = movement.x < 0.0
    var next_anim := "idle"
    if catch_clock > 0.0:
        catch_clock -= delta
        next_anim = "caught"
    elif not game.fishing.is_empty():
        var phase := str(game.fishing.get("phase", ""))
        if phase == "wait": next_anim = "wait"
        elif phase == "bite": next_anim = "cast"
        elif phase == "fight": next_anim = "reel"
    elif movement.length() > 1.0:
        next_anim = "walk"
    if next_anim != current_anim:
        current_anim = next_anim
        frame_index = 0
        anim_clock = 0.0
    var fps := 10.0 if current_anim == "walk" else (8.0 if current_anim in ["cast", "reel"] else 6.0)
    anim_clock += delta
    if anim_clock >= 1.0 / fps:
        anim_clock = 0.0
        var frames: Array = MC_FRAMES[current_anim]
        frame_index = (frame_index + 1) % frames.size()
        _set_mc_frame(current_anim, frame_index)
    last_player = p

func play_catch() -> void:
    catch_clock = 1.2
    current_anim = "caught"
    frame_index = 0
    _set_mc_frame("caught", 0)
    if game: spawn_vfx("catch", game.player + Vector2(0, -40))

func _install_mc() -> void:
    shadow = Sprite2D.new()
    shadow.texture = _ellipse(112, 34)
    shadow.modulate = Color(1, 1, 1, 0.28)
    shadow.z_index = 39
    game.add_child(shadow)
    mc = Sprite2D.new()
    mc.z_index = 50
    mc.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    mc.scale = Vector2(8.1, 8.1)
    game.add_child(mc)
    last_player = game.player
    _set_mc_frame("idle", 0)

func _set_mc_frame(anim: String, idx: int) -> void:
    var frames: Array = MC_FRAMES.get(anim, MC_FRAMES["idle"])
    mc.texture = _region(MC_OFFSET, frames[idx % frames.size()])

func get_ui_icon(id: String) -> Texture2D:
    return _region(UI_OFFSET, UI_RECTS[id]) if UI_RECTS.has(id) else null

func get_inventory_icon(id: String) -> Texture2D:
    return _region(INV_OFFSET, INV_RECTS[id]) if INV_RECTS.has(id) else null

func get_world_asset(id: String) -> Texture2D:
    return _region(WORLD_OFFSET, WORLD_RECTS[id]) if WORLD_RECTS.has(id) else null

func _region(offset: Vector2, logical: Rect2) -> AtlasTexture:
    var tex := AtlasTexture.new()
    tex.atlas = atlas
    tex.region = Rect2(offset + logical.position * SHEET_SCALE, logical.size * SHEET_SCALE)
    return tex

func _decorate_buttons() -> void:
    for node in _all_nodes(game):
        if node is Button:
            var b := node as Button
            var label := b.text.to_upper()
            var icon: Texture2D = null
            if label == "MISI": icon = get_ui_icon("mission")
            elif label == "ALAT": icon = get_inventory_icon("basic_rod")
            elif "MANCING" in label: icon = get_ui_icon("cast")
            elif label in ["INTERAKSI", "AKSI"]: icon = get_ui_icon("chat")
            if icon:
                b.icon = icon
                b.expand_icon = true
                b.icon_max_width = 40

func _install_world_props() -> void:
    var props := [
        {"id":"dock", "p":Vector2(105, 855), "s":2.6},
        {"id":"fish_crate", "p":Vector2(565, 410), "s":2.0},
        {"id":"fence", "p":Vector2(110, 555), "s":2.0},
        {"id":"canoe", "p":Vector2(525, 815), "s":2.2}
    ]
    for d in props:
        var s := Sprite2D.new()
        s.texture = get_world_asset(d.id)
        s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        s.position = d.p
        s.scale = Vector2(d.s, d.s)
        s.z_index = 5
        game.add_child(s)

func spawn_vfx(id: String, pos: Vector2) -> void:
    if not WORLD_RECTS.has(id): return
    var s := Sprite2D.new()
    s.texture = get_world_asset(id)
    s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    s.position = pos
    s.scale = Vector2(3.5, 3.5)
    s.z_index = 80
    game.add_child(s)
    var tw := create_tween()
    tw.parallel().tween_property(s, "scale", Vector2(4.3, 4.3), 0.25)
    tw.parallel().tween_property(s, "modulate:a", 0.0, 0.55)
    tw.tween_callback(s.queue_free)

func _all_nodes(root: Node) -> Array[Node]:
    var out: Array[Node] = []
    for c in root.get_children():
        out.append(c)
        out.append_array(_all_nodes(c))
    return out

func _ellipse(w: int, h: int) -> Texture2D:
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
