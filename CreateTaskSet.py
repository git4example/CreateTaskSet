#!/usr/bin/env python

##work in progress code 

import sys
import boto3
from pprint import pprint
import datetime
import argparse

'''

def get_all_tasks_on_container_instance(instance, cluster):
	""" This function will retun all the tasks from the container instance """
	client = boto3.client('ecs')
	allTasks = client.list_tasks(cluster=cluster, containerInstance=instance)['taskArns']
	return allTasks

def drain_and_deregister_container_instance(instance, cluster):
	""" This function will do the following steps:
		1. Get all the tasks from the container instance.
		2. Set the container instance state to "DRAINING" state.
		3. Stop all the tasks on the container instance.
		4. Deregister the container instance from the appropiate cluster """
	client = boto3.client('ecs')
	mytasks = get_all_tasks_on_container_instance(instance, cluster)
	print(" The {0}  - container instance is running {1} tasks".format(instance, len(mytasks)))
	print("Set {0} - containerInstance's state to DRAINING, so new tasks won't place to this instance".format(instance))
	updateInstanceState = client.update_container_instances_state(cluster=cluster, containerInstances=[instance], status="DRAINING")
	taskCount = len(mytasks)
	for task in mytasks:
		print("Stopping the task {0}".format(task))
		stop_task = client.stop_task(cluster=cluster, task=task, reason="Stopping the task as part of deregistering the containerInstance")
	get_tasks_count = len(get_all_tasks_on_container_instance(instance, cluster))
	if get_tasks_count == 0:
		deregisterInstance = client.deregister_container_instance(cluster=cluster, containerInstance=instance)
		return True
		#print("Deregistered the containerInstance {0}".format(instance))
'''

def main():
	""" Main Function """
	parser = argparse.ArgumentParser()
	parser.add_argument("-c", "--cluster", help="Pass the cluster name", type=str, required=True)
	parser.add_argument("-s", "--Service-Name", help="Pass the Service Name", type=str, required=True)
	parser.add_argument("-d", "--Desired-Count", help="Pass the Desired Count", type=str, required=True)
    
    parser.add_argument("-l", "--launch-type", help="Pass the launch type : EC2/FARGATE", type=str, required=True)
    parser.add_argument("-p", "--percent", help="Pass the scale %", type=str, required=True)
	parser.add_argument("-n", "--scale", help="Pass the scale %", type=str, required=True)

    
	args = parser.parse_args()
'''
	result = drain_and_deregister_container_instance(args.containerInstance, args.cluster)
	if result:
		print("Deregistered the containerInstance {0}".format(args.containerInstance))
		sys.exit(0)
	else:
		sys.exit(1)
'''

if __name__ == '__main__':
	main()