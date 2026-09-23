extends Node

const EXT_SAVE_PATH := "user://kail_kampung_v05_ext.json"

var game: Node
var rng := RandomNumberGenerator.new()

var ext_state := {
    "day": 0,
    "market_mult": 1.0,
    "daily": {
        "day": 0,
        "fish_id": "nila",
        "target": 3,
        "progress": 0,
        "reward": 250,
        "done": false,
        "claimed": false
    }
}

var base_prices := {}
var last_inventory := {}
var last_records := {}
var last_fish_count := 0
var last_phase := ""
var special_tapah_active := false

var info_label: Label
var notice_label: Label
var popup: Panel
var popup_title: Label
var popup_body: Label
var popup_actions: VBoxContainer
var mission_button: Button
var gear_button: Button

func _ready() -> void:
    process_priority = 100
    rng.randomize()
    call_deferred("_late_ready")

func _late_ready() -> void:
    game = get_parent()
    if not game:
        return
    install_v05_fish()
    capture_base_prices()
    load_ext()
    ensure_day_systems()
    apply_market_prices()
    build_v05_ui()
    last_inventory = game.state.inventory.duplicate(true)
    last_records = game.state.caught.duplicate(true)
    last_fish_count = int(game.state.stats.get("fish_caught", 0))
    save_ext()

func install_v05_fish() -> void:
    game.fish_data["gurame"] = {
        "name":"Gurame",
        "price":88,
        "min":24.0,
        "max":58.0,
        "rarity":"Jarang",
        "diff":0.59,
        "zones":["village"],
        "trait":"Penahan",
        "reel":0.94,
        "burst":0.92,
        "loss":0.88,
        "escape":1.08
    }

func capture_base_prices() -> void:
    base_prices.clear()
    for raw_id in game.fish_data.keys():
        var id: String = str(raw_id)
        var entry: Dictionary = game.fish_data[id]
        base_prices[id] = int(entry.get("price", 0))
    base_prices["tapah"] = 700

func build_v05_ui() -> void:
    var ui := CanvasLayer.new()
    ui.layer = 15
    add_child(ui)

    info_label = Label.new()
    info_label.position = Vector2(24, 166)
    info_label.size = Vector2(672, 54)
    info_label.add_theme_font_size_override("font_size", 16)
    info_label.add_theme_color_override("font_color", Color("f5df9b"))
    ui.add_child(info_label)

    notice_label = Label.new()
    notice_label.position = Vector2(55, 1000)
    notice_label.size = Vector2(610, 38)
    notice_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    notice_label.add_theme_font_size_override("font_size", 18)
    notice_label.add_theme_color_override("font_color", Color("fff2b2"))
    ui.add_child(notice_label)

    mission_button = Button.new()
    mission_button.text = "MISI"
    mission_button.position = Vector2(365, 1035)
    mission_button.size = Vector2(80, 60)
    mission_button.add_theme_font_size_override("font_size", 16)
    mission_button.pressed.connect(open_mission)
    ui.add_child(mission_button)

    gear_button = Button.new()
    gear_button.text = "ALAT"
    gear_button.position = Vector2(450, 1035)
    gear_button.size = Vector2(80, 60)
    gear_button.add_theme_font_size_override("font_size", 16)
    gear_button.pressed.connect(open_gear)
    ui.add_child(gear_button)

    popup = Panel.new()
    popup.position = Vector2(45, 245)
    popup.size = Vector2(630, 560)
    popup.visible = false
    ui.add_child(popup)

    var box := VBoxContainer.new()
    box.position = Vector2(24, 22)
    box.size = Vector2(582, 510)
    popup.add_child(box)

    popup_title = Label.new()
    popup_title.add_theme_font_size_override("font_size", 26)
    box.add_child(popup_title)

    popup_body = Label.new()
    popup_body.custom_minimum_size = Vector2(570, 245)
    popup_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    popup_body.add_theme_font_size_override("font_size", 19)
    box.add_child(popup_body)

    popup_actions = VBoxContainer.new()
    popup_actions.add_theme_constant_override("separation", 7)
    box.add_child(popup_actions)

