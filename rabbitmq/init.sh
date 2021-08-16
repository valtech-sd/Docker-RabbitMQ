#!/bin/sh

# Declare a helper function that will be called by the
# script below at the proper time!
run_ansible_rmq() {
  # Run the playbook that contains our provisioning
  ansible-playbook ${PROVISIONING_CONTAINER_PATH}/ansible-config-at-up.yml  \
    -i ${PROVISIONING_CONTAINER_PATH}/inventory
  # Get status for the Ansible command
  ansible_result=$?
  # Fail the container if provisioning fails
  if [ $ansible_result -ne 0 ]; then
    echo "Ansible Provisioning Failed!!"
    kill -9 `cat $RABBITMQ_PID_FILE`
  else
    # Success, output a help string.
    echo "*** Log in the Management UI at port 15671 (example: https://localhost:15671) ***"
    echo "*** If necessary. don't forget to update your /etc/hosts to point a custom domain. ***"
  fi
}

# Fire off some initial setup in a shell in the bkg so that
# RMQ server continues to start up. Note this calls the
# helper `run_ansible` but not until RMQ is "ready"!
( \
  # The work we're doing requires RMQ to be ready, so we wait.
  rabbitmqctl wait --timeout 60 $RABBITMQ_PID_FILE ; \
  # RMQ is up, do our setup using Ansible which is cross-platform
  run_ansible_rmq ; \
) &

# $@ is used to pass arguments to the rabbitmq-server command.
# For example if you use it like this: docker run -d rabbitmq arg1 arg2,
# it will be as you run in the container rabbitmq-server arg1 arg2
rabbitmq-server $@
