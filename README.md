# CreateTaskSet

### Types Of Deployment Available in ECS
* Rolling Update
* Blue/Green Deployment using CodeDeploy
* External Deployment

### External Deployment Controller

We are going to talk about External Deployment controller here, Lets see what External Deployment Controller is and what it allows us to do  :

* As name suggest, it allows you to have full control over deployment process to ECS service (*T&C, check towards the end of this article)
* Its completely on you how you want to orchestrate your deployments so you have to control it using APIs to control deployments to ECS Service using APIs (`CreateTaskSet, UpdateTaskSet, UpdateServicePrimaryTaskSet, DeleteTaskSet, DeleteTask, DescribeServices and DescribeTaskSets`).

    * `CreateTaskSet` is used to deploy TaskSet(s) in the ECS Service
    * `UpdateServicePrimaryTaskSet` API action modifies which task set in a service is the primary task set
    * `UpdateTaskSet` API action updates only the scale % for a task set.
    * `UpdateService` API action updates the desired count and health check grace period parameters for a service.
    * Use `CreateTaskSet` API to create new task set, If the launch type, platform version, load balancer details, network configuration, or task definition need to be updated.
    * `DeleteTaskSet` API action to delete TaskSet
    * Few others which you will be using to create your own scheduler.. `DeleteTask, DescribeServices and DescribeTaskSets`

* You can have multiple task definitions running under same ECS service using different TaskSets and ECS service will maintain desired count for each TaskSets
* This opens up possibility to create your own Deployment type, Write your own Deployment Scheduler (*T&C)
* ECS Service Auto Scaling is not supported while using External Deployment controller
* Only ALB and NLB are supported
* You can not use `DAEMON` scheduling strategy
* Currently deploymentConfiguration is having no effect on CreateTaskSet/UpdateTaskSet



### Create Task Set

Step 1 : Create ECS service :

```
cluster_name=default
service_name=TaskSetTesting
desired_count=2   
maximum_Percent=200
minimum_HealthyPercent=100
launch_type=FARGATE
vpc_id=vpc-2786cc40
vpc_subnets=subnet-0f2f0046,subnet-7c02301b,subnet-a00da0f8
vpc_security_group=sg-11de8369

taskdef_family=nginx
taskdef_family_version=1
```

```bash
aws ecs create-service --cluster default --service-name $service_name --desired-count $desired_count --deployment-controller type=EXTERNAL --scheduling-strategy REPLICA --deployment-configuration maximumPercent=$maximum_Percent,minimumHealthyPercent=$minimum_HealthyPercent
```

Step 2 : Now when you create task set, ECS service scheduler will start creating new task equal to scale % requested, % is calculated against --desired-count of ECS service

```bash
aws ecs create-task-set --cluster $cluster_name --service $service_name --task-definition $taskdef_family:$taskdef_family_version --launch-type $launch_type --scale unit=PERCENT,value=$desired_count --network-configuration "awsvpcConfiguration={subnets=[$vpc_subnets],securityGroups=[$vpc_security_group],assignPublicIp=ENABLED}")
```


### Deploy mixed Tasks in single ECS service
Now lets check what if I create yet another task set :

Step 3 : Note, I am using different task definition and created new task set, ECS service desired count is 2, however you will see 4 tasks running under this ECS service, 2 each for each TaskSet.

```bash
cluster_name=default
service_name=TaskSetTesting
desired_count=2   
maximum_Percent=200
minimum_HealthyPercent=100
launch_type=FARGATE
vpc_id=vpc-2786cc40
vpc_subnets=subnet-0f2f0046,subnet-7c02301b,subnet-a00da0f8
vpc_security_group=sg-11de8369

taskdef_family=httpd
taskdef_family_version=3

aws ecs create-task-set --cluster $cluster_name --service $service_name --task-definition $taskdef_family:$taskdef_family_version --launch-type $launch_type --scale unit=PERCENT,value=$desired_count --network-configuration "awsvpcConfiguration={subnets=[$vpc_subnets],securityGroups=[$vpc_security_group],assignPublicIp=ENABLED}")
```


### Blue/Green Deployment using EXTERNAL Deployment controller


