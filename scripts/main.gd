extends Node2D

const SAVE_PATH := "user://kail_kampung_save.json"
const W := 720.0
const H := 1280.0

var rng := RandomNumberGenerator.new()
var player := Vector2(360, 700)
var speed := 220.0
var move_touch := Vector2.ZERO
var fish_button_held := false
var dialog_open := false
var zone := "village"
var fishing := {}
var last_banter := {}

var state := {
    "money": 250,
    "stamina": 100.0,
    "max_stamina": 100.0,
    "day": 1,
    "minute": 390.0,
    "weather": "Cerah",
    "bait": 8,
    "level": 1,
    "xp": 0,
    "items": {"coffee": 1, "jamu": 0},
    "buffs": {"luck_casts": 0},
    "inventory": {},
    "caught": {},
    "stats": {"fish_caught": 0, "biggest": 0.0, "rare_caught": 0},
    "quest": {"nila_accepted": false, "nila_done": false, "swamp_unlocked": false},
    "side_quest": {"beni_accepted": false, "beni_ready": false, "beni_done": false, "target_size": 70.0},
    "upgrades": {"rod": 0, "line": 0, "hook": 0}
}

var fish_data := {
    "nila": {"name":"Ikan Nila","price":35,"min":18.0,"max":42.0,"rarity":"Umum","diff":0.42,"zones":["village"],"trait":"Kalem","reel":1.08,"burst":0.72,"loss":0.8,"escape":1.1},
    "mujair": {"name":"Mujair","price":42,"min":17.0,"max":38.0,"rarity":"Umum","diff":0.46,"zones":["village"],"trait":"Pelari","reel":1.0,"burst":1.05,"loss":1.18,"escape":1.0},
    "lele": {"name":"Lele Kampung","price":55,"min":22.0,"max":60.0,"rarity":"Umum","diff":0.54,"zones":["village","swamp"],"trait":"Penyelam","reel":0.95,"burst":1.12,"loss":1.05,"escape":1.0},
    "wader": {"name":"Wader","price":28,"min":10.0,"max":22.0,"rarity":"Umum","diff":0.35,"zones":["village"],"trait":"Gelisah","reel":1.18,"burst":0.88,"loss":0.92,"escape":1.18},
    "gabus": {"name":"Ikan Gabus","price":95,"min":28.0,"max":76.0,"rarity":"Jarang","diff":0.66,"zones":["village","swamp"],"trait":"Penyergap","reel":0.98,"burst":1.18,"loss":1.08,"escape":0.96},
    "patin": {"name":"Patin","price":110,"min":30.0,"max":82.0,"rarity":"Jarang","diff":0.71,"zones":["village","swamp"],"trait":"Berat","reel":0.84,"burst":1.08,"loss":0.82,"escape":1.12},
    "betok": {"name":"Ikan Betok","price":68,"min":15.0,"max":32.0,"rarity":"Umum","diff":0.52,"zones":["swamp"],"trait":"Keras Kepala","reel":0.96,"burst":1.0,"loss":0.96,"escape":1.02},
    "sepat": {"name":"Sepat Rawa","price":62,"min":14.0,"max":30.0,"rarity":"Umum","diff":0.48,"zones":["swamp"],"trait":"Kalem","reel":1.10,"burst":0.76,"loss":0.82,"escape":1.12},
    "baung": {"name":"Baung","price":135,"min":28.0,"max":75.0,"rarity":"Jarang","diff":0.77,"zones":["swamp"],"trait":"Penyelam Malam","reel":0.90,"burst":1.22,"loss":1.05,"escape":0.96,"night":true},
    "toman": {"name":"Toman","price":210,"min":38.0,"max":110.0,"rarity":"Langka","diff":0.88,"zones":["swamp"],"trait":"Brutal","reel":0.78,"burst":1.52,"loss":1.28,"escape":0.86},
    "belida": {"name":"Belida","price":240,"min":35.0,"max":96.0,"rarity":"Langka","diff":0.82,"zones":["swamp"],"trait":"Pelari Licin","reel":0.88,"burst":1.30,"loss":1.38,"escape":0.82,"night":true},
    "sidat": {"name":"Sidat Malam","price":270,"min":40.0,"max":115.0,"rarity":"Langka","diff":0.90,"zones":["village","swamp"],"trait":"Licin","reel":0.86,"burst":1.20,"loss":1.46,"escape":0.72,"night":true}
}