func _process(_delta: float) -> void:
    if not game or not info_label:
        return

    ensure_day_systems()
    refresh_tapah()
    update_version_text()
    update_info_text()
    detect_fishing_phase()
    detect_catches()

func update_version_text() -> void:
    if game.hud:
        game.hud.text = game.hud.text.replace("v0.4", "v0.5")

func update_info_text() -> void:
    var daily: Dictionary = ext_state.get("daily", {})
    var fish_id: String = str(daily.get("fish_id", "nila"))
    var fish_name: String = fish_id
    if game.fish_data.has(fish_id):
        fish_name = str(game.fish_data[fish_id].get("name", fish_id))
    var progress: String = "SELESAI" if bool(daily.get("done", false)) else "%d/%d" % [
        int(daily.get("progress", 0)),
        int(daily.get("target", 1))
    ]
    info_label.text = "Pasar hari ini x%.2f  •  Misi: %s %s" % [
        float(ext_state.get("market_mult", 1.0)),
        fish_name,
        progress
    ]

func ensure_day_systems() -> void:
    var day: int = int(game.state.get("day", 1))
    if int(ext_state.get("day", 0)) == day:
        return

    ext_state["day"] = day
    ext_state["market_mult"] = snappedf(rng.randf_range(0.84, 1.26), 0.01)

    var candidates: Array[String] = ["nila", "mujair", "lele", "gurame", "gabus", "patin"]
    if bool(game.state.quest.get("swamp_unlocked", false)):
        candidates.append_array(["betok", "sepat", "baung"])

    var chosen: String = candidates[rng.randi_range(0, candidates.size() - 1)]
    var rarity: String = str(game.fish_data[chosen].get("rarity", "Umum"))
    var target: int = 2 if rarity == "Jarang" else 3
    ext_state["daily"] = {
        "day": day,
        "fish_id": chosen,
        "target": target,
        "progress": 0,
        "reward": 250 + int(game.state.get("level", 1)) * 55 + (100 if target == 2 else 0),
        "done": false,
        "claimed": false
    }

    apply_market_prices()
    save_ext()
    show_notice("Hari baru: harga pasar & misi berubah.")

func apply_market_prices() -> void:
    var mult: float = float(ext_state.get("market_mult", 1.0))
    for raw_id in base_prices.keys():
        var id: String = str(raw_id)
        if game.fish_data.has(id):
            game.fish_data[id]["price"] = int(round(int(base_prices[id]) * mult))

func refresh_tapah() -> void:
    var level: int = int(game.state.get("level", 1))
    var minute: float = float(game.state.get("minute", 390.0))
    var is_night: bool = minute >= 1140.0 or minute < 300.0
    var weather: String = str(game.state.get("weather", "Cerah"))
    var should_exist: bool = level >= 4 and game.zone == "swamp" and is_night and weather == "Badai"

    if should_exist and not special_tapah_active:
        var mult: float = float(ext_state.get("market_mult", 1.0))
        game.fish_data["tapah"] = {
            "name":"Tapah Tua Kedung Wungu",
            "price":int(round(700.0 * mult)),
            "min":72.0,
            "max":165.0,
            "rarity":"Langka",
            "diff":0.97,
            "zones":["swamp"],
            "trait":"Monster Dasar",
            "reel":0.68,
            "burst":1.78,
            "loss":1.42,
            "escape":0.70,
            "night":true
        }
        special_tapah_active = true
        show_notice("Air rawa terasa berat... Tapah Tua mungkin muncul.")
    elif not should_exist and special_tapah_active:
        game.fish_data.erase("tapah")
        special_tapah_active = false

func detect_fishing_phase() -> void:
    var phase: String = ""
    if not game.fishing.is_empty():
        phase = str(game.fishing.get("phase", ""))
    if phase == "bite" and last_phase != "bite":
        Input.vibrate_handheld(75)
    last_phase = phase

