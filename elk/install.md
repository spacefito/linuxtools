Instlling Elasticsearch
=======================
  
    zypper ar  http://download.opensuse.org/repositories/Cloud:/OpenStack:/Master/openSUSE_Leap_42.3/ OBS:Cloud:Openstack:Master
    zypper refresh
    zypper install elasticsearch
  
    systemctl start elasticsearch
    systemctl status elasticsearch
    curl -X GET "localhost:9200/_cat/health?v"
    curl -X GET "localhost:9200/_cat/nodes?v"
    curl -X GET "localhost:9200/_cat/indices?v"


