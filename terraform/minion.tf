module "vm_instance_template_minion" {
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
    sudo apt-get install -y salt-minion python3-pip
    pip3 install pyinotify
    echo master: salt-master-001 | sudo tee /etc/salt/minion.d/minion.conf 
    echo id: $(hostname -s) | sudo tee -a /etc/salt/minion.d/minion.conf 
    sudo tee -a /etc/salt/minion.d/beacon.conf  > /dev/null <<EOT
beacons:
  inotify:
    - files:
        /etc/important_file:
          mask:
            - modify
EOT
    sudo systemctl enable salt-minion
    sudo systemctl restart salt-minion
  EOF
}


module "vm_compute_instance_minion" {
  source  = "terraform-google-modules/vm/google//modules/compute_instance"
  version = "6.2.0"
  # insert the 2 required variables here
  num_instances = 2
  instance_template = module.vm_instance_template_minion.self_link
  region = "asia-southeast2"
  hostname          = "salt-minion"
  subnetwork  = "projects/jago-sre-gcp-poc-2/regions/asia-southeast2/subnetworks/admin-protected"
  # static_ips = ["10.106.64.23"]
}
