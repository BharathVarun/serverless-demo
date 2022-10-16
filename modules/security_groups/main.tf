variable "vpc_id" {}
variable "prefix" {}
variable "jenkins_controller_port" {}
variable "jenkins_agents_port" {}

resource "aws_security_group" "jenkins_alb" {
   name        = "jenkins-alb"
   description = "Security group for the ALB that points to the Jenkins master"
   vpc_id      = var.vpc_id

   ingress {
      description = "Allow all traffic through port 80"
      from_port   = "80"
      to_port     = "80"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
   }

   egress {
      description = "Allow all outbound traffic"
      from_port   = "0"
      to_port     = "0"
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
   }

   tags = {
      Name = "${var.prefix}-jenkins-alb"
   }
}
resource "aws_security_group" "jenkins_agents" {
   name        = "jenkins-agents"
   description = "Security group for the Jenkins agents"
   vpc_id      = var.vpc_id

   egress {
      description = "Allow all outbound traffic"
      from_port   = "0"
      to_port     = "0"
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
   }

   tags = {
      Name = "${var.prefix}-jenkins-agents"
   }
}
resource "aws_security_group" "jenkins_controller" {
   name        = "jenkins-controller"
   description = "Security group for the Jenkins master"
   vpc_id      = var.vpc_id

   ingress {
      description       = "Allow traffic from the ALB"
      from_port         = "${var.jenkins_controller_port}"
      to_port           = "${var.jenkins_controller_port}"
      protocol          = "tcp"
      security_groups   = [aws_security_group.jenkins_alb.id]
   }

   ingress {
      description       = "Allow traffic from the Jenkins agents over JNLP"
      from_port         = "${var.jenkins_agent_port}"
      to_port           = "${var.jenkins_agent_port}"
      protocol          = "tcp"
      security_groups   = [aws_security_group.jenkins_agents.id]
   }

   ingress {
      description       = "Allow traffic from the Jenkins agents"
      from_port         = "${var.jenkins_controller_port}"
      to_port           = "${var.jenkins_controller_port}"
      protocol          = "tcp"
      security_groups   = [aws_security_group.jenkins_agents.id]
   }

   ingress {
      description       = "Allow traffic from VPC endpoints"
      from_port         = "443"
      to_port           = "443"
      protocol          = "tcp"
      security_groups   = [aws_security_group.vpc_endpoints.id]
   }

   egress {
      description = "Allow all outbound traffic"
      from_port   = "0"
      to_port     = "0"
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
   }

   tags = {
      Name = "${var.prefix}-jenkins-controller"
   }
}
resource "aws_security_group" "jenkins_efs" {
   name        = "jenkins-efs"
   description = "Security group for the EFS of the Jenkins controller"
   vpc_id      = var.vpc_id

   ingress {
      description       = "Allow traffic from the Jenkins controller"
      from_port         = "2049"
      to_port           = "2049"
      protocol          = "tcp"
      security_groups   = [aws_security_group.jenkins_controller.id]
   }

   egress {
      description = "Allow all outbound traffic"
      from_port   = "0"
      to_port     = "0"
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
   }

   tags = {
      Name = "${var.prefix}-jenkins-efs"
   }
}
resource "aws_security_group" "vpc_endpoints" {
   name        = "vpc-endpoints"
   description = "SG for VPC Endpoints"
   vpc_id      = var.vpc_id

   ingress {
      description = "Allow HTTPS traffic"
      from_port   = "443"
      to_port     = "443"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
   }

   egress {
      description = "Allow all outbound traffic"
      from_port   = "0"
      to_port     = "0"
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
   }

   tags = {
      Name = "${var.prefix}-vpc-endpoints"
   }
}
