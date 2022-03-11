resource "random_id" "efs_token" {
  byte_length = 8
  prefix      = "efs_token"
}

resource "aws_efs_file_system" "efs" {
  creation_token = "${random_id.efs_token.hex}"
}

resource "aws_efs_mount_target" "efs-1" {
  file_system_id  = "${aws_efs_file_system.efs.id}"
  subnet_id      = aws_default_subnet.default_az1.id
  security_groups = ["${aws_security_group.efs-sg.id}"]
}

resource "aws_efs_mount_target" "efs-2" {
  file_system_id  = "${aws_efs_file_system.efs.id}"
  subnet_id      = aws_default_subnet.default_az2.id
  security_groups = ["${aws_security_group.efs-sg.id}"]
}

resource "aws_security_group" "efs-sg" {
  description = "EFS-SG"
  vpc_id =  aws_default_vpc.default.id

  ingress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"

    cidr_blocks = [aws_default_vpc.default.cidr_block]
  }

  egress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"

    cidr_blocks = [aws_default_vpc.default.cidr_block]
  }
}


