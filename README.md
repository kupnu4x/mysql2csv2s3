# tl;dr
```bash
cp .env.example .env
vi .env
crontab -e
```
```cron
* * * * * cd /opt/etl; docker-compose up
```

# build
```bash
docker build . -t mydockertag/etl
docker push mydockertag/etl
```

# docker run
```bash
docker pull mydockertag/etl
docker run --rm --name test \
    -e MYSQL_HOST=172.17.0.1 \
    -e MYSQL_USER=<some_data> \
    -e MYSQL_PWD=<some_data> \
    -e MYSQL_DBNAME=test \
    -e MYSQL_QUERY="select * from test.test;" \
    -e S3_FILE_PATH=s3://mys3bucket/mypath/testdump-$(date -u +%Y%m%d-%H%M%S).gz \
    -e S3_ACCESS_KEY=<some_data> \
    -e S3_SECRET_KEY=<some_data> \
    -e S3_HOST=s3.amazonaws.com \
    -e S3_HOST_BUCKET="%(bucket)s.s3.amazonaws.com" \
    -e EMAIL_HOST=172.17.0.1 \
    -e EMAIL_FROM=info@example.com \
    -e EMAIL_TO=alice@example.com,bob@example.com \
    -ti mydockertag/etl
```
# docker-compose
```bash
cp .env.example .env
vi .env
docker-compose up
```
