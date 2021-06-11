# Deploy books API docker image
cd ./services/booksService &&
./deploy_books_service.sh &&

# Deploy users API docker image
cd ../usersService &&
./deploy_users_service.sh &&

# Deploy to cloud host (default AWS)
cd ../../devops/aws/ecs_fargate &&
terraform apply