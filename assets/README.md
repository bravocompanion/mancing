# Kail Kampung — Generated Art Pack

The generated cat-fisherman artwork is packed into one lightweight transparent WebP atlas for the Godot mobile build. Because the GitHub connector stores text files, the WebP payload is kept as base64 GDScript chunks under `assets/atlas/`; `scripts/visual_assets.gd` joins and decodes them once at startup into an in-memory `ImageTexture`. No manual copying of generated PNG files is required.

The runtime atlas is 160×600 and contains five transparent 160×120 sheet slots:

1. MC turnaround, expressions, palette and prop reference.
2. MC sprite sheet: idle, walk, run, cast, reel, caught-fish, tired and sit/wait.
3. Inventory/item/fish icons: rods, bait, tackle, clothing, consumables, currency, map tools, materials, trophy and species.
4. UI icons: inventory, quest, map, settings, home, shop, currencies, energy, XP, chat, warnings, locks, rewards, fishing controls, weather/time, mission, encyclopedia, leaderboard, audio, pause and rarity badges.
5. World/VFX: dock, stool, fish crate, baskets, bucket, signpost, reeds, rocks, lilies, bamboo fence, lantern, canoe, mooring, cooler, market basket, campfire, water effects and catch effects.

Visible integration currently includes the animated orange cat fisherman MC, mobile-button icons, cast/reel/bait state changes, fish catch species art, catch VFX, and themed village/swamp props. Gameplay state, fishing logic, NPC logic, quests and save data remain in the existing gameplay scripts.

The rest of the generated inventory/UI artwork stays inside the same atlas and is ready to be connected when dedicated shop, inventory, fish encyclopedia, quest and rarity screens are expanded.