Step 1 : Create ECS service :

```bash
cluster_name=default
service_name=BlueGreenTaskSetTesting
desired_count=100   
maximum_Percent=200
minimum_HealthyPercent=100
launch_type=FARGATE
vpc_id=vpc-2786cc40
vpc_subnets=subnet-0f2f0046,subnet-7c02301b,subnet-a00da0f8
vpc_security_group=sg-11de8369

taskdef_family=nginx
taskdef_family_version=1


aws ecs create-service --cluster default --service-name $service_name --desired-count $desired_count --deployment-controller type=EXTERNAL --scheduling-strategy REPLICA --deployment-configuration maximumPercent=$maximum_Percent,minimumHealthyPercent=$minimum_HealthyPercent
```

Step 2 : Now when you create Blue TaskSet

```bash
aws ecs create-task-set --cluster $cluster_name --service $service_name --external-id blue --task-definition $taskdef_family:$taskdef_family_version --launch-type $launch_type --scale unit=PERCENT,value=$requestedDesiredCount --network-configuration "awsvpcConfiguration={subnets=[$vpc_subnets],securityGroups=[$vpc_security_group],assignPublicIp=ENABLED}")


```

Wait for this TaskSet to reach "STEADY_STATE".

```bash
aws ecs describe-task-sets --service $service_name --cluster default --task-set $task_set_blue
```


Step 3 : Now lets make it the ```PRIMARY``` Task Set :

```bash
aws ecs update-service-primary-task-set --cluster $cluster_name --service $service_name --primary-task-set $task_set_blue

aws ecs describe-services --cluster $cluster_name --services $service_name
```


Step 4 : Now when you create Green TaskSet to deploy new task definition version. Note that we are not passing `--scale` parameter here, we are just going to create Deployment. We will scale it as needed.

```bash
cluster_name=default
service_name=BlueGreenTaskSetTesting
desired_count=100   
maximum_Percent=200
minimum_HealthyPercent=100
launch_type=FARGATE
vpc_id=vpc-2786cc40
vpc_subnets=subnet-0f2f0046,subnet-7c02301b,subnet-a00da0f8
vpc_security_group=sg-11de8369

taskdef_family=nginx
taskdef_family_version=2

aws ecs create-task-set --cluster $cluster_name --service $service_name --external-id green --task-definition $taskdef_family:$taskdef_family_version --launch-type $launch_type  --network-configuration "awsvpcConfiguration={subnets=[$vpc_subnets],securityGroups=[$vpc_security_group],assignPublicIp=ENABLED}"

```

Here you should see ```STEADY_STATE``` immediately as there nothing to scale (0%)

```
aws ecs describe-services --cluster $cluster_name --services $service_name
```

Step 5 : Now Scale Green Deployment to 100%
```bash
aws ecs update-task-set --cluster $cluster_name --service $service_name --scale unit=PERCENT,value=100 --task-set $task_set_green)
```

Wait for this TaskSet to reach "STEADY_STATE".

```bash
aws ecs describe-task-sets --service $service_name --cluster default --task-set $task_set_green
```

Step 6 : Now make Green deployment as Primary TaskSet. This will make it the baseline for future TaskSet by updating the default values on the service. You should see the task definition change in the top-level Service response:

```bash
aws ecs update-service-primary-task-set --cluster $cluster_name --service $service_name --primary-task-set $task_set_green

aws ecs describe-services --cluster $cluster_name --services $service_name
```

Step 7 : Scale down Blue TaskSet. --force allows you to delete a task set even if it hasn't been scaled down to zero.

```bash
aws ecs delete-task-set --cluster $cluster_name --service $service_name --task-set $task_set_blue --force
```


### T&C :
External Deployment controller piggy back on ECS scheduler, Meaning when we use External Deployment controller, ECS service scheduler is trying to run all the requested tasks (computedDesiredCount) in one go, which may cause throttling exceptions depending on the desired count of ECS service and scale % you have requested for TaskSet. With these new APIs (CreateTaskSet, UpdateTaskSet, UpdateServicePrimaryTaskSet, DeleteTaskSet...etc) ECS service is allowing external scheduling and controlling of the scheduling behavior, however there are still some elements like ECS scheduler level throttling is under ECS service scheduler logic which may affect your deployment and its speed of deployment. For example, ECS Scheduler only allow 10 TPS (task per second) burst and 1 task per second beyond for normal ECS service, however in case of External Deployment controller, ECS scheduler will try to run all requested tasks in one go and it will remain stuck if requested tasks (computedDesiredCount) are more then 10.


