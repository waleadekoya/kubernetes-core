# kubernetes-core

## Useful links:
- https://github.com/kubernetes/kubernetes
- https://kubernetes.io/docs/reference/kubectl/
- https://kubernetes.io/docs/setup/production-environment/turnkey-solutions/
- https://github.com/kubernetes-client/python
- https://airflow.apache.org/docs/helm-chart/stable/index.html
- https://airflow.apache.org/docs/apache-airflow/stable/index.html
- https://kind.sigs.k8s.io/docs/user/known-issues/
- https://airflow.apache.org/docs/helm-chart/stable/manage-dags-files.html
- https://airflow.apache.org/docs/helm-chart/stable/quick-start.html

Ensure to install the latest version of `kubectl` and `kind`
- ``choco install kubernetes-cli --version 1.25.0``
- ``choco install kind --version 0.17.0``

Install Apache Airflow on Local Kubernetes Cluster using Helm & Kind
1. Create a Local Kubernetes Cluster with Kind
   - `kind create cluster --name airflow-cluster --config kind-cluster.yaml`
   - `kubectl cluster-info`
   - `kubectl get nodes -o wide`
2. Deploy Airflow on the Kubernetes Cluster
   - `kubectl create namespace airflow`
   - `kubectl get namespaces`
   - `helm repo add apache-airflow https://airflow.apache.org`
   - `helm repo update`
   - `helm search repo airflow`
   - `helm install airflow apache-airflow/airflow --namespace airflow --debug`
   - `kubectl get pods -n airflow`
   - `helm ls -n airflow`
3. Configure Airflow on the Kubernetes Cluster (update `values.yaml` file)
   - `helm show values apache-airflow/airflow > values.yaml`
4. Install Dependencies with Airflow on Kubernetes
5. Deploy DAGs on Kubernetes with GitSync
   - Create a private repo on GitHub
   - Generate a private key using `ssh-keygen` command
   - Modify the `values.yaml` file
   - Create a secret with your private key in it
   - `kubectl create secret generic airflow-ssh-git-secret --from-file=gitSshKey=/Your/path/.ssh/id_rsa -n airflow`
   - Deploy the public key on the Git repository (Settings -> Deploy Key)
   - Upgrade Airflow instance: `helm upgrade --install airflow apache-airflow/airflow -n airflow -f values.yaml --debug`
6. Enable Logs with Airflow on Kubernetes 
   - `kubectl exec -it airflow-worker-0 -- /bin/bash`