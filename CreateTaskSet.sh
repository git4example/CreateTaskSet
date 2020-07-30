#!/bin/bash

# Ref : https://w.amazon.com/bin/view/EC2/Project_Madison/Bug_Bash/PublicTaskSets/
# set these values to resources that exist in your account:
cluster_name=default
service_name=TaskSetTesting10
desired_count=100
taskdef_family=Fargate
launch_type=FARGATE
vpc_id=vpc-2786cc40
vpc_subnets=subnet-0f2f0046,subnet-7c02301b,subnet-a00da0f8
vpc_security_group=sg-11de8369
scale_initial=10
scale_increment=10
scale_wait_sec=10 
computedDesiredCount=0
requestedDesiredCount=10
pendingCount=0
stabilityStatus=""
steadyStatus="STEADY_STATE"

echo "Deploymnet Started.." | ts
#Create Service 
aws ecs create-service --cluster default --service-name $service_name --desired-count $desired_count --deployment-controller type=EXTERNAL --scheduling-strategy REPLICA 

#Create TaskSet
task_set_out="$(aws ecs create-task-set --cluster $cluster_name --service $service_name --external-id blue --task-definition $taskdef_family:1 --launch-type $launch_type --scale unit=PERCENT,value=$requestedDesiredCount --network-configuration "awsvpcConfiguration={subnets=[$vpc_subnets],securityGroups=[$vpc_security_group],assignPublicIp=ENABLED}")"

#echo "task_set_out : " $task_set_out | ts

#Extract required values
task_set_id="$(echo $task_set_out | jq -r .taskSet.id)" 
echo "task_set_id : " $task_set_id | ts

while [ "$requestedDesiredCount" != "$computedDesiredCount" ]
do
    echo "wait 1 sec for request = compute count" | ts
    sleep 1

    task_set_out="$(aws ecs describe-task-sets --service $service_name --cluster default --task-set $task_set_id)"
    
    computedDesiredCount="$(echo $task_set_out | jq .taskSets[0].computedDesiredCount)" 
    echo "computedDesiredCount :" $computedDesiredCount | ts    
done 

#Describe to get Stabilization 
task_set_out="$(aws ecs describe-task-sets --service $service_name --cluster default --task-set $task_set_id)"
#echo "task_set_out : " $task_set_out | ts

stabilityStatus="$(echo $task_set_out | jq .taskSets[0].stabilityStatus)" 
#echo "stabilityStatus :" $stabilityStatus | ts

computedDesiredCount="$(echo $task_set_out | jq .taskSets[0].computedDesiredCount)" 
#echo "computedDesiredCount :" $computedDesiredCount | ts

pendingCount="$(echo $task_set_out | jq .taskSets[0].pendingCount)" 
#echo "pendingCount :" $pendingCount | ts

runningCount="$(echo $task_set_out | jq .taskSets[0].runningCount)" 
#echo "runningCount :" $runningCount | ts

echo "stabilityStatus :" $stabilityStatus " computedDesiredCount :" $computedDesiredCount " pendingCount :" $pendingCount "runningCount :" $runningCount " - POST-CREATE" | ts

while [ "$stabilityStatus" != "STEADY_STATE"  ]
do
    echo "wait 1 sec " | ts
    sleep 1
    
    total=`expr $runningCount + $pendingCount` 

    echo "total : " $(($runningCount + $pendingCount))

    # Update Task Set if previouse batch of 10 is already being executed i.e. (running + pending = computedDesired) and Yet to reach desired count number of service to reach 100%
    if [ "$total" = "$computedDesiredCount" -a "$computedDesiredCount" -lt  "$desired_count" ]; then

        scale=`expr $computedDesiredCount + 10` #in here desired count is 100 so just keep adding 10, else calculate % here for scale

        #echo "aws ecs update-task-set --service $service_name --cluster default --task-set $task_set_id --scale value=$scale,unit=PERCENT"
        task_set_out="$(aws ecs update-task-set --service $service_name --cluster default --task-set $task_set_id --scale value=$scale,unit=PERCENT)"
        #echo "task_set_out : " $task_set_out | ts

        #Extract required values
        stabilityStatus="$(echo $task_set_out | jq .taskSet.stabilityStatus)" 
        #echo "stabilityStatus :" $stabilityStatus | ts

        computedDesiredCount="$(echo $task_set_out | jq .taskSet.computedDesiredCount)" 
        #echo "computedDesiredCount :" $computedDesiredCount | ts

        pendingCount="$(echo $task_set_out | jq .taskSet.pendingCount)" 
        #echo "pendingCount :" $pendingCount | ts

        runningCount="$(echo $task_set_out | jq .taskSet.runningCount)" 
        #echo "runningCount :" $runningCount | ts

        echo "stabilityStatus :" $stabilityStatus " computedDesiredCount :" $computedDesiredCount " pendingCount :" $pendingCount "runningCount :" $runningCount " - UPDATE"| ts

    else
        task_set_out="$(aws ecs describe-task-sets --service $service_name --cluster default --task-set $task_set_id)"
        #echo "task_set_out : " $task_set_out | ts


        #Extract required values
        stabilityStatus="$(echo $task_set_out | jq .taskSets[0].stabilityStatus)" 
        #echo "stabilityStatus :" $stabilityStatus | ts

        computedDesiredCount="$(echo $task_set_out | jq .taskSets[0].computedDesiredCount)" 
        #echo "computedDesiredCount :" $computedDesiredCount | ts

        pendingCount="$(echo $task_set_out | jq .taskSets[0].pendingCount)" 
        #echo "pendingCount :" $pendingCount | ts

        runningCount="$(echo $task_set_out | jq .taskSets[0].runningCount)" 
        #echo "runningCount :" $runningCount | ts
        echo "stabilityStatus :" $stabilityStatus " computedDesiredCount :" $computedDesiredCount " pendingCount :" $pendingCount "runningCount :" $runningCount " - DESCRIBE" | ts
    fi
done

echo "Deploymnet Finished.." | ts


#aws ecs create-task-set --service TaskSetTesting100 --cluster default --task-definition Fargate:1 --launch-type FARGATE --scale value=10,unit=PERCENT --network-configuration "awsvpcConfiguration={subnets=[subnet-0f2f0046,subnet-7c02301b,subnet-a00da0f8],securityGroups=[sg-11de8369],assignPublicIp=ENABLED}"

#Keep updating scale value in the increament of 10 after about a min wait.


# You can use Describe call to check stabilityStatus, computedDesiredCount, pendingCount and runningCount to make next Update call.
#aws ecs describe-task-sets --service TaskSetTesting100 --cluster default --task-set $task_set_id

#Wait for it to enter STEADY_STATE. This indicates that all tasks that should be running are running: