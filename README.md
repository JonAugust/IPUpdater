# IPUpdater

![](https://img.shields.io/badge/kinda-%20useful-blue) 

:man_shrugging:

IPUpdater is a DIY Dynamic DNS Updater.  You can run this from your home on a Linux instance or a Raspberry Pi.

This shell script will ask IPInfo.io for your current public-facing IP and compare it to the last collected value. If the two differ, the script will then update the value at AWS Route53 and then update a firewall rule at DigitalOcean.

The script is designed this way because I have DNS services at AWS and Droplets at DigitalOcean.  The firewall rule limits ssh access to my home network.

### Notifications

The script can notify you of updates or errors using Twilio SMS or Pushover.net Push Notifications.

This configuration may not fit your needs 100%, but it should help get you started.

----

When I have some more time, I will may improve the code around sending notifications and add support for AWS Security Groups.  Please feel free to contirbute.