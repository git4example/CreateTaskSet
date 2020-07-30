# CreateTaskSet

How to use CreateTaskSet : 

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