var npc_profiles := {
    "darto":{"name":"Pak Darto","trait":"Optimistis • jiwa ketua RT","lines":["Hidup itu kayak mancing. Belum dapat? Lempar lagi. Tetap belum? Bilang ikannya lagi rapat.","Kampung ini bakal maju. Minimal jalan depan rumah gue dulu yang maju.","Kalau masalah nggak selesai, biasanya kita bikin grup WhatsApp baru. Tambah ramai, belum tentu selesai.","Target saya sederhana: warga rukun, ikan banyak, iuran tepat waktu. Yang terakhir paling mistis.","Gagal mancing itu proses. Gagal bayar warung itu urusan Bu Yati.","Saya tadi olahraga keliling kampung. Naik motor sih, tapi keliling.","Hujan badai? Anggap aja langit lagi cuci kampung gratis.","Optimisme itu penting. Apalagi kalau saldo rekening nggak membantu."]},
    "yati":{"name":"Bu Yati","trait":"Pedagang sarkastik","lines":["Uang nggak bisa beli bahagia. Tapi bisa beli gorengan, dan itu lumayan dekat.","Ikan gede jangan langsung dipamerin. Timbang dulu. Kadang egonya doang yang kiloan.","Harga ikan naik turun. Yang stabil cuma orang ngutang bilang besok.","Warung buka tiap hari karena tagihan juga rajin datang.","Mau beli bilang beli. Mau ngutang, pura-pura nggak lihat saya aja.","Untung sedikit nggak apa-apa. Yang penting jangan sedikit terus.","Kalau mancing dapat sandal, jangan dibuang. Siapa tahu besok dapat pasangannya.","Saya bukan pelit. Saya cuma menghargai uang sampai tingkat emosional."]},
    "rian":{"name":"Bang Rian","trait":"Teknisi agak sinting","lines":["Gue pernah bikin kail pakai pegas motor. Embernya mental, ikannya enggak.","Senar murah gue tes pakai galon. Galonnya selamat, harga diri gue enggak.","Kalau alat bunyi krek, antara ikannya besar atau rancangan gue terlalu kreatif.","Gue kepikiran joran pakai shockbreaker. Tetangga sudah minta jangan.","Kalau sesuatu belum rusak, berarti belum diuji maksimal.","Kail baja ini aman. Definisi aman kita samain dulu ya.","Umpan aroma kopi gagal. Ikannya nggak melek, gue yang semalaman bangun.","Barang aneh di toko bukan cacat. Itu prototipe yang terlalu cepat dijual."]},
    "ujang":{"name":"Ujang","trait":"Politis • teori konspirasi ringan","lines":["Ikan berkurang menjelang pemilihan RT. Saya belum punya data, tapi polanya terasa.","Jalan rawa dibuka demi warga. Pertanyaannya: warga yang mana?","Kalau ikan bisa nyoblos, lele itu swing voter. Munculnya malam, susah diprediksi.","Saya netral. Semua pihak saya komentari.","Kampung butuh transparansi. Terutama anggaran umpan lomba tahun lalu.","Politik kampung sederhana: yang bawa gorengan paling banyak didengar paling lama.","Saya bukan curiga. Saya cuma punya tiga puluh tujuh pertanyaan.","Rapat mendadak biasanya antara got mampet, ayam hilang, atau parkir."]},
    "beni":{"name":"Pak Beni","trait":"Mantan pemancing lomba","lines":["Dulu saya pernah narik patin sampai perahu muter. Saksi mata cuma saya, tapi itu cukup.","Pemancing hebat itu tenang. Saya dulu tenang sekali sampai ketiduran.","Piala lomba saya masih ada. Debunya juga konsisten juara.","Ikan besar tahu siapa yang pegang joran. Makanya saya selalu berdiri meyakinkan.","Rekor itu untuk dipecahkan. Cerita lama untuk dibesarkan sedikit.","Saya nggak sombong. Saya hanya menjaga sejarah versi saya.","Kalau ikan lepas, jangan salahkan diri sendiri. Salahkan simpul dulu.","Anak muda sekarang alatnya canggih. Zaman saya sonar itu Pak RT teriak dari tepi."]},
    "tika":{"name":"Mbak Tika","trait":"Penjual jamu pseudo-ilmiah","lines":["Kopi saya bikin fokus. Kalau masih salah lempar, berarti masalahnya personal.","Jamu umpan resep keluarga. Keluarga saya nggak mancing, tapi jangan fokus ke detail.","Bahannya alami. Takaran rahasia karena saya lupa catat.","Orang kota bilang placebo. Kalau ikannya percaya, ya tetap bekerja.","Bang Rian pernah minum ramuan saya lalu bikin reel dari kipas angin.","Badan capek minum kopi. Hati capek tidur. Dompet capek jangan lihat harga.","Ramuan sudah diuji. Pengujinya saya, metodenya perasaan.","Jamu umpan jangan diminum sendiri. Nanti kamu yang tertarik sama cacing."]},
    "maman":{"name":"Mang Maman","trait":"Filosof rawa absurd","lines":["Rawa ngajarin sabar. Nyamuk ngajarin setiap pelajaran ada biayanya.","Ikan yang lepas bukan milik kita. Umpan yang hilang jelas milik kita.","Tiga jam nggak dapat ikan? Itu meditasi dengan joran.","Air tenang menghanyutkan. Air rawa juga menghanyutkan sandal.","Toman itu guru kehidupan: kalau marah, semua orang ikut repot.","Malam di rawa damai sampai ada bunyi pluk. Kita sepakat nggak perlu tahu.","Kejar ikan seperlunya. Sisanya biar takdir dan kualitas senar bekerja.","Umur singkat. Antrean ikan juga. Kail dulu, filsafat belakangan."]},
    "sari":{"name":"Sari","trait":"Pengamat lingkungan • humor datar","lines":["Air rawa bagus hari ini. Mang Maman belum protes, itu indikator.","Kalau lihat sampah, ambil. Ikan belum punya grup protes.","Katanya toman sebesar paha. Tiap diceritain ukurannya nambah.","Saya bukan gosip. Saya mendokumentasikan perilaku sosial tanpa izin responden.","Bu Yati bilang saya kebanyakan mengamati orang. Lokasi saya memang strategis.","Kalau hujan rawa hidup. Kalau badai rawa hidup banget. Kita yang mikir ulang.","Ekosistem itu seimbang. Ujang makan gorengan pas rapat juga bagian rantai makanan.","Malam rawa nggak seram. Yang seram baterai HP dua persen."]}
}

