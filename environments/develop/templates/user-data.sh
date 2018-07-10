#!/bin/bash
echo ECS_CLUSTER=ecs-xport-development >> /etc/ecs/ecs.config

## Installing DataDog Agent ##
DD_API_KEY=85f339e1dfe1ddf1b317c167d7994507 bash -c "$(curl -L https://raw.githubusercontent.com/DataDog/datadog-agent/master/cmd/agent/install_script.sh)"
usermod -a -G docker dd-agent

cat > /etc/datadog-agent/conf.d/docker.d/docker_daemon.yaml <<EOF
init_config:

instances:
    - url: "unix://var/run/docker.sock"
      new_tag_names: true
EOF

stop datadog-agent
start datadog-agent
