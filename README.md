# CreateTaskSet

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