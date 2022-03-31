#about Steps to install monitorig for kafka on openshift

Follow this guide https://access.redhat.com/documentation/en-us/red_hat_amq/2020.q4/html-single/deploying_and_upgrading_amq_streams_on_openshift/index#assembly-metrics-setup-str


Those commands are required cluster wide to enable user definened monitoring projects as described here https://access.redhat.com/documentation/en-us/openshift_container_platform/4.10/html-single/monitoring/index#creating-cluster-monitoring-configmap_configuring-the-monitoring-stack 
As cluster admin:

1. *** oc apply -f 101-101-cluster-monitoring-config-map.yaml***

    ## Note that we will modify this cm aganin later
2. ***oc apply -f 102-workload-monitoring-config.yaml*** and add in t

3. Check if everything is ok with ***oc -n openshift-user-workload-monitoring get pod***
    Check the following to be sure that you have enabled correctly monitoring of user-defined projects:
    If monitoring for user-defined projects is enabled, the openshift-user-workload-monitoring project contains the following components:

        A Prometheus Operator
        A Prometheus instance (automatically deployed by the Prometheus Operator)
        A Thanos Ruler instance
As normal user:


1. Deploy kakfka instance with metrics enabled :
    *** oc apply -f 104-kafka-installation-with-metrics-enabled.yaml -n amq-test ***

2. Optional but useful, install kafdrop to get through topics
    ***oc apply -f 104-kafdrop-deploy.yaml ***
    ***oc expose service kafdrop-service***
3. Applichiamo i pod monitor ***oc apply -f 106-strimzi-pod-monitor.yaml***
4. service account for grafana : oc apply -f 107 107-create-service-account-grafana.yaml
5. as admin Create RoleBinding so add in the project from the console or ***oc apply -f 108-role-binding-grafana.yaml***
6. ***oc create configmap grafana-config --from-file=datasource.yaml -n amq-test***
7. ***oc apply -f 109-grafana-app.yaml -n amq-test***
8. create route for grafana ***oc create route edge MY-GRAFANA-ROUTE --service=grafana --namespace=KAFKA-NAMESPACE***
9. Click on the route and login with admin/admin
