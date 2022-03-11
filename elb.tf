resource "aws_elb" "web" {
  name               = "Wordpress-ELB"
  availability_zones = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  security_groups    = [aws_security_group.web.id]
  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }
  health_check {
    target              = "HTTP:80/"
    interval            = 300
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 60
  }
}
