#!/bin/bash
#
# For latest Ubuntu 16.04 LTS AMI (currently: ami-a8d2d7ce)
#

apt-get update
apt-get install -y awscli
ln -s /usr/bin/aws /usr/local/bin/aws

if ${mount_volume}; then
  echo ""
  echo "Formatting and mounting volume for Docker root"
  echo ""
  lsblk -a
  mkfs -t ext4 /dev/xvdf
  mkdir -p /var/lib/docker
  mount /dev/xvdf /var/lib/docker
fi


echo ""
echo "Tagging instance"
echo ""
INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
export AWS_DEFAULT_REGION=eu-west-1
/usr/local/bin/aws ec2 create-tags --resources "$INSTANCE_ID" --tags Key="weave:peerGroupName",Value="${ecs_cluster_name}"

echo ""
echo "Installing Docker"
echo ""
#
# Install Docker CE (from https://docs.docker.com/engine/installation/linux/ubuntu/#install-using-the-repository)

apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get update
apt-get install -y docker-ce

echo ""
echo "Configuring Docker"
echo ""
cat <<EOF >> /etc/docker/daemon.json
{
  "storage-driver": "overlay2"
}
EOF

systemctl restart docker

docker run --rm hello-world

#
# Install WeaveNet
apt-get install -y jq
curl -L git.io/weave -o /usr/local/bin/weave
chmod a+x /usr/local/bin/weave
/usr/local/bin/weave setup

curl -L https://raw.githubusercontent.com/weaveworks/integrations/master/aws/ecs/packer/to-upload/weave.conf -o /etc/init/weave.conf

mkdir /etc/weave
curl -L https://raw.githubusercontent.com/weaveworks/integrations/master/aws/ecs/packer/to-upload/peers.sh -o /etc/weave/peers.sh
chmod +x /etc/weave/peers.sh

curl -L https://raw.githubusercontent.com/weaveworks/integrations/master/aws/ecs/packer/to-upload/run.sh -o /etc/weave/run.sh
chmod +x /etc/weave/run.sh

# Remove all ECS execution traces added while running packer
rm -rf /var/log/ecs/* /var/lib/ecs/data/*

cat <<EOF >> /etc/systemd/system/weave.service
[Unit]
Description=Weave Network
Documentation=http://docs.weave.works/weave/latest_release/
Requires=docker.service
After=docker.service

[Service]
[Service]
EnvironmentFile=-/etc/sysconfig/weave
ExecStartPre=/usr/local/bin/weave launch --no-restart $(/etc/weave/peers.sh)
ExecStart=/usr/bin/docker attach weave
ExecStop=/usr/local/bin/weave stop

[Install]
WantedBy=multi-user.target
EOF

chmod 755 /etc/systemd/system/weave.service
systemctl daemon-reload
systemctl enable weave
systemctl start weave

#
# Install ECS Agent
sh -c "echo 'net.ipv4.conf.all.route_localnet = 1' >> /etc/sysctl.conf"
sysctl -p /etc/sysctl.conf
iptables -t nat -A PREROUTING -p tcp -d 169.254.170.2 --dport 80 -j DNAT --to-destination 127.0.0.1:51679
iptables -t nat -A OUTPUT -d 169.254.170.2 -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 51679
sh -c 'iptables-save > /etc/network/iptables.rules'
mkdir -p /etc/ecs && touch /etc/ecs/ecs.config
cat <<EOF >> /etc/ecs/ecs.config
ECS_DATADIR=/data
ECS_ENABLE_TASK_IAM_ROLE=true
ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true
ECS_LOGFILE=/log/ecs-agent.log
ECS_AVAILABLE_LOGGING_DRIVERS=["json-file","awslogs"]
ECS_LOGLEVEL=info
ECS_CLUSTER=${ecs_cluster_name}
EOF
echo ""
echo "Joined ECS Cluster: ${ecs_cluster_name}"
echo ""

mkdir -p /var/log/ecs /var/lib/ecs/data



cat <<EOF >> /etc/systemd/system/ecs.service
[Unit]
Description=Amazon ECS agent
Requires=weave.service
After=network.target
StartLimitInterval=200
StartLimitBurst=5

[Service]
Type=simple
Environment="DOCKER_HOST=unix:///var/run/weave/weave.sock"
ExecStartPre=-/usr/bin/docker stop ecs-agent
ExecStartPre=-/usr/bin/docker rm ecs-agent
ExecStartPre=/usr/bin/docker pull amazon/amazon-ecs-agent:latest
ExecStart=/usr/bin/docker run --name ecs-agent --privileged=true --volume=/var/run/weave/weave.sock:/var/run/docker.sock --volume=/var/log/ecs/:/log:Z --volume=/var/lib/ecs/data:/data:Z --volume=/etc/ecs:/etc/ecs --net=host --env-file=/etc/ecs/ecs.config amazon/amazon-ecs-agent:latest
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF
chmod 755 /etc/systemd/system/ecs.service
systemctl daemon-reload
systemctl enable ecs
systemctl start ecs