### Deployment time
Based on my testing it looks like amount of time to complete deployment depends on few variable element as below (and may be more). However these are primary ones as I could point out as of now :

1.  ECS scheduler allows 10 task in one go, so need to wait for one batch of 10 task to be scheduled then we can push next batch.
2. There is delay between update API and scheduler calculate computedDesiredCount value. Once computedDesiredCount is calculated, than task scheduler will start rolling out new set of tasks based on new value.
3. Deployment of tasks itself
4. Task Creation and Stabilization period of each individual task itself, which includes container pull, run, network delay ..etc
5. Health checks, if any applicable 

### Throttling Exception 

If you see following throttling exception, its mostly because you are trying to deploy more then 10 TPS (computedDesiredCount > 10), ECS service scheduler will try to deploy all at once in case of External Deployment and it will remain in this status forever until you take action to fix your deployment. 

```
(service <servicename>) operations are being throttled. Will try again later.
```

### Account Limits 

If we reach Fargate task account limits then ECS Service Events reports different error message which is not inline with Fargate deployment :

```
service <servicename> was unable to place a task because no container instance met all of its requirements. Reason: You've reached the limit on the number of tasks you can run concurrently. For more information, see the Troubleshooting section.
```

Regular Fargate task limit message looks like like this :

```
service <servicename> was unable to place a task. Reason: You've reached the limit on the number of tasks you can run concurrently. For more information, see the Troubleshooting section.
```

### How to workaround 10 Task Per Second (10 TPS) ECS service scheduler limit

You can write script similar to "CreateTaskSet.sh" to scale 10 task in one go to successfully complete your TaskSet deployments.


# How to use this script 

Use CreateTaskSet.sh script to update your environment details in top section of the script

Currently scaling/deploying number of task beyond 10 task per CreateTaskSet is throttled,  this script is POC to quickly deploy more number of tasks in quickest possible way.

Sample output of test run : 

