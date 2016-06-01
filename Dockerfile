FROM ruby:latest
MAINTAINER Christophe Burki, christophe.burki@gmail.com

# Install system requirements
RUN apt-get update && apt-get install -y --no-install-recommends \
    emacs24-nox \
    less \
    locales \
    node \
    openssh-server \
    pwgen \
    tmux \
    xterm && \
    apt-get autoremove -y && \
    apt-get clean

# Install jekyll requirements
RUN gem install \
  jekyll \
  jekyll-redirect-from \
  jekyll-textile-converter \
  kramdown \
  rouge

# Configure locales and timezone
RUN locale-gen en_US.UTF-8 en_GB.UTF-8 fr_CH.UTF-8 && \
    cp /usr/share/zoneinfo/Europe/Zurich /etc/localtime && \
    echo "Europe/Zurich" > /etc/timezone

# Configure sshd
RUN mkdir /var/run/sshd && \
    sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \
    sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config && \
    sed -ri 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config && \
    mkdir /root/.ssh

# s6 install and configs
COPY bin/* /usr/bin/
COPY configs/etc/s6 /etc/s6/
RUN chmod a+x /usr/bin/s6-* && \
    chmod a+x /etc/s6/.s6-svscan/finish /etc/s6/sshd/run /etc/s6/sshd/finish /etc/s6/jekyll/run /etc/s6/jekyll/finish

# install setup scripts
COPY scripts/* /opt/
RUN chmod a+x /opt/setupusers.sh /opt/setupgit.sh

# setup shell environment
COPY configs/tmux/tmux.conf /root/.tmux.conf
RUN echo 'export PAGER=less' >> /root/.bashrc && \
    echo 'export TERM=xterm' >> /root/.bashrc && \
    echo 'export GEM_HOME=/usr/local/bundle' >> /root/.bashrc && \
    echo 'PS1="\[\e[32m\]\u\[\e[m\]\[\e[32m\]@\[\e[m\]\[\e[32m\]\h\[\e[m\]\[\e[32m\]:\[\e[m\]\[\e[34m\]\W\[\e[m\] \[\e[34m\]\\$\[\e[m\] "' >> /root/.bashrc && \
    echo '#[ -z "$TMUX" ] && command -v tmux > /dev/null && tmux && exit 0' >> /root/.bashrc && \
    echo 'PATH="/usr/local/bundle/bin:$PATH"' >> /root/.bashrc

VOLUME /data/src
WORKDIR /data/src

EXPOSE 22 4000

CMD ["/usr/bin/s6-svscan", "/etc/s6"]