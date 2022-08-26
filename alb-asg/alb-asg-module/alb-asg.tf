resource "aws_security_group" "allow_http_ssh" {
  name        = "MySG"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = "vpc-0582c689110087755"

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_lb" "test" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http_ssh.id]
  subnets            = [ "subnet-0d75e47db9b4102f6", "subnet-066d237845f64d995", "subnet-0b0d06725cd4dd000" ]

  enable_deletion_protection = false

  tags = {
    Environment = "Dev"
  }
  depends_on = [ aws_security_group.allow_http_ssh ]
}

resource "aws_lb_target_group" "test" {
  name     = var.tg_name
  port     = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id   = "vpc-0582c689110087755"
  health_check {
    protocol = "HTTP"
    path = "/" 
    port = "traffic-port" 
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 5
    interval = 10      
  }
  depends_on = [ aws_lb.test ]
}

resource "aws_lb_listener" "http_front_end" {
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.test.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-2:365170125456:certificate/cad24eac-644e-45f1-9ef5-2addbb1a0539"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test.arn
  }
}

resource "aws_launch_configuration" "asg_launch_config" {
  name = "terraform-launch-config"
  image_id      = "ami-0568773882d492fc8"
  instance_type = "t3.micro"
  key_name = "testkey"
  iam_instance_profile = "Administrator_Access"
  security_groups = [ aws_security_group.allow_http_ssh.id ]
  associate_public_ip_address = true
  enable_monitoring = true
  ebs_optimized = true
  root_block_device {
    volume_type = "gp2"
    volume_size = 10
    delete_on_termination = true
    encrypted = true  
  }
  user_data = <<-EOF
    #!/bin/bash
    yum install -y httpd
    service httpd start
    chkconfig httpd on
    echo "<h1>Hello Ritesh123</h1>" >> /var/www/html/index.html
  EOF

  placement_tenancy = "default"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "bar" {
  name                      = "foobar3-terraform-test"
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 100  ## Time after instance comes into service before checking health
  health_check_type         = "ELB"
  desired_capacity          = 3
  default_cooldown          = 100  #The amount of time, in seconds, after a scaling activity completes before another scaling activity can start.
  service_linked_role_arn = "arn:aws:iam::365170125456:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
  launch_configuration      = aws_launch_configuration.asg_launch_config.name
  vpc_zone_identifier       = ["subnet-0d75e47db9b4102f6", "subnet-066d237845f64d995", "subnet-0b0d06725cd4dd000"]
  target_group_arns = [ aws_lb_target_group.test.arn ]
  force_delete = true
  termination_policies = ["OldestLaunchConfiguration"]
  tag {
    key = "Environment"
    value = "Dev"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
  
  depends_on = [ aws_launch_configuration.asg_launch_config, aws_lb_target_group.test ]
}

resource "aws_autoscaling_policy" "scaleup" {
  autoscaling_group_name = aws_autoscaling_group.bar.name
  name                   = "scaleout"
  policy_type = "StepScaling"
  adjustment_type        = "ChangeInCapacity"
  estimated_instance_warmup = 100
#  cooldown               = 300
  step_adjustment {
    scaling_adjustment          = 1
    metric_interval_lower_bound = 0
    metric_interval_upper_bound = ""
  }
  depends_on = [ aws_autoscaling_group.bar ]
}

resource "aws_autoscaling_policy" "scaledown" {
  autoscaling_group_name = aws_autoscaling_group.bar.name
  name                   = "scalein"
  policy_type = "StepScaling"
  adjustment_type        = "ChangeInCapacity"
  estimated_instance_warmup = 100
#  cooldown               = 300
  step_adjustment {
    scaling_adjustment          = -1
    metric_interval_lower_bound = ""
    metric_interval_upper_bound = 0
  }
  depends_on = [ aws_autoscaling_group.bar ]
}

resource "aws_cloudwatch_metric_alarm" "cloudwatch_alarm_high" {
  alarm_name                = "cloudwatch_alarmhigh"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  datapoints_to_alarm       = "1"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "50"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.bar.name
  }
  alarm_actions     = [ aws_autoscaling_policy.scaleup.arn ]
  depends_on = [ aws_autoscaling_group.bar,aws_autoscaling_policy.scaleup ]
}

resource "aws_cloudwatch_metric_alarm" "cloudwatch_alarm_low" {
  alarm_name                = "cloudwatch_alarmlow"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = "1"
  datapoints_to_alarm       = "1"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "50"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.bar.name
  }
  alarm_actions     = [ aws_autoscaling_policy.scaledown.arn ]
  depends_on = [ aws_autoscaling_group.bar,aws_autoscaling_policy.scaledown ]
}