```log
Jul 30 20:34:13 Deploymnet Started..
{
    "service": {
        "serviceArn": "arn:aws:ecs:ap-southeast-2:064250592128:service/default/TaskSetTesting100",
        "serviceName": "TaskSetTesting100",
        "clusterArn": "arn:aws:ecs:ap-southeast-2:064250592128:cluster/default",
        "loadBalancers": [],
        "serviceRegistries": [],
        "status": "ACTIVE",
        "desiredCount": 100,
        "runningCount": 0,
        "pendingCount": 0,
        "launchType": "EC2",
        "deploymentConfiguration": {
            "maximumPercent": 200,
            "minimumHealthyPercent": 100
        },
        "taskSets": [],
        "deployments": [],
        "roleArn": "arn:aws:iam::064250592128:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS",
        "events": [],
        "createdAt": "2020-07-30T20:34:14.494000+10:00",
        "placementConstraints": [],
        "placementStrategy": [],
        "schedulingStrategy": "REPLICA",
        "deploymentController": {
            "type": "EXTERNAL"
        },
        "createdBy": "arn:aws:iam::064250592128:user/admin",
        "enableECSManagedTags": false,
        "propagateTags": "NONE"
    }
}
Jul 30 20:34:15 TaskSet Created ... task_set_id :  ecs-svc/8340555382392028389
Jul 30 20:34:17 Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount: 0  = requestedDesiredCount: 10
Jul 30 20:34:19 Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount: 0  = requestedDesiredCount: 10
Jul 30 20:34:21 Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount: 10  = requestedDesiredCount: 10
Jul 30 20:34:22 stabilityStatus : STABILIZING  computedDesiredCount : 10  total :  (pendingCount : 0 runningCount : 0 ) - POST-CREATE
Jul 30 20:34:24 stabilityStatus : STABILIZING  computedDesiredCount : 10  total : 0  (pendingCount : 10 runningCount : 0 ) - DESCRIBE
Jul 30 20:34:28 Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount: 10  = scale: 20
Jul 30 20:34:30 Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount: 10  = scale: 20
Jul 30 20:34:32 Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount: 20  = scale: 20
Jul 30 20:34:32 stabilityStatus : STABILIZING  computedDesiredCount : 20  total : 10  (pendingCount : 10 runningCount : 0 ) - UPDATE scale:  20
Jul 30 20:34:35 stabilityStatus : STABILIZING  computedDesiredCount : 20  total : 10  (pendingCount : 20 runningCount : 0 ) - DESCRIBE
Jul 30 20:34:38 Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount: 20  = scale: 30
Jul 30 20:34:40 Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount: 20  = scale: 30
Jul 30 20:34:42 Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount: 30  = scale: 30
Jul 30 20:34:42 stabilityStatus : STABILIZING  computedDesiredCount : 30  total : 20  (pendingCount : 20 runningCount : 0 ) - UPDATE scale:  30
Jul 30 20:34:45 stabilityStatus : STABILIZING  computedDesiredCount : 30  total : 20  (pendingCount : 30 runningCount : 0 ) - DESCRIBE
Jul 30 20:34:48 Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount: 30  = scale: 40
Jul 30 20:34:50 Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount: 30  = scale: 40
Jul 30 20:34:52 Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount: 30  = scale: 40
Jul 30 20:34:54 Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount: 40  = scale: 40
Jul 30 20:34:54 stabilityStatus : STABILIZING  computedDesiredCount : 40  total : 30  (pendingCount : 25 runningCount : 5 ) - UPDATE scale:  40
Jul 30 20:34:56 stabilityStatus : STABILIZING  computedDesiredCount : 40  total : 30  (pendingCount : 30 runningCount : 10 ) - DESCRIBE
Jul 30 20:35:00 Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount: 40  = scale: 50
Jul 30 20:35:02 Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount: 40  = scale: 50
Jul 30 20:35:04 Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount: 50  = scale: 50
Jul 30 20:35:04 stabilityStatus : STABILIZING  computedDesiredCount : 50  total : 40  (pendingCount : 21 runningCount : 19 ) - UPDATE scale:  50
Jul 30 20:35:07 stabilityStatus : STABILIZING  computedDesiredCount : 50  total : 40  (pendingCount : 31 runningCount : 19 ) - DESCRIBE
Jul 30 20:35:10 Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount: 50  = scale: 60
Jul 30 20:35:12 Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount: 50  = scale: 60
Jul 30 20:35:14 Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount: 50  = scale: 60
Jul 30 20:35:16 Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount: 60  = scale: 60
Jul 30 20:35:16 stabilityStatus : STABILIZING  computedDesiredCount : 60  total : 50  (pendingCount : 23 runningCount : 27 ) - UPDATE scale:  60
Jul 30 20:35:19 stabilityStatus : STABILIZING  computedDesiredCount : 60  total : 50  (pendingCount : 30 runningCount : 30 ) - DESCRIBE
Jul 30 20:35:22 Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount: 60  = scale: 70
Jul 30 20:35:24 Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount: 60  = scale: 70
Jul 30 20:35:26 Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount: 60  = scale: 70
Jul 30 20:35:28 Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount: 60  = scale: 70
Jul 30 20:35:30 Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount: 70  = scale: 70
Jul 30 20:35:30 stabilityStatus : STABILIZING  computedDesiredCount : 70  total : 60  (pendingCount : 20 runningCount : 40 ) - UPDATE scale:  70
Jul 30 20:35:32 stabilityStatus : STABILIZING  computedDesiredCount : 70  total : 60  (pendingCount : 28 runningCount : 42 ) - DESCRIBE
Jul 30 20:35:36 Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount: 70  = scale: 80
Jul 30 20:35:38 Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount: 70  = scale: 80
Jul 30 20:35:40 Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount: 70  = scale: 80
Jul 30 20:35:42 Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount: 70  = scale: 80
Jul 30 20:35:44 Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount: 80  = scale: 80
Jul 30 20:35:44 stabilityStatus : STABILIZING  computedDesiredCount : 80  total : 70  (pendingCount : 17 runningCount : 53 ) - UPDATE scale:  80
Jul 30 20:35:47 stabilityStatus : STABILIZING  computedDesiredCount : 80  total : 70  (pendingCount : 24 runningCount : 56 ) - DESCRIBE
Jul 30 20:35:51 Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount: 80  = scale: 90
Jul 30 20:35:52 Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount: 80  = scale: 90
Jul 30 20:35:54 Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount: 90  = scale: 90
Jul 30 20:35:55 stabilityStatus : STABILIZING  computedDesiredCount : 90  total : 80  (pendingCount : 20 runningCount : 60 ) - UPDATE scale:  90
Jul 30 20:35:57 stabilityStatus : STABILIZING  computedDesiredCount : 90  total : 80  (pendingCount : 27 runningCount : 63 ) - DESCRIBE
Jul 30 20:36:01 Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount: 90  = scale: 100
Jul 30 20:36:03 Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount: 90  = scale: 100
Jul 30 20:36:04 Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount: 90  = scale: 100
Jul 30 20:36:06 Waiting 1 sec for computedDesiredCount to catch up .. computedDesiredCount: 100  = scale: 100
Jul 30 20:36:07 stabilityStatus : STABILIZING  computedDesiredCount : 100  total : 90  (pendingCount : 20 runningCount : 70 ) - UPDATE scale:  100
Jul 30 20:36:09 stabilityStatus : STABILIZING  computedDesiredCount : 100  total : 90  (pendingCount : 19 runningCount : 71 ) - DESCRIBE
Jul 30 20:36:11 stabilityStatus : STABILIZING  computedDesiredCount : 100  total : 90  (pendingCount : 17 runningCount : 73 ) - DESCRIBE
Jul 30 20:36:13 stabilityStatus : STABILIZING  computedDesiredCount : 100  total : 90  (pendingCount : 15 runningCount : 75 ) - DESCRIBE
Jul 30 20:36:16 stabilityStatus : STABILIZING  computedDesiredCount : 100  total : 90  (pendingCount : 13 runningCount : 77 ) - DESCRIBE
Jul 30 20:36:18 stabilityStatus : STABILIZING  computedDesiredCount : 100  total : 90  (pendingCount : 12 runningCount : 78 ) - DESCRIBE
Jul 30 20:36:20 stabilityStatus : STABILIZING  computedDesiredCount : 100  total : 90  (pendingCount : 10 runningCount : 80 ) - DESCRIBE
Jul 30 20:36:22 stabilityStatus : STABILIZING  computedDesiredCount : 100  total : 90  (pendingCount : 5 runningCount : 85 ) - DESCRIBE
Jul 30 20:36:24 stabilityStatus : STABILIZING  computedDesiredCount : 100  total : 90  (pendingCount : 3 runningCount : 87 ) - DESCRIBE
Jul 30 20:36:27 stabilityStatus : STABILIZING  computedDesiredCount : 100  total : 90  (pendingCount : 2 runningCount : 88 ) - DESCRIBE
Jul 30 20:36:29 stabilityStatus : STABILIZING  computedDesiredCount : 100  total : 90  (pendingCount : 1 runningCount : 89 ) - DESCRIBE
Jul 30 20:36:31 stabilityStatus : STABILIZING  computedDesiredCount : 100  total : 90  (pendingCount : 0 runningCount : 90 ) - DESCRIBE
Jul 30 20:36:33 stabilityStatus : STABILIZING  computedDesiredCount : 100  total : 90  (pendingCount : 0 runningCount : 90 ) - DESCRIBE
Jul 30 20:36:35 stabilityStatus : STABILIZING  computedDesiredCount : 100  total : 90  (pendingCount : 0 runningCount : 90 ) - DESCRIBE
Jul 30 20:36:38 stabilityStatus : STABILIZING  computedDesiredCount : 100  total : 90  (pendingCount : 0 runningCount : 90 ) - DESCRIBE
Jul 30 20:36:40 stabilityStatus : STABILIZING  computedDesiredCount : 100  total : 90  (pendingCount : 10 runningCount : 90 ) - DESCRIBE
Jul 30 20:36:42 stabilityStatus : STABILIZING  computedDesiredCount : 100  total : 100  (pendingCount : 10 runningCount : 90 ) - DESCRIBE
Jul 30 20:36:44 stabilityStatus : STABILIZING  computedDesiredCount : 100  total : 100  (pendingCount : 10 runningCount : 90 ) - DESCRIBE
Jul 30 20:36:46 stabilityStatus : STABILIZING  computedDesiredCount : 100  total : 100  (pendingCount : 10 runningCount : 90 ) - DESCRIBE
Jul 30 20:36:48 stabilityStatus : STABILIZING  computedDesiredCount : 100  total : 100  (pendingCount : 10 runningCount : 90 ) - DESCRIBE
Jul 30 20:36:50 stabilityStatus : STABILIZING  computedDesiredCount : 100  total : 100  (pendingCount : 10 runningCount : 90 ) - DESCRIBE
Jul 30 20:36:53 stabilityStatus : STABILIZING  computedDesiredCount : 100  total : 100  (pendingCount : 10 runningCount : 90 ) - DESCRIBE
Jul 30 20:36:55 stabilityStatus : STABILIZING  computedDesiredCount : 100  total : 100  (pendingCount : 10 runningCount : 90 ) - DESCRIBE
Jul 30 20:36:57 stabilityStatus : STABILIZING  computedDesiredCount : 100  total : 100  (pendingCount : 10 runningCount : 90 ) - DESCRIBE
Jul 30 20:36:59 stabilityStatus : STABILIZING  computedDesiredCount : 100  total : 100  (pendingCount : 10 runningCount : 90 ) - DESCRIBE
Jul 30 20:37:01 stabilityStatus : STABILIZING  computedDesiredCount : 100  total : 100  (pendingCount : 10 runningCount : 90 ) - DESCRIBE
Jul 30 20:37:03 stabilityStatus : STABILIZING  computedDesiredCount : 100  total : 100  (pendingCount : 8 runningCount : 92 ) - DESCRIBE
Jul 30 20:37:05 stabilityStatus : STABILIZING  computedDesiredCount : 100  total : 100  (pendingCount : 7 runningCount : 93 ) - DESCRIBE
Jul 30 20:37:07 stabilityStatus : STABILIZING  computedDesiredCount : 100  total : 100  (pendingCount : 4 runningCount : 96 ) - DESCRIBE
Jul 30 20:37:10 stabilityStatus : STABILIZING  computedDesiredCount : 100  total : 100  (pendingCount : 0 runningCount : 100 ) - DESCRIBE
Jul 30 20:37:12 stabilityStatus : STEADY_STATE  computedDesiredCount : 100  total : 100  (pendingCount : 0 runningCount : 100 ) - DESCRIBE
Jul 30 20:37:12 Deploymnet Finished..
```

