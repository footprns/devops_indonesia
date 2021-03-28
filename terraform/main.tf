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
    sudo apt-get install -y salt-master salt-api python3-pip
    pip3 install cherrypy
    sudo mkdir -p /srv/salt/reactor
    # install salt-api
    pip3 install cherrypy
    sudo salt-call --local tls.create_self_signed_cert
    sudo tee /etc/salt/master.d/master.conf > /dev/null <<EOT
fileserver_backend:
  - gitfs
  - roots
gitfs_remotes:
  - https://github.com/saltstack-formulas/apache-formula.git
  - https://github.com/saltstack-formulas/tomcat-formula.git
  - https://github.com/footprns/devops_indonesia.git
file_roots:
  base:
    - /srv/salt
EOT
  sudo tee /etc/salt/master.d/reactor.conf > /dev/null <<EOT
# reactor:
#   - 'salt/minion/*/start':
#       - /srv/salt/reactor/start.sls
#   - 'salt/beacon/salt-minion-001/inotify//etc/important_file':
#       - /srv/salt/reactor/important_file.sls
EOT
  sudo tee /etc/salt/master.d/salt-api.conf > /dev/null <<EOT
rest_cherrypy:
  port: 8000
  ssl_crt: /etc/pki/tls/certs/localhost.crt
  ssl_key: /etc/pki/tls/certs/localhost.key
external_auth:
  pam:
    thatch:
      - 'web*':
        - test.*
        - network.*
    saltdev:
      - .*
EOT
  sudo tee /srv/salt/reactor/start.sls > /dev/null <<EOT
install_zsh:
  local.state.single:
    - tgt: 'kernel:Linux'
    - tgt_type: grain
    - args:
      - fun: pkg.installed
      - name: zsh
EOT
  sudo tee /srv/salt/reactor/important_file.sls > /dev/null <<EOT
put_important_file:
  local.state.single:
    - tgt: 'kernel:Linux'
    - tgt_type: grain
    - args:
      - fun: file.managed
      - name: /etc/important_file
      - contents: |
          This is important file
EOT
    sudo apt-get install -y python-pygit2 python-git
    sudo systemctl enable salt-master
    sudo systemctl restart salt-master
    sudo systemctl enable salt-api
    sudo systemctl restart salt-api
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
