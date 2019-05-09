#!/bin/bash
# Update The Software Version From Online

# Get The Versions Of The Software
SITE_VERSION=$(curl -s http://mirrors.jenkins.io/war-stable/ | grep -Eo "[0-9]{1,2}\.[0-9]{1,4}\.[0-9]{1,4}" | tail -n1)
LOCAL_VERSION=$(grep "finalImageVersion" config.yml | cut -d: -f 2 | sed 's/^ //g')

# Check Versions And Update File
if [ "$SITE_VERSION" != "$LOCAL_VERSION" ]
then
  sed -i "s/^finalImageVersion:.*/finalImageVersion:\ ${SITE_VERSION}/" config.yml
  SHA=$(curl -s "http://mirrors.jenkins.io/war-stable/${SITE_VERSION}/jenkins.war.sha256" | awk '{print $1}')
  sed -i "s/^jenkinsSha256:.*/jenkinsSha256:\ ${SHA}/" config.yml
  echo " Version Updated."
else
  echo " No Version Change."
fi