# How to use CreateTaskSet : 

```
aws ecs create-service --cluster default --service-name TaskSetTesting --deployment-controller type=EXTERNAL --scheduling-strategy REPLICA --desired-count 2 
```
```json
{
    "service": {
        "serviceArn": "arn:aws:ecs:ap-southeast-2:064250592128:service/default/TaskSetTesting",
        "serviceName": "TaskSetTesting",
        "clusterArn": "arn:aws:ecs:ap-southeast-2:064250592128:cluster/default",
        "loadBalancers": [],
        "serviceRegistries": [],
        "status": "ACTIVE",
        "desiredCount": 2,
        "runningCount": 0,
        "pendingCount": 0,
        "launchType": "EC2",
        "deploymentConfiguration": {
            "maximumPercent": 200,
            "minimumHealthyPercent": 100
        },
        "taskSets": [],
        "deployments": [],
        "roleArn": "arn:aws:iam::064250592128:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS",
        "events": [],
        "createdAt": "2020-07-28T14:28:01.209000+10:00",
        "placementConstraints": [],
        "placementStrategy": [],
        "schedulingStrategy": "REPLICA",
        "deploymentController": {
            "type": "EXTERNAL"
        },
        "createdBy": "arn:aws:iam::064250592128:user/admin",
        "enableECSManagedTags": false,
        "propagateTags": "NONE"
    }
}
```

