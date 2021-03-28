module "vm_instance_template_proxy" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "6.2.0"
  # insert the 3 required variables here
  project_id      = "jago-sre-gcp-poc"
  subnetwork  = "projects/jago-sre-gcp-poc-2/regions/asia-southeast2/subnetworks/admin-protected"
  region = "asia-southeast2"
  source_image = "ubuntu-1804-bionic-v20200716"
  source_image_family = "ubuntu-1804-lts"
  source_image_project = "confidential-vm-images"
#   service_account = "321052482526-compute@developer.gserviceaccount.com"
  service_account = {
      email = "321052482526-compute@developer.gserviceaccount.com"
      scopes = ["compute-rw"]
  }
  startup_script = <<EOF
    # Download key
    sudo curl -fsSL -o /usr/share/keyrings/salt-archive-keyring.gpg https://repo.saltproject.io/py3/ubuntu/18.04/amd64/latest/salt-archive-keyring.gpg
    # Create apt sources list file
    echo "deb [signed-by=/usr/share/keyrings/salt-archive-keyring.gpg] https://repo.saltproject.io/py3/ubuntu/18.04/amd64/latest bionic main" | sudo tee /etc/apt/sources.list.d/salt.list
    sudo apt-get update
    sudo apt-get install -y salt-minion=2017.7.4+dfsg1-1ubuntu18.04.2 salt-common=2017.7.4+dfsg1-1ubuntu18.04.2 salt-proxy python3-pip w3m
    pip3 install bottle
    cd /tmp
    git clone https://github.com/saltstack/salt-contrib.git
    cd /tmp/salt-contrib/proxyminion_rest_example
    sudo mkdir -p /etc/salt/proxy.d
    sudo mkdir -p /etc/salt/minion.d
    echo master: salt-master-001.asia-southeast2-a.c.jago-sre-gcp-poc.internal | sudo tee /etc/salt/proxy.d/proxy.conf 
    echo master: salt-master-001.asia-southeast2-a.c.jago-sre-gcp-poc.internal | sudo tee /etc/salt/minion.d/minion.conf 
    echo id: $(hostname -s) | sudo tee -a /etc/salt/minion.d/minion.conf
    sudo systemctl enable salt-minion
    sudo systemctl restart salt-minion
    python3 rest.py &
  EOF
}


module "vm_compute_instance_proxy" {
  source  = "terraform-google-modules/vm/google//modules/compute_instance"
  version = "6.2.0"
  # insert the 2 required variables here
  num_instances = 2
  instance_template = module.vm_instance_template_proxy.self_link
  region = "asia-southeast2"
  hostname          = "salt-proxy"
  subnetwork  = "projects/jago-sre-gcp-poc-2/regions/asia-southeast2/subnetworks/admin-protected"
  # static_ips = ["10.106.64.23"]
}
