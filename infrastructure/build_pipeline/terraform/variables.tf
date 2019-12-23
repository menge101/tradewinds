variable "project_name" {
  type = string
  default = "tradewinds-ci"
}

variable "region" {
  type    = string
  default = "us-east-2"
}

variable "profile" {
  type = string
}

variable "cred_file" {
  type = string
}

variable "pg_db_username" {
  type = string
  default = "postgres"
}

variable "pg_db_password" {
  type = string
  default = "postgres"
}

variable "pg_db_name" {
  type = string
  default = "TradewindsCi"
}

variable "skip_snapshot" {
  type = bool
  default = true
}

variable "final_snapshot_id" {
  type = string
  default = "none"
}

variable "instance_class" {
  type = string
  default = "db.t2.micro"
}

variable "pg_version" {
  type = string
  default = "11.5"
}

variable "deletion_protection" {
  type = bool
  default = false
}

variable "identifier" {
  type = string
  default = "tradewinds-ci"
}

variable "auth0_domain" {
  type = string
  default = "example.auth0.com"
}

variable "auth0_client_id" {
  type = string
  default = "an auth0 client id"
}

variable "auth0_client_secret" {
  type = string
  default = "an auth0 client secret"
}

variable "codebuild_prefix" {
  type = string
  default = "347157418948.dkr.ecr.us-east-2.amazonaws.com"
}
variable "codebuild_image" {
  type = string
  default = "tradewinds/codebuildimage"
}

variable "codebuild_image_version" {
  type = string
  default = "0.1"
}
