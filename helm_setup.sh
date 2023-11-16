# Kong Helm deployment script

# Delete the namespace and helm charts and stop
if [ "$1" == "clean" ]
then
    echo "Starting cleanup =============================="

    echo "Deleting Helm charts -------------------------"
    #Delete kong releases if already there
    ## delete control plane helm
    helm del kongcp -n cp
    ## delete data plane helm
    helm del kongdp -n dp

    echo "Deleting Namespaces -------------------------"
    #Delete k8s namespaces
    ## delete control plane namespaces
    kubectl delete namespace cp
    ## delete data plane namespaces
    kubectl delete namespace dp
   
    echo "Cleanup complete."
    
    exit
elif [ "$1" == "upgrade" ]
then
    echo "Starting upgrade =============================="

    echo "Upgrade Control Plane helm charts -------------------------"
    helm upgrade kongcp kong/kong --values=./charts/cp_values.yaml -n cp
    
    echo "Upgrade Data Plane helm charts -------------------------"
    helm upgrade kongdp  kong/kong --values=./charts/dp_values.yaml -n dp

elif [ "$1" == "new" ]
then
    echo "Starting new =============================="
    echo "Creating Namespaces -------------------------"
    #create k8s namespaces
    ## create control plane namespaces
    kubectl create namespace cp
    ## create data plane namespaces
    kubectl create namespace dp

    echo "Creating secrets Control Plane -------------------------"

    ############# create the k8s secrets for CP
    ## Kong enterprise license
    kubectl create secret generic kong-enterprise-license --from-file=license=./license/kong-license.json -n cp
    ## create postgres password
    kubectl create secret generic kong-enterprise-postgres-password --from-literal=password=K5B1HXkFT3WzlOgOEMV3 -n cp
    ##gui and api certificates 
    kubectl create secret tls kong-ssl-cert --cert=./certs/ssl-certs/MBUATCERT-cer.cer --key=./certs/ssl-certs/MBUATCERT-Key.key -n cp
    ##shared mode cluster certs
    kubectl create secret tls kong-cluster-cert --cert=./certs/hybrid/cluster.crt --key=./certs/hybrid/cluster.key -n cp
    ## manager and portal session conf
    kubectl create secret generic kong-session-conf --from-file=./conf/admin_gui_session_conf --from-file=./conf/portal_session_conf -n cp
    ## manager and portal auth conf
    kubectl create secret generic kong-auth-conf --from-file=./conf/admin_gui_auth_conf --from-file=./conf/portal_auth_conf -n cp

    ## Kong super user password
    kubectl create secret generic kong-enterprise-superuser-password --from-literal=password="kalidass" -n cp

    echo "Creating secrets Data Plane -------------------------"

    ############# create the k8s secrets for DP

    ## Kong enterprise license
    kubectl create secret generic kong-enterprise-license --from-file=license=./license/kong-license.json -n dp
    ## shared mode cluster certs
    kubectl create secret tls kong-cluster-cert --cert=./certs/hybrid/cluster.crt --key=./certs/hybrid/cluster.key -n dp
    
    kubectl create secret tls kong-internal-ssl-cert --cert=./certs/ssl-certs/MBUATCERT-cer.cer --key=./certs/ssl-certs/MBUATCERT-Key.key -n dp
    kubectl create secret tls kong-ssl-cert --cert=./certs/dp_cert/star_mbank_ae.pem --key=./certs/dp_cert/star_mbank_ae.key -n dp

    echo "Install Control Plane helm charts -------------------------"
    helm install kongcp kong/kong --values=./charts/cp_values.yaml -n cp

    echo "Install Data Plane 1 helm charts -------------------------"
    helm install kongdp  kong/kong --values=./charts/dp_values.yaml -n dp

    echo "Install Data Plane 2 helm charts -------------------------"
    helm install kongdp2  kong/kong --values=./charts/dp2_values.yaml -n dp

else
    echo "Parameters not provided"
    echo "helm_setup.sh new|upgrade|clean"
    echo "new - fresh install"
    echo "upgrade - only upgrade helm charts"
    echo "clean - clean up"
fi

echo "======== COMPLETE ========="