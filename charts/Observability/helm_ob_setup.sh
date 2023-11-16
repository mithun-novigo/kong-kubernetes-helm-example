
helm repo add elastic https://helm.elastic.co

kubectl apply -f ./elastic-credentials-secret.yml -n logging

# kubectl create secret tls elastic-certificates --cert=./certs/ssl-certs/MBUATCERT-cer.cer --key=./certs/ssl-certs/MBUATCERT-Key.key -n cp

kubectl apply -f ./elastic-certificates-secret.yml -n logging

helm upgrade --install elasticsearch \
  elastic/elasticsearch \
  --namespace logging \
  --version "8.5.1" \
  --values ./values-elasticsearch.yml

# helm upgrade --install kibana \
#   elastic/kibana \
#   --namespace logging \
#   --version "7.17.1" \
#   --values ./values-kibana.yml

# helm upgrade --install filebeat \
#   elastic/filebeat \
#   --namespace logging \
#   --version "7.17.1" \
#   --values ./values-filebeat.yml


# https://www.elastic.co/guide/en/elasticsearch/reference/7.17/configuring-stack-security.html

# https://www.elastic.co/guide/en/elasticsearch/reference/7.17/security-settings.html

