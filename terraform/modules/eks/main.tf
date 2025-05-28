# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  depends_on = [
    var.cluster_role_arn,
  ]

  tags = {
    Name = var.cluster_name
    Environment = var.environment
  }
}

# EKS Node Group
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-nodes"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.node_subnet_ids

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  update_config {
    max_unavailable = 1
  }

  instance_types = var.node_instance_types

  depends_on = [
    var.node_role_arn,
  ]

  tags = {
    Name = "${var.cluster_name}-node-group"
  }
}

# EKS Add-ons
resource "aws_eks_addon" "ebs_csi" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "aws-ebs-csi-driver"
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "vpc-cni"
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "coredns"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "kube-proxy"
}

# Configure kubectl for local-exec
resource "null_resource" "kubectl_config" {
  depends_on = [aws_eks_node_group.main]

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl config unset users.${self.triggers.cluster_name}"
    on_failure = continue
  }

  triggers = {
    cluster_name = aws_eks_cluster.main.name
    region       = var.aws_region
  }
}

# Wait for cluster to be ready
resource "null_resource" "wait_for_cluster" {
  depends_on = [null_resource.kubectl_config]

  provisioner "local-exec" {
    command = <<-EOL
      echo "Waiting for cluster to be ready..."
      for i in {1..30}; do
        if kubectl get nodes >/dev/null 2>&1; then
          echo "Cluster is ready"
          break
        fi
        echo "Waiting... ($i/30)"
        sleep 10
      done
    EOL
  }
}

# Install Prometheus using Helm
resource "null_resource" "install_prometheus" {
  depends_on = [null_resource.wait_for_cluster]

  provisioner "local-exec" {
    command = <<-EOL
      # Add Prometheus Helm repository
      helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
      helm repo update

      # Create monitoring namespace
      kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

      # Install kube-prometheus-stack
      helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
        --namespace monitoring \
        --set prometheus.service.type=LoadBalancer \
        --set grafana.service.type=LoadBalancer \
        --set grafana.adminPassword=${var.grafana_admin_password} \
        --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
        --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false \
        --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=${var.prometheus_storage_size} \
        --set grafana.persistence.enabled=true \
        --timeout 10m \
        --wait
    EOL
  }

  provisioner "local-exec" {
    when = destroy
    command = <<-EOL
      helm uninstall prometheus -n monitoring || true
      kubectl delete namespace monitoring || true
    EOL
    on_failure = continue
  }

  triggers = {
    cluster_endpoint = aws_eks_cluster.main.endpoint
  }
}

# Install AWS Load Balancer Controller
resource "null_resource" "install_aws_lb_controller" {
  depends_on = [null_resource.wait_for_cluster]

  provisioner "local-exec" {
    command = <<-EOL
      # Add EKS Helm repository
      helm repo add eks https://aws.github.io/eks-charts
      helm repo update

      # Install AWS Load Balancer Controller
      helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
        --namespace kube-system \
        --set clusterName=${aws_eks_cluster.main.name} \
        --set serviceAccount.create=false \
        --set serviceAccount.name=aws-load-balancer-controller \
        --set region=${var.aws_region} \
        --set vpcId=${var.vpc_id} \
        --timeout 5m \
        --wait
    EOL
  }

  provisioner "local-exec" {
    when = destroy
    command = "helm uninstall aws-load-balancer-controller -n kube-system || true"
    on_failure = continue
  }

  triggers = {
    cluster_endpoint = aws_eks_cluster.main.endpoint
  }
}

# Install Metrics Server
resource "null_resource" "install_metrics_server" {
  depends_on = [null_resource.wait_for_cluster]

  provisioner "local-exec" {
    command = <<-EOL
      # Add Metrics Server Helm repository
      helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
      helm repo update

      # Install Metrics Server
      helm upgrade --install metrics-server metrics-server/metrics-server \
        --namespace kube-system \
        --set args[0]=--kubelet-insecure-tls \
        --timeout 5m \
        --wait
    EOL
  }

  provisioner "local-exec" {
    when = destroy
    command = "helm uninstall metrics-server -n kube-system || true"
    on_failure = continue
  }

  triggers = {
    cluster_endpoint = aws_eks_cluster.main.endpoint
  }
}

# Get monitoring URLs
resource "null_resource" "get_monitoring_urls" {
  depends_on = [null_resource.install_prometheus]

  provisioner "local-exec" {
    command = <<-EOL
      echo "Waiting for LoadBalancer services to get external IPs..."
      sleep 60
      
      echo "Getting service URLs..."
      PROMETHEUS_URL=$(kubectl get svc prometheus-kube-prometheus-prometheus -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "pending")
      GRAFANA_URL=$(kubectl get svc prometheus-grafana -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "pending")
      
      echo "Prometheus URL: http://$PROMETHEUS_URL:9090"
      echo "Grafana URL: http://$GRAFANA_URL:80 (admin/admin123)"
      
      # Save URLs to file for later reference
      cat > monitoring_urls.txt <<EOF
Prometheus: http://$PROMETHEUS_URL:9090
Grafana: http://$GRAFANA_URL:80
Grafana Credentials: admin/admin123
EOF
    EOL
  }
}