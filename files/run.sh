#!/bin/bash

set -e

/data/solr-6.2.1/bin/solr start
/data/solr-6.2.1/bin/solr create -c feature-location 
/data/solr-6.2.1/bin/solr stop
rm /data/solr-6.2.1/server/solr/feature-location/conf/managed-schema 
cd /data/golr-schema && mvn exec:java -Dexec.mainClass="org.bbop.cli.Main" -Dexec.args="-c /data/monarch-app/conf/golr-views/feature-location-config.yaml -o /data/solr-6.2.1/server/solr/feature-location/conf/schema.xml"
wget -O /data/scigraph.tgz http://scigraph-data-dev.monarchinitiative.org/static_files/scigraph.tgz 
cd /data/ && tar xzfv scigraph.tgz
mkdir -p /data/json
/data/solr-6.2.1/bin/solr start
cd /data/golr-loader && java -Xmx50G -Dlog4j.configuration=file:/data/log4j.properties -jar target/golr-loader-0.0.1-SNAPSHOT-jar-with-dependencies.jar -g /data/graph.yaml -q /data/monarch-cypher-queries/src/main/cypher/feature-location -o /data/json/ -s http://localhost:8983/solr/feature-location
/data/solr-6.2.1/bin/solr stop
cd /data/solr-6.2.1/server/solr && tar czfv feature-location.tgz feature-location/
cp /data/solr-6.2.1/server/solr/feature-location.tgz /solr