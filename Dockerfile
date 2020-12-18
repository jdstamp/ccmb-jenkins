FROM jenkins/jenkins:lts

ARG BUILD_DATE
ARG VCS_REF

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt

LABEL org.jdstamp.ccmb-jenkins.build-date=$BUILD_DATE
LABEL org.jdstamp.ccmb-jenkins.vcs-ref=$VCS_REF
