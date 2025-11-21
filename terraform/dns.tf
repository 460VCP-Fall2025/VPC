#--------------------------------------
#Setting up a DNS for the Load Balancer
#--------------------------------------


resource "aws_route53_zone" "private" {
  name = "local"

  vpc {
    vpc_id = aws_vpc.main.id
  }
}

resource "aws_route53_record" "alb_alias" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "lb.local"
  type    = "A"

  alias {
    name                   = aws_lb.nlb.dns_name
    zone_id                = aws_lb.nlb.zone_id
    evaluate_target_health = true
  }
}


resource "aws_vpc_dhcp_options" "dns" {
  domain_name         = "local"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    Name = "460VPC-dhcp-options"
  }
}

resource "aws_vpc_dhcp_options_association" "dns_assoc" {
  vpc_id          = aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.dns.id
}
