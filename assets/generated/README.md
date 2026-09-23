# Kail Kampung — Generated Visual Pack

Folder ini dipakai oleh `scripts/visual_assets.gd`.

Letakkan file berikut dengan nama persis:

- `mc_animations.webp` — sprite/animasi MC kucing pemancing (idle, walk, run, cast, reel, caught, tired, wait)
- `mc_reference.webp` — reference/portrait/expression MC
- `inventory_icons.webp` — joran, kail, umpan, perlengkapan, currency, trophy, ikan
- `ui_icons.webp` — inventory, quest, map, settings, home, shop, coin, gem, energy, chat, mission, cast, reel, cuaca, rarity, dll.
- `world_vfx.webp` — dermaga, keranjang, crate, tumbuhan, perahu, cooler, campfire serta splash/ripple/catch VFX

Semua master sheet berukuran 1448x1086 dan memiliki transparency.

## Runtime

`VisualAssets` dipasang sebagai child pada `Main.tscn`. Jika pack tersedia, karakter prosedural dapat ditimpa oleh MC kucing baru. Bila file belum ada, game tetap berjalan dengan visual fallback lama sehingga repo tidak rusak.

Asset helper dapat diakses dari node `Main/VisualAssets` melalui `get_asset_texture(kind)` untuk `mc_reference`, `inventory`, `ui`, dan `world_vfx`.
