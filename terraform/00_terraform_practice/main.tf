resource "aws_s3_bucket" "demo" {
  bucket = "my-terra-b"
}

output "welcome"{
    value = "Hello terra"
}