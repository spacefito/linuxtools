#!/bin/bash 
grep $1 /var/log/nova/nova-compute.log | grep -v oslo.messaging._drivers.impl_rabbit
