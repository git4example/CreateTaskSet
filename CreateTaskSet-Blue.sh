#!/bin/bash

# set these values to resources that exist in your account:
cluster_name=default
service_name=BlueGreenTaskSetTesting

launch_type=FARGATE
vpc_id=vpc-2786cc40
vpc_subnets=subnet-0f2f0046,subnet-7c02301b,subnet-a00da0f8
vpc_security_group=sg-11de8369

requestedDesiredCount=100

taskdef_family=nginx_fargate
taskdef_family_version=1
echo "Deployment Started.." | ts

#Create TaskSet

task_set_out="$(aws ecs create-task-set --cluster $cluster_name --service $service_name --external-id blue --task-definition $taskdef_family:$taskdef_family_version --launch-type $launch_type --scale unit=PERCENT,value=$requestedDesiredCount --network-configuration "awsvpcConfiguration={subnets=[$vpc_subnets],securityGroups=[$vpc_security_group],assignPublicIp=ENABLED}")"

task_set_blue="$(echo $task_set_out | jq -r .taskSet.id)" 
echo "TaskSet Blue Created ... task_set_blue : " $task_set_blue | ts

#Make blue TaskSet Primary
echo "Make blue TaskSet Primary"
aws ecs update-service-primary-task-set --cluster $cluster_name --service $service_name --primary-task-set $task_set_blue
aws ecs describe-services --cluster $cluster_name --services $service_name

#Wait for blue to reach STEADY_STATE
echo "Wait for blue to reach STEADY_STATE"
task_set_out="$(aws ecs describe-task-sets --service $service_name --cluster default --task-set $task_set_blue)"

stabilityStatus="$(echo $task_set_out | jq -r .taskSets[0].stabilityStatus)" 
echo "stabilityStatus :" $stabilityStatus | ts


while [ "$stabilityStatus" != "STEADY_STATE"  ]
do
    #To prevent other API throttling wait 1 sec - can use exponential backoff in production 
    sleep 1
        
    task_set_out="$(aws ecs describe-task-sets --service $service_name --cluster default --task-set $task_set_blue)"

    stabilityStatus="$(echo $task_set_out | jq -r .taskSets[0].stabilityStatus)" 
    echo "stabilityStatus :" $stabilityStatus | ts
done

echo "Deployment Finished.." | ts

echo "Now you can roll out Green TaskSet..."

