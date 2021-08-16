# Declare arguments we're expecting passed into Dockerfile
# via Context from the Docker Compose yml.
ARG RMQ_VERSION_TAG

# Starting with a RabbitMQ Image and the desired tag...
FROM rabbitmq:${RMQ_VERSION_TAG}

# Define environment variables

# The path that holds the RMQ Pid so we can check for RMQ "ready"
ENV RABBITMQ_PID_FILE /var/lib/rabbitmq/rabbitmq.pid

# Add Ansible so we can do further RMQ provisioning easily
RUN apt-get -y update
RUN apt-get -y install software-properties-common
RUN apt-add-repository ppa:ansible/ansible
RUN apt-get -y install ansible

# Add a custom init script to serve as entry point for our custom image
ADD init.sh /init.sh
RUN chmod +x /init.sh

# Define default command for Docker Up
CMD ["/init.sh"]
