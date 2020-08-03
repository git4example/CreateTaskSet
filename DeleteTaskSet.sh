#!/bin/bash

# set these values to resources that exist in your account:
cluster_name=default
service_name=TaskSetTesting100

region=ap-southeast-2
account_id=064250592128
task_set_id="ecs-svc/4598187513658215931"


echo "Delete Started.." | ts

#Delete TaskSet
task_set_out="$(aws ecs delete-task-set --cluster $cluster_name --service $service_name  --task-set arn:aws:ecs:$region:$account_id:task-set/$cluster_name/$service_name/$task_set_id)"

echo "task_set_out : " $task_set_out | ts
echo "Delete Finished.." | ts