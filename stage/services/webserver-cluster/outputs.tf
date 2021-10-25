output "elb_dns_name" {
  value = "${aws_elb.elb.dns_name}"

}

output "db_address" {
  value = "${data.terraform_remote_state.db.outputs.address}"
}

output "db_port" {
  value = "${data.terraform_remote_state.db.outputs.port}"
}