var village_npcs := {
    "darto": Vector2(180, 410), "yati": Vector2(330, 410), "rian": Vector2(500, 410),
    "tika": Vector2(405, 520), "ujang": Vector2(590, 590), "beni": Vector2(620, 350)
}
var swamp_npcs := {"maman":Vector2(190,430), "sari":Vector2(520,500)}
var fishing_spots := {
    "village":[Vector2(100,940),Vector2(280,960),Vector2(500,945),Vector2(640,965)],
    "swamp":[Vector2(90,900),Vector2(290,930),Vector2(500,910),Vector2(635,940)]
}

var hud: Label
var dialog_panel: Panel
var dialog_title: Label
var dialog_body: Label
var dialog_actions: HBoxContainer
var status_label: Label
var tension_label: Label
var hint_label: Label
var touch_buttons := {}

func _ready() -> void:
    rng.randomize()
    load_game()
    build_ui()
    queue_redraw()

func build_ui() -> void:
    var ui := CanvasLayer.new()
    add_child(ui)

    hud = Label.new()
    hud.position = Vector2(22, 18)
    hud.size = Vector2(676, 155)
    hud.add_theme_font_size_override("font_size", 22)
    hud.add_theme_color_override("font_color", Color("f4f6e9"))
    ui.add_child(hud)

    hint_label = Label.new()
    hint_label.position = Vector2(22, 1080)
    hint_label.size = Vector2(676, 48)
    hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    hint_label.add_theme_font_size_override("font_size", 18)
    ui.add_child(hint_label)

    tension_label = Label.new()
    tension_label.position = Vector2(60, 880)
    tension_label.size = Vector2(600, 120)
    tension_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    tension_label.add_theme_font_size_override("font_size", 22)
    ui.add_child(tension_label)

    dialog_panel = Panel.new()
    dialog_panel.position = Vector2(45, 250)
    dialog_panel.size = Vector2(630, 470)
    dialog_panel.visible = false
    ui.add_child(dialog_panel)

    var box := VBoxContainer.new()
    box.position = Vector2(24, 22)
    box.size = Vector2(582, 425)
    dialog_panel.add_child(box)

    dialog_title = Label.new()
    dialog_title.add_theme_font_size_override("font_size", 25)
    box.add_child(dialog_title)

    dialog_body = Label.new()
    dialog_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    dialog_body.custom_minimum_size = Vector2(570, 260)
    dialog_body.add_theme_font_size_override("font_size", 20)
    box.add_child(dialog_body)

    dialog_actions = HBoxContainer.new()
    dialog_actions.add_theme_constant_override("separation", 10)
    box.add_child(dialog_actions)

    status_label = Label.new()
    status_label.position = Vector2(40, 220)
    status_label.size = Vector2(640, 700)
    status_label.visible = false
    status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    status_label.add_theme_font_size_override("font_size", 22)
    ui.add_child(status_label)

    make_touch_button(ui,"up","▲",Vector2(95,1080),Vector2(78,70))
    make_touch_button(ui,"left","◀",Vector2(15,1155),Vector2(78,70))
    make_touch_button(ui,"down","▼",Vector2(95,1155),Vector2(78,70))
    make_touch_button(ui,"right","▶",Vector2(175,1155),Vector2(78,70))
    make_touch_button(ui,"interact","E",Vector2(455,1150),Vector2(72,76))
    make_touch_button(ui,"fish","MANCING",Vector2(535,1135),Vector2(165,92))
    make_touch_button(ui,"status","STATUS",Vector2(535,1035),Vector2(165,60))

