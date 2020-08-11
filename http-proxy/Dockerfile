FROM httpd:2.4

# install xinetd to make it possible to add check_mk to the Docker container
# procps (to be precise: the 'pgrep' binary) is required by the postinst script of check-mk-agent
RUN apt-get -qq update && apt-get -qq upgrade -f && apt-get install -qq -y xinetd procps
COPY thirdparty/check-mk-agent_1.5.0p24-1_all.deb /tmp/check-mk-agent.deb
RUN dpkg -i /tmp/check-mk-agent.deb && rm /tmp/check-mk-agent.deb

# Es wird xinetd in den Entrypoint reingepatcht, damit der check-mk agent abgerufen werden kann.
RUN sed -e '2ixinetd' -i /usr/local/bin/httpd-foreground

COPY httpd.conf /usr/local/apache2/conf/httpd.conf
