########################################################### vm1
resource "aws_launch_configuration" "vm1" {
  image_id = data.aws_ami.amazon-2.image_id
  instance_type = "t3.micro"
  user_data = base64encode(templatefile("${path.module}/templates/init_vm1.tpl", { 
      vm1_index = "<html><head><meta http-equiv=\"refresh\" content=\"1\"></head><body><h1>data from vm1 is shown</body></html>" 
      } ))
  security_groups = [aws_security_group.ingress-all-ssh.id, aws_security_group.ingress-all-http.id]
  name_prefix = "${var.creativelighttp_name}-vm1-"

  lifecycle {
    create_before_destroy = true
  }
}

########################################################### vm1- Autoscaling_group

resource "aws_autoscaling_group" "asg-vm1" {
  availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
  desired_capacity   = var.desired_instances
  max_size           = var.max_instances
  min_size           = var.min_instances
  name = "${var.creativelighttp_name}-asg-vm1"

  launch_configuration = aws_launch_configuration.vm1.name


  health_check_type    = "ELB"
  load_balancers = [
    aws_elb.vm1_elb.id
  ]
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }

  tag {
    key                 = "Name"
    value               = "${var.creativelighttp_name}-vm1"
    propagate_at_launch = true
  }

}

########################################################### vm1- Load Balancer

resource "aws_elb" "vm1_elb" {
  name = "${var.creativelighttp_name}-vm1-elb"
  availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
  security_groups = [
    aws_security_group.elb_http_8080.id
  ]

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:8080/"
  }

  listener {
    lb_port = 8080
    lb_protocol = "http"
    instance_port = "8080"
    instance_protocol = "http"
  }

}