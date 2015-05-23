```
=== SkidCheck - 2.0 ===
--By HeX

This addon checks the HAC database (sv_SkidList.lua, over ~42,114 cheaters) and lets
everyone in the server know if any are on the current game. This can not *detect*
cheaters, nor can it punish anyone it finds. It only does a warning message.

Check back here often, more IDs added almost daily!

How to use:
Nothing is needed to configure or set up (Unless you want to). Default is to prevent
connection to the server if the player is on the DB.

Commands:
sk            --Does a re-check of everyone in game, does the sound and message.

CVars:
sk_kick  1/0  --Prevent players who are in the DB from joining.
ON by default

sk_omit  0/1  --Don't send the SK message to the cheater in question.
OFF by default, useless if sk_kick or sk_admin is 1

sk_admin 0/1  --Only send SK messages to admins.
OFF by default, useless if sk_kick or sk_omit is 1


Logs (in the /data folder):
sk_encounters.txt    --Logs every cheater that spawns
sk_blocked.txt       --Logs blocked cheater connection attempts if sk_kick is 1


Hooks (SERVER side):
This is called when a known cheater is detected. Return true to stop the default
message and handle it yourself, such as for custom chatboxes/punishments.

hook.Add("OnSkid", "SK", function(ply, Reason) return true end)
```







