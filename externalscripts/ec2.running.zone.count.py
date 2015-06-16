#!/usr/bin/env python

# Example: ec2.count.py us-west-1c


from boto.ec2.connection import EC2Connection
import boto.ec2
import sys

count=0
conn = boto.ec2.connect_to_region(str(sys.argv[1][:-1]))

for r in conn.get_all_instances():
    for i in r.instances:
          if "running" in i.state:
                if str(sys.argv[1]) in i.placement:
                   count=count+1

print  count
