# cpu-control

Bash script to enable/disable CPUs (cores) on a Linux machine

# Usage

Script needs to be executed as root
```
./cpu-control.sh 0.5 # enable half of installed CPUs to run
./cpu-control.sh 1 # enable all CPUs to run
```

# Example use case

1. Modify available CPU power based on daily schedule
  - Dial down available CPUs during office hours to limit heat, noise generated by computers
2. Conserve energy based on (pricing) schedule
  - If you have a long running and CPU demanding job you can limit CPUs during times when electricity is more expensive
  - And enable all CPUs when price goes down. For example limit CPU usage between 8 AM and 8 PM
  
  
# Installation
```
curl https://raw.githubusercontent.com/wlk/cpu-control/master/cpu-control.sh > /usr/sbin/cpu-control.sh
chmod +x /usr/sbin/cpu-control.sh
```

# Enable in cron
Just an example
```
echo "30 7 * * 1-5  root /usr/sbin/cpu-control.sh 0.2" >  /etc/cron.d/cpu-control-enable
echo "0 17 * * 1-5  root /usr/sbin/cpu-control.sh 1" >  /etc/cron.d/cpu-control-disable
```