func make_touch_button(parent:CanvasLayer,key:String,caption:String,pos:Vector2,size:Vector2)->void:
    var b := Button.new()
    b.text=caption; b.position=pos; b.size=size
    b.add_theme_font_size_override("font_size",18)
    parent.add_child(b); touch_buttons[key]=b
    if key in ["up","down","left","right"]:
        b.button_down.connect(func(): set_touch_move(key,true))
        b.button_up.connect(func(): set_touch_move(key,false))
    elif key=="fish":
        b.button_down.connect(func(): fish_button_held=true; on_fish_pressed())
        b.button_up.connect(func(): fish_button_held=false)
    elif key=="interact": b.pressed.connect(on_interact)
    elif key=="status": b.pressed.connect(toggle_status)

func set_touch_move(key:String,down:bool)->void:
    var v := Vector2.ZERO
    if key=="up":v=Vector2.UP
    elif key=="down":v=Vector2.DOWN
    elif key=="left":v=Vector2.LEFT
    elif key=="right":v=Vector2.RIGHT
    if down: move_touch+=v
    else: move_touch-=v

func _process(delta:float)->void:
    if not dialog_open and not status_label.visible and fishing.is_empty(): update_player(delta)
    update_time(delta)
    update_fishing(delta)
    update_hud()
    queue_redraw()

func _input(event:InputEvent)->void:
    if event.is_action_pressed("interact"):on_interact()
    if event.is_action_pressed("fish"):fish_button_held=true;on_fish_pressed()
    if event.is_action_released("fish"):fish_button_held=false

func update_player(delta:float)->void:
    var dir := Input.get_vector("move_left","move_right","move_up","move_down")+move_touch
    if dir.length()>1.0:dir=dir.normalized()
    var next := player+dir*speed*delta
    next.x=clamp(next.x,28.0,W-28.0); next.y=clamp(next.y,190.0,1015.0)
    var water_y := 890.0 if zone=="swamp" else 920.0
    var bridge_x := Vector2(315,405) if zone=="village" else Vector2(325,395)
    if next.y>water_y and not(next.x>bridge_x.x and next.x<bridge_x.y):next.y=water_y
    player=next

func update_time(delta:float)->void:
    state.minute+=delta*.42
    if state.minute>=1440.0:
        state.day+=1; state.minute=375.0; state.stamina=state.max_stamina; roll_weather(); save_game()

func roll_weather()->void:
    var r := rng.randf()
    state.weather="Cerah" if r<.48 else("Mendung" if r<.76 else("Hujan" if r<.94 else "Badai"))

func time_text()->String:
    var m := int(state.minute)%1440
    return "%02d:%02d"%[m/60,m%60]

func update_hud()->void:
    var zname := "Desa Karang Tirta" if zone=="village" else "Rawa Kedung Wungu"
    hud.text="KAIL KAMPUNG v0.4 • %s\nHari %d • %s • %s\nLv.%d %s • XP %d/%d\nRp%s • Tenaga %d/%d • Cacing %d"%[zname,state.day,time_text(),state.weather,state.level,angler_title(),state.xp,xp_need(state.level),format_money(state.money),int(state.stamina),int(state.max_stamina),state.bait]
    hint_label.text=current_hint()
    if fishing.is_empty():tension_label.text=""

func current_hint()->String:
    if dialog_open:return ""
    var npc:=nearest_npc()
    if npc!="":return "E • Bicara dengan %s"%npc_profiles[npc].name
    if near_gate():return "E • %s"%("Ke Rawa Kedung Wungu" if zone=="village" else "Balik ke Karang Tirta")
    if near_spot():return "MANCING • lempar kail"
    return "Jelajahi kampung • cari NPC dan spot air"

