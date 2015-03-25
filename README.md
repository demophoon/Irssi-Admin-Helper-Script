Irssi Admin Helper Script
=========================

Installation
------------
Place the `adminhelper.pl` script in `~/.irssi/scripts/autorun/` directory and load it into Irssi.

How to use
----------

* /masks <hostmask|nickname> - Display what users the hostmask will effect in the current channel.
* /masks_action <action> [<kick_msg>] - Perform an action based on the hostmask
  set in `/masks`. Note that this function will only run if `/masks` was passed
  in a hostmask previously. It also will only run in the last channel where
  `/masks` was ran from to prevent accidentally banning someone in the wrong
  channel.

Actions include:
* VOICE
* DEVOICE
* OP
* DEOP
* BAN
* UNBAN
* KICK
    - Only works when hostmask matches one nick.
