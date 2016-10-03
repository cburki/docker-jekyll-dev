#!/bin/bash

ENV_STATUS_FILE=/opt/setupenv.status

if [ -f ${ENV_STATUS_FILE} ]; then
    exit 0
fi

echo 'export GEM_HOME=/usr/local/bundle' >> /root/.bashrc
echo 'PATH="/usr/local/bundle/bin:$PATH"' >> /root/.bashrc
if [ -n "${SSH_USER}" ]; then
    echo 'export GEM_HOME=/usr/local/bundle' >> /home/${SSH_USER}/.bashrc
    echo 'PATH="/usr/local/bundle/bin:$PATH"' >> /home/${SSH_USER}/.bashrc
fi

echo "done" >> ${ENV_STATUS_FILE}

exit 0
