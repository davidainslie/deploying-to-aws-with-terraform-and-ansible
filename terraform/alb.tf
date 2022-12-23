resource "aws_lb" "app-lb" {
  provider = aws.region-master
  name = "jenkins-lb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.lb-sg.id]
  subnets = [aws_subnet.subnet-1.id, aws_subnet.subnet-2.id]

  tags = {
    Name = "jenkins-lb"
  }
}

resource "aws_lb_target_group" "app-lb-tg" {
  provider = aws.region-master
  name = "app-lb-tg"
  port = var.webserver-port
  target_type = "instance"
  vpc_id = aws_vpc.vpc-master.id
  protocol = "HTTP"

  health_check {
    enabled = true
    interval = 10
    path = "/"
    port = var.webserver-port
    protocol = "HTTP"
    matcher = "200-299"
  }

  tags = {
    Name = "jenkins-tg"
  }
}

/*
Original version - Without ACM certificate we just forwarded to port 80 of our app - Now we will redirect to port 443
resource "aws_lb_listener" "jenkins-listener-http" {
  provider = aws.region-master
  load_balancer_arn = aws_lb.app-lb.arn
  port = var.webserver-port
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.app-lb-tg.id
  }
}
*/
resource "aws_lb_listener" "jenkins-listener-http" {
  provider = aws.region-master
  load_balancer_arn = aws_lb.app-lb.arn
  port = var.webserver-port
  protocol = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

/* With the new version above to redirect, we now need a listener for port 443 */
resource "aws_lb_listener" "jenkins-listener-https" {
  provider = aws.region-master
  load_balancer_arn = aws_lb.app-lb.arn
  ssl_policy = "ELBSecurityPolicy-2016-08"
  port = "443"
  protocol = "HTTPS"
  certificate_arn = aws_acm_certificate.jenkins-lb-https.arn

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.app-lb-tg.id
  }
}

resource "aws_lb_target_group_attachment" "jenkins-master-attachment" {
  provider = aws.region-master
  target_group_arn = aws_lb_target_group.app-lb-tg.arn
  target_id = aws_instance.jenkins-master.id
  port = var.webserver-port
}

output "lb-dns-name" {
  value = aws_lb.app-lb.dns_name
}