```bash
aws ecs create-task-set --service TaskSetTesting --cluster default --task-definition Fargate:1 --launch-type FARGATE --scale value=100,unit=PERCENT --network-configuration "awsvpcConfiguration={subnets=[subnet-0f2f0046,subnet-7c02301b,subnet-a00da0f8],securityGroups=[sg-11de8369],assignPublicIp=ENABLED}"
```

```json
{
    "taskSet": {
        "id": "ecs-svc/3979528455399974988",
        "taskSetArn": "arn:aws:ecs:ap-southeast-2:064250592128:task-set/default/TaskSetTesting/ecs-svc/3979528455399974988",
        "serviceArn": "arn:aws:ecs:ap-southeast-2:064250592128:service/TaskSetTesting",
        "clusterArn": "arn:aws:ecs:ap-southeast-2:064250592128:cluster/default",
        "status": "ACTIVE",
        "taskDefinition": "arn:aws:ecs:ap-southeast-2:064250592128:task-definition/Fargate:1",
        "computedDesiredCount": 0,
        "pendingCount": 0,
        "runningCount": 0,
        "createdAt": "2020-07-28T14:50:43.189000+10:00",
        "updatedAt": "2020-07-28T14:50:43.189000+10:00",


        "platformVersion": "1.3.0",
        "networkConfiguration": {
            "awsvpcConfiguration": {
                "subnets": [
                    "subnet-0f2f0046",
                    "subnet-7c02301b",
                    "subnet-a00da0f8"
                ],
                "securityGroups": [
                    "sg-11de8369"
                ],
                "assignPublicIp": "ENABLED"
            }
        },
        "loadBalancers": [],
        "serviceRegistries": [],
        "scale": {
            "value": 100.0,
            "unit": "PERCENT"
        },
        "stabilityStatus": "STABILIZING",
        "stabilityStatusAt": "2020-07-28T14:50:43.189000+10:00",
        "tags": []
    }
}
```

