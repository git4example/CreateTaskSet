#!/bin/bash

# set these values to resources that exist in your account:
cluster_name=default
service_name=TaskSetTesting100
desired_count=100   #if you are scaling to different number then please update calculation to accommodate % calculation which should no more then 10 in on go.
maximum_Percent=200
minimum_HealthyPercent=100 
taskdef_family=nginx_fargate
taskdef_family_version=1
launch_type=FARGATE
vpc_id=vpc-2786cc40
vpc_subnets=subnet-0f2f0046,subnet-7c02301b,subnet-a00da0f8
vpc_security_group=sg-11de8369
computedDesiredCount=0
requestedDesiredCount=10 #max allowed by ECS scheduler in one go
pendingCount=0
stabilityStatus=""
steadyStatus="STEADY_STATE"

echo "Deploymnet Started.." | ts
#Create Service 
aws ecs create-service --cluster default --service-name $service_name --desired-count $desired_count --deployment-controller type=EXTERNAL --scheduling-strategy REPLICA --deployment-configuration maximumPercent=$maximum_Percent,minimumHealthyPercent=$minimum_HealthyPercent 

#Create TaskSet
task_set_out="$(aws ecs create-task-set --cluster $cluster_name --service $service_name --external-id blue --task-definition $taskdef_family:$taskdef_family_version --launch-type $launch_type --scale unit=PERCENT,value=$requestedDesiredCount --network-configuration "awsvpcConfiguration={subnets=[$vpc_subnets],securityGroups=[$vpc_security_group],assignPublicIp=ENABLED}")"

#echo "task_set_out : " $task_set_out | ts

#Extract required values
task_set_id="$(echo $task_set_out | jq -r .taskSet.id)" 
echo "TaskSet Created ... task_set_id : " $task_set_id | ts

while [ "$requestedDesiredCount" != "$computedDesiredCount" ]
do
    sleep 1
    task_set_out="$(aws ecs describe-task-sets --service $service_name --cluster default --task-set $task_set_id)"
    
    computedDesiredCount="$(echo $task_set_out | jq .taskSets[0].computedDesiredCount)" 
    echo "Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount:" $computedDesiredCount " = requestedDesiredCount:" $requestedDesiredCount| ts    
done 

#Describe to get Stabilization 
task_set_out="$(aws ecs describe-task-sets --service $service_name --cluster default --task-set $task_set_id)"
#echo "task_set_out : " $task_set_out | ts

stabilityStatus="$(echo $task_set_out | jq -r .taskSets[0].stabilityStatus)" 
#echo "stabilityStatus :" $stabilityStatus | ts

computedDesiredCount="$(echo $task_set_out | jq .taskSets[0].computedDesiredCount)" 
#echo "computedDesiredCount :" $computedDesiredCount | ts

pendingCount="$(echo $task_set_out | jq .taskSets[0].pendingCount)" 
#echo "pendingCount :" $pendingCount | ts

runningCount="$(echo $task_set_out | jq .taskSets[0].runningCount)" 
#echo "runningCount :" $runningCount | ts

echo "stabilityStatus :" $stabilityStatus " computedDesiredCount :" $computedDesiredCount " total :" $total " (pendingCount :" $pendingCount "runningCount :" $runningCount ") - POST-CREATE" | ts

while [ "$stabilityStatus" != "STEADY_STATE"  ]
do
    #To prevent other API throttling wait 1 sec - can use exponential backoff in production 
    sleep 1
    total=`expr $runningCount + $pendingCount` 

    # Update Task Set if previouse batch of 10 is already being executed i.e. (running + pending = computedDesired) and Yet to reach desired count number of service to reach 100%
    if [ "$total" = "$computedDesiredCount" -a "$computedDesiredCount" -lt  "$desired_count" ]; then

        scale=`expr $computedDesiredCount + $requestedDesiredCount` #in here desired count is 100 so just keep adding 10, else calculate % here for scale

        #echo "aws ecs update-task-set --service $service_name --cluster default --task-set $task_set_id --scale value=$scale,unit=PERCENT"
        task_set_out="$(aws ecs update-task-set --service $service_name --cluster default --task-set $task_set_id --scale value=$scale,unit=PERCENT)"
        #echo "task_set_out : " $task_set_out | ts
        
        computedDesiredCount="$(echo $task_set_out | jq .taskSet.computedDesiredCount)" 
        
        while [ "$scale" != "$computedDesiredCount" ]
        do
            sleep 1
            task_set_out="$(aws ecs describe-task-sets --service $service_name --cluster default --task-set $task_set_id)"
            
            computedDesiredCount="$(echo $task_set_out | jq .taskSets[0].computedDesiredCount)" 
            echo "Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount:" $computedDesiredCount " = scale:" $scale| ts     
        done 

        #Extract required values
        stabilityStatus="$(echo $task_set_out | jq -r .taskSets[0].stabilityStatus)" 
        
        computedDesiredCount="$(echo $task_set_out | jq .taskSets[0].computedDesiredCount)" 
        
        pendingCount="$(echo $task_set_out | jq .taskSets[0].pendingCount)" 
        
        runningCount="$(echo $task_set_out | jq .taskSets[0].runningCount)" 
        
        echo "stabilityStatus :" $stabilityStatus " computedDesiredCount :" $computedDesiredCount " total :" $total " (pendingCount :" $pendingCount "runningCount :" $runningCount ") - UPDATE scale: " $scale | ts

    else
        task_set_out="$(aws ecs describe-task-sets --service $service_name --cluster default --task-set $task_set_id)"
        #echo "task_set_out : " $task_set_out | ts


        #Extract required values
        stabilityStatus="$(echo $task_set_out | jq -r .taskSets[0].stabilityStatus)" 
        
        computedDesiredCount="$(echo $task_set_out | jq .taskSets[0].computedDesiredCount)" 
        
        pendingCount="$(echo $task_set_out | jq .taskSets[0].pendingCount)" 
        
        runningCount="$(echo $task_set_out | jq .taskSets[0].runningCount)" 
        
        echo "stabilityStatus :" $stabilityStatus " computedDesiredCount :" $computedDesiredCount " total :" $total " (pendingCount :" $pendingCount "runningCount :" $runningCount ") - DESCRIBE" | ts
    fi
done

echo "Deploymnet Finished.." | ts

