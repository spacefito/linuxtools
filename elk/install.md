Installing Logstash
===================

        wget https://artifacts.elastic.co/downloads/logstash/logstash-6.3.0.rpm
        zypper install ./logstash-6.3.0.rpm
        /usr/share/logstash/bin/logstash-plugin install logstash-filter-multiline

add _beats_pipeline.conf_ under /etc/logstash/conf.d :

        # cat beats_pipeline.conf
    
        input {
            beats {
             port => "5044"
            }
        }

        filter {
            grok {
                match => { "message" => "(?m)^%{TIMESTAMP_ISO8601:logdate}%{SPACE}%{NUMBER:pid}?%{SPACE}?(?<loglevel>AUDIT|CRITICAL|DEBUG|INFO|TRACE|WARNING|ERROR) \[?\b%{NOTSPACE:module}\b\]?%{SPACE}?%{GREEDYDATA:logmessage}?" }
            }
        }

        output {
            elasticsearch{ hosts => ['localhost:9200']
                     index => "%{[@metadata][beat]}-%{[@metadata][version]}-%{+YYYY.MM.dd}"
            }
        }


Installing Elasticsearch
========================

    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.3.0.rpm
    zypper install ./elasticsearch-6.3.0.rpm
    systemctl daemon-reload
    systemctl start elasticsearch
    curl -X GET "localhost:9200/_cat/health?v"
    curl -X GET "localhost:9200/_cat/nodes?v"
    curl -X GET "localhost:9200/_cat/indices?v"


Installing Kibana
=================

    wget https://artifacts.elastic.co/downloads/kibana/kibana-6.3.0-x86_64.rpm
    zypper install ./kibana-6.3.0-x86_64.rpm
    

Installing Filebeats
====================
    wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-6.3.0-x86_64.rpm
    zypper install ./filebeat-6.3.0-x86_64.rpm

Add the following to end of /etc/filebeat/filebeat.yml

    #==========================processors===============================
    processors:
    - drop_fields:
        fields: ["host"]

Filebeats config file example: 

    #cat filebeat.yml
    filebeat.prospectors:
    - type: log
      paths:
        - /home/adolfo/logs/input/*/*.log
    output.logstash:
        hosts: ['localhost:5044']

