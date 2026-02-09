# Kubernetes Deployment with Istio Gateway

This project deploys a microservices application featuring two control plane components, a gateway, and a MySQL database. Istio is utilized to manage and secure external access.
---
- ## Prerequisites
  
  * **Istio**: Installed and configured on the cluster.
  * **Kubernetes**: A running cluster (e.g., Minikube, EKS, GKE).
  * **kubectl**: Installed and configured.
  
  ---
- ## Deployment Steps
- ### 1. Generate Certificates & Secret
  Generate local certificates and create the TLS secret in the `istio-system` namespace.
- Generate local certificates
  
  ```bash
  ./scripts/generate-local-certificates.sh
  ```
- Create the Istio ingress TLS secret
  
  ```bash
  kubectl -n istio-system create secret tls wso2-ingress-cert \
  --cert=certificates/server.crt \
  --key=certificates/server.key \
  --dry-run=client -o yaml | kubectl apply -f -
  ```
- Restart the gateway to apply the secret
  
  ```bash
  kubectl -n istio-system rollout restart deploy/istio-ingressgateway
  kubectl -n istio-system rollout status deploy/istio-ingressgateway
  ```
- ### 2. Infrastructure Setup
  Apply the Istio Gateway configuration and initialize the MySQL database.
  ```
  # Apply Istio Gateway
  kubectl apply -f istio-gateway.yaml
  
  # Deploy MySQL and run initialization scripts
  kubectl apply -f mysql.yaml
  ./scripts/deploy-mysql.sh
  ```
- ### 3. Apply ConfigMaps
  Apply the configuration for control plane components and the gateway.
  ```
  kubectl apply -f cm-cp1.yaml
  kubectl apply -f cm-cp2.yaml
  kubectl apply -f cm-gw.yaml
  ```
- ### 4. Deploy Applications
  Deploy the control plane components and the gateway logic.
  ```
  kubectl apply -f deployment-cp1.yaml
  kubectl apply -f deployment-cp2.yaml
  kubectl apply -f deployment-gw.yaml
  ```
- ### 5. Expose Services
  Expose the deployments inside the cluster.
  ```
  kubectl apply -f service-cp.yaml
  kubectl apply -f service-gw.yaml
  ```