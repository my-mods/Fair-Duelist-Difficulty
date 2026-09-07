# Fair Duelist Difficulty

Modifies the existing Duelist preset in The Blood of Dawnwalker.
Select Fair Duelist in the game's difficulty settings. This is the renamed Duelist slot, not a fifth preset.

[Download the Vortex archive](https://github.com/my-mods/Fair-Duelist-Difficulty/raw/refs/heads/main/Fair-Duelist.zip)

Enemy health: original Duelist (90% of Fair).
Enemy damage: Fair (100%, reduced from Duelist 160%).
Player combat stamina costs: Fair (100%, reduced from Duelist 175%).
Enemy aggression, animation speed, parry timing and directional indicator settings: original Duelist.

Customization: keep RPG Difficulty on Fair Duelist to retain enemy health at 90%, enemy damage at 100%, and combat stamina costs at 100%. Changing Action Difficulty changes attack speed, aggression and parry timing, but does not change the RPG values. Indicators, consumables and other custom options can be changed independently. The overall preset may display Custom; that alone does not remove the RPG changes. Selecting another RPG difficulty or overall preset changes the balance accordingly. For the exact intended setup, keep Action Difficulty on Fair Duelist and directional indicators off.
Other presets and player maximum health are unchanged.

Installation: import Fair-Duelist.zip into Vortex, choose the game-root installer if prompted, enable and deploy. Restart the game and select Fair Duelist.
Requirements: The Blood of Dawnwalker; Vortex with its Dawnwalker extension. No UE4SS dependency.
Update: replace the same Vortex mod entry with the new archive and deploy.
Uninstall: disable/remove this mod in Vortex and deploy; restart the game.
Conflicts: replaces /Game/_Dawnwalker/Combat/DA_DifficultyConfig, /Game/_Dawnwalker/Combat/StringTables/ST_Difficulties, and /Game/_Dawnwalker/System/Settings/ST_Settings_Tab_Game. Text mods replacing these string tables may conflict. Use only one mod replacing each of these assets; Fair Duelist Difficulty must win for these values to apply. Archive filenames alone cannot detect this conflict.
Compatibility: prepared against locally installed game files on 2026-09-07. Recheck after game updates. No in-game validation yet. Achievement eligibility is unverified.

Original difficulty data belongs to Rebel Wolves and its respective rights holders. This mod changes two difficulty multipliers and the corresponding menu text.
