# Jenkins Container
ARG IMAGE_USER=geoffh1977
ARG IMAGE_NAME=openjdk8
ARG IMAGE_VERSION=latest

FROM ${IMAGE_USER}/${IMAGE_NAME}:${IMAGE_VERSION}
LABEL maintainer="geoffh1977 <geoffh1977@gmail.com>"
USER root

ARG HTTP_PORT=8080
ARG AGENT_PORT=50000
ARG JENKINS_HOME=/data
ARG JENKINS_VERSION
ARG JENKINS_SHA
ARG JENKINS_URL=http://mirrors.jenkins.io/war-stable/${JENKINS_VERSION}/jenkins.war

ENV JENKINS_VERSION="${JENKINS_VERSION}" \
  JENKINS_HOME="${JENKINS_HOME}" \
  JENKINS_SLAVE_AGENT_PORT="${AGENT_PORT}" \
  JENKINS_UC="https://updates.jenkins.io" \
  JENKINS_UC_EXPERIMENTAL="https://updates.jenkins.io/experimental" \
  JENKINS_INCREMENTALS_REPO_MIRROR="https://repo.jenkins-ci.org/incrementals" \
  COPY_REFERENCE_FILE_LOG="${JENKINS_HOME}/copy_reference_file.log"

# Install Software
# hadolint ignore=DL3018,DL4006
RUN apk add --no-cache git openssh-client curl unzip bash ttf-dejavu coreutils tini docker && \
  mkdir -p "$JENKINS_HOME" /usr/share/jenkins/ref/init.groovy.d && \
  chown "${ALPINE_USER}":"${ALPINE_USER}" "$JENKINS_HOME" && \
  curl -fsSL "${JENKINS_URL}" -o /usr/share/jenkins/jenkins.war && \
  echo "${JENKINS_SHA}  /usr/share/jenkins/jenkins.war" | sha256sum -c - && \
  sed -i "/^docker:/s/$/${ALPINE_USER}/" /etc/group && \
  chmod u+s /usr/bin/docker

COPY scripts/init.groovy /usr/share/jenkins/ref/init.groovy.d/tcp-slave-agent-port.groovy
COPY scripts/jenkins-support.sh /usr/local/bin/jenkins-support
COPY scripts/jenkins.sh /usr/local/bin/jenkins.sh
COPY scripts/tini-shim.sh /bin/tini
COPY scripts/plugins.sh /usr/local/bin/plugins.sh
COPY scripts/install-plugins.sh /usr/local/bin/install-plugins.sh

# Set Permissions On Files
RUN chown -R "${ALPINE_USER}" "${JENKINS_HOME}" /usr/share/jenkins/ref && \
  chmod 0755 /usr/local/bin/jenkins-support /usr/local/bin/jenkins.sh /bin/tini /usr/local/bin/plugins.sh /usr/local/bin/install-plugins.sh

USER ${ALPINE_USER}
EXPOSE ${HTTP_PORT} ${AGENT_PORT}
VOLUME ${JENKINS_HOME}
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/jenkins.sh"]
