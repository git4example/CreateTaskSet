

### Types Of Deployment Available in ECS
* Rolling Update
* Blue/Green Deployment using CodeDeploy
* External Deployment

### External Deployment Controller

We are going to talk about External Deployment controller here, Lets see what External Deployment Controller is and what it allows us to do  :

* As name suggest, it allows you to have full control over deployment process to ECS service (*T&C apply : Still ECS scheduler limits and throttling will apply)
* Its completely on you how you want to orchestrate your deployments so you have to control it using APIs to control deployments to ECS Service using APIs (CreateTaskSet, UpdateTaskSet, UpdateServicePrimaryTaskSet, DeleteTaskSet, DeleteTask, DescribeServices and DescribeTaskSets).

    * CreateTaskSet is used to deploy TaskSet(s) in the ECS Service
    * UpdateServicePrimaryTaskSet API action modifies which task set in a service is the primary task set
    * UpdateTaskSet API action updates only the scale % for a task set.
    * UpdateService API action updates the desired count and health check grace period parameters for a service.
    * Use CreateTaskSet API to create new task set, If the launch type, platform version, load balancer details, network configuration, or task definition need to be updated.
    * DeleteTaskSet API action to delete TaskSet
    * Few others which you will be using to create your own scheduler.. DeleteTask, DescribeServices and DescribeTaskSets

* You can have multiple task definitions running under same ECS service using different TaskSets and ECS service will maintain desired count for each TaskSets
* This opens up possibility to create your own Deployment type, Write your own Deployment Scheduler (*T&C apply : piggy back on ECS scheduler)
* ECS Service Auto Scaling is not supported while using External Deployment controller
* Only ALB and NLB are supported
* You can not use DAEMON scheduling strategy
* Currently deploymentConfiguration is having no effect on CreateTaskSet/UpdateTaskSet


T&C :

Meaning when we use External Deployment controller, ECS service scheduler is trying to run all the requested tasks (computedDesiredCount) in one go, which may cause throttling exceptions depending on the desired count of ECS service and scale % you have requested for TaskSet. With these new APIs (CreateTaskSet, UpdateTaskSet, UpdateServicePrimaryTaskSet, DeleteTaskSet...etc) ECS service is allowing external scheduling and controlling of the scheduling behavior, however there are still some elements like ECS scheduler level throttling is under ECS service scheduler logic which may affect your deployment and its speed of deployment. For example, ECS Scheduler only allow 10 TPS (task per second) burst and 1 task per second beyond for normal ECS service, however in case of External Deployment controller, ECS scheduler will try to run all requested tasks in one go and it will remain stuck if requested tasks (computedDesiredCount) are more then 10.


### Deployment time
Based on my testing it looks like amount of time to complete deployment depends on few variable element as below (and may be more). However these are primary ones as I could point out as of now :

1.  ECS scheduler allows 10 task in one go, so need to wait for one batch of 10 task to be scheduled then we can push next batch.
2. There is delay between update API and scheduler calculate computedDesiredCount value. Once computedDesiredCount is calculated, than task scheduler will start rolling out new set of tasks based on new value.
3. Deployment of tasks itself
4. Task Creation and Stabilization period of each individual task itself, which includes container pull, run, network delay ..etc
5. Health checks, if any applicable (not tested)


### Create Task Set

Step 1 : Create ECS service :

```
cluster_name=default
service_name=TaskSetTesting
desired_count=2   #if you are scaling to different number then please update calcuation to accomodate % calucation which should no more then 10 in on go.
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
desired_count=2   #if you are scaling to different number then please update calcuation to accomodate % calucation which should no more then 10 in on go.
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
desired_count=100   #if you are scaling to different number then please update calcuation to accomodate % calucation which should no more then 10 in on go.
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


Step 4 : Now when you create Green TaskSet to deploy new task definition version. Note that we are not passing --scale parameter here, we are just going to create Deployment. We will scale it as needed.

```bash
cluster_name=default
service_name=BlueGreenTaskSetTesting
desired_count=100   #if you are scaling to different number then please update calcuation to accomodate % calucation which should no more then 10 in on go.
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

Step 6 : Now make Green deployment as Primary TaskSet. This will make it the baseline for future tasksets by updating the default values on the service. You should see the task definition change in the top-level Service response:

```bash
aws ecs update-service-primary-task-set --cluster $cluster_name --service $service_name --primary-task-set $task_set_green

aws ecs describe-services --cluster $cluster_name --services $service_name
```

Step 7 : Scale down Blue TaskSet. --force allows you to delete a task set even if it hasn't been scaled down to zero.

```bash
aws ecs delete-task-set --cluster $cluster_name --service $service_name --task-set $task_set_blue --force
```

### How to workaround 10 Task Per Second (10 TPS) ECS service scheduler limit

You can write script similar to [1] "CreateTaskSet.sh" to scale 10 task in one go to successfully complete your TaskSet deployments.

[1] https://github.com/hello2parikshit/CreateTaskSet
