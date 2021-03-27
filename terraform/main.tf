module "vm_instance_template_master" {
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
    sudo apt-get install -y salt-master
    sudo mkdir -p /srv/salt/reactor
    sudo tee /etc/salt/master.d/master.conf > /dev/null <<EOT
fileserver_backend:
  - gitfs
  - roots
gitfs_remotes:
  - https://github.com/footprns/devops_indonesia.git
file_roots:
  base:
    - /srv/salt
EOT
  sudo tee /etc/salt/master.d/reactor.conf > /dev/null <<EOT
reactor:
  - 'salt/minion/*/start':
      - /srv/salt/reactor/start.sls
EOT
    sudo apt-get install -y python-pygit2 python-git
    sudo systemctl enable salt-master
    sudo systemctl restart salt-master
  EOF
}


module "vm_compute_instance_master" {
  source  = "terraform-google-modules/vm/google//modules/compute_instance"
  version = "6.2.0"
  # insert the 2 required variables here
  num_instances = 1
  instance_template = module.vm_instance_template_master.self_link
  region = "asia-southeast2"
  hostname          = "salt-master"
  subnetwork  = "projects/jago-sre-gcp-poc-2/regions/asia-southeast2/subnetworks/admin-protected"
  # static_ips = ["10.106.64.23"]
}
