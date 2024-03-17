data "aws_iam_policy_document" "eks_nodes_role" {
    version = "2012-10-17"
    statement {
        actions = [ "sts:AssumeRole" ]
        principals {
            type = "Service"
            identifiers = [
                "ec2.amazonaws.com"
            ]
        }
    }
}

resource "aws_iam_policy" "secrets_manager_policy" {
  name        = "secrets-manager-policy"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "sqs_manager_policy" {
  name        = "sqs-manager-policy"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["sqs:*"],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "sns_manager_policy" {
  name        = "sns-manager-policy"
  
  policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
        {
          Action: ["sns:*"],
          Effect: "Allow",
          Resource: "*"
        }
    ]
  })
}

resource "aws_iam_role" "eks_nodes_roles" {
    name = format("%s-eks-nodes", var.cluster_name)
    assume_role_policy = data.aws_iam_policy_document.eks_nodes_role.json
}

resource "aws_iam_role_policy_attachment" "cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role = aws_iam_role.eks_nodes_roles.name
}

resource "aws_iam_role_policy_attachment" "node" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role = aws_iam_role.eks_nodes_roles.name
}

resource "aws_iam_role_policy_attachment" "ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role = aws_iam_role.eks_nodes_roles.name
}

resource "aws_iam_role_policy_attachment" "secrets_manager" {
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
  role = aws_iam_role.eks_nodes_roles.name
}

resource "aws_iam_role_policy_attachment" "sqs_manager" {
  policy_arn = aws_iam_policy.sqs_manager_policy.arn
  role = aws_iam_role.eks_nodes_roles.name
}

resource "aws_iam_role_policy_attachment" "sns_manager" {
  policy_arn = aws_iam_policy.sns_manager_policy.arn
  role = aws_iam_role.eks_nodes_roles.name
}

resource "aws_iam_role_policy_attachment" "autoscaling" {
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
  role       = aws_iam_role.eks_nodes_roles.name
}