func detect_catches() -> void:
    var fish_count: int = int(game.state.stats.get("fish_caught", 0))
    if fish_count <= last_fish_count:
        if fish_count < last_fish_count:
            last_fish_count = fish_count
        return

    var inv: Dictionary = game.state.inventory
    for raw_id in inv.keys():
        var id: String = str(raw_id)
        var now_count: int = int(inv.get(id, 0))
        var old_count: int = int(last_inventory.get(id, 0))
        if now_count > old_count:
            for _i in range(now_count - old_count):
                on_catch_detected(id)

    last_inventory = inv.duplicate(true)
    last_fish_count = fish_count
    last_records = game.state.caught.duplicate(true)
    Input.vibrate_handheld(120)

func on_catch_detected(id: String) -> void:
    var daily: Dictionary = ext_state.get("daily", {})
    if not bool(daily.get("done", false)) and str(daily.get("fish_id", "")) == id:
        daily["progress"] = int(daily.get("progress", 0)) + 1
        if int(daily.get("progress", 0)) >= int(daily.get("target", 1)):
            daily["progress"] = int(daily.get("target", 1))
            daily["done"] = true
            show_notice("Misi harian selesai! Ambil hadiah di tombol MISI.")
        save_ext()

    if game.fish_data.has(id):
        var entry: Dictionary = game.fish_data[id]
        var record: float = float(game.state.caught.get(id, 0.0))
        var old_record: float = float(last_records.get(id, 0.0))
        var min_size: float = float(entry.get("min", 0.0))
        var max_size: float = float(entry.get("max", min_size + 1.0))
        var ratio: float = (record - min_size) / maxf(1.0, max_size - min_size)
        if record > old_record and ratio >= 0.82:
            show_notice("TROFI! %s %.1f cm — rekor baru." % [str(entry.get("name", id)), record])

        if id == "tapah":
            show_notice("LEGENDARIS! Tapah Tua Kedung Wungu berhasil ditaklukkan!")

func open_mission() -> void:
    if not can_open_popup():
        return
    var daily: Dictionary = ext_state.get("daily", {})
    var fish_id: String = str(daily.get("fish_id", "nila"))
    var fish_name: String = str(game.fish_data.get(fish_id, {"name":fish_id}).get("name", fish_id))
    var claimed: bool = bool(daily.get("claimed", false))
    var done: bool = bool(daily.get("done", false))

    popup_title.text = "Papan Misi Harian"
    popup_body.text = "Hari %d\nTangkap %d %s\nProgress: %d/%d\nHadiah: Rp%s + 35 XP\n\nHarga pasar hari ini: x%.2f\n\nRumor rawa: Tapah Tua hanya terlihat saat badai malam setelah pemancing cukup berpengalaman." % [
        int(game.state.get("day", 1)),
        int(daily.get("target", 1)),
        fish_name,
        int(daily.get("progress", 0)),
        int(daily.get("target", 1)),
        format_money(int(daily.get("reward", 250))),
        float(ext_state.get("market_mult", 1.0))
    ]
    clear_popup_actions()

    if done and not claimed:
        add_popup_button("AMBIL HADIAH", claim_daily)
    elif claimed:
        popup_body.text += "\n\nHadiah hari ini sudah diambil."
    add_popup_button("TUTUP", close_popup)
    show_popup()

func claim_daily() -> void:
    var daily: Dictionary = ext_state.get("daily", {})
    if not bool(daily.get("done", false)) or bool(daily.get("claimed", false)):
        close_popup()
        return
    daily["claimed"] = true
    var reward: int = int(daily.get("reward", 250))
    game.state.money += reward
    game.gain_xp(35)
    game.save_game()
    save_ext()
    close_popup()
    show_notice("+Rp%s • +35 XP dari misi harian." % format_money(reward))

