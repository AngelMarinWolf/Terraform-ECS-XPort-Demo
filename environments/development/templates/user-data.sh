#!/bin/bash
echo ECS_CLUSTER=ecs-xport-development >> /etc/ecs/ecs.config

## Installing DataDog Agent ##
DD_API_KEY=85f339e1dfe1ddf1b317c167d7994507 bash -c "$(curl -L https://raw.githubusercontent.com/DataDog/datadog-agent/master/cmd/agent/install_script.sh)"
usermod -a -G docker dd-agent

sed -i -e 's/# logs_enabled: disabled/logs_enabled: true/g'

cat > /etc/datadog-agent/conf.d/docker.d/docker_daemon.yaml <<EOF
init_config:

instances:
    - url: "unix://var/run/docker.sock"
      new_tag_names: true

logs:
    - type: docker
      service: docker
      image: 197736343114.dkr.ecr.us-east-1.amazonaws.com/xport
      source: nginx
      sourcecategory: web_server
EOF

stop datadog-agent
start datadog-agent
