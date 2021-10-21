[
    {
        "essential": true,
        "memory": 512,
        "name": "worker",
        "cpu": 256,
        "image": "486526169498.dkr.ecr.ap-south-1.amazonaws.com/worker:latest",
        "networkMode" : "awsvpc",
        "portMappings" : [
           {
             "containerPort" : 80,
             "protocol" : "tcp",
             "hostPort" : 80
           }
        ],
        "logConfiguration": {
           "logDriver": "awslogs",
           "options": {
             "awslogs-group": "ecs/test-worker",
             "awslogs-region": "ap-south-1",
             "awslogs-stream-prefix": "ecs"
           }
        }
    }
]