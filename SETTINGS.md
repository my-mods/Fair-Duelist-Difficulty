# Settings

Choose and confirm a starting difficulty in the game's settings, then open Mod Settings > Fair Duelist - Customizable Difficulty to adjust individual controls. Press Apply, then load a save. Restore discards unapplied changes; Reset loads Duelist defaults. Warning: confirming another difficulty in the game's settings replaces the corresponding custom values; canceled previews preserve them.

All percentages are absolute, measured against the unscaled game value. `100%` is normal, `50%` is half, and `150%` is one and a half times. `0%` damage is zero damage. Attack-delay percentages measure cooldown length; a lower value means a shorter delay, rather than a slower animation.

| Setting | Range or choices |
| --- | --- |
| Override difficulty balance | Off, On |
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

At startup, outdated or invalid settings.ini files are replaced in full with current Duelist defaults. Old multipliers and personal INI values are not imported. Valid current settings are retained. Back up preferences before updating if you want to keep a reference. New installations initialize from the currently selected native RPG and Action difficulties on first save load.

Back up your generated preferences before reinstalling or uninstalling. Do not overwrite an absolute settings file with an old INI. Invalid, duplicate or missing required values stop loading and are reported in `Dawnwalker/Binaries/Win64/ue4ss/UE4SS.log`.

An interrupted conversion retains `settings.ini.absolute-v2.backup`; an interrupted later write retains `settings.ini.absolute-write.backup`. If the primary file is missing, preserve any transaction files and recover the complete matching backup before restarting. The mod refuses to overwrite unresolved backups or a settings file changed during a write.

## When values apply

Mod Settings Apply writes the selected percentages. Load a save to apply that snapshot to gameplay. Confirmed changes in the game's own difficulty settings reset and save the corresponding percentages and refresh the active combat settings. A full preset resets both RPG and action balance; an individual RPG/Action change resets only its controls. Unrelated settings changes and canceled difficulty previews preserve your balance. There are no console commands or background settings polls.

**Logging** is the final menu setting and the only diagnostic control. Leave it Off for normal play; On writes troubleshooting details to `Dawnwalker/Binaries/Win64/ue4ss/UE4SS.log`.
