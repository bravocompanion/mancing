extends RefCounted
class_name KailAssetCatalog

const INVENTORY_ITEMS := [
    "basic_rod","pro_rod","golden_rod","bait_bucket","worm_bait","shrimp_bait","lure",
    "hook","bobber","fishing_net","tackle_box","fish_basket","lantern","village_sandals",
    "fisher_hat","raincoat","energy_drink","rice_packet","coin_stack","gem","map",
    "compass","old_key","wood_plank","rope_bundle","boat_paddle","trophy",
    "catfish","tilapia","carp","snakehead","eel","shrimp","crab","golden_fish"
]

const UI_ICONS := [
    "inventory","quest","map","settings","home","shop","coin","gem","energy","level_up","exp","chat",
    "warning","check","locked","unlocked","reward","trophy","hook_meter","cast","reel","bait_select",
    "weather_sun","weather_rain","weather_cloud","weather_storm","time_day","time_night","location","mission",
    "fish_encyclopedia","leaderboard","sound_on","sound_off","pause",
    "common","uncommon","rare","epic","legendary","mythic"
]

const WORLD_PROPS := [
    "dock","stool","fish_crate","basket","bait_bucket","signpost","reeds","rocks","water_lily",
    "bamboo_fence","lantern_post","canoe","mooring_pole","cooler","market_basket","campfire"
]

const VFX := [
    "splash_small","splash_medium","splash_large","ripple_1","ripple_2","ripple_3","bobber_splash",
    "line_swoosh","catch_sparkle","exclamation_pop","dust_puff","sweat_drop","happy_sparkle","celebration_burst"
]

static func sheet_for(asset_id: String) -> String:
    if INVENTORY_ITEMS.has(asset_id): return "inventory"
    if UI_ICONS.has(asset_id): return "ui"
    if WORLD_PROPS.has(asset_id) or VFX.has(asset_id): return "world_vfx"
    return ""
