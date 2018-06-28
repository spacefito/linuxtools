Installing Logstash
===================
    wget https://artifacts.elastic.co/downloads/logstash/logstash-6.3.0.rpm
    zypper install ./logstash-6.3.0.rpm
    /usr/share/logstash/bin/logstash-plugin install logstash-filter-multiline


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
    


