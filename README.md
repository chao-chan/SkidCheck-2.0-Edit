```
=== SkidCheck - 2.0 ===
--By HeX

This addon checks the HAC database (sv_SkidList.lua, over ~6900 cheaters) and lets
everyone in the server know if any are on the current game. This can not *detect*
cheaters, nor can it punish anyone it finds.

How to use:
Runs when players spawn. Nothing is needed to configure or set up.

Commands:
sk           --Does a re-check of everyone in game, does the sound and message.

CVars:
sk_kick 0/1  --Prevent players who are in the DB from joining. OFF by default

Logs:
sk_encounters.txt    --Logs every cheater that spawns
sk_blocked.txt       --Logs connection attempts if sk_kick 1 is set

There also exists a hook, "OnSkid" (ply, Reason, is_serverside) to run custom events
when a known cheater is detected.
```







