# IPUpdater

![](https://img.shields.io/badge/kinda-%20useful-blue) :man_shrugging:

This shell script will check your IP against IPInfo.io and compare it to the last collected value. If the two differ, the script will then update the value at AWS Route53 and then update a firewall rule at DigitalOcean.

This configuration is because I have DNS services at AWS and Droplets at DigitalOcean.  The firewall rule limits ssh access to my home network.

### Notifications

The script can notify you of updates or errors using Twilio SMS or Pushover.net Push Notifications.

This configuration may not fit your needs 100%, but it should help get you started.

