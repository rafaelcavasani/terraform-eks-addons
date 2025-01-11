# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_access_key_id" {
  description = "AWS acces key id"
  type        = string
}

variable "aws_secret_access_key" {
  description = "AWS secret acces key"
  type        = string
}
