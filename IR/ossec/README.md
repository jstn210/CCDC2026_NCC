## ossec fix for : "ERROR: Cannot unlink /queue/rids/sender: No such file or directory
###Run:
touch /var/ossec/queue/rids/sender

## agents that can't communicate with server
use source code and start as standalone

## source install agent packages:
https://www.ossec.net/docs/docs/manual/installation/installation-requirements.html
### for deb: apt-get install build-essential make zlib1g-dev libpcre2-dev libevent-dev libssl-dev libsystemd-dev gcc


## steps to start agent
### 1. Install agent binary or use source code (if source code make sure ossec installs in /var/ossec)
### 2. to enroll agent go to /var/ossec/bin/manage_agents and give key from server
### 3. Start the agent with /var/ossec/bin/ossec-control ; other available options: {start|stop|reload|restart|status}