```bash
aws ecs create-task-set --service TaskSetTesting --cluster default --task-definition Fargate:3 --launch-type FARGATE --scale value=100,unit=PERCENT --network-configuration "awsvpcConfiguration={subnets=[subnet-0f2f0046,subnet-7c02301b,subnet-a00da0f8],securityGroups=[sg-11de8369],assignPublicIp=ENABLED}"
```

```json
{
    "taskSet": {
        "id": "ecs-svc/2784411390646843134",
        "taskSetArn": "arn:aws:ecs:ap-southeast-2:064250592128:task-set/default/TaskSetTesting/ecs-svc/2784411390646843134",
        "serviceArn": "arn:aws:ecs:ap-southeast-2:064250592128:service/TaskSetTesting",
        "clusterArn": "arn:aws:ecs:ap-southeast-2:064250592128:cluster/default",
        "status": "ACTIVE",
        "taskDefinition": "arn:aws:ecs:ap-southeast-2:064250592128:task-definition/Fargate:3",
        "computedDesiredCount": 0,
        "pendingCount": 0,
        "runningCount": 0,
        "createdAt": "2020-07-28T14:52:56.415000+10:00",
        "updatedAt": "2020-07-28T14:52:56.415000+10:00",
        "launchType": "FARGATE",
        "platformVersion": "1.3.0",
        "networkConfiguration": {
            "awsvpcConfiguration": {
                "subnets": [
                    "subnet-0f2f0046",
                    "subnet-7c02301b",
                    "subnet-a00da0f8"
                ],
                "securityGroups": [
                    "sg-11de8369"
                ],
                "assignPublicIp": "ENABLED"
            }
        },
        "loadBalancers": [],
        "serviceRegistries": [],
        "scale": {
            "value": 100.0,
            "unit": "PERCENT"
        },
        "stabilityStatus": "STABILIZING",
        "stabilityStatusAt": "2020-07-28T14:52:56.415000+10:00",
        "tags": []
    }
}
```