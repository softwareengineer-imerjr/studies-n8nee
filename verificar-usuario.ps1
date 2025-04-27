$sql = "SELECT * FROM ""user"" WHERE email='maria@example.com';"
docker-compose exec db psql -U n8n -d n8n -c $sql
