resource "aws_api_gateway_vpc_link" "ecs-vpc-link" {
  name        = "vpc-link-ecs"
  target_arns = [aws_lb.nlb.arn]
}

resource "aws_api_gateway_rest_api" "ecs-rest-api" {
  name = "api-gateway-ecs"
}

resource "aws_api_gateway_resource" "ecs-api-resource" {
  rest_api_id = aws_api_gateway_rest_api.ecs-rest-api.id
  parent_id   = aws_api_gateway_rest_api.ecs-rest-api.root_resource_id
  path_part   = "index.html"
}

resource "aws_api_gateway_method" "ecs-gateway-method" {
  rest_api_id   = aws_api_gateway_rest_api.ecs-rest-api.id
  resource_id   = aws_api_gateway_resource.ecs-api-resource.id
  http_method   = "ANY"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "ecs-gw-integration" {
  rest_api_id = aws_api_gateway_rest_api.ecs-rest-api.id
  resource_id = aws_api_gateway_resource.ecs-api-resource.id
  http_method = aws_api_gateway_method.ecs-gateway-method.http_method
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
  type                    = "HTTP_PROXY"
  uri                     = "http://${aws_lb.nlb.dns_name}:80/{proxy}"
  integration_http_method = var.integration_http_method
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.ecs-vpc-link.id
}

resource "aws_api_gateway_deployment" "ecs-gw-deploy" {
  rest_api_id = aws_api_gateway_rest_api.ecs-rest-api.id
  stage_name = "${var.environment}-env"
  depends_on = [aws_api_gateway_integration.ecs-gw-integration]
  variables = {
    # just to trigger redeploy on resource changes
    resources = join(", ", [aws_api_gateway_resource.ecs-api-resource.id])
    # note: redeployment might be required with other gateway changes.
    # when necessary run `terraform taint <this resource's address>`
  }
}

