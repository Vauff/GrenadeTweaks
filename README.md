# disable_grenade_smoke

This plugin stops the smoke created from HE grenades by overriding CS:GO's [default function](https://github.com/perilouswithadollarsign/cstrike15_src/blob/master/game/shared/cstrike15/hegrenade_projectile.cpp#L111) that decides it to always use a smokeless grenade particle (explosion_hegrenade_brief), unless the explosion was in water, in which case smoke would not have been created anyways.

## Requirements

- [DHooks](https://forums.alliedmods.net/showpost.php?p=2588686&postcount=589)