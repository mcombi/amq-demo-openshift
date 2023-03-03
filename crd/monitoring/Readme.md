## about Steps to install monitorig for kafka on openshift

### Preliminary steps: 

1. Install Red Hat Integration - AMQ Streams Operator

2. Create your project : ***oc new-project amq-test***

3. Install Prometheus Operator -> The comunity operator must be installed in every project


Follow this guide https://access.redhat.com/documentation/en-us/red_hat_amq/2020.q4/html-single/deploying_and_upgrading_amq_streams_on_openshift/index#assembly-metrics-setup-str


Those commands are required cluster wide to enable user definened monitoring projects as described here https://access.redhat.com/documentation/en-us/openshift_container_platform/4.10/html-single/monitoring/index#creating-cluster-monitoring-configmap_configuring-the-monitoring-stack 
As cluster admin:

1. *** oc apply -f 101-101-cluster-monitoring-config-map.yaml***


2. ***oc apply -f 102-workload-monitoring-config.yaml*** 

3. Check if everything is ok with ***oc -n openshift-user-workload-monitoring get pod*** or got to openshift-user-workload-monitoring project
    Check the following to be sure that you have enabled correctly monitoring of user-defined projects:
    If monitoring for user-defined projects is enabled, the openshift-user-workload-monitoring project contains the following components:

        A Prometheus Operator
        A Prometheus instance (automatically deployed by the Prometheus Operator)
        A Thanos Ruler instance


As normal user:


1. Deploy kafka instance with metrics enabled : *** oc apply -f 104-kafka-installation-with-metrics-enabled.yaml -n amq-test ***

2. Optional but useful, install kafdrop to get through topics
    ***oc apply -f 104-kafdrop-deploy.yaml ***
    ***oc expose service kafdrop-service*** -> Improvement include route in the previous step.
3. Create  pod monitor ***oc apply -f 106-strimzi-pod-monitor.yaml***
4. service account for grafana : oc apply -f 107 107-create-service-account-grafana.yaml
5. as admin Create RoleBinding in the project from the console or ***oc apply -f 108-role-binding-grafana.yaml -n amq-test***
5.1. You have to grab service account token with ***oc serviceaccounts get-token grafana-serviceaccount -n amq-test*** and put in datasource.yaml (NOTE Works with 4.10, with recent versions. With 4.12 issue with getting the token.
6. ***oc create configmap grafana-config --from-file=datasource.yaml -n amq-test***
7. ***oc apply -f 109-grafana-app.yaml -n amq-test***
8. create route for grafana ***oc create route edge MY-GRAFANA-ROUTE --service=grafana --namespace=KAFKA-NAMESPACE***
9. Click on the route and login with admin/admin
10. Check if datasource is working. If U get and 403 error You have to reset the token (remember to use the format "Bearer token")
11. Import ***109-kafka-dashboard.json*** from DashBoard, manage


