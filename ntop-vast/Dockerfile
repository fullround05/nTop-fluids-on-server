FROM us-docker.pkg.dev/ntopweb/ntop-automate/ntop-automate:latest

USER root

RUN dnf install -y \
        openssh-server \
        passwd \
        tmux \
        nano \
        && ssh-keygen -A \
        && dnf clean all

RUN mkdir -p /run/sshd

COPY startup.sh /startup.sh
RUN chmod +x /startup.sh

ENTRYPOINT ["/startup.sh"]

# How to build and push:
# docker build -t gravygravy/ntop-vast .
# docker push gravygravy/ntop-vast
