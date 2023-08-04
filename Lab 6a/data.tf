data "aws_instance" "Public_Instances_Fleet_1" {
    count = 4
    instance_id = aws_instance.Public_Instances_Fleet_1[count.index].id
}

