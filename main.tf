provider "aws" {
  region = "us-east-1" # You can change this if needed
}

resource "random_id" "bucket_id" {
  byte_length = 8
}

# Generate an SSH Key Pair
resource "tls_private_key" "jenkins_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Save the private key to a local file
resource "local_file" "jenkins_private_key" {
  content  = tls_private_key.jenkins_key.private_key_pem
  filename = "/Users/alhajib/Jenkins-project/JenkinsKey.pem"
}

# Use the public key for the AWS Key Pair
resource "aws_key_pair" "jenkins_key" {
  key_name   = "JenkinsKey"
  public_key = tls_private_key.jenkins_key.public_key_openssh
}

# Security Group for Jenkins
resource "aws_security_group" "jenkins_sg" {
  name_prefix = "jenkins-sg"
  description = "Security group for Jenkins"
  vpc_id      = "vpc-0601b102bb3b5b175" # Replace with your VPC ID

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["96.231.150.247/32"] # Replace with your IP address
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open to all for Jenkins web UI
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance for Jenkins using Amazon Linux AMI
resource "aws_instance" "jenkins" {
  ami                    = "ami-063d43db0594b521b"           # Amazon Linux 2 AMI
  instance_type          = "t2.micro"                        # EC2 Instance Type
  key_name               = aws_key_pair.jenkins_key.key_name # Reference to the AWS Key Pair
  subnet_id              = "subnet-0879ea7991028b248"        # Your subnet ID
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

}


# S3 bucket for Jenkins artifacts
resource "aws_s3_bucket" "jenkins_artifacts" {
  bucket = "jenkins-artifacts-${random_id.bucket_id.hex}"
}

# S3 bucket policy to deny non-HTTPS requests
resource "aws_s3_bucket_policy" "jenkins_artifacts_policy" {
  bucket = aws_s3_bucket.jenkins_artifacts.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.jenkins_artifacts.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.jenkins_artifacts.bucket}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}
