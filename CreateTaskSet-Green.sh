#!/bin/bash

# Use this scrip for your new deployments - It will be always considered Green in regards to this script
# DON`T Miss to update TaskDefinition and task_set_blue value for new deployment and current PRIMARY deployment id before running this script


# set these values to resources that exist in your account:
cluster_name=default
service_name=BlueGreenTaskSetTesting

launch_type=FARGATE
vpc_id=vpc-2786cc40
vpc_subnets=subnet-0f2f0046,subnet-7c02301b,subnet-a00da0f8
vpc_security_group=sg-11de8369

requestedDesiredCount=100

taskdef_family=nginx_fargate
taskdef_family_version=2
task_set_blue="ecs-svc/4826018505467357700"

echo "Deployment Started.." | ts

#Create TaskSet without Scale 

task_set_out="$(aws ecs create-task-set --cluster $cluster_name --service $service_name --external-id green --task-definition $taskdef_family:$taskdef_family_version --launch-type $launch_type --network-configuration "awsvpcConfiguration={subnets=[$vpc_subnets],securityGroups=[$vpc_security_group],assignPublicIp=ENABLED}")"

task_set_green="$(echo $task_set_out | jq -r .taskSet.id)" 
echo "TaskSet green Created ... task_set_green : " $task_set_green | ts

#Wait for it to reach "STEADY_STATE"
while [ "$stabilityStatus" != "STEADY_STATE"  ]
do
    #To prevent other API throttling wait 1 sec - can use exponential backoff in production 
    sleep 1
        
    task_set_out="$(aws ecs describe-task-sets --service $service_name --cluster default --task-set $task_set_green)"

    stabilityStatus="$(echo $task_set_out | jq -r .taskSets[0].stabilityStatus)" 
    echo "stabilityStatus :" $stabilityStatus | ts
done


#Now Scale it to 100%
echo "Scaling to 100%"
task_set_out="$(aws ecs update-task-set --cluster $cluster_name --service $service_name --scale unit=PERCENT,value=100 --task-set $task_set_green)"

task_set_green="$(echo $task_set_out | jq -r .taskSet.id)" 
echo "TaskSet Green scaled ... task_set_green : " $task_set_green | ts

task_set_out="$(aws ecs describe-task-sets --service $service_name --cluster default --task-set $task_set_green)"

stabilityStatus="$(echo $task_set_out | jq -r .taskSets[0].stabilityStatus)" 
echo "stabilityStatus :" $stabilityStatus | ts

#Wait for greent to reach "STEADY_STATE"
echo "Wait for green to reach STEADY_STATE"

while [ "$stabilityStatus" != "STEADY_STATE"  ]
do
    #To prevent other API throttling wait 1 sec - can use exponential backoff in production 
    sleep 1
        
    task_set_out="$(aws ecs describe-task-sets --service $service_name --cluster default --task-set $task_set_green)"

    stabilityStatus="$(echo $task_set_out | jq -r .taskSets[0].stabilityStatus)" 
    echo "stabilityStatus :" $stabilityStatus | ts
done


#Make green TaskSet Primary
echo "Make green TaskSet Primary"
aws ecs update-service-primary-task-set --cluster $cluster_name --service $service_name --primary-task-set $task_set_green
aws ecs describe-services --cluster $cluster_name --services $service_name

task_set_out="$(aws ecs describe-task-sets --service $service_name --cluster default --task-set $task_set_green)"

stabilityStatus="$(echo $task_set_out | jq -r .taskSets[0].stabilityStatus)" 
echo "stabilityStatus :" $stabilityStatus | ts

echo "Wait for green to reach STEADY_STATE"
while [ "$stabilityStatus" != "STEADY_STATE"  ]
do
    #To prevent other API throttling wait 1 sec - can use exponential backoff in production 
    sleep 1
        
    task_set_out="$(aws ecs describe-task-sets --service $service_name --cluster default --task-set $task_set_green)"

    stabilityStatus="$(echo $task_set_out | jq -r .taskSets[0].stabilityStatus)" 
    echo "stabilityStatus :" $stabilityStatus | ts
done

#Scale down Blue TaskSet.

echo "Scale down Blue TaskSet."
aws ecs delete-task-set --cluster $cluster_name --service $service_name --task-set $task_set_blue --force



echo "Deployment Finished.." | ts

echo "Now you can roll out Green TaskSet..."

