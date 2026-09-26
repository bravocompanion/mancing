extends Node

# Kail Kampung MC failsafe.
# Guarantees the player is always represented as a cat even if the generated
# atlas fails to decode or VisualAssets exits early. The fallback automatically
# hides itself as soon as the primary MC sprite is healthy.

var game: Node2D
var fallback_cat: Sprite2D
var legacy_cover: Sprite2D
var shadow: Sprite2D
var primary_active: bool = false

func _ready() -> void:
    process_priority = 80
    call_deferred("_late_ready")

func _late_ready() -> void:
    game = get_parent() as Node2D
    if game == null:
        push_error("MCFailsafe: game parent missing")
        return

    legacy_cover = Sprite2D.new()
    legacy_cover.name = "LegacyPlayerCover"
    legacy_cover.texture = _cover_texture(60, 72)
    legacy_cover.z_index = 45
    game.add_child(legacy_cover)

    shadow = Sprite2D.new()
    shadow.name = "MCFailsafeShadow"
    shadow.texture = _ellipse_texture(84, 24)
    shadow.modulate = Color(1, 1, 1, 0.26)
    shadow.z_index = 46
    game.add_child(shadow)

    fallback_cat = Sprite2D.new()
    fallback_cat.name = "MCFallbackCat"
    fallback_cat.texture = _cat_texture(96, 104)
    fallback_cat.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    fallback_cat.z_index = 49
    game.add_child(fallback_cat)

    print("Kail Kampung MC failsafe armed")

func _process(_delta: float) -> void:
    if game == null or fallback_cat == null:
        return

    var p_value: Variant = game.get("player")
    if not (p_value is Vector2):
        return
    var p: Vector2 = p_value

    var primary: Sprite2D = _get_primary_mc()
    primary_active = primary != null and primary.texture != null and primary.visible

    fallback_cat.visible = not primary_active
    shadow.visible = not primary_active
    legacy_cover.visible = true

    legacy_cover.position = p + Vector2(0.0, 10.0)
    legacy_cover.modulate = _ground_color(p)
    fallback_cat.position = p + Vector2(0.0, -49.0)
    shadow.position = p + Vector2(0.0, 18.0)

    var movement_value: Variant = game.get("move_touch")
    if movement_value is Vector2:
        var movement: Vector2 = movement_value
        if abs(movement.x) > 0.01:
            fallback_cat.flip_h = movement.x < 0.0

func _get_primary_mc() -> Sprite2D:
    if game == null:
        return null
    var visual: Node = game.get_node_or_null("VisualAssets")
    if visual == null:
        return null
    var value: Variant = visual.get("mc")
    if value is Sprite2D:
        return value as Sprite2D
    return null

func _ground_color(p: Vector2) -> Color:
    var zone_name: String = str(game.get("zone"))
    var village: bool = zone_name == "village"
    var grass: Color = Color("6c9658") if village else Color("637b50")
    var road: Color = Color("b3a074") if village else Color("8c825f")
    var water: Color = Color("3f8da8") if village else Color("477b70")
    var water_y: float = 920.0 if village else 890.0
    var bridge_x: float = 315.0 if village else 325.0

    if p.y >= 610.0 and p.y <= 690.0:
        return road
    if p.x >= 330.0 and p.x <= 390.0:
        return road
    if p.x >= bridge_x and p.x <= bridge_x + 90.0 and p.y >= water_y - 12.0:
        return road
    if p.y >= water_y:
        return water
    return grass

