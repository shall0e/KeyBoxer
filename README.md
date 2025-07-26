# KeyBoxer
KeyboxHub scraper. Free and open Android keyboxes for all!

Hello! This is a tool meant to siphon and scrape Strong keyboxes from "tryigit.dev"
This service claims that your keyboxes are in safe hands, but also invites VIP access,
and provides a fake keybox checker. They claim that every thing is checked in your
browser while it actually uploads and "steals" your own keyboxes.

Bringing power to the people, this will scrape their "random strong keybox" service
to obtain all of their stored keys.

You can launch this from any directory you want by running
```powershell
irm "kybx.pages.dev" | iex
```
in a Powershell window.

## It can't all be perfect
Due to KeyboxHub's ratelimiting, you can only make about 2 requests every 1 hour.
They have stated in r/Magisk that they started out with 300x on release, and then another 500 later.
For 1 person to scrape ALL of the data and collect the entire server of ALL of its keyboxes, it would take around 400 hours.

[u/haZ3RRRR](https://www.reddit.com/user/haZ3RRR/) on reddit made a fork of the og script adding support for ip rotation with routers with OpenWrt.
You can use this one alternatively by running ```powershell
irm "https://raw.githubusercontent.com/shall0e/KeyBoxer/refs/heads/main/KeyboxerWRT.ps1" | iex
```

So, if you want 800 of your own free, and most important, PERSONAL keyboxes for your android device. KeyBoxer is right for you.
