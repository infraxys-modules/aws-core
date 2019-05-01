# Infraxys module - aws-core

## Introduction

This module contains some helper functions and packets for base AWS functionality.

## Packets

### AWS Region

Simple packet only defining variable 'aws_region'.
 
#### Usage
 
Put this packet as the root of an instance tree in which children need the AWS region that they live in.
 
### AWS tags

Specify one or more tags for AWS resources.

#### Usage

AWS resource packets that are configured the apply tags, can use a shared instance of this packet. 
This ensures that all taggable resources have the same tags.

## Bash functions

### EC2 

- get_instance_json_by_name
- get_instance_private_ip
- get_ami
- get_security_group_id

### VPC

- get_vpc
- get_vpc_id
- get_subnet_id

### Route53

- get_zone_id_by_name