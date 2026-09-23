extends Node2D

# Visual integration layer for Kail Kampung.
# Keeps gameplay/state in scripts/main.gd untouched and replaces the placeholder
# presentation with the generated cat fisherman, UI art, fish icons, props and VFX.

const SOURCE_SCALE := 160.0 / 1448.0
const SHEET_HEIGHT := 120.0
const DISPLAY_SCALE := 320.0 / 160.0

# The mobile atlas is a 160x600 transparent WebP split into text-safe chunks.
# It is reconstructed once at startup, so no loose generated PNG files are needed.
# Atlas slots: 0 reference, 1 MC sprites, 2 inventory/fish, 3 UI, 4 world/VFX.
const ATLAS_CHUNKS := [
    preload("res://assets/atlas/chunk_00.gd"),
    preload("res://assets/atlas/chunk_01_02.gd"),
    preload("res://assets/atlas/chunk_03_04.gd"),
    preload("res://assets/atlas/chunk_05_06.gd"),
    preload("res://assets/atlas/chunk_07_08.gd"),
    preload("res://assets/atlas/chunk_09_10.gd"),
    preload("res://assets/atlas/chunk_11.gd"),
    preload("res://assets/atlas/chunk_12.gd"),
    preload("res://assets/atlas/chunk_13.gd"),
    preload("res://assets/atlas/chunk_14.gd")
]

var game: Node
var master_atlas: Texture2D
var player_sprite: AnimatedSprite2D
var catch_icon: Sprite2D
var catch_fx: Sprite2D
var village_props: Array[Sprite2D] = []
var swamp_props: Array[Sprite2D] = []

var last_player_pos := Vector2.ZERO
var last_catch_text := ""
var last_fishing_empty := true
var cast_until_ms := 0
var catch_timer := 0.0


func _ready() -> void:
    game = get_parent()
    master_atlas = _load_master_atlas()
    if master_atlas == null:
        push_error("Kail Kampung generated art atlas could not be decoded.")
        set_process(false)
        return

    _build_player()
    _build_world_props()
    _build_catch_feedback()
    call_deferred("_finish_ui_setup")


func _load_master_atlas() -> Texture2D:
    var encoded := ""
    for chunk_script in ATLAS_CHUNKS:
        var constants: Dictionary = chunk_script.get_script_constant_map()
        encoded += str(constants.get("DATA", ""))

    var raw := Marshalls.base64_to_raw(encoded)
    if raw.is_empty():
        return null

    var image := Image.new()
    if image.load_webp_from_buffer(raw) != OK:
        return null
    return ImageTexture.create_from_image(image)


func _finish_ui_setup() -> void:
    # Parent _ready() creates the CanvasLayer/buttons after child _ready().
    # Deferred setup lets us decorate those existing controls without changing
    # any of their signals or gameplay behavior.
    var buttons_value = game.get("touch_buttons")
    if not (buttons_value is Dictionary):
        return
    var buttons: Dictionary = buttons_value

    _set_button_icon(buttons, "interact", _ui_icon(Rect2(545, 300, 173, 135)))
    _set_button_icon(buttons, "fish", _ui_icon(Rect2(755, 500, 195, 150)))
    _set_button_icon(buttons, "status", _ui_icon(Rect2(10, 55, 188, 170)))

    if buttons.has("fish"):
        var fish_button: Button = buttons["fish"]
        fish_button.add_theme_font_size_override("font_size", 16)
    if buttons.has("status"):
        var status_button: Button = buttons["status"]
        status_button.add_theme_font_size_override("font_size", 15)


func _set_button_icon(buttons: Dictionary, key: String, texture: Texture2D) -> void:
    if not buttons.has(key):
        return
    var button = buttons[key]
    if button is Button:
        button.icon = texture
        button.expand_icon = true


func _process(delta: float) -> void:
    if game == null or master_atlas == null:
        return

    _update_player_visual()
    _update_world_visibility()
    _update_fishing_button()
    _update_catch_feedback(delta)


