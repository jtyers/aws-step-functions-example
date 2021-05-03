# example input:
#
# {
#   "inputCaseID": "001",
#   "statuscode": "200"  # change to 503 or other codes to trigger API call failures
# }
#
module "step_function" {
  source = "terraform-aws-modules/step-functions/aws"

  name = "my-step-function"
  definition = jsonencode({
    Comment = "A simple AWS Step Functions state machine that automates a call center support session.",
    StartAt = "Call API",
    States = {
      "Call API" = {
        Type     = "Task",
        Resource = module.lambda_mock_api.lambda_function_arn,
        Next     = "OK",
        Comment  = "Catch a 429 (Too many requests) API exception, and resubmit the failed request in a rate-limiting fashion.",
        Retry = [{
          ErrorEquals     = ["TooManyRequestsException"],
          IntervalSeconds = 1,
          MaxAttempts     = 2
        }],
        Catch = [
          {
            ErrorEquals = ["TooManyRequestsException"],
            Next        = "Wait and Try Later"
            }, {
            ErrorEquals = ["ServerUnavailableException"],
            Next        = "Server Unavailable"
            }, {
            ErrorEquals = ["States.ALL"],
            Next        = "Catch All"
          }
        ]
      },
      "Wait and Try Later" = {
        Type    = "Wait",
        Seconds = 1,
        Next    = "Change to 200"
      },
      "Server Unavailable" = {
        Type  = "Fail",
        Error = "ServerUnavailable",
        Cause = "The server is currently unable to handle the request."
      },
      "Catch All" = {
        Type  = "Fail",
        Cause = "Unknown error!",
        Error = "An error of unknown type occurred"
      },
      "Change to 200" = {
        Type   = "Pass",
        Result = { "statuscode" : "200" },
        Next   = "Call API"
      },
      OK = {
        Type   = "Pass",
        Result = "The request has succeeded.",
        Next   = "Open Case"
      },
      "Open Case" = {
        Type     = "Task",
        Resource = module.lambda_open_case.lambda_function_arn,
        Next     = "Assign Case"
      },
      "Assign Case" = {
        Type     = "Task",
        Resource = module.lambda_assign_case.lambda_function_arn,
        Next     = "Work on Case"
      },
      "Work on Case" = {
        Type     = "Task",
        Resource = module.lambda_work_on_case.lambda_function_arn,
        Next     = "Is Case Resolved"
      },
      "Is Case Resolved" = {
        Type = "Choice",
        Choices = [
          { Variable = "$.Status", NumericEquals = 1, Next = "Close Case" },
          { Variable = "$.Status", NumericEquals = 0, Next = "Escalate Case" }
        ]
      },
      "Close Case" = {
        Type     = "Task",
        Resource = module.lambda_close_case.lambda_function_arn,
        End      = true
      },
      "Escalate Case" = {
        Type     = "Task",
        Resource = module.lambda_escalate_case.lambda_function_arn,
        Next     = "Fail"
      },
      Fail = {
        Type = "Fail",
      Cause = "Engage Tier 2 Support." }
    }
  })

  service_integrations = {
    lambda = {
      lambda = [
        module.lambda_open_case.lambda_function_arn,
        module.lambda_assign_case.lambda_function_arn,
        module.lambda_work_on_case.lambda_function_arn,
        module.lambda_escalate_case.lambda_function_arn,
        module.lambda_close_case.lambda_function_arn,
        module.lambda_mock_api.lambda_function_arn,
      ]
    }
  }

  type = "STANDARD"
}
