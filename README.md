# devops_indonesia
Sharing Knowledge


gcloud beta compute ssh --zone "asia-southeast2-a" "salt-master-001" --tunnel-through-iap --project "jago-sre-gcp-poc"
gcloud beta compute ssh --zone "asia-southeast2-a" "salt-minion-001" --tunnel-through-iap --project "jago-sre-gcp-poc"
gcloud beta compute ssh --zone "asia-southeast2-b" "salt-minion-002" --tunnel-through-iap --project "jago-sre-gcp-poc"
gcloud beta compute ssh --zone "asia-southeast2-a" "salt-proxy-001" --tunnel-through-iap --project "jago-sre-gcp-poc"


# Command
## SaltStack Architecture
sudo systemctl status salt-master
sudo systemctl status salt-minion

## Event System Architecture
sudo salt-run state.event pretty=True

## Key based authentication
gcloud beta compute ssh --zone "asia-southeast2-a" "salt-master-001" --tunnel-through-iap --project "jago-sre-gcp-poc"
sudo salt-key -L

## Salt Grains
sudo salt salt-minion-001 grains.items
echo role: devops_indonesia | sudo tee -a /etc/salt/grains && sudo systemctl restart salt-minion
sudo salt salt-minion-001 grains.get role

## Salt State
ls -la /tmp/appendfile.txt
sudo salt salt-minion-001 state.sls state.firststate

## Salt Returner
No demo

## Salt Reactor
sudo vi /etc/salt/master.d/reactor.conf 
sudo systemctl restart salt-master
sudo salt-run state.event pretty=True
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
    -H 'X-Auth-Token: 9dadb468298c7863f0005cd9bfc93c521667d9f9'\
    -d client=local \
    -d tgt='*' \
    -d fun=test.ping

## Salt Proxy
https://github.com/saltstack/salt-contrib
https://github.com/napalm-automation/napalm-salt

sudo salt-proxy --proxyid=p8000 -l debug
https://docs.saltproject.io/en/latest/topics/proxyminion/index.html

w3m http://127.0.0.1:8000/
sudo salt p8000 service.start apache
sudo salt p8000 pkg.install svc-patch1