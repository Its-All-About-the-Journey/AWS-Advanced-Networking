data "aws_instance" "Public_Instances_Fleet_1" {
  count       = 2
  instance_id = aws_instance.Public_Instances_Fleet_1[count.index].id
}

data "aws_instance" "Public_Instances_Fleet_2" {
  count       = 2
  instance_id = aws_instance.Public_Instances_Fleet_2[count.index].id
}

data "aws_lb" "My_ALB" {
  count = 2
  arn   = aws_lb.My_ALB[count.index].arn
}

data "aws_lb_target_group" "HTTP" {
  count = 2
  arn = aws_lb_target_group.HTTP[count.index].arn
}

data "aws_lb_listener" "HTTP" {
  count = 2
  arn   = aws_lb_listener.HTTP[count.index].arn
}

data "aws_cloudfront_distribution" "ALB_distribution" {
  id = aws_cloudfront_distribution.ALB_distribution.id
}

data "aws_s3_bucket" "Logs_Bucket" {
  bucket = aws_s3_bucket.Logs_Bucket.id
}

