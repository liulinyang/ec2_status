import sys
import boto3
import os
import jinja2
from datetime import datetime
from jinja2 import Template
from jinja2 import Environment, PackageLoader
from pyjavaproperties import Properties
import argparse

def generate_property_file():
	p = Properties()
	p['DATE'] = datetime.now().strftime("%Y-%m-%d")
	p.store(open('k.properties','w'))

def getKey(item):
	return item['owner']

def get_tag_value(tags, name):
	for t in tags:
		if t['Key'].lower() == name.lower():
			return t['Value']
	return 'n/a'


def get_rds_tags(client, instance_id, region):
	ARN_RDS_SCHEMA = "arn:aws:rds:%s:240343058503:db:%s"
	rsp = client.list_tags_for_resource(
			ResourceName= ARN_RDS_SCHEMA % (region, instance_id)
			)

	return rsp['TagList']


def get_es_tags(client, arn):
	rsp = client.list_tags(ARN=arn)
	return rsp['TagList']


def get_es_domain_config(client, es_domain_name):
	rsp = client.describe_elasticsearch_domain_config(
			DomainName=es_domain_name
			)

	return rsp['DomainConfig']


def get_es_list(region, account='qa'):
	print "checking region: %s for ES" % region
	session = boto3.Session(profile_name=account.lower())
	client = session.client('es', region_name=region)

	#response = client.describe_elasticsearch_domains() 
	response = client.list_domain_names()

	date_str = datetime.now().strftime("%Y-%m-%d")
	report_fh = open("report_es_%s.txt"%(region), 'w')
	report_fh.write("%-43s%-15s%-50s%-20s%-20s%-20s%-20s\n" % ('Domain-ID', 'Type', 'version', 'Storage', 'Running-days', 'Status', 'Region'))
	report_fh.write("="*145)
	report_fh.write("\n")

	result=[]
	for d in response['DomainNames']:
		instance_name = d["DomainName"]

		domain = client.describe_elasticsearch_domain(DomainName=instance_name) 
		i = domain['DomainStatus']
		instance_id = i["DomainId"]
		instance_type = i["ElasticsearchClusterConfig"]["InstanceType"]
		instance_count = i["ElasticsearchClusterConfig"]["InstanceCount"]
		master_instance_type = i["ElasticsearchClusterConfig"].get("DedicatedMasterType", '-')
		master_instance_count = i["ElasticsearchClusterConfig"].get("DedicatedMasterCount", '-')
		engine_version= i["ElasticsearchVersion"]
		arn= i["ARN"]
		storage = i["EBSOptions"]["VolumeSize"]

		domain_config = get_es_domain_config(client, instance_name)
		launch_time = domain_config['AdvancedOptions']['Status']['CreationDate']
		state = domain_config['AdvancedOptions']['Status']['State']
		elapse_time = datetime.now() - launch_time.replace(tzinfo=None)

		tags = get_es_tags(client, arn)
		owner = get_tag_value(tags, 'owner')
		name= get_tag_value(tags, 'name')
		keep = get_tag_value(tags, 'keep')
		role = get_tag_value(tags, 'role')

		flag = ''
		if owner == 'n/a': 
			flag = 'X'
		elif int(elapse_time.days)>5 and keep == 'n/a' and owner.lower() != 'stg':
			flag = 'X'
		else:
			flag = ''
		report_fh.write("%-3s%-40s%-15s%-50s%-20s%-20s%-20s%-20s%s\n" % (flag, instance_id, instance_type, engine_version, storage, elapse_time.days, state, instance_count, region))
		result.append( {
				'instance_id': instance_id,
				'state': state,
				'launch_time': launch_time,
				'instance_type': instance_type,
				'instance_count': instance_count,
				'master_instance_type': master_instance_type,
				'master_instance_count': master_instance_count,
				'name': instance_id,
				'owner': owner,
				'role': role,
				'running': elapse_time.days,
				'flag': flag,
				'region': region,
				'storage': storage,
				'keep':keep
				})
	
	report_fh.close()
	return result
	


def get_rds_list(region, account='qa'):
	print "checking region: %s" % region
	session = boto3.Session(profile_name=account.lower())
	client = session.client('rds', region_name=region)

	response = client.describe_db_instances(
			MaxRecords=100,
			Marker='====show-me-status===='
		)

	date_str = datetime.now().strftime("%Y-%m-%d")
	report_fh = open("report_rds_%s.txt"%(region), 'w')
	report_fh.write("%-43s%-15s%-50s%-20s%-20s%-20s%-20s\n" % ('Instance-ID', 'Type', 'version', 'Storage', 'Running-days', 'Status', 'Region'))
	report_fh.write("="*145)
	report_fh.write("\n")

	result=[]
	for i in response['DBInstances']:
		instance_id = i["DBInstanceIdentifier"]
		instance_type = i["DBInstanceClass"]
		instance_name = i["DBInstanceIdentifier"]
		storage = i["AllocatedStorage"]
		launch_time = i['InstanceCreateTime']
		engine_version= i["EngineVersion"]
		state = i["DBInstanceStatus"]
		elapse_time = datetime.now() - launch_time.replace(tzinfo=None)


		tags = get_rds_tags(client, instance_id, region)
		owner = get_tag_value(tags, 'owner')
		name= get_tag_value(tags, 'name')
		keep = get_tag_value(tags, 'keep')
		role = get_tag_value(tags, 'role')

		flag = ''
		if owner == 'n/a': 
			flag = 'X'
		elif int(elapse_time.days)>5 and keep == 'n/a' and owner.lower() != 'stg':
			flag = 'X'
		else:
			flag = ''
		report_fh.write("%-3s%-40s%-15s%-50s%-20s%-20s%-20s%s\n" % (flag, instance_id, instance_type, engine_version, storage, elapse_time.days, state, region))
		result.append( {
				'instance_id': instance_id,
				'state': state,
				'launch_time': launch_time,
				'instance_type': instance_type,
				'name': instance_id,
				'owner': owner,
				'role': role,
				'running': elapse_time.days,
				'flag': flag,
				'region': region,
				'storage': storage,
				'keep':keep,
				'engine_version':engine_version
				})
	
	report_fh.close()
	return result
	