func _draw()->void:
    draw_rect(Rect2(0,0,W,H),Color("6c9658") if zone=="village" else Color("637b50"))
    draw_rect(Rect2(0,610,W,80),Color("b3a074") if zone=="village" else Color("8c825f"))
    draw_rect(Rect2(330,170,60,750),Color("b3a074") if zone=="village" else Color("8c825f"))
    var wy:=920.0 if zone=="village" else 890.0
    draw_rect(Rect2(0,wy,W,H-wy),Color("3f8da8") if zone=="village" else Color("477b70"))
    for x in range(20,700,80):draw_line(Vector2(x,wy+35+(x%3)*8),Vector2(x+38,wy+35+(x%3)*8),Color(1,1,1,.18),2)
    var bx:=315.0 if zone=="village" else 325.0
    draw_rect(Rect2(bx,wy-12,90,100),Color("9d7650"))
    if zone=="village":
        draw_building(Rect2(45,260,130,105),"Rumah");draw_building(Rect2(235,260,130,105),"Warung");draw_building(Rect2(420,260,130,105),"Toko");draw_building(Rect2(565,240,115,105),"Balai")
    else:
        draw_building(Rect2(50,270,130,100),"Pondok");draw_building(Rect2(500,260,145,100),"Nipah")
    for p in [Vector2(40,470),Vector2(110,760),Vector2(650,470),Vector2(620,790),Vector2(250,500)]:
        draw_circle(p,26,Color("4f7847"));draw_circle(p+Vector2(-10,-8),15,Color("658e55"))
    for s in fishing_spots[zone]:
        draw_arc(s,18,0,TAU,28,Color(1,1,1,.75),2);draw_arc(s+Vector2(5,4),10,0,TAU,20,Color(1,1,1,.45),2)
    var npcs:=village_npcs if zone=="village" else swamp_npcs
    for id in npcs:
        var p:Vector2=npcs[id];draw_circle(p,14,Color("d69b78"));draw_rect(Rect2(p.x-12,p.y+12,24,28),Color("294237"));draw_string(ThemeDB.fallback_font,p+Vector2(-28,-22),npc_profiles[id].name,HORIZONTAL_ALIGNMENT_LEFT,120,16,Color.WHITE)
    var gx:=685.0 if zone=="village" else 8.0
    draw_rect(Rect2(gx,600,27,100),Color("67563d"))
    draw_circle(player,14,Color("efbd78"));draw_rect(Rect2(player.x-12,player.y+12,24,30),Color("35617c"))
    var minute:=fmod(state.minute,1440.0)
    if minute>=1140 or minute<300:draw_rect(Rect2(0,0,W,H),Color(0.02,0.05,0.11,.38))
    if state.weather in ["Hujan","Badai"]:
        var count:=65 if state.weather=="Hujan" else 110
        for i in range(count):
            var x:=fmod(i*83.0+Time.get_ticks_msec()*.18,W);var y:=fmod(i*47.0+Time.get_ticks_msec()*.34,H);draw_line(Vector2(x,y),Vector2(x-7,y+20),Color(.75,.88,1,.42),2)

func draw_building(r:Rect2,label:String)->void:
    draw_rect(r,Color("d0bea0"))
    var roof:=PackedVector2Array([Vector2(r.position.x-8,r.position.y+18),Vector2(r.position.x+r.size.x/2,r.position.y-24),Vector2(r.end.x+8,r.position.y+18)])
    draw_colored_polygon(roof,Color("7d4f3e"))
    draw_string(ThemeDB.fallback_font,r.position+Vector2(15,r.size.y+23),label,HORIZONTAL_ALIGNMENT_LEFT,110,17,Color("20352a"))

func nearest_npc()->String:
    var npcs:=village_npcs if zone=="village" else swamp_npcs
    var best:="";var best_d:=9999.0
    for id in npcs:
        var d:=player.distance_to(npcs[id])
        if d<best_d:best_d=d;best=id
    return best if best_d<72.0 else ""

func near_spot()->bool:
    for s in fishing_spots[zone]:
        if player.distance_to(s)<80:return true
    return false

func near_gate()->bool:return player.x>640.0 if zone=="village" else player.x<80.0

func on_interact()->void:
    if dialog_open:close_dialog();return
    if status_label.visible:status_label.visible=false;return
    var id:=nearest_npc()
    if id!="":talk_npc(id);return
    if near_gate():use_gate()

func random_banter(id:String)->String:
    var lines:Array=npc_profiles[id].lines;var idx:=rng.randi_range(0,lines.size()-1)
    if last_banter.has(id) and idx==last_banter[id] and lines.size()>1:idx=(idx+1)%lines.size()
    last_banter[id]=idx;return lines[idx]

