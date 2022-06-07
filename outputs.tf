# VPC
output "vpce_endpont_id" {
  description = "The ID of the VPC"
  value       = aws_networkfirewall_firewall.NetworkFirewall
}