# region name: us-east-1 or us-west-2
def get_ec2_list(region, account='qa'):
	print "checking region: %s" % region
	session = boto3.Session(profile_name=account.lower())
	client = session.client('ec2', region_name=region)
	
	response = client.describe_instances(
			DryRun=False, 
			Filters=[
					{
					'Name':'instance-state-name',
					'Values': ['running']
					}
				],
			)
	date_str = datetime.now().strftime("%Y-%m-%d")
	report_fh = open("report_%s.txt"%(region), 'w')
	report_fh.write("%-23s%-15s%-50s%-20s%-20s%-20s\n" % ('Instance-ID', 'Type', 'Name', 'Role', 'Owner', 'Region'))
	report_fh.write("="*145)
	report_fh.write("\n")
	
	#print "%-20s%-15s%-50s%-20s%-20s" % (i['InstanceId'], instance_type, name, role, owner)
	
	result = []
	for r in response['Reservations']:
		for i in r['Instances']:
			instance_id = i['InstanceId']
			state = i['State']
			launch_time = i['LaunchTime']
		 	instance_type = i['InstanceType']
	
			tags = i['Tags']
			name = get_tag_value(tags, 'name')
			owner = get_tag_value(tags, 'owner')
			role = get_tag_value(tags, 'role')
			keep = get_tag_value(tags, 'keep')
			elapse_time = datetime.now() - launch_time.replace(tzinfo=None)
			flag = ''
			if owner == 'n/a': 
				flag = 'X'
			elif int(elapse_time.days)>5 and keep == 'n/a' and owner.lower() != 'stg':
				flag = 'X'
			else:
				flag = ''

			report_fh.write("%-3s%-20s%-15s%-50s%-20s%-20s%-20s\n" % (flag, i['InstanceId'], instance_type, name, role, owner, region))
			result.append( {
				'instance_id': instance_id,
				'state': state,
				'launch_time': launch_time,
				'instance_type': instance_type,
				'name': name,
				'owner': owner,
				'role': role,
				'running': elapse_time.days,
				'flag': flag,
				'region': region,
				'keep':keep 
				})
	
			#print "%-20s%-15s%-50s%-20s%-20s" % (i['InstanceId'], instance_type, name, role, owner)
	
	report_fh.close()
	return result

	#print result
	#sys.exit(1)

def generate_html_report(ec2_result, rds_result, es_result, account):
	env = Environment(loader=jinja2.FileSystemLoader('/root/ec2_status'))
	template = env.get_template('instances.tpl')
	td_class = {'even': "tg-b7b8", 'odd':"tg-yw41", 'warning':"tg-9w9z"}
	
	with open("report.html",'w') as f:
		f.write(template.render(
			ec2_instances=[(idx, i) for idx, i in enumerate(sorted(ec2_result, key=getKey))], 
			rds_instances=[(idx, i) for idx, i in enumerate(sorted(rds_result, key=getKey))],
			es_instances=[(idx, i) for idx, i in enumerate(sorted(es_result, key=getKey))],
			td_class=td_class, 
			account=account.upper())
			)


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("account", help="AWS account qa or dev")
	args = parser.parse_args()
	account = args.account
	print "account: ===%s===" % account
	
	if not account.lower() in ('qa', 'dev'):
		print "Error: account %s is not supported." % account
		sys.exit(-1)

	region_list = [
			"us-east-1",
			"us-west-1",
			"us-west-2",
			"ap-south-1",
			"ap-northeast-1",
			"ap-northeast-2",
			"ap-southeast-1",
			"ap-southeast-2",
			"eu-central-1",
			"eu-west-1",
			"sa-east-1"
		]

	#region_list = [
	#		"us-west-2"
	#	]

	ec2_instance_list = []
	for region in region_list:
		ec2_instance_list.extend(get_ec2_list(region, account))
	
	rds_instance_list = []
	for region in region_list:
		rds_instance_list.extend(get_rds_list(region, account))

	es_instance_list = []
	for region in region_list:
		es_instance_list.extend(get_es_list(region, account))

	generate_html_report(ec2_instance_list, rds_instance_list, es_instance_list, account)
	generate_property_file()
	
	sys.exit(0)

if __name__ == "__main__":
	#get_rds_list("us-west-2")
	#get_es_list("us-west-2")
	main()



