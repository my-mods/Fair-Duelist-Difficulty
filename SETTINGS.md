# Settings

Open Mod Settings > Fair Duelist - Customizable Difficulty. Select a balance preset, adjust the controls, press Apply, then load a save. Choosing a preset replaces all pending balance values, including custom edits. Restore discards unapplied changes; Reset loads Duelist defaults. Confirming a difficulty in the game's own settings also resets the corresponding balance values; canceled previews do not change your saved configuration.

All percentages are absolute, measured against the unscaled game value. `100%` is normal, `50%` is half, and `150%` is one and a half times. `0%` damage is zero damage. Attack-delay percentages measure cooldown length; a lower value means a shorter delay, rather than a slower animation.

| Setting | Range or choices |
| --- | --- |
| Override difficulty balance | Off, On |
| Balance preset | Story, Fair, Challenging, Duelist, Custom |
| Enemy health | 0–500% |
| Enemy damage | 0–800% |
| Combat stamina cost | 0–875% |
| Enemy attack delay | 0–2000% |
| Low-health enemy attack delay | 0–2000% |
| Ranged enemy attack delay | 0–2000% |
| Attacks while another enemy blocks | Off, On |
| Logging | Off, On |

Sliders move by one percentage point and display one decimal place. Existing fractional preferences retain their precision until edited. Native Story/Fair/Challenging/Duelist values are listed in the README. Custom is recognized from the actual control values. The coordinated-attack option is Off for Story/Fair and On for Challenging/Duelist.

## Storage and migration

The stable menu ID is `oOCamilleOo_FairDuelist`; the runtime folder remains `FairDuelist`. Generated `settings.ini` is the authoritative store and is never shipped. Its version marker distinguishes absolute percentages from the older relative-percentage format.

On the first save load, existing decimal multipliers or relative percentages convert to absolute values using their saved reference difficulty. The original file is retained as `settings.ini.absolute-v2.backup`. Unrelated settings and comments remain in place. Old attack pressure converts to the equivalent three absolute delays, preserving the original inverse-cooldown behavior. A pre-menu personal `FairDuelist.ini` is imported only when no generated settings file exists and is retained. New installations start from the currently selected native RPG and Action difficulties.

Back up your generated preferences before reinstalling or uninstalling. Do not overwrite an absolute settings file with an old INI. Invalid, duplicate or missing required values stop loading and are reported in `Dawnwalker/Binaries/Win64/ue4ss/UE4SS.log`.

An interrupted conversion retains `settings.ini.absolute-v2.backup`; an interrupted later write retains `settings.ini.absolute-write.backup`. If the primary file is missing, preserve any transaction files and recover the complete matching backup before restarting. The mod refuses to overwrite unresolved backups or a settings file changed during a write.

## When values apply

Mod Settings Apply writes the selected percentages. Load a save to apply that snapshot to gameplay. Confirmed changes in the game's own difficulty settings reset and save the corresponding percentages and refresh the active combat settings. A full preset resets both RPG and action balance; an individual RPG/Action change resets only its controls. Unrelated settings changes and canceled difficulty previews preserve your balance. There are no console commands or background settings polls.

**Logging** is the final menu setting and the only diagnostic control. Leave it Off for normal play; On writes troubleshooting details to `Dawnwalker/Binaries/Win64/ue4ss/UE4SS.log`.
