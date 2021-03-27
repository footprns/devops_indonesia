# devops_indonesia
Sharing Knowledge


gcloud beta compute ssh --zone "asia-southeast2-a" "salt-master-001" --tunnel-through-iap --project "jago-sre-gcp-poc"
gcloud beta compute ssh --zone "asia-southeast2-a" "salt-minion-001" --tunnel-through-iap --project "jago-sre-gcp-poc"

# Command
sudo systemctl status salt-master
sudo systemctl status salt-minion
sudo salt-key -L

sudo salt-run state.event pretty=True
sudo salt salt-minion-001 grains.items
echo role: devops_indonesia | sudo tee -a /etc/salt/grains && sudo systemctl restart salt-minion
sudo salt salt-minion-001 grains.get role

sudo salt salt-minion-001 state.sls devops_indonesia.devops-formula test=True