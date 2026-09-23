# Kail Kampung — Generated Art Pack

The generated cat-fisherman art is packed into `kail_art_master.webp` for the Godot mobile build.

The master atlas contains five transparent sheets stacked vertically at 320×240 each:

1. MC turnaround, expressions, palette and prop reference.
2. MC sprite sheet: idle, walk, run, cast, reel, caught-fish, tired and sit/wait.
3. Inventory/item/fish icons: rods, bait, tackle, clothing, consumables, currency, map tools, materials, trophy and species.
4. UI icons: inventory, quest, map, settings, home, shop, currencies, energy, XP, chat, warnings, locks, rewards, fishing controls, weather/time, mission, encyclopedia, leaderboard, audio, pause and rarity badges.
5. World/VFX: dock, stool, fish crate, baskets, bucket, signpost, reeds, rocks, lilies, bamboo fence, lantern, canoe, mooring, cooler, market basket, campfire, water effects and catch effects.

`scripts/visual_assets.gd` reads atlas regions directly. This avoids dozens of duplicate runtime textures while keeping the full generated batch inside the game project.

Visible integration includes the animated orange cat fisherman MC, mobile-button icons, cast/reel/bait state changes, fish catch art, catch VFX, and themed village/swamp props. The remaining icons in the master atlas are ready for inventory, shop, encyclopedia, quests and rarity UI.
