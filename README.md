# amq-demo

## about This repository hosts the resources needed to make a simple demonstration about AMQ Streams.

Prerequisites:
Have at least one openshift cluster setted up. 

In order to see the full potential of mirror maker 2, another target cluster can be useful. 



## How to start

1. Login as cluster administrator and Install the Kafka Operator -> Red Hat Integration - AMQ Streams (Remember to select Maual Approval for updates)

2. Create a project ***oc new-project amq-demo-prj-1*** 

3. Create a kafka cluster ***oc apply -f 1-kafka-installation.yaml***

4. Create the config map that stores some useful properties ***oc apply -f 2-create-config-map.yaml*** (optional, non really sure if this is really usefull)

5. Create a kafka topic ***oc apply -f 3-kafka-topic.yaml***

6. Deploy KafDrop oc app ***oc apply -f 4-kafdrop-deploy.yaml***.This command will deploy the DC and a service

7. Expose the KafDrop route ***oc expose service kafdrop-service***. Kafdrop is a simple client to see the topics and their content

8. Create a simple job to send message to our topic ***oc apply -f 6-job.yaml***


## Mirror Maker 2
In this scenario we will install another kafka cluster in another project so we will replay all the steps from 1 to 7 changing the project name to ***amq-demo-prj-2*** 

8. Obtain the source cluster certificate on the source cluster ***oc extract secret/my-cluster-cluster-ca-cert --keys=ca.crt --to=- > ca.crt***

9. Import the certificate as a secret creating a secret via openshif console in ***amq-demo-prj-2*** (or use ) the file ***7-mm2-source-secret.yaml*** (but is to be confirmed)

10. create the mm2 configuration using internal service ***oc apply -f 8-mm2-definition-internal-cluster.yaml*** or the external one ***8-mm2-definition-external-cluster.yaml***. Be awaare that you may need to join the projects network if you work in a multitenant cluster.

After this step you can see with kafdrop in amq-demo-prj-2 that a new topic has been created (my-source-my-topic) and this topic contains all the messages as the source one. 



If we have a running kafka cluster in another openshift cluster we have to follow this guide https://developers.redhat.com/blog/2019/06/10/accessing-apache-kafka-in-strimzi-part-3-red-hat-openshift-routes#exposing_kafka_using_openshift_routes

to join networks oc adm pod-network join-projects --to=<project1> <project2> <project3>

Reference to mm2 on ocp https://access.redhat.com/documentation/en-us/red_hat_amq/2020.q4/html-single/using_amq_streams_on_openshift/index#assembly-mirrormaker-str


## Quarkus-getting-started

It'a simple java project to test kafka interaction. 


To build and deploy on openshift you have to run this command:
./mvnw clean package -Dquarkus.kubernetes.deploy=true -Dmaven.test.skip=true

You also need to install the following extensions: 
 ./mvnw quarkus:add-extension -Dextensions="resteasy-jsonb,openshift"

 To post an order you simply need to execute: 

 curl --request POST \
  --url http://quarkus-getting-started-amq-demo-prj-1.apps.cluster-mfv6c.mfv6c.sandbox1168.opentlc.com/order \
  --header 'Content-Type: application/json' \
  --cookie ac4e8ed0d64330286f822894901bc7b5=d4ee36f5e99297994da7e3c5c905ad43 \
  --data '{"id":2008, "description":"The Dark Knight","quantity":1}'



Connections

oc annotate dc quarkus-store-project 'app.openshift.io/connects-to'='[{"apiVersion":"apps.openshift.io/v1","kind":"DeploymentConfig","name":"orders"}]' --overwrite

oc annotate dc quarkus-store-project 'app.openshift.io/connects-to'='[{"apiVersion":"apps.openshift.io/v1","kind":"StatefulSet","name":"my-cluster-kafka"}]' --overwrite

Define an application to group nodes
oc label dc orders 'app.kubernetes.io/part-of'='store'

Connections

oc annotate dc quarkus-store-project 'app.openshift.io/connects-to'='[{"apiVersion":"apps.openshift.io/v1","kind":"DeploymentConfig","name":"orders"}]' --overwrite

oc annotate dc quarkus-orders-project 'app.openshift.io/connects-to'='[{"apiVersion":"apps.openshift.io/v1","kind":"StatefulSet","name":"my-cluster-kafka"}]' --overwrite

Define an application to group nodes
oc label dc orders 'app.kubernetes.io/part-of'='orders' (this is the postres database so this command depends on the name you give at the deployment)
oc label dc quarkus-store-project 'app.kubernetes.io/part-of'='orders'
