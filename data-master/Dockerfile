FROM ubuntu:20.04

RUN apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y openssh-server python3 rsync

RUN sed -i 's/^#? *PermitRootLogin .*$/PermitRootLogin yes/' /etc/ssh/sshd_config && sed -i 's/^#? *PasswordAuthentication /PasswordAuthentication no/g' /etc/ssh/sshd_config

COPY lock_directory.py /

COPY unlock_directory.py /

RUN mkdir -p -m0755 /run/sshd && mkdir -p /root/.ssh && chmod 755 /root/.ssh && chmod 755 /*.py

RUN rm -f /root/.ssh/authorized_keys && \
    ln -s /ssh-authorized-keys/authorized_keys /root/.ssh/authorized_keys && \
    echo "A SSH public key will be copied into a Docker volume mounted at /ssh-authorized-keys in the next step. It will fail if you have not created this file yet! Please see the subsection \"SSH-Schlüssel\" in the chapter \"Geocoding\" in the setup guide for further details."

COPY id_root_ed25519.pub /ssh-authorized-keys/authorized_keys

# Remove PasswordAuthentication for all users (does not really matter as long as default for root logins is prohibit-password but we can then check this box)
RUN sed -i -Ee 's/^#? *PasswordAuthentication .*$/PasswordAuthentication no/g' /etc/ssh/sshd_config

EXPOSE 22

CMD /usr/sbin/sshd -D -e
