resource "random_string" "wp_password" {
  length  = 10
  special = true
}

data "template_file" "wordpress" {
  template = "${file("wordpress.sh")}"

  vars = {
    efs_dns_name                        = "${aws_efs_file_system.efs.dns_name}"
    elb_dns_name                        = "${aws_elb.web.dns_name}"
    DB_NAME                             = "wordpress"
    DB_USER                             = "dbadmin"
    DB_PASSWORD                         = "${random_string.rds_password.result}"
    DB_HOST                             = "${aws_db_instance.rds.address}"
    WP_TITLE                            = "Wordpress"
    WP_USER                             = "wpadmin"
    WP_PASS                             = "${random_string.wp_password.result}"
    WP_EMAIL                            = "mail@example.com"
  }
}

resource "aws_launch_configuration" "web" {
  name_prefix                 = "Wordpress-LC-"
  image_id                    = data.aws_ami.latest_amazon_linux.id
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.web.id]
  user_data                   = "${data.template_file.wordpress.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web" {
  name                 = "ASG-${aws_launch_configuration.web.name}"
  launch_configuration = aws_launch_configuration.web.name
  min_size             = 2
  max_size             = 2
  min_elb_capacity     = 2
  health_check_type    = "ELB"
  vpc_zone_identifier  = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  load_balancers       = [aws_elb.web.name]

  dynamic "tag" {
    for_each = {
      Name   = "Wordpress"
      Owner  = "Wordpress"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
