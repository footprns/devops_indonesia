# devops_indonesia
Sharing Knowledge


gcloud beta compute ssh --zone "asia-southeast2-a" "salt-master-001" --tunnel-through-iap --project "jago-sre-gcp-poc"
gcloud beta compute ssh --zone "asia-southeast2-a" "salt-minion-001" --tunnel-through-iap --project "jago-sre-gcp-poc"
gcloud beta compute ssh --zone "asia-southeast2-b" "salt-minion-002" --tunnel-through-iap --project "jago-sre-gcp-poc"


# Command
## SaltStack Architecture
sudo systemctl status salt-master
sudo systemctl status salt-minion

## Event System Architecture
sudo salt-run state.event pretty=True

## Key based authentication
gcloud beta compute ssh --zone "asia-southeast2-a" "salt-master-001" --tunnel-through-iap --project "jago-sre-gcp-poc"

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

# Salt Beacon
sudo vi /etc/important_file
sudo cat /etc/important_file

# Salt Orchestration
sudo salt-key -L
sudo salt-run state.orch orch.timestamp
ls -la /tmp/timestamp.txt

# Salt API
sudo useradd saltdev
sudo passwd saltdev
curl -sSk https://localhost:8000/login \
    -H 'Accept: application/x-yaml' \
    -d username=saltdev \
    -d password=saltdev \
    -d eauth=pam

curl -sSk https://localhost:8000 \
    -H 'Accept: application/x-yaml' \
    -H 'X-Auth-Token: 2cceff677b76d4b668653bae4055ee471547c2d7'\
    -d client=local \
    -d tgt='*' \
    -d fun=test.ping