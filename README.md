# Dial-a-Song

This is a simple containerized Asterisk config that makes it easy to implement a dial-a-song booth, where people can call a number on an olde timey phone and listen to a song, story, easter egg, or whever else you want to configure.  It's meant to run on a Raspberry Pi with an analog telephone adapter (ATA) like the Grandstream HT801 directly connected via ethernet.


## Quickstart

Set up a pi however you want.  This repo assumes you're using a debian-style distro on it.

Install prereqs:
```
sudo apt install ansible git podman
```

Clone this repo onto a pi.

Build a copy of the container for root:
```
cd dial-a-song/
sudo podman build -t dial-a-song .
```

Run ansible:
```
cd dial-a-song/ansiblerepo
sudo ansible-playbook -i inventory/all.yaml -l localhost site.yaml --diff
```

Configure the ATA.  The pi will have its ethernet interface's ipv4 address set to 10.0.0.1, which will then work with these settings:

 - ATA's address: 10.0.0.2
 - Username: ext1414
 - Password: bananaph0ne
 - SIP host: 10.0.0.1
 - No encryption or anything else fancy like that

Enjoy!


## Adding Songs

For any number that's dialed, the Asterisk config runs an AGI script that looks for mp3 files that match the number and plays it.  If more than one file matches a given number, one of the matching files will chosen randomly.

The mp3 files live in `/home/pi/sounds` on the base OS, and their name should have the format:
```
NNN-any_string.mp3
```
where:
 - `NNN` is the phone number that this file is associated with without dashes or any other separators.  Although this example has three `N`s, you can choose how long the phone number is.
 - `any_string` is any arbitrary extra identifier you want to add to the file name.
 - `-` is a single dash that seprates the number from the rest of the file name.

The sound directory is bind-mounted into the asterisk container and can be updated without restarting the container or the pi.


## Extra notes

The idea: a physical bux with a power port and a phone jack that can play songs, stories, or whatever when numbers are dialed.  Running it should be as automated as possible (ie, adding new files should be really simple)

Some implementation details and ideas:
 - The box might need a USB port that, when a drive is plugged in to it, automatically copies new sound file into place
 - Maybe name the files in a format like `NNNNNNN-file-description.gsm`, where `NNNNNNN` is the phone number the file is associated with.  Then an AGI script can look for all files that have a name that matches the number dialed, choose one randomly, and tell asterisk to play it.
 - Have an import script that watches for a drive to be plugged in and copies/converts any files on it.  
   - But how would you get rid of old files you don't want anymore?
 - Build a physical box that has a pi and an ATA in it, with the ATA's ethernet port plugged directly into the pi's ethernet port.
   - The grandstream ATAs use a USB style plug as their power source; I wonder if they could be powered directly from the pi?
 - Maybe put an eink screen on the box that shows what number is currently being dialed or some other sort of thing?  Could potentially be used as part of an interface for removing unwanted files or something too.
 - I'll want an asterisk container, clearly.  But to make it easy (?) to maintain, do I want dhcp and nginx too?  That way I could assign an IP address to the ATA and let it download its config too, which would make it easier to replace parts if needed.  Or maybe that is too much premature optimization.
 - I'll want some ansible to wrap around this to set up the network port and podman unit files on the pi.
 - maybe use the mp3 asterisk app to avoid needing to do conversions?


Increase verbosity from the asterisk shell:
```
scrapper*CLI> core set verbose 5
scrapper*CLI> module reload logger
```

Startup:
```
podman run --rm --name dial-a-song -v ./conf/modules.conf:/etc/asterisk/modules.conf:Z -v ./conf/extensions.conf:/etc/asterisk/extensions.conf:Z -v ./conf/pjsip.conf:/etc/asterisk/pjsip.conf:Z -v ./scripts:/usr/share/asterisk/agi-bin:Z -v ./sounds:/usr/share/asterisk/sounds/custom:Z --network host --entrypoint /bin/bash -ti dial-a-song:latest
```


Startup on the pi:
```
podman run --name dial-a-song --network host --rm -v /home/pi/sounds:/usr/share/asterisk/sounds/custom/external:Z dial-a-song
```

Create a unit file:
```
podman generate systemd dial-a-song --name --new
```