func talk_npc(id:String)->void:
    var banter:=random_banter(id)
    if id=="darto":
        if not state.quest.nila_accepted:
            show_dialog("Pak Darto — Optimistis",banter+"\n\nSaya butuh 3 nila buat acara RT. Bantu?",[{"text":"Gas, Pak","call":func():state.quest.nila_accepted=true;save_game();close_dialog()},{"text":"Nanti","call":close_dialog}]);return
        if not state.quest.nila_done:
            var have:=int(state.inventory.get("nila",0))
            if have>=3:
                show_dialog("Pak Darto — Optimistis",banter+"\n\nNila sudah lengkap. Saya ambil 3 ekor ya. Jalan rawa saya bukakan.",[{"text":"Serahkan","call":func():state.inventory.nila=have-3;state.money+=600;state.quest.nila_done=true;state.quest.swamp_unlocked=true;gain_xp(50);save_game();close_dialog()},{"text":"Nanti","call":close_dialog}]);return
            show_dialog("Pak Darto — Optimistis",banter+"\n\nNila baru %d/3."%have,[{"text":"Oke","call":close_dialog}]);return
    elif id=="yati":
        var value:=inventory_value()
        if value>0:
            show_dialog("Bu Yati — Pedagang",banter+"\n\nSemua ikanmu saya beli Rp%s."%format_money(value),[{"text":"Jual semua","call":func():state.money+=value;state.inventory={};save_game();close_dialog()},{"text":"Simpan","call":close_dialog}]);return
    elif id=="rian":
        show_dialog("Bang Rian — Teknisi",banter+"\n\n5 cacing Rp100.",[{"text":"Beli","call":buy_bait},{"text":"Nanti","call":close_dialog}]);return
    elif id=="tika":
        show_dialog("Mbak Tika — Jamu",banter+"\n\nKopi Rp120, Jamu Umpan Rp180.",[{"text":"Kopi","call":func():buy_item("coffee")},{"text":"Jamu","call":func():buy_item("jamu")},{"text":"Nanti","call":close_dialog}]);return
    elif id=="beni":
        if state.side_quest.beni_done:show_dialog("Pak Beni",banter,[{"text":"Oke","call":close_dialog}]);return
        if state.side_quest.beni_ready:
            show_dialog("Pak Beni",banter+"\n\nOke, saya akui. Ambil hadiahnya.",[{"text":"Hadiah","call":func():state.side_quest.beni_done=true;state.money+=900;state.items.jamu+=1;gain_xp(90);save_game();close_dialog()}]);return
        if not state.side_quest.beni_accepted:
            show_dialog("Pak Beni",banter+"\n\nTangkap ikan minimal 70 cm.",[{"text":"Gas","call":func():state.side_quest.beni_accepted=true;save_game();close_dialog()},{"text":"Nanti","call":close_dialog}]);return
    show_dialog(npc_profiles[id].name,banter,[{"text":"Oke","call":close_dialog}])

func show_dialog(title:String,body:String,actions:Array)->void:
    dialog_open=true;dialog_panel.visible=true;dialog_title.text=title;dialog_body.text=body
    for c in dialog_actions.get_children():c.queue_free()
    for a in actions:
        var b:=Button.new();b.text=a.text;b.add_theme_font_size_override("font_size",18);dialog_actions.add_child(b);b.pressed.connect(a.call)

func close_dialog()->void:
    dialog_open=false
    dialog_panel.visible=false

func use_gate() -> void:
    if zone=="village":
        if not state.quest.swamp_unlocked:
            show_dialog("Jalan Kedung Wungu","Masih ditutup warga. Selesaikan urusan Pak Darto dulu.",[{"text":"Oke","call":close_dialog}]); return
        zone="swamp"; player=Vector2(80,650)
    else:
        zone="village"; player=Vector2(625,650)
    save_game()

func buy_bait() -> void:
    if state.money < 100: return
    state.money-=100; state.bait+=5; save_game(); close_dialog()

func buy_item(kind: String) -> void:
    var cost := 120 if kind=="coffee" else 180
    if state.money < cost: return
    state.money-=cost; state.items[kind]=int(state.items.get(kind,0))+1; save_game(); close_dialog()

func on_fish_pressed() -> void:
    if dialog_open or status_label.visible: return
    if not fishing.is_empty():
        if fishing.phase=="bite": hook_fish()
        return
    if not near_spot(): return
    if state.bait<=0 or state.stamina<5: return
    state.bait-=1; state.stamina-=4
    var event := "normal"
    var r:=rng.randf()
    if r<.11:event="feeding"
    elif r<.19:event="current"
    elif r<.24:event="quiet"
    fishing={"phase":"wait","timer":rng.randf_range(.8,2.8)+(1.0 if event=="quiet" else 0.0),"event":event,"fish":"","tension":32.0,"progress":0.0,"escape":0.0,"burst":0.0,"burst_timer":rng.randf_range(1.8,3.8)}
    if state.buffs.luck_casts>0: state.buffs.luck_casts-=1
    save_game()

func hook_fish() -> void:
    fishing.phase="fight"
    fishing.fish=roll_fish()
    fishing.tension=34.0
    fishing.progress=0.0