func _build_player() -> void:
    player_sprite = AnimatedSprite2D.new()
    player_sprite.name = "CatFisherMC"
    player_sprite.z_index = 30
    player_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR

    var frames := SpriteFrames.new()
    _add_animation(frames, "idle", [
        Rect2(205, 0, 135, 160),
        Rect2(345, 0, 132, 160),
        Rect2(478, 0, 130, 160),
        Rect2(608, 0, 130, 160)
    ], 3.0, true)

    _add_animation(frames, "walk", [
        Rect2(195, 154, 135, 156),
        Rect2(328, 154, 132, 156),
        Rect2(460, 154, 145, 156),
        Rect2(610, 154, 145, 156),
        Rect2(755, 154, 145, 156),
        Rect2(900, 154, 145, 156),
        Rect2(1038, 154, 145, 156),
        Rect2(1182, 154, 140, 156)
    ], 8.0, true)

    # Generated casting row contains long fishing-line arcs that overlap
    # neighboring frames. Use the two clean end poses for the short cast.
    _add_animation(frames, "cast", [
        Rect2(806, 440, 225, 150),
        Rect2(1012, 440, 220, 150)
    ], 5.0, false)

    _add_animation(frames, "reel", [
        Rect2(198, 575, 215, 165),
        Rect2(395, 575, 205, 165),
        Rect2(595, 575, 215, 165),
        Rect2(800, 580, 220, 160),
        Rect2(985, 585, 230, 155)
    ], 7.0, true)

    _add_animation(frames, "caught", [
        Rect2(395, 730, 145, 150),
        Rect2(575, 730, 145, 150),
        Rect2(755, 725, 155, 155)
    ], 4.0, false)

    _add_animation(frames, "wait", [
        Rect2(195, 970, 210, 116),
        Rect2(625, 970, 215, 116),
        Rect2(850, 970, 210, 116)
    ], 3.0, true)

    _add_animation(frames, "tired", [
        Rect2(390, 865, 225, 210),
        Rect2(565, 875, 195, 105),
        Rect2(795, 890, 210, 95)
    ], 2.0, true)

    player_sprite.sprite_frames = frames
    player_sprite.scale = Vector2.ONE * (2.02 * DISPLAY_SCALE)
    player_sprite.play("idle")
    add_child(player_sprite)


func _add_animation(frames: SpriteFrames, name: String, regions: Array, fps: float, looped: bool) -> void:
    frames.add_animation(name)
    frames.set_animation_speed(name, fps)
    frames.set_animation_loop(name, looped)
    for region in regions:
        frames.add_frame(name, _mc_frame(region))


func _update_player_visual() -> void:
    var player_value = game.get("player")
    if not (player_value is Vector2):
        return

    var pos: Vector2 = player_value
    player_sprite.position = pos + Vector2(0, 6)

    var dx := pos.x - last_player_pos.x
    if absf(dx) > 0.25:
        player_sprite.flip_h = dx < 0.0

    var fishing_value = game.get("fishing")
    var fishing: Dictionary = fishing_value if fishing_value is Dictionary else {}
    var fishing_empty := fishing.is_empty()
    var now_ms := Time.get_ticks_msec()

    if last_fishing_empty and not fishing_empty:
        cast_until_ms = now_ms + 430

    var tension_text := _tension_text()
    var target_animation := "idle"

    if tension_text.begins_with("Dapat "):
        target_animation = "caught"
    elif now_ms < cast_until_ms:
        target_animation = "cast"
    elif not fishing_empty:
        var phase := str(fishing.get("phase", ""))
        if phase == "fight":
            target_animation = "reel"
        else:
            target_animation = "wait"
    elif pos.distance_to(last_player_pos) > 0.35:
        target_animation = "walk"

    if player_sprite.animation != target_animation:
        player_sprite.play(target_animation)
    elif not player_sprite.is_playing():
        player_sprite.play(target_animation)

    last_player_pos = pos
    last_fishing_empty = fishing_empty


func _build_world_props() -> void:
    # Village: small fishing settlement details around the existing playable map.
    _add_prop(village_props, Rect2(17, 14, 644, 295), Vector2(360, 952), 0.92, 1) # dock
    _add_prop(village_props, Rect2(907, 62, 276, 211), Vector2(285, 390), 0.71, 2) # fish crate
    _add_prop(village_props, Rect2(1199, 102, 231, 185), Vector2(415, 393), 0.64, 2) # basket
    _add_prop(village_props, Rect2(253, 309, 196, 244), Vector2(623, 730), 0.64, 2) # signpost
    _add_prop(village_props, Rect2(23, 556, 278, 233), Vector2(110, 690), 0.64, 1) # bamboo fence
    _add_prop(village_props, Rect2(292, 565, 160, 244), Vector2(575, 805), 0.64, 2) # lantern
    _add_prop(village_props, Rect2(950, 618, 232, 176), Vector2(500, 850), 0.58, 2) # cooler
    _add_prop(village_props, Rect2(1198, 564, 234, 231), Vector2(295, 565), 0.52, 2) # market basket

    # Swamp: denser reeds, rocks, canoe and night-fishing details.
    _add_prop(swamp_props, Rect2(481, 600, 312, 200), Vector2(210, 835), 0.80, 1) # canoe
    _add_prop(swamp_props, Rect2(471, 289, 279, 255), Vector2(120, 775), 0.64, 1) # reeds
    _add_prop(swamp_props, Rect2(765, 343, 340, 196), Vector2(560, 780), 0.58, 1) # rocks
    _add_prop(swamp_props, Rect2(1114, 353, 310, 180), Vector2(505, 920), 0.61, 1) # lilies
    _add_prop(swamp_props, Rect2(790, 563, 156, 217), Vector2(385, 895), 0.58, 2) # mooring
    _add_prop(swamp_props, Rect2(28, 784, 275, 184), Vector2(560, 570), 0.58, 2) # campfire
    _add_prop(swamp_props, Rect2(36, 327, 189, 205), Vector2(250, 535), 0.48, 2) # bait bucket
    _add_prop(swamp_props, Rect2(681, 103, 208, 176), Vector2(610, 505), 0.58, 2) # stool


