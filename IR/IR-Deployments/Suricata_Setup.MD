
### Installation and Setup Steps:

1. Install the APK package
2. Run Suricata on startup using `rc-update`
3. Start the service
4. Edit the Suricata configuration file located in `/etc/suricata/suricata.yaml`
5. Set the home network address `192.168.220.0/24`
6. Gather data from traffic directed to hosts on the private infrastructure
7. Ensure interfaces are correct (`eth0`)
8. Edit `community-id` value to `true`
9. Update changes to Suricata
10. Load other rule sets
11. Update changes
12. Test the configuration file
13. Run an IDS test
14. View `fast.log` to ensure operability

### Turning on the IDS:

1. Run `suricata-update`
2. Run `rc-service suricata start`
3. To view information from `fast.log`, run:  
   `cat /var/log/suricata/fast.log`
4. To view information from `eve.json`, run:  
   `tail -f /var/log/suricata/eve.json | jq ‘select(.event_type==”alert”)’`
5. Examine information within the log files
6. Note the port numbers, source IP, destination IP, and comments
7. Note if packets are dropped or passed by Suricata
8. Note any anomalies or unwanted behavior