func open_gear() -> void:
    if not can_open_popup():
        return
    var up: Dictionary = game.state.get("upgrades", {})
    popup_title.text = "Bengkel Pancing Bang Rian"
    popup_body.text = "Upgrade alat benar-benar memengaruhi pertarungan ikan.\n\nJoran Lv.%d: tarikan lebih cepat.\nSenar Lv.%d: tension lebih stabil.\nKail Lv.%d: peluang ikan langka lebih baik." % [
        int(up.get("rod",0)) + 1,
        int(up.get("line",0)) + 1,
        int(up.get("hook",0)) + 1
    ]
    clear_popup_actions()
    add_gear_button("rod", "Joran")
    add_gear_button("line", "Senar")
    add_gear_button("hook", "Kail")
    add_popup_button("TUTUP", close_popup)
    show_popup()

func add_gear_button(kind: String, caption: String) -> void:
    var up: Dictionary = game.state.get("upgrades", {})
    var level: int = int(up.get(kind, 0))
    if level >= 2:
        add_popup_button("%s — MAKSIMAL" % caption, func(): pass)
        return
    var prices: Dictionary = {
        "rod":[0,650,1800],
        "line":[0,500,1450],
        "hook":[0,450,1200]
    }
    var list: Array = prices[kind]
    var price: int = int(list[level + 1])
    add_popup_button("%s → Lv.%d  Rp%s" % [caption, level + 2, format_money(price)], func(): buy_upgrade(kind, price))

func buy_upgrade(kind: String, price: int) -> void:
    if int(game.state.money) < price:
        show_notice("Uang kurang. Butuh Rp%s." % format_money(price))
        return
    var level: int = int(game.state.upgrades.get(kind, 0))
    if level >= 2:
        return
    game.state.money -= price
    game.state.upgrades[kind] = level + 1
    game.save_game()
    show_notice("%s naik ke Lv.%d." % [gear_name(kind), level + 2])
    open_gear()

func gear_name(kind: String) -> String:
    if kind == "rod":
        return "Joran"
    if kind == "line":
        return "Senar"
    return "Kail"

func can_open_popup() -> bool:
    if popup.visible:
        close_popup()
        return false
    if game.dialog_open or game.status_label.visible:
        return false
    return true

func show_popup() -> void:
    popup.visible = true
    game.dialog_open = true

func close_popup() -> void:
    popup.visible = false
    if not game.dialog_panel.visible:
        game.dialog_open = false

func clear_popup_actions() -> void:
    for child in popup_actions.get_children():
        child.queue_free()

func add_popup_button(caption: String, callback: Callable) -> void:
    var button := Button.new()
    button.text = caption
    button.custom_minimum_size = Vector2(560, 46)
    button.add_theme_font_size_override("font_size", 17)
    button.pressed.connect(callback)
    popup_actions.add_child(button)

func show_notice(message: String) -> void:
    if not notice_label:
        return
    notice_label.text = message
    var timer := get_tree().create_timer(2.8)
    timer.timeout.connect(func():
        if notice_label and notice_label.text == message:
            notice_label.text = ""
    )

func format_money(value: int) -> String:
    var s := str(value)
    var out := ""
    var count := 0
    for i in range(s.length() - 1, -1, -1):
        if count > 0 and count % 3 == 0:
            out = "." + out
        out = s[i] + out
        count += 1
    return out

func save_ext() -> void:
    var file := FileAccess.open(EXT_SAVE_PATH, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(ext_state))

func load_ext() -> void:
    if not FileAccess.file_exists(EXT_SAVE_PATH):
        return
    var file := FileAccess.open(EXT_SAVE_PATH, FileAccess.READ)
    if not file:
        return
    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) == TYPE_DICTIONARY:
        merge_ext(ext_state, parsed)

func merge_ext(target: Dictionary, source: Dictionary) -> void:
    for key in source.keys():
        if target.has(key) and target[key] is Dictionary and source[key] is Dictionary:
            merge_ext(target[key], source[key])
        elif target.has(key):
            target[key] = source[key]
