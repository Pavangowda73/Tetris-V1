resource "aws_iam_role" "ec2-role"{
    name = "ec2-role"
    assume_role_policy = <<EOF
    {
         "Version": "2012-10-17",
        "Statement": [
       {
          "Effect": "Allow",
          "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
       ]
    }
EOF
}

resource "aws_iam_role_policy_attachment" "policy1"{
    role = aws_iam_role.ec2-role.name
    policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "ec2-profile" {
  name = "ec2-profile"
  role = aws_iam_role.ec2-role.name
}

resource "aws_security_group" "ec-sg"{
    name = "ec2-sg"
    description = "port for 22,80,443,8080,9000,3000"

    ingress = [ 
        for port in [22,80,443,8080,9000,3000] : {
            description = "for multiple ports"
            from_port = port
            to_port = port
            protocol = "tcp"
            cidr_blocks = [ "0.0.0.0/0" ]
            ipv6_cidr_blocks = [ ]
            self = false
            prefix_list_ids = []
            security_groups = []
        }
     ]

     egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
     }

     tags={
        Name = "ec2-sg"
     }
}

resource "aws_instance" "instance"{
    ami = "ami-09b0a86a2c84101e1"
    instance_type = "t2.large"
    key_name = "pavan"
    vpc_security_group_ids = [ aws_security_group.ec-sg.id ]
    user_data = templatefile("./install_jenkins.sh",{})
    iam_instance_profile = aws_iam_instance_profile.ec2-profile.name

    root_block_device {
      volume_size = 30
    }

    tags={
        Name = "Jenskins-EC2"
    }
}
