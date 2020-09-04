#!/bin/bash
usage(){
  echo "please set following env variables: "
  echo "    MYSQL_HOST"
  echo "    MYSQL_USER"
  echo "    MYSQL_PWD"
  echo "    MYSQL_DBNAME"
  echo "    MYSQL_QUERY (like 'select * from test.test;')"
  echo "    S3_FILE_PATH (like s3://test-sbermarket/mypath/testdump-$(date -u +%Y%m%d-%H%M%S).gz)"
  echo "    S3_ACCESS_KEY"
  echo "    S3_SECRET_KEY"
  echo "    S3_HOST (like s3.amazonaws.com)"
  echo "    S3_HOST_BUCKET (like %(bucket)s.s3.amazonaws.com)"
}
if [[ -z "${MYSQL_HOST}" || -z "${MYSQL_USER}" || -z "${MYSQL_QUERY}" || -z "${S3_FILE_PATH}" || -z "${S3_ACCESS_KEY}" || -z "${S3_SECRET_KEY}" ]]; then
  usage
  exit 1
fi
if [[ -z "${S3_HOST}" ]]; then
  S3_HOST=s3.amazonaws.com
fi
if [[ -z "${S3_HOST_BUCKET}" ]]; then
  S3_HOST_BUCKET="%(bucket)s.s3.amazonaws.com"
fi

#MYSQL_HOST,MYSQL_PWD from env
mysql -u "${MYSQL_USER}" "${MYSQL_DBNAME}" -B -s -e "${MYSQL_QUERY}" | \
  sed -e 's/"/""/g' -e "s/\t/\",\"/g;s/^/\"/;s/$/\"/" -e 's/\\t/\t/g;s/\\n/\n/g' | \
  gzip | \
  s3cmd put - "${S3_FILE_PATH}" \
    --access_key="${S3_ACCESS_KEY}" \
    --secret_key="${S3_SECRET_KEY}" \
    --host="${S3_HOST}" \
    --host-bucket="${S3_HOST_BUCKET}"
