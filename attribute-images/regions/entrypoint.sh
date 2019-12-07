#!/usr/bin/env sh

curl -s https://raw.githubusercontent.com/infraxys-modules/infraxys-by-example/data/master/attribute-images/regions/ec2_regions.json | jq -r '.Regions[] | .RegionName';

