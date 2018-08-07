#!/bin/bash 
grep $1 /var/logs/nova/nova-compute.log | grep oslo.messaging._drivers.impl_rabbit
