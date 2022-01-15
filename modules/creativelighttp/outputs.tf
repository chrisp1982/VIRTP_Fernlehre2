output "creativelighttp-url" {
  value = "http://${aws_elb.vm0_elb.dns_name}"
}