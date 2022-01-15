########################################################### vm0

resource "aws_launch_configuration" "vm0" {
  image_id = data.aws_ami.amazon-2.image_id
  instance_type = "t3.micro"
  user_data = base64encode(templatefile("${path.module}/templates/init_vm0.tpl", { 
      vm1_host = aws_elb.vm1_elb.dns_name, 
      vm2_host = aws_elb.vm2_elb.dns_name
      } ))
  security_groups = [aws_security_group.ingress-all-ssh.id, aws_security_group.ingress-all-http.id]
  name_prefix = "${var.creativelighttp_name}-vm0-"

  lifecycle {
    create_before_destroy = true
  }
}

########################################################### vm0- Autoscaling_group

resource "aws_autoscaling_group" "asg-vm0" {
  availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
  desired_capacity   = var.desired_instances
  max_size           = var.max_instances
  min_size           = var.min_instances
  name = "${var.creativelighttp_name}-asg-vm0"

  launch_configuration = aws_launch_configuration.vm0.name

  health_check_type    = "ELB"
  load_balancers = [
    aws_elb.vm0_elb.id
  ]

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      instance_warmup = "60"
    }
    triggers = ["tag"]
  }

  tag {
    key                 = "Name"
    value               = "${var.creativelighttp_name}-vm0"
    propagate_at_launch = true
  }

}

########################################################### vm0- Load Balancer

resource "aws_elb" "vm0_elb" {
  name = "${var.creativelighttp_name}-vm0-elb"
  availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
  security_groups = [
    aws_security_group.elb_http.id
  ]

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:8080/"
  }

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "8080"
    instance_protocol = "http"
  }
}