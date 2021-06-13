[
  {
    "name": "${service_name}",
    "image": "${image}",
    "cpu": ${fargate_cpu},
    "memory": ${fargate_memory},
    "entryPoint": [],
    "environment": [],
    "portMappings": [
      {
        "hostPort": ${container_port},
        "containerPort": ${container_port},
        "protocol": "tcp"
      }
    ],
    "volumesFrom": [],
    "links": [],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "${aws_logs_group}",
            "awslogs-region": "${aws_region}",
            "awslogs-stream-prefix": "ecs"
        }
    },
    "essential": true
  }
]