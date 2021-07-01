resource "aws_launch_configuration" "Web-Server" {

  image_id      = "ami-033af134328c47f48"
  instance_type = "t2.micro"

  security_groups             = [aws_security_group.ws-sg.id]
  associate_public_ip_address = true

  user_data = file("install-httpd.sh")


  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "ws-elb" {
  security_groups = [aws_security_group.ws-sg.id]
  subnets       = aws_subnet.public.*.id

  cross_zone_load_balancing = true

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:80/"
  }

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "80"
    instance_protocol = "http"
  }
}

resource "aws_autoscaling_group" "ws-asg" {

  min_size         = 2
  desired_capacity = 2
  max_size         = 4

  health_check_type = "ELB"
  load_balancers    = [aws_elb.ws-elb.id]

  launch_configuration = aws_launch_configuration.Web-Server.name

  tag {
    key                 = "Name"
    value               = "Web Server"
    propagate_at_launch = true
  }

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  vpc_zone_identifier = aws_subnet.public.*.id

  lifecycle {
    create_before_destroy = true
  }
}
