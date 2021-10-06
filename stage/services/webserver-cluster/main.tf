terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

data "aws_availability_zones" "all" {}

provider "aws" {
  profile = "efiorucci"
  region  = "us-west-2"
}

resource "aws_launch_configuration" "launch_configuration" {
  image_id  = "ami-22eb9e5a"
  instance_type = "t1.micro"
  security_groups = ["${aws_security_group.security-group.id}"]
  user_data = "${data.template_file.user_data.rendered}"
          
  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "user_data" {
  template = "${file("user-data.sh")}"

  vars {
    server_port = "${var.server_port}"
    db_address = "${data.terraform_remote_state.db.address}"
    db_port = "${data.terraform_remote_stage.db.port}"
  }
}

resource "aws_security_group" "security-group" {
  name = "terraform-segurity-group"

  ingress {
    from_port = "${var.server_port}"
    to_port = "${var.server_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  launch_configuration = "${aws_launch_configuration.launch_configuration.id}"
  #availability_zones = ["${data.aws_availability_zones.all.names}"]
  availability_zones = data.aws_availability_zones.all.names

  load_balancers = ["${aws_elb.elb.name}"]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key = "Name"
    value = "terraform-asg-example"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "sg_elb" {
  name = "terraform-example-sg"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "elb" {
  name = "terraform-elb-example"
  #availability_zones = ["${data.aws_availability_zones.all.names}"]
  availability_zones = data.aws_availability_zones.all.names
  security_groups = ["${aws_security_group.sg_elb.id}"]

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "${var.server_port}"
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:${var.server_port}/"
  }
}

data "terraform_remote_state" "db" {
  backend = "s3"

  config = {
    bucket = "terraform-up-and-running-stage-eva"
    key = "stage/data-stores/mysql/terraform.tsfstate"
    region = "us-west-2"
    profile = "efiorucci"
  } 
}

terraform {
    backend "s3" {
        bucket = "terraform-up-and-running-stage-eva"
        key = "stage/services/webserver-cluster/terraform.tfstate"
        region = "us-west-2"

        dynamodb_table = "terraform-up-and-running-locks"
        encrypt = true
        profile = "efiorucci"
    }
}