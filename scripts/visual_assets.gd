extends Node

# Kail Kampung visual asset integration layer.
# The game remains playable if an asset is missing; procedural drawing stays as fallback.

const ASSET_ROOT := "res://assets/generated/"
const MC_SHEET := ASSET_ROOT + "mc_animations.webp"
const MC_REFERENCE := ASSET_ROOT + "mc_reference.webp"
const INVENTORY_SHEET := ASSET_ROOT + "inventory_icons.webp"
const UI_SHEET := ASSET_ROOT + "ui_icons.webp"
const WORLD_VFX_SHEET := ASSET_ROOT + "world_vfx.webp"

var game: Node2D
var mc_sprite: Sprite2D
var mc_shadow: Sprite2D
var mc_sheet: Texture2D
var visual_ready := false
var last_player := Vector2.ZERO
var anim_time := 0.0
var frame_index := 0
var current_anim := "idle"

const MC_FRAMES := {
    "idle": [Rect2(205,0,145,165),Rect2(355,0,145,165),Rect2(505,0,145,165),Rect2(655,0,145,165)],
    "walk": [Rect2(195,155,145,150),Rect2(340,155,145,150),Rect2(485,155,145,150),Rect2(630,155,145,150),Rect2(775,155,145,150),Rect2(920,155,145,150),Rect2(1065,155,145,150),Rect2(1210,155,145,150)],
    "run": [Rect2(195,300,150,150),Rect2(345,300,150,150),Rect2(495,300,150,150),Rect2(645,300,150,150),Rect2(795,300,150,150),Rect2(945,300,150,150),Rect2(1095,300,150,150),Rect2(1245,300,150,150)],
    "cast": [Rect2(185,445,190,150),Rect2(375,445,190,150),Rect2(565,445,190,150),Rect2(755,445,190,150),Rect2(945,445,190,150),Rect2(1135,445,250,150)],
    "reel": [Rect2(190,590,180,150),Rect2(370,590,180,150),Rect2(550,590,180,150),Rect2(730,590,180,150),Rect2(910,590,180,150),Rect2(1090,590,240,150)],
    "caught": [Rect2(200,735,165,145),Rect2(365,735,165,145),Rect2(530,735,165,145),Rect2(695,735,165,145)],
    "tired": [Rect2(200,865,165,120),Rect2(365,865,165,120),Rect2(530,865,210,120),Rect2(740,865,210,120)],
    "wait": [Rect2(200,970,200,115),Rect2(400,970,200,115),Rect2(600,970,200,115),Rect2(800,970,230,115)]
}

func _ready() -> void:
    process_priority = 90
    call_deferred("_late_ready")

func _late_ready() -> void:
    game = get_parent() as Node2D
    if game == null:
        return
    if not FileAccess.file_exists(MC_SHEET):
        push_warning("Kail Kampung visual pack belum ditemukan di assets/generated/. Procedural fallback tetap aktif.")
        return
    mc_sheet = load(MC_SHEET) as Texture2D
    if mc_sheet == null:
        return
    _install_mc()
    last_player = game.player
    visual_ready = true

func _install_mc() -> void:
    mc_shadow = Sprite2D.new()
    mc_shadow.z_index = 40
    mc_shadow.texture = _make_ellipse_texture(110,34)
    mc_shadow.modulate = Color(1,1,1,0.28)
    game.add_child(mc_shadow)

    mc_sprite = Sprite2D.new()
    mc_sprite.z_index = 50
    mc_sprite.centered = true
    mc_sprite.scale = Vector2(0.72,0.72)
    game.add_child(mc_sprite)
    _set_frame("idle",0)

func _process(delta: float) -> void:
    if not visual_ready or game == null or mc_sprite == null:
        return

    var p: Vector2 = game.player
    var delta_pos := p - last_player
    var moved := delta_pos.length()
    mc_sprite.position = p + Vector2(0,-28)
    mc_shadow.position = p + Vector2(0,18)

    var next_anim := "idle"
    if not game.fishing.is_empty():
        var phase := str(game.fishing.get("phase",""))
        if phase == "wait": next_anim = "wait"
        elif phase == "bite": next_anim = "cast"
        elif phase == "fight": next_anim = "reel"
    elif moved > 1.0:
        next_anim = "walk"

    if next_anim != current_anim:
        current_anim = next_anim
        frame_index = 0
        anim_time = 0.0

    var fps := 6.0
    if current_anim == "walk": fps = 10.0
    elif current_anim in ["cast","reel"]: fps = 8.0
    anim_time += delta
    if anim_time >= 1.0 / fps:
        anim_time = 0.0
        frame_index = (frame_index + 1) % (MC_FRAMES[current_anim] as Array).size()
        _set_frame(current_anim,frame_index)

    if abs(delta_pos.x) > 0.3:
        mc_sprite.flip_h = delta_pos.x < 0.0
    last_player = p

func play_catch() -> void:
    if not visual_ready:
        return
    current_anim = "caught"
    frame_index = 0
    anim_time = 0.0
    _set_frame("caught",0)

func _set_frame(anim: String,index: int) -> void:
    var frames: Array = MC_FRAMES.get(anim,MC_FRAMES["idle"])
    if frames.is_empty() or mc_sheet == null:
        return
    var atlas := AtlasTexture.new()
    atlas.atlas = mc_sheet
    atlas.region = frames[index % frames.size()]
    mc_sprite.texture = atlas

func _make_ellipse_texture(w: int,h: int) -> Texture2D:
    var image := Image.create(w,h,false,Image.FORMAT_RGBA8)
    image.fill(Color(0,0,0,0))
    var cx := w / 2.0
    var cy := h / 2.0
    for y in range(h):
        for x in range(w):
            var nx := (x - cx) / maxf(1.0,cx)
            var ny := (y - cy) / maxf(1.0,cy)
            if nx*nx + ny*ny <= 1.0:
                image.set_pixel(x,y,Color(0.03,0.05,0.04,0.7))
    return ImageTexture.create_from_image(image)

func get_asset_texture(kind: String) -> Texture2D:
    var path := ""
    match kind:
        "mc_reference": path = MC_REFERENCE
        "inventory": path = INVENTORY_SHEET
        "ui": path = UI_SHEET
        "world_vfx": path = WORLD_VFX_SHEET
        _: path = ""
    if path != "" and FileAccess.file_exists(path):
        return load(path) as Texture2D
    return null