func _add_prop(target: Array[Sprite2D], region: Rect2, pos: Vector2, scale_value: float, z: int) -> void:
    var sprite := Sprite2D.new()
    sprite.texture = _world_icon(region)
    sprite.position = pos
    sprite.scale = Vector2.ONE * (scale_value * DISPLAY_SCALE)
    sprite.z_index = z
    sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    add_child(sprite)
    target.append(sprite)


func _update_world_visibility() -> void:
    var zone := str(game.get("zone"))
    var show_village := zone == "village"
    for prop in village_props:
        prop.visible = show_village
    for prop in swamp_props:
        prop.visible = not show_village


func _build_catch_feedback() -> void:
    catch_fx = Sprite2D.new()
    catch_fx.texture = _world_icon(Rect2(414, 921, 203, 150))
    catch_fx.visible = false
    catch_fx.z_index = 38
    catch_fx.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    add_child(catch_fx)

    catch_icon = Sprite2D.new()
    catch_icon.visible = false
    catch_icon.z_index = 40
    catch_icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    add_child(catch_icon)


func _update_catch_feedback(delta: float) -> void:
    var text := _tension_text()
    if text.begins_with("Dapat ") and text != last_catch_text:
        last_catch_text = text
        catch_icon.texture = _fish_texture_for_message(text)
        catch_timer = 1.65
        catch_icon.visible = true
        catch_fx.visible = true

    if catch_timer > 0.0:
        catch_timer = maxf(0.0, catch_timer - delta)
        var player_value = game.get("player")
        var base_pos: Vector2 = player_value if player_value is Vector2 else Vector2(360, 700)
        var progress := 1.0 - catch_timer / 1.65
        catch_icon.position = base_pos + Vector2(0, -72.0 - progress * 34.0)
        catch_fx.position = base_pos + Vector2(0, -72.0)
        catch_icon.scale = Vector2.ONE * ((1.66 + progress * 0.25) * DISPLAY_SCALE)
        catch_fx.scale = Vector2.ONE * ((1.47 + progress * 0.32) * DISPLAY_SCALE)
        var alpha := clampf(catch_timer / 0.35, 0.0, 1.0)
        catch_icon.modulate.a = alpha
        catch_fx.modulate.a = alpha
    else:
        catch_icon.visible = false
        catch_fx.visible = false

    if not text.begins_with("Dapat "):
        last_catch_text = ""


func _update_fishing_button() -> void:
    var buttons_value = game.get("touch_buttons")
    if not (buttons_value is Dictionary):
        return
    var buttons: Dictionary = buttons_value
    if not buttons.has("fish"):
        return
    var button = buttons["fish"]
    if not (button is Button):
        return

    var fishing_value = game.get("fishing")
    var fishing: Dictionary = fishing_value if fishing_value is Dictionary else {}
    var state_value = game.get("state")
    var bait_count := 0
    if state_value is Dictionary:
        bait_count = int(state_value.get("bait", 0))

    if not fishing.is_empty() and str(fishing.get("phase", "")) == "fight":
        button.icon = _ui_icon(Rect2(985, 500, 197, 150))
    elif bait_count <= 0:
        button.icon = _ui_icon(Rect2(1220, 500, 220, 150))
    else:
        button.icon = _ui_icon(Rect2(755, 500, 195, 150))


func _fish_texture_for_message(text: String) -> Texture2D:
    # Map existing Indonesian fish names to the closest generated species art.
    if "Lele" in text or "Patin" in text or "Baung" in text:
        return _inventory_icon(Rect2(0, 930, 185, 115)) # catfish
    if "Gabus" in text or "Toman" in text:
        return _inventory_icon(Rect2(555, 930, 205, 115)) # snakehead
    if "Sidat" in text:
        return _inventory_icon(Rect2(780, 930, 145, 115)) # eel
    if "Wader" in text or "Belida" in text:
        return _inventory_icon(Rect2(370, 930, 175, 115)) # carp / generic fish
    return _inventory_icon(Rect2(190, 930, 170, 115)) # tilapia for nila/mujair/betok/sepat


func _tension_text() -> String:
    var value = game.get("tension_label")
    if value is Label:
        return value.text
    return ""


func _mc_frame(region: Rect2) -> AtlasTexture:
    return _atlas(1, region)


func _ui_icon(region: Rect2) -> AtlasTexture:
    return _atlas(3, region)


func _inventory_icon(region: Rect2) -> AtlasTexture:
    return _atlas(2, region)


func _world_icon(region: Rect2) -> AtlasTexture:
    return _atlas(4, region)


func _atlas(sheet_index: int, source_region: Rect2) -> AtlasTexture:
    var texture := AtlasTexture.new()
    texture.atlas = master_atlas
    texture.region = Rect2(
        Vector2(
            source_region.position.x * SOURCE_SCALE,
            source_region.position.y * SOURCE_SCALE + float(sheet_index) * SHEET_HEIGHT
        ),
        source_region.size * SOURCE_SCALE
    )
    return texture
