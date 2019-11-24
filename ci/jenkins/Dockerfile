FROM jenkins/jenkins:2.205-alpine

MAINTAINER helhindi (fb@elhindi.net)

# Disable admin password setup
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

# Install plugins from `plugins.txt`
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
