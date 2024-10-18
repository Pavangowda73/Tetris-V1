terraform{
    backend "s3" {
      bucket = "firstpavans3bucket2024"
      key = "Jenkins/terraform.tfstate"
      region = "ap-south-1"
    }
}