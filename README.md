![](http://i.imgur.com/3bxeiqQ.png)

```
=== SkidCheck - 2.0 ===
--By HeX

This addon checks the HAC database (The sv_SkidList files, over ~52,844 cheaters)
and lets everyone in the server know if any are on the current game.
This can not *detect* cheaters, nor can it punish anyone it finds. It only does
a warning message.

Check back here often, more IDs added almost daily!

How to use:
Nothing is needed to configure or set up (Unless you want to). Default is to prevent
connection to the server if the player is on the database, and to update the database
from GitHub on server map change, and every 6 hours after.

CVars:
sk_kick  1/0  --Prevent players who are in the DB from joining.
ON by default

sk_omit  0/1  --Don't send the SK message to the cheater in question.
OFF by default, useless if sk_kick or sk_admin is 1

sk_admin 0/1  --Only send SK messages to admins.
OFF by default, useless if sk_kick or sk_omit is 1

sk_sync  6/0  --Allow list sync from GitHub? in hours to check for updates.
ON by default


Commands:
sk            --Does a re-check of everyone in game, does the sound and message.

sk_update     --Sync all lists rignt now, usually runs every sk_sync hours



Logs (in the /data folder):
sk_encounters.txt    --Logs every cheater that spawns
sk_blocked.txt       --Logs blocked cheater connection attempts if sk_kick is 1


Hooks (SERVER side):
This is called when a known cheater is detected. Return true to stop the default
message and handle it yourself, such as for custom chatboxes/punishments.

sk_kick must be 0 for this to work, which will ALLOW them to join the server unless
handled yourself in this hook!

hook.Add("OnSkid", "SK", function(ply, Reason) return true end)
```







