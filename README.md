# Fair Duelist - Customizable Difficulty

Modifies the existing Duelist preset in The Blood of Dawnwalker.
Select Fair Duelist in the game's difficulty settings. This is the renamed Duelist slot, not a fifth preset.

[Download the Vortex archive](https://github.com/my-mods/Fair-Duelist-Customizable-Difficulty/raw/refs/heads/main/Fair-Duelist-Customizable-Difficulty.zip)

Enemy health: 75% of Fair (25% less health).
Enemy damage: Fair (100%, reduced from Duelist 160%).
Player combat stamina costs: Fair (100%, reduced from Duelist 175%).
Enemy attack pressure: configurable relative to the chosen reference; defaults to Duelist. Animation speed, parry timing and directional indicators remain controlled by the game.

Customization: keep RPG Difficulty on Fair Duelist to retain your INI balance (defaults: enemy health 75%, damage 100%, and combat stamina costs 100%). Changing Action Difficulty changes attack speed, aggression and parry timing, but does not change the RPG values. Indicators, consumables and other custom options can be changed independently. The overall preset may display Custom; that alone does not remove the RPG changes. Selecting another RPG difficulty or overall preset changes the balance accordingly. For the exact intended setup, keep Action Difficulty on Fair Duelist and directional indicators off.
Other presets and player maximum health are unchanged.

Installation: import Fair-Duelist-Customizable-Difficulty.zip into Vortex, choose the game-root installer if prompted, enable and deploy. Restart the game and select Fair Duelist.
Requirements: The Blood of Dawnwalker; Vortex with its Dawnwalker extension. UE4SS is required for INI overrides; the packaged default preset can run without it.
Update: replace the same Vortex mod entry with the new archive and deploy.
Uninstall: disable/remove this mod in Vortex and deploy; restart the game.
Conflicts: replaces /Game/_Dawnwalker/Combat/DA_DifficultyConfig, /Game/_Dawnwalker/Combat/StringTables/ST_Difficulties, and /Game/_Dawnwalker/System/Settings/ST_Settings_Tab_Game. Text mods replacing these string tables may conflict. Use only one mod replacing each of these assets; Fair Duelist - Customizable Difficulty must win for these values to apply. Archive filenames alone cannot detect this conflict.
Compatibility: built for the PC version; conflicts are listed above.

Original difficulty data belongs to Rebel Wolves and its respective rights holders. This mod changes three difficulty multipliers and the corresponding menu text.

## INI configuration

The INI feature requires UE4SS with ExecuteInGameThreadWithDelay support (develop build 97b7e501c or compatible). [UE4SS downloads](https://github.com/UE4SS-RE/RE-UE4SS/releases).
After the first launch, edit `%LOCALAPPDATA%/Dawnwalker/Saved/Config/FairDuelist.ini`, then restart the game and load your save. Keep RPG Difficulty and Action Difficulty on Fair Duelist to apply all overrides.

```ini
[FairDuelist]
referenceDifficulty=Duelist
enabled=true
enemyHealthMultiplier=0.833333333333
enemyDamageMultiplier=0.625
staminaCostMultiplier=0.571428571429
enemyAggressionMultiplier=1.0
debugLogging=false
```

Choose `Story`, `Fair`, `Challenging`, or `Duelist` as `referenceDifficulty`. Every numeric multiplier uses that difficulty's original values: 1 means unchanged, 0.75 means 25% less, and 1.25 means 25% more. Changing the reference changes the meaning of all multipliers, including inherited defaults. Set all four multipliers to 1 to reproduce the reference's RPG balance and cooldown-based attack pressure. This does not select its animation speed, parry windows or other gameplay options.

| Example | Reference | Health | Damage | Stamina cost | Aggression |
| --- | --- | --- | --- | --- | --- |
| Fair | Fair | 1 | 1 | 1 | 1 |
| Challenging | Challenging | 1 | 1 | 1 | 1 |
| Story | Story | 1 | 1 | 1 | 1 |
| Shorter Fair fights with more breathing room | Fair | 0.75 | 1 | 1 | 0.75 |

Multipliers accept 0.1 through 5.0. Lower health shortens fights; lower damage makes enemy hits less punishing; lower stamina cost makes combat actions cheaper.

`enemyAggressionMultiplier` scales three helper attack cooldowns with `cooldown = reference cooldown / multiplier`. At 0.75, cooldowns are about 33% longer; at 1.25, they are 20% shorter. Group-attack permissions are copied from the selected reference. Actual attack frequency also depends on AI behavior, and zero cooldowns stay zero. Level-based AI scaling, animation speed, parry windows, boss phases and scripted red/unblockable attacks remain unchanged. This setting affects the Fair Duelist Action slot only; select that Action difficulty to use it.

The personal INI follows the same rules as the other Dawnwalker mods: it is outside Vortex-managed directories, in `Saved/Config` without a Windows subfolder. The mod creates a commented reference only if missing. Uncomment only settings you want to override; omitted/commented values inherit the current shipped `FairDuelist.defaults.ini`, read at startup. Existing personal files are never rewritten by the mod. Back up your preferences before manually replacing a personal INI.

There is no legacy conversion or lookup in old INI locations. The former `enemyAggression` key has been replaced by `enemyAggressionMultiplier`; remove the former key when updating an existing personal INI. A missing `referenceDifficulty` inherits the shipped default, just like other omitted settings. Invalid settings disable runtime overrides for that launch and report the problem in UE4SS.log without overwriting the file.

`enabled=false` disables all runtime overrides while leaving the packaged native preset installed. Comment out overrides to inherit defaults again. The packaged default balance remains 75% of Fair enemy health, Fair damage and Fair stamina costs; tooltips describe that packaged balance. For 25% less health than Duelist, choose Duelist as the reference and set health to 0.75.

Set `debugLogging=true` for applied reference, multipliers, setup counts and failures in `Dawnwalker/Binaries/Win64/ue4ss/UE4SS.log`. The mod reads configuration once at startup and uses bounded setup retries plus map/object lifecycle events.
