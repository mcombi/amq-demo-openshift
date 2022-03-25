oc label deployment kafdrop app.openshift.io/runtime=spring-boot
oc label deployment kafdrop app.openshift.io/connects-to=my-cluster-kafka
oc annotate dc store-project 'app.openshift.io/connects-to'='[{"apiVersion":"apps.openshift.io/v1","kind":"DeploymentConfig","name":"orders"}]' --overwrite
oc annotate dc kafdrop 'app.openshift.io/connects-to'='[{"apiVersion":"apps.openshift.io/v1","kind":"DeploymentConfig","name":"my-cluster-kafka"}]' --overwrite
oc annotate dc kafdrop 'app.openshift.io/connects-to'='[{"apiVersion":"apps.openshift.io/v1","kind":"StatefulSet","name":"my-cluster-kafka"}]' --overwrite