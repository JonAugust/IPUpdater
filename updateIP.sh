#!/bin/sh

# Needed to install the following:
# Python
# pip
# awscli via pip
# doctl (sudo snap install doctl)
#    - mkdir .config
#    - doctl auth init

# Import Creds from another file - Entire file looks like this:
# export AWS_ACCESS_KEY_ID=""
# export AWS_SECRET_ACCESS_KEY=""
# export IPINFO_TOKEN=""
# export AWS_ROUTE53_ZONEID=""
# export TWILIO_ENABLED=false
# export TWILIO_SID=""
# export TWILIO_TOKEN=""
# export TWILIO_FROM=""
# export TWILIO_TO=""
# export FIREWALL_ID=""
# export HOSTNAME=""
# export PUSHOVER_ENABLED=false
# export PUSHOVER_USER=""
# export PUSHOVER_TOKEN=""

# You will want to edit the path to your credentials file:
. /home/jon/Creds/IPUpdaterCreds.sh

TEMPFILE="/tmp/updateIP.tmp"

TTL="300"

IP=`/usr/bin/curl ipinfo.io/ip?token=$IPINFO_TOKEN` 2>/dev/null
OLDIP=''
NEEDSUPDATE=false

if [ -f "$TEMPFILE" ]
then
    OLDIP=`/bin/cat $TEMPFILE` 2>/dev/null
    if [ $IP = $OLDIP ]
    then
        echo "no change"
    else
        NEEDSUPDATE=true
    fi
else
    NEEDSUPDATE=true
fi

if [ "$NEEDSUPDATE" = true ]
then
    if expr "$IP" : '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null; then
        /usr/local/bin/aws route53 change-resource-record-sets --hosted-zone-id $AWS_ROUTE53_ZONEID --change-batch "{ \"Changes\": [ { \"Action\": \"UPSERT\", \"ResourceRecordSet\": { \"Name\": \"$HOSTNAME\", \"Type\": \"A\", \"TTL\": $TTL, \"ResourceRecords\": [ { \"Value\": \"$IP\" } ] } } ] }"
        echo "Updated the DNS Zone to $IP"
        echo "$IP" > $TEMPFILE
	      /snap/bin/doctl compute firewall remove-rules $FIREWALL_ID --inbound-rules "protocol:tcp,ports:22,address:$OLDIP"
        /snap/bin/doctl compute firewall add-rules $FIREWALL_ID --inbound-rules "protocol:tcp,ports:22,address:$IP"
        if [ "$TWILIO_ENABLED" = true ]
        then
            /usr/bin/curl -X POST https://api.twilio.com/2010-04-01/Accounts/$TWILIO_SID/Messages.json \
	              --data-urlencode "Body=Dynamic DNS IP Updated" \
	              --data-urlencode "From=+1$TWILIO_FROM" \
	              --data-urlencode "To=+1$TWILIO_TO" \
	              -u $TWILIO_SID:$TWILIO_TOKEN >/dev/null 2>&1
        fi
        if [ "$PUSHOVER_ENABLED" = true ]
        then
	          /usr/bin/curl --location 'https://api.pushover.net/1/messages.json' \
                --form "token=$PUSHOVER_TOKEN" \
                --form "user=$PUSHOVER_USER" \
                --form "message=Dynamic DNS IP Updated" \
                --form "title=Router IP Updated" \
                --form "sound=tugboat"
        fi
    else
        echo "Invalid IP"
        if [ "$TWILIO_ENABLED" = true ]
        then
	        /usr/bin/curl -X POST https://api.twilio.com/2010-04-01/Accounts/$TWILIO_SID/Messages.json \
	            --data-urlencode "Body=IP from IPInfo no good. Something wrong," \
	            --data-urlencode "From=+1$TWILIO_FROM" \
	            --data-urlencode "To=+1$TWILIO_TO" \
	            -u $TWILIO_SID:$TWILIO_TOKEN >/dev/null 2>&1
        fi
        if [ "$PUSHOVER_ENABLED" = true ]
        then
	        /usr/bin/curl --location 'https://api.pushover.net/1/messages.json' \
              --form "token=$PUSHOVER_TOKEN" \
              --form "user=$PUSHOVER_USER" \
              --form "message=IP from IPInfo no good. Something wrong" \
              --form "title=IPInfo Error" \
              --form "sound=tugboat"
        fi
    fi
fi