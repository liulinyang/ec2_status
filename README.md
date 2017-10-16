### Overview

This script will scan the running instances list in all 9 regions and check for those  not following rules. The instace would be marked in red if it matchs one of below criteria
 * it doesn't have 'owner' tag.
 * it doesn't have 'keep' tag and 'running days' > 5 days, unless it's owner is 'stg', which means it's in QA STG Environment.
 
```
[root@kevin ec2_status]# python  ec2_status.py -h
usage: ec2_status.py [-h] account

positional arguments:
  account     AWS account qa or dev

optional arguments:
  -h, --help  show this help message and exit
```

### Configuration 
before running this script, please setup boto3 configuration correctly. For instance, you could setup __~/.aws/credentials__ as below.


```
[default]
aws_access_key_id = xxx
aws_secret_access_key = xxx

[qa]
aws_access_key_id = xxxx
aws_secret_access_key = xxx

[dev]
aws_access_key_id = xxxx
aws_secret_access_key = xxx
```




