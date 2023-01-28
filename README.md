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
- https://book.kubebuilder.io/reference/kind.html

Ensure to install the latest version of `kubectl` and `kind`
- ``choco install kubernetes-cli --version 1.25.0``
- ``choco install kind --version 0.17.0``

Install Apache Airflow on Local Kubernetes Cluster using Helm & Kind
1. Create a Local Kubernetes Cluster with Kind
   - `kind create cluster --name airflow-cluster --config kind-cluster.yaml`
   - Interact with the cluster: `kubectl cluster-info --context kind-airflow-cluster`
   - `kubectl get nodes -o wide`
   - Get a list of clusters: `kind get clusters`
   - Get a list of images present on a cluster: `docker exec -it <node-name/docker-container> crictl images`
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
   - Get the values.yaml file with `helm show values apache-airflow/airflow > values.yaml`
   - Change the executor to one of: `LocalExecutor`, `LocalKubernetesExecutor`, `CeleryExecutor`, `KubernetesExecutor`, `CeleryKubernetesExecutor`
   - If you have variables or connections that needs export for each Airflow deployment:
      - define a `ConfigMap` - see example in `variables.yaml`
      - Modify `extraEnvFrom` in `values.yaml` file and;
      - apply the ConfigMap to the cluster with: `kubectl apply -f variables.yaml`
      - deploy Airflow on Kubernetes again: `helm upgrade --install airflow apache-airflow/airflow -n airflow -f values.yaml --debug`
4. Install Dependencies with Airflow on Kubernetes
   - To install dependencies like Spark or Amazon providers, you need to build a custom Docker image
   - create a `requirements.txt` file with the package you need installed
   - Create a Dockerfile with the content of `Dockerfile` in this repo
   - Build the custom docker image: `docker build -t airflow-custom:1.0.0 .`
   - Load the docker image into the local Kubernetes cluster: `kind load docker-image airflow-custom:1.0.0 --name airflow-cluster`
   - Edit `defaultAirflowRepository` and `defaultAirflowTag` in `values.yaml` file to the repo and image tag above
   - Deploy Airflow on Kubernetes again: `helm upgrade --install airflow apache-airflow/airflow -n airflow -f values.yaml --debug`
   - Check the providers with command: `kubectl exec <webserver_pod_id> -n airflow -- airflow providers list`
5. Start Airflow server by port-forwarding the Airflow UI to `http://localhost:8080/`
   - `kubectl port-forward svc/airflow-webserver 8080:8080 -n airflow --context kind-airflow-cluster --set-string \`
     `"env[0].name=AIRFLOW__CORE__LOAD_EXAMPLES" --set-string "env[0].value=True"`
6. Deploy DAGs on Kubernetes with GitSync
   - Create a private repo on GitHub
   - Generate a private key using `ssh-keygen` command
   - Modify the `values.yaml` file
   - Create a secret with your private key in it
   - `kubectl create secret generic airflow-ssh-git-secret --from-file=gitSshKey=/Your/path/.ssh/id_rsa -n airflow`
   - Deploy the public key on the Git repository (Settings -> Deploy Key)
   - Upgrade Airflow instance: `helm upgrade --install airflow apache-airflow/airflow -n airflow -f values.yaml --debug`
7. Enable Logs with Airflow on Kubernetes 
   - `kubectl exec -it airflow-worker-0 -- /bin/bash`
8. Rollback to a previous working release `helm rollback <release> airflow <revision no> 3 -n airflow`
9. Run commands against a pod:
   - shell into pod `kubectl -n airflow exec -it <pod-name> sh`
   - run any command directly on the pod: `kubectl -n airflow exec <pod-name> -- ls`
10. Useful kubectl commands
  - `kubectl port-forward svc/<servic-name> <node-port>:<host-port> -n namespace`
  - `kubectl get pods -n namespace --show-labels`
  - `kubectl describe replicaset <pod-name> -n namespace` OR `kubectl describe rs <pod-name> -n namespace`
  - `kubectl get all -n namespace --show-labels`
  - `kubectl get ns` get all namespaces defined on the k8s system
  - `kubectl logs <pod-name>` - emits the application system logs: add `-f` to freeze the console and follow the logs
11. To clean up use: 
  - `helm delete airflow --namespace airflow`
  - `docker image rm -f airflow-docker-image-id`
