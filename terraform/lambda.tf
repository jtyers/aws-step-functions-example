module "lambda_open_case" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "open-case"
  handler       = "index.handler"
  runtime       = "nodejs14.x"

  source_path = "../src/open-case"
}

module "lambda_assign_case" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "assign-case"
  handler       = "index.handler"
  runtime       = "nodejs14.x"

  source_path = "../src/assign-case"
}

module "lambda_work_on_case" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "work-on-case"
  handler       = "index.handler"
  runtime       = "nodejs14.x"

  source_path = "../src/work-on-case"
}

module "lambda_close_case" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "close-case"
  handler       = "index.handler"
  runtime       = "nodejs14.x"

  source_path = "../src/close-case"
}

module "lambda_escalate_case" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "escalate-case"
  handler       = "index.handler"
  runtime       = "nodejs14.x"

  source_path = "../src/escalate-case"
}

module "lambda_mock_api" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "mock-api"
  handler       = "index.handler"
  runtime       = "python3.8"

  source_path = "../src/mock-api"
}
