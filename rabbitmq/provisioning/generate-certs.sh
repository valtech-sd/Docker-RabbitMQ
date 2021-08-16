#!/bin/bash

# This script uses the TLS-GEN library to generate self-signed
# TLS certs suitable to use for RMQ. The certificates will be
# copied to the /[repo-root]/rabbitmq/config/certs/.
# You can change the domain to suit your needs!

# Learn more about TLS-GEN at https://github.com/michaelklishin/tls-gen
# The TLS-GEN library requires Python 3.6 or later and openssl.
# Install those prior to running this tool.

# Change into the tool directory. Basis is fine for our use.
cd tls-gen/basic/
# Generate the certs for our desired hostname
# USING THE DOMAIN NAME "docker-rmq.local" below, but you can change
# this to suit your needs!
make CN=docker-rmq.local
# copy over to the right location in the project
cp -r result/ ../../../config/certs/
# Cleanup
rm -rf server client testca result

