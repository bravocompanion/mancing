extends Node

# Kail Kampung visual runtime v2.
# MC uses a dedicated normalized high-resolution atlas; compact atlas remains UI/props only.

const RUNTIME_ATLAS_PATH := "res://assets/generated/kail_runtime_atlas.webp"
const MC_ATLAS_PATH := "res://assets/generated/mc_character_atlas.webp"
const OLD_SHEET_SCALE := 128.0 / 1448.0
const INV_OFFSET := Vector2(128, 0)
const UI_OFFSET := Vector2(0, 96)
const WORLD_OFFSET := Vector2(128, 96)

const MC_CELL := Vector2(160, 120)
const MC_COLUMNS := 8
const MC_SCALE := 0.80
const MC_Y_OFFSET := -44.0

const MC_ANIMS := {
    "idle": [0, 1, 2, 3],
    "walk": [4, 5, 6, 7, 8, 9, 10, 11],
    "run": [12, 13, 14, 15, 16, 17, 18, 19],
    "cast": [20, 21, 22, 23, 24, 25],
    "reel": [26, 27, 28, 29, 30, 31],
    "caught": [32, 33, 34, 35],
    "tired": [36, 37, 38, 39],
    "wait": [40, 41, 42, 43]
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

var game: Node2D
var runtime_atlas: Texture2D
var mc_atlas: Texture2D
var mc: Sprite2D
var shadow: Sprite2D
var cover: Sprite2D
var last_player := Vector2.ZERO
var current_anim := "idle"
var frame_index := 0
var anim_clock := 0.0
var catch_clock := 0.0

func _ready() -> void:
    process_priority = 90
    call_deferred("_late_ready")

func _late_ready() -> void:
    game = get_parent() as Node2D
    if game == null:
        push_error("VisualAssetsV2: game parent missing")
        return
    if not ResourceLoader.exists(MC_ATLAS_PATH):
        push_error("VisualAssetsV2: MC atlas missing: %s" % MC_ATLAS_PATH)
        return
    mc_atlas = load(MC_ATLAS_PATH) as Texture2D
    if ResourceLoader.exists(RUNTIME_ATLAS_PATH):
        runtime_atlas = load(RUNTIME_ATLAS_PATH) as Texture2D
    _install_mc()
    await get_tree().process_frame
    _decorate_buttons()
    _install_world_props()

func _process(delta: float) -> void:
    if game == null or mc == null:
        return
    var p: Vector2 = game.player
    var movement: Vector2 = p - last_player
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
        _set_mc_frame(current_anim, frame_index)

    var fps: float = 6.0
    if current_anim == "walk": fps = 10.0
    elif current_anim in ["cast", "reel"]: fps = 8.0

    anim_clock += delta
    if anim_clock >= 1.0 / fps:
        anim_clock = 0.0
        var frames: Array = MC_ANIMS[current_anim]
        frame_index = (frame_index + 1) % frames.size()
        _set_mc_frame(current_anim, frame_index)

    mc.position = p + Vector2(0, MC_Y_OFFSET)
    shadow.position = p + Vector2(0, 18)
    cover.position = p + Vector2(0, 10)
    cover.modulate = _ground_color(p)
    if abs(movement.x) > 0.2:
        mc.flip_h = movement.x < 0.0
    last_player = p

func _install_mc() -> void:
    shadow = Sprite2D.new()
    shadow.texture = _ellipse_texture(94, 28)
    shadow.modulate = Color(1, 1, 1, 0.28)
    shadow.z_index = 46
    game.add_child(shadow)

    # Covers the old procedural player body still drawn by main.gd.
    cover = Sprite2D.new()
    cover.texture = _cover_texture(38, 52)
    cover.z_index = 45
    game.add_child(cover)

    mc = Sprite2D.new()
    mc.z_index = 50
    mc.centered = true
    mc.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    mc.scale = Vector2(MC_SCALE, MC_SCALE)
    game.add_child(mc)
    last_player = game.player
    _set_mc_frame("idle", 0)

func _set_mc_frame(anim: String, local_index: int) -> void:
    var frames: Array = MC_ANIMS.get(anim, MC_ANIMS["idle"])
    var absolute_index: int = int(frames[local_index % frames.size()])
    var col: int = absolute_index % MC_COLUMNS
    var row: int = absolute_index / MC_COLUMNS
    var tex := AtlasTexture.new()
    tex.atlas = mc_atlas
    tex.region = Rect2(float(col) * MC_CELL.x, float(row) * MC_CELL.y, MC_CELL.x, MC_CELL.y)
    mc.texture = tex

func play_catch() -> void:
    catch_clock = 1.2
    current_anim = "caught"
    frame_index = 0
    anim_clock = 0.0
    _set_mc_frame("caught", 0)
    if game != null:
        spawn_vfx("catch", game.player + Vector2(0, -30))

func get_ui_icon(id: String) -> Texture2D:
    if runtime_atlas == null or not UI_RECTS.has(id): return null
    return _runtime_region(UI_OFFSET, UI_RECTS[id])

func get_inventory_icon(id: String) -> Texture2D:
    if runtime_atlas == null or not INV_RECTS.has(id): return null
    return _runtime_region(INV_OFFSET, INV_RECTS[id])

func get_world_asset(id: String) -> Texture2D:
    if runtime_atlas == null or not WORLD_RECTS.has(id): return null
    return _runtime_region(WORLD_OFFSET, WORLD_RECTS[id])

func _runtime_region(offset: Vector2, logical: Rect2) -> AtlasTexture:
    var tex := AtlasTexture.new()
    tex.atlas = runtime_atlas
    tex.region = Rect2(offset + logical.position * OLD_SHEET_SCALE, logical.size * OLD_SHEET_SCALE)
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
            if icon != null:
                b.icon = icon
                b.expand_icon = true

func _install_world_props() -> void:
    if runtime_atlas == null: return
    var props := [
        {"id":"dock", "p":Vector2(105, 855), "s":2.6},
        {"id":"fish_crate", "p":Vector2(565, 410), "s":2.0},
        {"id":"fence", "p":Vector2(110, 555), "s":2.0},
        {"id":"canoe", "p":Vector2(525, 815), "s":2.2}
    ]
    for d in props:
        var s := Sprite2D.new()
        s.texture = get_world_asset(str(d.get("id", "")))
        s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
        s.position = d.get("p", Vector2.ZERO)
        var prop_scale: float = float(d.get("s", 1.0))
        s.scale = Vector2(prop_scale, prop_scale)
        s.z_index = 5
        game.add_child(s)

func spawn_vfx(id: String, pos: Vector2) -> void:
    if runtime_atlas == null or not WORLD_RECTS.has(id): return
    var s := Sprite2D.new()
    s.texture = get_world_asset(id)
    s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    s.position = pos
    s.scale = Vector2(3.5, 3.5)
    s.z_index = 80
    game.add_child(s)
    var tw := create_tween()
    tw.parallel().tween_property(s, "scale", Vector2(4.3, 4.3), 0.25)
    tw.parallel().tween_property(s, "modulate:a", 0.0, 0.55)
    tw.tween_callback(s.queue_free)

func _all_nodes(root: Node) -> Array:
    var out: Array = []
    for c in root.get_children():
        out.append(c)
        out.append_array(_all_nodes(c))
    return out

func _ground_color(p: Vector2) -> Color:
    var village := game.zone == "village"
    var grass := Color("6c9658") if village else Color("637b50")
    var road := Color("b3a074") if village else Color("8c825f")
    var water := Color("3f8da8") if village else Color("477b70")
    var water_y := 920.0 if village else 890.0
    var bridge_x := 315.0 if village else 325.0
    if p.y >= 610.0 and p.y <= 690.0: return road
    if p.x >= 330.0 and p.x <= 390.0: return road
    if p.x >= bridge_x and p.x <= bridge_x + 90.0 and p.y >= water_y - 12.0: return road
    if p.y >= water_y: return water
    return grass

func _ellipse_texture(w: int, h: int) -> Texture2D:
    var image := Image.create(w, h, false, Image.FORMAT_RGBA8)
    image.fill(Color(0,0,0,0))
    var cx := float(w) / 2.0
    var cy := float(h) / 2.0
    for y in range(h):
        for x in range(w):
            var nx := (float(x)-cx) / maxf(1.0,cx)
            var ny := (float(y)-cy) / maxf(1.0,cy)
            if nx*nx + ny*ny <= 1.0:
                image.set_pixel(x,y,Color(0.03,0.05,0.04,0.72))
    return ImageTexture.create_from_image(image)

func _cover_texture(w: int, h: int) -> Texture2D:
    var image := Image.create(w, h, false, Image.FORMAT_RGBA8)
    image.fill(Color.WHITE)
    return ImageTexture.create_from_image(image)
