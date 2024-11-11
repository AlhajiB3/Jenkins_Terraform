# Output the public IP of the Jenkins EC2 instance
output "jenkins_instance_public_ip" {
  description = "Public IP of the Jenkins EC2 instance"
  value       = aws_instance.jenkins.public_ip
}

# Output the URL to access Jenkins in the browser
output "jenkins_url" {
  description = "URL to access Jenkins"
  value       = "http://${aws_instance.jenkins.public_ip}:8080"
}

# Output the name of the S3 bucket for Jenkins artifacts
output "s3_bucket_name" {
  description = "Name of the S3 bucket for Jenkins artifacts"
  value       = aws_s3_bucket.jenkins_artifacts.bucket
}
