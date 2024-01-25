module "network" {
    source       = "./modules/network"
    cluster_name = var.cluster_name
    aws_region   = var.aws_region
}

module "master" {
    source            = "./modules/eks/master"
    cluster_name      = var.cluster_name
    aws_region        = var.aws_region
    kube_version      = var.kube_version
    
    cluster_vpc       = module.network.cluster_vpc
    # private_subnet_1a = module.network.private_subnet_1a
    # private_subnet_1b = module.network.private_subnet_1b
    public_subnet_1a = module.network.public_subnet_1a
    public_subnet_1b = module.network.public_subnet_1b
}

module "nodes" {
    source = "./modules/eks/node"
    cluster_name      = var.cluster_name
    aws_region        = var.aws_region
    kube_version      = var.kube_version
    
    cluster_vpc       = module.network.cluster_vpc
    # private_subnet_1a = module.network.private_subnet_1a
    # private_subnet_1b = module.network.private_subnet_1b
    public_subnet_1a = module.network.public_subnet_1a
    public_subnet_1b = module.network.public_subnet_1b

    eks_cluster       = module.master.eks_cluster
    eks_cluster_sg    = module.master.security_group

    nodes_instances_sizes = var.nodes_instances_sizes
    auto_scale_options = {
      desired = var.auto_scale_options.desired
      max = var.auto_scale_options.max
      min = var.auto_scale_options.min
    }
}

# module "helm" {
#     source = "./modules/helm"
#     cluster_name = var.cluster_name
# }