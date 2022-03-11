output "efs_id" {
  value = "${aws_efs_file_system.efs.id}"
}

output "efs_dns_name" {
  value = "${aws_efs_file_system.efs.dns_name}"
}

output "wp_lb_url" {
  value = "${aws_elb.web.dns_name}"
}

output "rds_address" {
  value = "${aws_db_instance.rds.address}"
}

output "rds_password" {
  value = "${random_string.rds_password.result}"
}

output "wp_password" {
  value = "${random_string.wp_password.result}"
}