func roll_fish() -> String:
    var pool: Array[String] = []
    var minute: float = float(state.get("minute", 390.0))
    var night: bool = minute >= 1140.0 or minute < 300.0

    for raw_id in fish_data.keys():
        var id: String = str(raw_id)
        var f: Dictionary = fish_data[id]
        var allowed_zones: Array = f.get("zones", [])
        if not allowed_zones.has(zone):
            continue
        if bool(f.get("night", false)) and not night:
            continue
        pool.append(id)

    var upgrades: Dictionary = state.get("upgrades", {})
    var buffs: Dictionary = state.get("buffs", {})
    var hook_level: float = float(upgrades.get("hook", 0))
    var luck_casts: int = int(buffs.get("luck_casts", 0))
    var event_name: String = str(fishing.get("event", "normal"))
    var rarity_roll: float = rng.randf() + hook_level * 0.025
    if luck_casts > 0:
        rarity_roll += 0.09
    if event_name == "feeding":
        rarity_roll += 0.10

    var filtered: Array[String] = []
    for id in pool:
        var fish_entry: Dictionary = fish_data[id]
        var rarity: String = str(fish_entry.get("rarity", "Umum"))
        if rarity == "Langka" and rarity_roll > 0.91:
            filtered.append(id)
        elif rarity == "Jarang" and rarity_roll > 0.60:
            filtered.append(id)
        elif rarity == "Umum":
            filtered.append(id)

    if filtered.is_empty():
        filtered = pool.duplicate()
    if filtered.is_empty():
        return "nila"
    return filtered[rng.randi_range(0, filtered.size() - 1)]

func update_fishing(delta: float) -> void:
    if fishing.is_empty(): return
    if fishing.phase=="wait":
        fishing.timer-=delta
        tension_label.text="Menunggu ikan..."
        if fishing.timer<=0: fishing.phase="bite"; fishing.timer=.95
    elif fishing.phase=="bite":
        fishing.timer-=delta
        tension_label.text="NYANGKUT! Tekan MANCING!"
        if fishing.timer<=0: fail_fish("Telat. Ikannya kabur.")
    elif fishing.phase=="fight":
        var fish_id: String = str(fishing.get("fish", "nila"))
        var f: Dictionary = fish_data[fish_id]
        var event_name: String = str(fishing.get("event", "normal"))
        var diff: float = minf(0.98, float(f.get("diff", 0.5)) + (0.11 if event_name == "current" else 0.0))
        fishing.burst_timer-=delta
        if fishing.burst_timer<=0 and fishing.burst<=0:
            fishing.burst=.45+diff*.55; fishing.burst_timer=rng.randf_range(1.8,max(2.0,3.0-diff))
        if fishing.burst>0: fishing.burst-=delta
        var burst_force: float = (28.0 + diff * 55.0) * float(f.get("burst", 1.0)) if float(fishing.get("burst", 0.0)) > 0.0 else 0.0
        var upgrades: Dictionary = state.get("upgrades", {})
        var rod_level: float = float(upgrades.get("rod", 0))
        var line_level: float = float(upgrades.get("line", 0))
        var gear_power: float = 1.0 + rod_level * 0.10 + line_level * 0.085
        if fish_button_held or Input.is_action_pressed("fish"):
            fishing.tension += delta * ((34.0 + diff * 37.0 + burst_force) / (1.0 + line_level * 0.12))
            var sweet: float = 1.22 if float(fishing.get("tension", 0.0)) >= 42.0 and float(fishing.get("tension", 0.0)) <= 72.0 else 0.82
            fishing.progress += delta * ((14.0 + 22.0 * (1.0 - diff)) * gear_power * sweet * float(f.get("reel", 1.0)))
        else:
            fishing.tension -= delta*(48-7*diff)
            fishing.progress -= delta * (3.0 + diff * 5.0 + (6.0 if float(fishing.get("burst", 0.0)) > 0.0 else 0.0)) * float(f.get("loss", 1.0))
        fishing.tension=clamp(fishing.tension,0.0,110.0)
        fishing.progress=clamp(fishing.progress,0.0,100.0)
        if fishing.tension>=100: fail_fish("KRAK! Senar putus."); return
        if fishing.tension<=2:
            fishing.escape+=delta
            if float(fishing.get("escape", 0.0)) > 1.05 * float(f.get("escape", 1.0)):
                fail_fish("Senar terlalu kendur. Ikan lepas.")
                return
        else: fishing.escape=max(0.0,fishing.escape-delta*2)
        if fishing.progress>=100: catch_fish(fishing.fish); return
        tension_label.text = "%s • %s%s\nTension %d%% | Tarikan %d%%" % [
            str(f.get("name", "Ikan")),
            str(f.get("trait", "Biasa")),
            " • NGAMUK!" if float(fishing.get("burst", 0.0)) > 0.0 else "",
            int(fishing.get("tension", 0.0)),
            int(fishing.get("progress", 0.0))
        ]

