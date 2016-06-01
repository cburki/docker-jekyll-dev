#!/bin/bash

USER_STATUS_FILE=/opt/setupuser.status

if [ -f ${USER_STATUS_FILE} ]; then
    exit 0
fi


if [ -n "${SSH_PASSWORD}" ]; then
    echo "root:${SSH_PASSWORD}" | chpasswd
fi

if [ -n "${SSH_AUTHORIZED_KEY}" ]; then
    echo "${SSH_AUTHORIZED_KEY}" > /root/.ssh/authorized_keys
fi

if [ -n "${SSH_USER}" ]; then

    CREATED=/home/${SSH_USER}/.user-created
    
    if [ -f ${CREATED} ]; then
        exit 0
    fi
    
    USER_ID=1000
    if [ -n "${SSH_USER_ID}" ]; then
        USER_ID=${SSH_USER_ID}
    fi
    
    groupadd -g ${USER_ID} ${SSH_USER}
    useradd -g ${USER_ID} -u ${USER_ID} -d /home/${SSH_USER} -m -k /etc/skel -s /bin/bash ${SSH_USER}
    
    if [ -z "${SSH_PASSWORD}" ]; then
        SSH_PASSWORD=$(pwgen -c -n -1 12)
        echo "New user password : ${SSH_PASSWORD}"
    fi
    echo "${SSH_USER}:${SSH_PASSWORD}" | chpasswd
    
    if [ -n "${SSH_AUTHORIZED_KEY}" ]; then
        mkdir -p /home/${SSH_USER}/.ssh
        echo "${SSH_AUTHORIZED_KEY}" > /home/${SSH_USER}/.ssh/authorized_keys
    fi
    
    cp /etc/skel/.bashrc /home/${SSH_USER}/.
    cp /etc/skel/.profile /home/${SSH_USER}/.
    cp /root/.tmux.conf /home/${SSH_USER}/.tmux.conf
    echo "export PAGER=less" >> /home/${SSH_USER}/.bashrc
    echo "export TERM=xterm" >> /home/${SSH_USER}/.bashrc
    echo "export GEM_HOME=/usr/local/bundle" >> /home/${SSH_USER}/.bashrc
    echo 'PS1="\[\e[32m\]\u\[\e[m\]\[\e[32m\]@\[\e[m\]\[\e[32m\]\h\[\e[m\]\[\e[32m\]:\[\e[m\]\[\e[34m\]\W\[\e[m\] \[\e[34m\]\\$\[\e[m\] "' >> /home/${SSH_USER}/.bashrc
    echo '#[ -z "$TMUX" ] && command -v tmux > /dev/null && tmux && exit 0' >> /home/${SSH_USER}/.bashrc
    echo 'PATH="/usr/local/bundle/bin:$PATH"' >> /home/${SSH_USER}/.bashrc
    
    chown ${SSH_USER}:${SSH_USER} /home/${SSH_USER}
    chown ${SSH_USER}:${SSH_USER} /home/${SSH_USER}/.bashrc
    chown ${SSH_USER}:${SSH_USER} /home/${SSH_USER}/.profile
    chown -R ${SSH_USER}:${SSH_USER} /home/${SSH_USER}/.ssh
    
    touch ${CREATED}
fi

echo "done" >> ${USER_STATUS_FILE}

exit 0
