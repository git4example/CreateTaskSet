#!/bin/bash

# set these values to resources that exist in your account:
cluster_name=default
service_name=BlueGreenTaskSetTesting
desired_count=2   #if you are scaling to different number then please update calculation to accommodate % calculation which should no more then 10 in on go.
maximum_Percent=200
minimum_HealthyPercent=100 
launch_type=FARGATE
vpc_id=vpc-2786cc40
vpc_subnets=subnet-0f2f0046,subnet-7c02301b,subnet-a00da0f8
vpc_security_group=sg-11de8369

taskdef_family=nginx
taskdef_family_version=1

# Create Service for External Deployment 
aws ecs create-service --cluster default --service-name $service_name --desired-count $desired_count --deployment-controller type=EXTERNAL --scheduling-strategy REPLICA --deployment-configuration maximumPercent=$maximum_Percent,minimumHealthyPercent=$minimum_HealthyPercent 