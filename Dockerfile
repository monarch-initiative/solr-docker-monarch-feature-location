FROM maven:3.6.0-jdk-8-slim
# use bash
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

VOLUME /solr

# Install git and wget
RUN apt-get -y update && apt-get install -y git wget

# Define working directory.
WORKDIR /data
ADD files/functions.inc /data/
ADD files/logback.xml /data/
ADD files/run.sh /data/
ADD files/feature-location-config.yaml /data/

RUN git clone https://github.com/SciGraph/SciGraph.git /data/scigraph
RUN git clone https://github.com/SciGraph/golr-loader.git /data/golr-loader
RUN git clone https://github.com/monarch-initiative/monarch-cypher-queries.git /data/monarch-cypher-queries
RUN git clone https://github.com/berkeleybop/golr-schema /data/golr-schema

RUN cd /data/scigraph && mvn install -DskipTests -DskipITs
RUN cd /data/golr-loader && mvn install -Dmaven.test.skip
RUN cd /data/monarch-cypher-queries && mvn install
RUN cd /data/golr-schema && mvn install

RUN wget http://archive.apache.org/dist/lucene/solr/6.2.1/solr-6.2.1.tgz -P /data/
RUN cd /data && tar xzfv /data/solr-6.2.1.tgz

RUN cd /data && source /data/functions.inc && getGraphConfiguration /data/graph https://archive.monarchinitiative.org/201911/translationtable/curie_map.yaml > graph.yaml

CMD /data/run.sh
