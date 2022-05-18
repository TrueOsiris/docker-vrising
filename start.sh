#!/bin/bash
/usr/bin/touch /var/log/cron.log 2>/dev/null
/usr/bin/chmod 666 /var/log/cron.log 2>/dev/null

echo $'/var/log/cron.log {\n  rotate 7\n  daily\n  missingok\n  notifempty\n  create\n}' > /etc/logrotate.d/git-cron
echo "$date Running start.sh" >> /var/log/cron.log
echo "30 5 * * * /usr/sbin/logrotate /etc/logrotate.d/git-cron" >> /etc/cron.d/git-cron
echo " " >> /etc/cron.d/git-cron
/usr/bin/crontab /etc/cron.d/git-cron
/usr/sbin/cron -f
/usr/bin/tail -f /var/log/cron.log

