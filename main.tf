variable "region" {
  default     = "us-east-1"
  description = "AWS region"
}

provider "aws" {
  region = var.region
}

resource "aws_networkfirewall_firewall" "NetworkFirewall" {
  name = "Miax-network-firewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.FirewallPolicy.arn
  vpc_id = "vpc-0d0ba8de6402dcf04"
  delete_protection = false
  subnet_change_protection = false
  firewall_policy_change_protection = false
  description = "Firewall for Miax Project"

  subnet_mapping {
    subnet_id = "subnet-02bf3dd5f6df1b048"
  }
}

resource "aws_networkfirewall_rule_group" "RuleGroup1" {
  name = "Miax-stateful-rule-1"
  type = "STATEFUL"
  capacity = 25
  description = "Miax stateful rule"

  rule_group {
    rules_source {
      stateful_rule {
        action = "PASS"
        header {
          direction = "ANY"
          protocol = "TCP"
          source = "10.5.10.0/24"
          destination = "[10.248.16.0/20,10.248.48.0/20,10.248.32.0/20]"
          destination_port = "ANY"
          source_port = "ANY"
        }
        rule_option {
          keyword = "sid:1"
        }
      }
    
      stateful_rule {
        action = "PASS"
        header {
          direction = "ANY"
          protocol = "TCP"
          source = "[10.248.16.0/20,10.248.48.0/20,10.248.32.0/20]"
          destination = "ANY"
          destination_port = "[80,8080,443,22]"
          source_port = "ANY"
        }
        rule_option {
          keyword = "sid:2"
        }
      }
    
      stateful_rule {
        action = "PASS"
        header {
          direction = "ANY"
          protocol = "TCP"
          source = "[10.248.8.0/24,10.248.10.0/24,10.248.9.0/24]"
          destination = "[10.248.16.0/20,10.248.48.0/20,10.248.32.0/20]"
          destination_port = "[80,8080,443,22]"
          source_port = "ANY"
        }
        rule_option {
          keyword = "sid:3"
        }
      }
    
    
    }
  
  }
}

resource "aws_networkfirewall_rule_group" "RuleGroup2" {
  name = "Miax-statless-rule-1"
  type = "STATELESS"
  capacity = 50
  description = "statlessrule"

  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        stateless_rule {
          priority = 1
          rule_definition {
            actions = ["aws:pass"]
            match_attributes {
              protocols = [1]
              source {
                address_definition = "0.0.0.0/0"
              }
              destination {
                address_definition = "0.0.0.0/0"
              }
            }
          }
        }
        stateless_rule {
          priority = 2
          rule_definition {
            actions = ["aws:forward_to_sfe"]
            match_attributes {
              protocols = [6]
              source {
                address_definition = "0.0.0.0/0"
              }
              destination {
                address_definition = "0.0.0.0/0"
              }
            }
          }
        }
        stateless_rule {
          priority = 3
          rule_definition {
            actions = ["aws:forward_to_sfe"]
            match_attributes {
              protocols = [17]
              source {
                address_definition = "0.0.0.0/0"
              }
              destination {
                address_definition = "0.0.0.0/0"
              }
            }
          }
        }        
      }
    }
  }
}


resource "aws_networkfirewall_firewall_policy" "FirewallPolicy" {
  name = "Miax-firewall-policy"
  description = "Miax firewall policy"

firewall_policy {
  stateless_default_actions = ["aws:pass"]
  stateless_fragment_default_actions = ["aws:forward_to_sfe"]
  stateful_rule_group_reference {
    resource_arn = aws_networkfirewall_rule_group.RuleGroup1.arn
  }
  stateless_rule_group_reference {
    priority = 1
    resource_arn = aws_networkfirewall_rule_group.RuleGroup2.arn
  }
}
}
