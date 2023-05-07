terraform {
  required_version = ">= 1.4.5"

  required_providers {
	aws = {
		source = "hashicorp/aws"
		version = ">= 4.66.0"
	}
	archive= {
		source = "hashicorp/archive"
		version = ">= 2.3.0"
	}
	random = {
		source = "hashicorp/random"
		version = ">= 3.5.1"
	}
  }
}
