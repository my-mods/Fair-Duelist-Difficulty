# Fair Duelist - Customizable Difficulty

[Download the Vortex archive](https://github.com/my-mods/Fair-Duelist-Customizable-Difficulty/raw/refs/heads/main/Fair-Duelist-Customizable-Difficulty.zip)

Customize enemy health, damage, combat stamina costs and enemy attack delays. Start from Story, Fair, Challenging or Duelist, then adjust individual values. You can use the optional Mod Setting Menu or edit settings.ini yourself.

**Requirements**

- **Required: [UE4SS for BoD](https://www.nexusmods.com/thebloodofdawnwalker/mods/283).** Install a version compatible with your game build. This version of Fair Duelist uses Lua for all balance changes.
- **Optional: [Mod Setting Menu 1.0.5.1 or later](https://www.nexusmods.com/thebloodofdawnwalker/mods/271).** Adds in-game controls for the same settings.ini file. Fair Duelist works without it.


**Default values and what the percentages mean**

On a fresh installation, load a save once before configuring the mod. When no settings.ini exists, Fair Duelist creates it from your currently selected RPG and Action difficulties. It does not automatically force the old 75%-health preset. If your RPG and Action difficulties differ, their respective values are combined.

**100%** means the unscaled game value, **50%** means half, and **150%** means one and a half times. These percentages are absolute, not additional multipliers on top of the selected difficulty. All six percentage settings accept values from **0 to 500**. Enter 75 for 75%, not 0.75 or 75%.

The six balance values are: **enemy health / enemy damage / combat stamina cost / normal attack delay / low-health attack delay / ranged attack delay**.

- **Story:** health 50%, damage 40%, stamina cost 50%; normal, low-health and ranged attack delays 200%. Attacks while another enemy blocks: Off.
- **Fair:** health 100%, damage 100%, stamina cost 100%; normal delay 140%, low-health delay 120%, ranged delay 140%. Attacks while another enemy blocks: Off.
- **Challenging:** health 100%, damage 130%, stamina cost 150%; normal delay 120%, low-health delay 100%, ranged delay 120%. Attacks while another enemy blocks: On.
- **Duelist:** health 90%, damage 160%, stamina cost 175%; normal delay 100%, low-health delay 60%, ranged delay 100%. Attacks while another enemy blocks: On.


The balance override starts On and Logging starts Off. **Reset in Mod Settings uses the Duelist values above.** Outdated or invalid settings files also reset to those defaults.

Lower health means enemies take fewer hits; lower damage means you take less damage; lower stamina cost makes combat actions cheaper. **Lower attack-delay percentages let enemies attack more frequently; higher values give longer waits.** Low-health and ranged delays control those specific attack cooldowns. These settings do not change attack animation speed or parry timing. The coordinated-attack switch allows an enemy to attack while another enemy is reacting to a block.

**Change settings without Mod Setting Menu**

- Install UE4SS and Fair Duelist, start the game, and load a save once to create settings.ini. Then fully close the game.
- Open the game's installation folder. In Steam, right-click the game, then choose Manage > Browse local files.
- Open the file below with Notepad. Back it up before editing.


```ini
Dawnwalker\Binaries\Win64\ue4ss\Mods\FairDuelist\settings.ini
```

Edit the existing values under **[Settings]**. Keep every generated key and the section heading. Do not edit mod_settings.ini, the files in Scripts, or the old %LOCALAPPDATA%\Dawnwalker\Saved\Config\FairDuelist.ini; that old INI is no longer read.

This is a complete **Duelist-default example**; your generated numbers may differ because they start from your selected game difficulties. Change only the values you want in your existing file:

```ini
[Settings]
settingsVersion = 2
enabled = 1
difficultyPreset = 3
enemyHealthPercent = 90
enemyDamagePercent = 160
staminaCostPercent = 175
attackDelayPercent = 100
lowHealthAttackDelayPercent = 60
rangedAttackDelayPercent = 100
attackDuringBlock = 1
debugLogging = 0
```


Keep settingsVersion at 2. Leave the generated difficultyPreset line in place; changing that number does not select a preset. Choose presets through the game's own difficulty settings. For the three switches, 1 means On and 0 means Off. Setting enabled to 0 disables the custom balance override. Leave debugLogging at 0 for normal play. Decimal percentages such as 73.25 are accepted.

**Example: shorter fights with Fair damage, stamina costs and attack delays.** Set enemyHealthPercent to 75, enemyDamagePercent and staminaCostPercent to 100, attackDelayPercent and rangedAttackDelayPercent to 140, lowHealthAttackDelayPercent to 120, and attackDuringBlock to 0. Keep enabled at 1. This gives enemies 25% less health than Fair.

**Save the file, restart the game, and load a save to use your changes.** Do not leave values commented out, duplicate keys, or enter values outside their ranges: an obsolete or invalid file is replaced in full with Duelist defaults.

**Change settings with the optional Mod Setting Menu**

Load a save once, then open Mod Settings > Fair Duelist - Customizable Difficulty. Adjust the controls, press Apply, and load a save again to apply that snapshot to gameplay. Percentage sliders move in 5-point steps. Restore discards unapplied changes; Reset loads Duelist defaults. Logging is the final control.

**Choosing another difficulty**

Confirming a difficulty in the game's settings replaces the corresponding custom values in settings.ini. A full preset resets all balance values; RPG Difficulty resets health, damage and stamina costs; Action Difficulty resets attack delays and attacks while another enemy blocks. Canceling an unconfirmed preview preserves your saved values. To customize a new starting preset, confirm it first, then make your edits. Other game options, including indicators and parry settings, remain controlled by the game's difficulty settings.

**Install and update through Vortex**

Close the game and back up your settings. Replace/reinstall the existing Fair Duelist entry using Fair-Duelist-Customizable-Difficulty.zip. When updating from the old asset-based version, disable it and deploy first so Vortex removes zzz_FairDuelist_P.pak, .ucas and .utoc. If updating from a development build that replaced a shared menu file, disable and deploy it first to restore the original menu file. Install the replacement ZIP, deploy, and restart. Keep only one Fair Duelist entry active. Redeployment alone does not update an old archive's installation layout.

The old personal FairDuelist.ini is no longer imported. Existing valid absolute settings are retained; percentages above the new 500% cap are reduced to 500%, with the original saved as settings.ini.before-500-percent. Obsolete or invalid settings.ini files are replaced in full with Duelist defaults. Keep a preference backup if you want to re-enter old choices manually.

**Manual Install**

Close the game. If an older version was installed through Vortex, remove it through Vortex first and deploy. For a previous manual asset-based install, remove its zzz_FairDuelist_P.pak, .ucas and .utoc files from Dawnwalker\Content\Paks\~mods. Copy the new archive's Dawnwalker folder into the game's installation folder, merging with the existing Dawnwalker folder. The final runtime folder is Dawnwalker\Binaries\Win64\ue4ss\Mods\FairDuelist. Restart and load a save, then follow either settings method above.

**Uninstall**

Close the game and back up generated settings.ini. Disable/remove Fair Duelist in Vortex and deploy. For a manual installation, remove the FairDuelist runtime folder. Restart the game.

**Compatibility and conflicts**

This version does not replace cooked difficulty assets, game string tables or Mod Setting Menu files. Other mods writing the same runtime balance fields can conflict. Animation speed, parry windows and other native game options follow the game's settings. Logging writes to Dawnwalker\Binaries\Win64\ue4ss\UE4SS.log.

**Credits and source**

Original game and difficulty data: Rebel Wolves and the respective rights holders. Balance choices and mod: oOCamilleOo. This is an unofficial mod. Includes pinned MIT-licensed [ue4ss-common](https://github.com/my-mods/ue4ss-common) helpers; no separate shared-library installation is required.
[Source repository](https://github.com/my-mods/Fair-Duelist-Customizable-Difficulty)
