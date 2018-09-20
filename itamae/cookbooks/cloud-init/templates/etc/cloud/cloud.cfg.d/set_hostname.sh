#! /bin/bash -x

INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
NAME=$(AWS_DEFAULT_REGION=<%= node[:aws][:region] %> aws ec2 describe-tags | jq -r ".Tags[] | select(.ResourceId == \"${INSTANCE_ID}\" and .Key == \"Name\").Value")

hostname ${NAME}
