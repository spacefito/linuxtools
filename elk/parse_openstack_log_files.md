Prerequisites:
==============
```
ELK:/etc/logstash/conf.d # zypper lr
Repository priorities are without effect. All enabled repositories share the same priority.

#  | Alias                     | Name                                    | Enabled | GPG Check | Refresh
---+---------------------------+-----------------------------------------+---------+-----------+--------
 1 | openSUSE-Leap-42.3-0      | openSUSE-Leap-42.3-0                    | No      | ----      | ----
 2 | packman.inode.at-suse     | Packman Repository                      | Yes     | (r ) Yes  | No
 3 | repo-debug                | openSUSE-Leap-42.3-Debug                | No      | ----      | ----
 4 | repo-debug-non-oss        | openSUSE-Leap-42.3-Debug-Non-Oss        | No      | ----      | ----
 5 | repo-debug-update         | openSUSE-Leap-42.3-Update-Debug         | No      | ----      | ----
 6 | repo-debug-update-non-oss | openSUSE-Leap-42.3-Update-Debug-Non-Oss | No      | ----      | ----
 7 | repo-non-oss              | openSUSE-Leap-42.3-Non-Oss              | Yes     | (r ) Yes  | No
 8 | repo-oss                  | openSUSE-Leap-42.3-Oss                  | Yes     | (r ) Yes  | No
 9 | repo-source               | openSUSE-Leap-42.3-Source               | No      | ----      | ----
10 | repo-source-non-oss       | openSUSE-Leap-42.3-Source-Non-Oss       | No      | ----      | ----
11 | repo-update               | openSUSE-Leap-42.3-Update               | Yes     | (r ) Yes  | No
12 | repo-update-non-oss       | openSUSE-Leap-42.3-Update-Non-Oss       | Yes     | (r ) Yes  | No
```

```
zypper install java-1_8_0-openjdk
```

Installing Logstash
===================

```

sudo wget https://artifacts.elastic.co/downloads/logstash/logstash-6.3.0.rpm
sudo zypper install ./logstash-6.3.0.rpm
sudo /usr/share/logstash/bin/logstash-plugin install logstash-filter-multiline
```

add _beats_pipeline.conf_ under /etc/logstash/conf.d :

```
# sudo cat /etc/logstash/conf.d/beats_pipeline.conf
input {
    beats {
        port => "5044"
    }
}

filter {
    grok {
      match => { "message" => "(?m)^%{TIMESTAMP_ISO8601:logdate}%{SPACE}%{NUMBER:pid}?%{SPACE}?(?<loglevel>AUDIT|CRITICAL|DEBUG|INFO|TRACE|WARNING|ERROR) \[?\b%{NOTSPACE:module}\b\]?%{SPACE}?%{GREEDYDATA:logmessage}?" }
    }

    date {
      match => [ "logdate", "ISO8601"]
    }
}

output {
  elasticsearch{ hosts => ['localhost:9200']
                 index => "%{[@metadata][beat]}-%{[@metadata][version]}-%{+YYYY.MM.dd}"
  }
}
```

Installing Elasticsearch
========================
```
sudo wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.3.0.rpm
sudo zypper install ./elasticsearch-6.3.0.rpm
sudo systemctl daemon-reload
sudo systemctl start elasticsearch
curl -X GET "localhost:9200/_cat/health?v"
curl -X GET "localhost:9200/_cat/nodes?v"
curl -X GET "localhost:9200/_cat/indices?v"
```

Installing Kibana
=================
```
sudo wget https://artifacts.elastic.co/downloads/kibana/kibana-6.3.0-x86_64.rpm
sudo zypper install ./kibana-6.3.0-x86_64.rpm
```    

Installing Filebeats
====================
```
sudo wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-6.3.0-x86_64.rpm
sudo zypper install ./filebeat-6.3.0-x86_64.rpm
```

Add the following to end of /etc/filebeat/filebeat.yml
``` 
#==========================processors===============================
processors:
- drop_fields:
    fields: ["host"]
```
Createa Filebeats config file: 

*Note that _/home/username/_  is _~\/_, but it is best to spell out in the yml file
```
#cat ~/logs/input/filebeat.yml
filebeat.prospectors:
- type: log
  paths:
    - /home/username/logs/input/*/*.log
  multiline:
    match: after
    negate: true
    pattern: '^${patterns.timestamp} ${patterns.pid} ${patterns.level} ${patterns.component} \['

output.logstash:
  hosts: ['localhost:5044']

patterns:
  timestamp: '(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}.\d{3})'
  pid: '(\d+)'
  level: '(ERROR|CRITICAL|INFO|DEBUG|WARNING|TRACE)' # or use '\w+' if unsure about all levels
  component: '([^\s]+)'
```


Collect logs
=============
Collect logs under ~/logs/input/\*/\*.log
```
sudo systemctl start elasticsearch
sudo leapone:/home/username/logs/input # systemctl start kibana
sudo systemctl start logstash
    
# cp all the *.log files you want to process to /home/username/logs/input/*/*.log
# The following resets Filebeats to read all of the files, otherwise it only reads new information, not whole file
sudo rm /var/lib/filebeat/registry
    
#run filebeats. Press Ctrl-C when it is done processing all files
sudo /usr/bin/filebeat -e -c /home/username/logs/input/filebeat.yml -d "*"
```