func catch_fish(id:String) -> void:
    var f: Dictionary = fish_data[id]
    var size: float = snappedf(rng.randf_range(float(f.get("min", 10.0)), float(f.get("max", 20.0))), 0.1)
    state.inventory[id]=int(state.inventory.get(id,0))+1
    state.caught[id]=max(float(state.caught.get(id,0.0)),size)
    state.stats.fish_caught+=1; state.stats.biggest=max(float(state.stats.biggest),size)
    var rarity: String = str(f.get("rarity", "Umum"))
    if rarity == "Langka": state.stats.rare_caught += 1
    var base_xp: int = 28 if rarity == "Langka" else (17 if rarity == "Jarang" else 9)
    var xp: int = int(base_xp + float(f.get("diff", 0.5)) * 12.0)
    gain_xp(xp)
    if state.side_quest.beni_accepted and not state.side_quest.beni_done and size>=state.side_quest.target_size: state.side_quest.beni_ready=true
    state.minute+=16; state.stamina=max(0.0,state.stamina-2)
    fishing = {}
    tension_label.text = "Dapat %s %.1f cm! +%d XP" % [str(f.get("name", "Ikan")), size, xp]
    save_game()
    await get_tree().create_timer(2.0).timeout
    if fishing.is_empty(): tension_label.text=""

func fail_fish(msg:String) -> void:
    fishing={}; tension_label.text=msg; state.minute+=7; save_game()
    await get_tree().create_timer(1.7).timeout
    if fishing.is_empty(): tension_label.text=""

func inventory_value() -> int:
    var total:=0
    for id in state.inventory: if fish_data.has(id): total += int(state.inventory[id])*int(fish_data[id].price)
    return total

func gain_xp(amount:int) -> void:
    state.xp+=amount
    while state.xp>=xp_need(state.level):
        state.xp-=xp_need(state.level); state.level+=1; state.max_stamina+=4; state.stamina=min(state.max_stamina,state.stamina+20)

func xp_need(level:int) -> int: return 80+(level-1)*55
func angler_title() -> String:
    if state.level>=8:return "Legenda Pinggir Air"
    if state.level>=6:return "Raja Rawa"
    if state.level>=4:return "Jagoan Kali"
    if state.level>=2:return "Anak Pancing"
    return "Pemancing Gang"

func toggle_status() -> void:
    if dialog_open:return
    status_label.visible=not status_label.visible
    if status_label.visible:
        status_label.text="STATUS PEMANCING\n\nLv.%d — %s\nXP %d/%d\nTenaga %d/%d\nUang Rp%s\nCacing %d\n\nKopi Tubruk: %d\nJamu Umpan: %d\n\nTotal ikan: %d\nIkan langka: %d\nRekor ukuran: %.1f cm\n\nQuest Pak Beni: %s\n\nTekan STATUS lagi untuk menutup."%[state.level,angler_title(),state.xp,xp_need(state.level),int(state.stamina),int(state.max_stamina),format_money(state.money),state.bait,state.items.coffee,state.items.jamu,state.stats.fish_caught,state.stats.rare_caught,state.stats.biggest,("Selesai" if state.side_quest.beni_done else ("Kembali ke Pak Beni" if state.side_quest.beni_ready else ("Cari ikan 70 cm" if state.side_quest.beni_accepted else "Belum diambil")))]

func format_money(v:int) -> String:
    var s:=str(v); var out:=""; var count:=0
    for i in range(s.length()-1,-1,-1):
        if count>0 and count%3==0: out="."+out
        out=s[i]+out; count+=1
    return out

func save_game() -> void:
    var data:=state.duplicate(true); data["zone"]=zone; data["player"]=[player.x,player.y]
    var f:=FileAccess.open(SAVE_PATH,FileAccess.WRITE)
    if f: f.store_string(JSON.stringify(data))

func load_game() -> void:
    if not FileAccess.file_exists(SAVE_PATH): return
    var f:=FileAccess.open(SAVE_PATH,FileAccess.READ)
    if not f:return
    var parsed=JSON.parse_string(f.get_as_text())
    if typeof(parsed)!=TYPE_DICTIONARY:return
    merge_state(state,parsed)
    zone=parsed.get("zone","village")
    var p=parsed.get("player",[360,700]); if p is Array and p.size()>=2: player=Vector2(float(p[0]),float(p[1]))

func merge_state(target:Dictionary, source:Dictionary) -> void:
    for k in source:
        if target.has(k) and target[k] is Dictionary and source[k] is Dictionary: merge_state(target[k],source[k])
        elif target.has(k): target[k]=source[k]
