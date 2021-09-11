# A means of tailing pihole queries and filtering on a given IP
tail -f /var/log/pihole.log | grep -e 192\.168\.1\.7