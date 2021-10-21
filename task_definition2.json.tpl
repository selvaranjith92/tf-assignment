[
    {
        "essential": true,
        "memory": 512,
        "name": "backend",
        "cpu": 256,
        "image": "486526169498.dkr.ecr.ap-south-1.amazonaws.com/redis:latest",
        "networkMode" : "awsvpc",
        "portMappings" : [
        {
          "containerPort" : 6379,
          "protocol" : "tcp",
          "hostPort" : 6379
          }
        ]
    }
]