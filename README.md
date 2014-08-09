```
=== SkidCheck - 2.0 ===
--By HeX

This addon checks the HAC database @ unitedhosts.org and lets everyone in the server know if
any known cheaters are on. This can not *detect* cheaters, nor can it punish anyone it
finds.

How to use:
Runs when players spawn. Nothing is needed to configure or set up.

Commands:
sk [f]       --Force a re-check of everyone in game, run with "f" to update the database
before checking.
sk_kick 0/1  --Prevent players who are banned from joining the server. OFF by default

There exists a hook, "OnSkid" (ply, Reason) to run custom events when a known cheater is
detected.
```







