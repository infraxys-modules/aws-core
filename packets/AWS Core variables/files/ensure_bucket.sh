#!/usr/bin/env bash

set -euo pipefail;

ensure_bucket_exists --bucket "$aws_core_s3_state_bucket" --region "$aws_core_region";