func _cat_texture(w: int, h: int) -> Texture2D:
    var image: Image = Image.create(w, h, false, Image.FORMAT_RGBA8)
    image.fill(Color(0, 0, 0, 0))

    var orange := Color("e9863a")
    var orange_dark := Color("b9572d")
    var cream := Color("f6dfbf")
    var hat := Color("596149")
    var hat_dark := Color("414735")
    var shirt := Color("e7d6bd")
    var shorts := Color("516574")
    var line := Color("442d24")

    # Tail behind body.
    for y in range(50, 83):
        for x in range(4, 31):
            var dx := float(x - 20)
            var dy := float(y - 66)
            if dx * dx / 190.0 + dy * dy / 430.0 <= 1.0 and not (x > 20 and y > 66):
                image.set_pixel(x, y, orange)

    # Body and shorts.
    for y in range(49, 91):
        for x in range(28, 69):
            var dx := float(x - 48)
            var dy := float(y - 68)
            if dx * dx / 470.0 + dy * dy / 720.0 <= 1.0:
                image.set_pixel(x, y, shirt if y < 72 else shorts)

    # Head.
    for y in range(18, 61):
        for x in range(22, 75):
            var dx := float(x - 48)
            var dy := float(y - 39)
            if dx * dx + dy * dy <= 26.0 * 26.0:
                image.set_pixel(x, y, orange)

    # Ears.
    for y in range(5, 31):
        var spread: int = int(float(y - 5) * 0.55)
        for x in range(23 - spread, 24 + spread):
            if x >= 0 and x < w:
                image.set_pixel(x, y, orange)
        for x in range(72 - spread, 73 + spread):
            if x >= 0 and x < w:
                image.set_pixel(x, y, orange)

    # Muzzle.
    for y in range(37, 53):
        for x in range(34, 63):
            var dx := float(x - 48)
            var dy := float(y - 45)
            if dx * dx / 220.0 + dy * dy / 70.0 <= 1.0:
                image.set_pixel(x, y, cream)

    # Fisher hat crown + brim.
    for y in range(10, 26):
        for x in range(25, 72):
            var dx := float(x - 48)
            var dy := float(y - 20)
            if dx * dx / 610.0 + dy * dy / 170.0 <= 1.0:
                image.set_pixel(x, y, hat)
    for y in range(24, 30):
        for x in range(18, 79):
            image.set_pixel(x, y, hat_dark)

    # Eyes, nose and simple whiskers.
    for px in [38, 58]:
        for y in range(36, 42):
            for x in range(px - 2, px + 3):
                image.set_pixel(x, y, line)
    for y in range(44, 48):
        for x in range(46, 51):
            image.set_pixel(x, y, orange_dark)
    for y in [47, 50]:
        for x in range(20, 35):
            if (x + y) % 2 == 0:
                image.set_pixel(x, y, line)
        for x in range(62, 77):
            if (x + y) % 2 == 0:
                image.set_pixel(x, y, line)

    # Legs / paws.
    for y in range(84, 101):
        for x in range(31, 43):
            image.set_pixel(x, y, orange_dark)
        for x in range(54, 66):
            image.set_pixel(x, y, orange_dark)

    # Sling bag strap.
    for i in range(30):
        var x := 34 + i
        var y := 51 + int(float(i) * 0.75)
        if x < w and y < h:
            image.set_pixel(x, y, line)
            if y + 1 < h:
                image.set_pixel(x, y + 1, line)

    return ImageTexture.create_from_image(image)

func _cover_texture(w: int, h: int) -> Texture2D:
    var image: Image = Image.create(w, h, false, Image.FORMAT_RGBA8)
    image.fill(Color.WHITE)
    return ImageTexture.create_from_image(image)

func _ellipse_texture(w: int, h: int) -> Texture2D:
    var image: Image = Image.create(w, h, false, Image.FORMAT_RGBA8)
    image.fill(Color(0, 0, 0, 0))
    var cx: float = float(w) * 0.5
    var cy: float = float(h) * 0.5
    for y in range(h):
        for x in range(w):
            var nx: float = (float(x) - cx) / maxf(1.0, cx)
            var ny: float = (float(y) - cy) / maxf(1.0, cy)
            if nx * nx + ny * ny <= 1.0:
                image.set_pixel(x, y, Color(0.02, 0.03, 0.02, 0.72))
    return ImageTexture.create_from_image(image)
