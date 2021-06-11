# Deploy API docker image
cd ./booksService &&
./deploy_books_service.sh &&

# Deploy Frontend docker image
cd ../usersService &&
./deploy_users_service.sh &&

# Deploy to cloud host (default AWS)
cd ../devops/aws &&
terraform apply