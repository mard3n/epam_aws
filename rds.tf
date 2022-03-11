resource "random_string" "rds_password" {
  length  = 8
  special = false
}

resource "random_string" "suffix" {
  length  = 5
  special = false
}

resource "aws_db_subnet_group" "rds" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
}

resource "aws_db_instance" "rds" {
  allocated_storage         = 5
  backup_retention_period   = 3
  db_subnet_group_name      = "${aws_db_subnet_group.rds.name}"
  engine                    = "mysql"
  engine_version            = "5.7.19"
  final_snapshot_identifier = "snapshot"
  identifier                = "rds-mysql"
  instance_class            = "db.t2.micro"                                        
  multi_az                  = true
  name                      = "rdsmysql"
  password                  = "${random_string.rds_password.result}"
  storage_encrypted         = false                                                            
  storage_type              = "gp2"
  username                  = "dbadmin"
  vpc_security_group_ids    = ["${aws_security_group.rds-sg.id}"]
}

resource "aws_security_group" "rds-sg" {
  description = "RDS SG"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_default_vpc.default.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
