#!/bin/bash

echo 'export GEM_HOME=/usr/local/bundle' >> /root/.bashrc
echo 'PATH="/usr/local/bundle/bin:$PATH"' >> /root/.bashrc
if [ -n "${SSH_USER}" ]; then
    echo 'export GEM_HOME=/usr/local/bundle' >> /home/${SSH_USER}/.bashrc
    echo 'PATH="/usr/local/bundle/bin:$PATH"' >> /home/${SSH_USER}/.bashrc
fi
