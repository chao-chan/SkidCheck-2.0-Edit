*NOTICE: I DO NOT OWN THIS!!! ALL CREDIT SHOULD GO TO HEX!*
Link to Original: https://github.com/MFSiNC/SkidCheck-2.0
![](http://i.imgur.com/qJSb8nT.png)

```
=== SkidCheck - 2.0 ===
--By HeX

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
+ SkidCheck is the database of players who *I* don't want joining the UHDM server. +
+ If you don't trust the list, don't install it. It was made by me to keep out     +
+ people who ruin the game.  Not to cause drama.                                   +
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

How to use:
Nothing is needed to configure or set up (Unless you want to).

This addon will, by default, for any IDs in the database, do a warning message and
sound when those players spawn in the server.
It will also update the lists from GitHub on server map change, then every 6 hours.

It can not *detect* cheaters, nor can it punish anyone it finds. It can only do the
following:


CVars:
sk_kick  0/1  --Prevent players in the DB from joining. Overrides everything else
OFF by default

sk_omit  1/0  --Don't send the SK message to the cheater in question.
ON by default, useless if sk_kick or sk_admin is 1

sk_admin 0/1  --Only send SK messages to admins.
OFF by default, useless if sk_kick or sk_omit is 1

sk_sync  6/0  --Allow list sync from GitHub? in hours to check for updates.
ON by default


Commands:
sk            --Re-play the sound and message of any cheaters in game.

sk_update     --Sync all lists rignt now, usually runs every sk_sync hours



Logs (in the server's /data folder):
sk_connect.txt       --Logs cheater join attempts (Player blocked if sk_kick is 1)
sk_encounters.txt    --Logs every cheater that spawns (if sk_kick is 0)


Hooks (SERVER side):
This is called when a known cheater is detected. Return true to stop the default
message and handle it yourself, such as for custom chatboxes/punishments.

sk_kick must be 0 for this to work, which will ALLOW them to join the server unless
handled yourself in this hook!

hook.Add("OnSkid", "SK", function(ply, Reason) return true end)
```







