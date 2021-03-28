# devops_indonesia
Sharing Knowledge


gcloud beta compute ssh --zone "asia-southeast2-a" "salt-master-001" --tunnel-through-iap --project "jago-sre-gcp-poc"
gcloud beta compute ssh --zone "asia-southeast2-a" "salt-minion-001" --tunnel-through-iap --project "jago-sre-gcp-poc"

# Command
## SaltStack Architecture
sudo systemctl status salt-master
sudo systemctl status salt-minion

## Event System Architecture
sudo salt-run state.event pretty=True

## Key based authentication
sudo salt-key -L

## Salt Grains
sudo salt salt-minion-001 grains.items
echo role: devops_indonesia | sudo tee -a /etc/salt/grains && sudo systemctl restart salt-minion
sudo salt salt-minion-001 grains.get role

## Salt State
ls -la /tmp/appendfile.txt
sudo salt salt-minion-001 state.sls state.firststate test=True

## Salt Returner
No demo

## Salt Reactor
sudo vi /etc/salt/master.d/reactor.conf 
sudo systemctl restart salt-minion
