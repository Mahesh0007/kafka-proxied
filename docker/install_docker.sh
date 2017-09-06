#!/bin/sh
. ../scripts/common.sh

if [[ $EUID -ne 0 ]]; then
  display_error "This script must be run as root"
  exit 1
fi

eval 'docker --version' > /dev/null 2>&1
if [ $? -eq 127 ]; then
  display_info "installing docker and docker-compose..."
  cat >/etc/yum.repos.d/docker.repo <<-EOF
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

  yum -y install docker
  systemctl start docker.service
  systemctl enable docker.service
  groupadd docker

  yum -y install python-pip
  pip install --upgrade pip
  pip install -U docker-compose

else
  display_error "docker and docker-compose already installed"
fi

# user_count=`ll /home |tail -n +2 |awk '{print $9}' |wc -l`
# echo "There are $user_count users on the system."
while true; do
  read -e -p "Enter a user to be added to the docker group: " -i "$user" user
  usermod -aG docker $user
  sleep 1
  echo "user $user added to docker group"
  user=""
done
