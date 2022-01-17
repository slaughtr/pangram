aws_region = "us-west-2"
name = "pangram"
tags = {Name: "pangram", Use: "demo"}
api_description = "API that accepts a string and returns whether or not it is a pangram"
stage_name = "v0"
api_path_part = "{pangram+}"
lambda_timeout = 3
lambda_memory = 128
lambda_handler = "index.handler"
lambda_runtime = "nodejs12.x"