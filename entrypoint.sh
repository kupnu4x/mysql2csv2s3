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
  echo "    EMAIL_HOST"
  echo "    EMAIL_FROM"
  echo "    EMAIL_TO"
}
mail(){
  subj=$1
  body=$2
  echo "To: ${EMAIL_TO}
From: ${EMAIL_FROM}
Subject: ${subj}

${body}" | msmtp --EMAIL_FROM="${EMAIL_FROM}" --EMAIL_HOST="${EMAIL_HOST}" "${EMAIL_TO}"
}
if [[ -z "${MYSQL_HOST}" || \
  -z "${MYSQL_USER}" || \
  -z "${MYSQL_QUERY}" || \
  -z "${S3_FILE_PATH}" || \
  -z "${S3_ACCESS_KEY}" || \
  -z "${S3_SECRET_KEY}" || \
  -z "${EMAIL_HOST}" || \
  -z "${EMAIL_FROM}" || \
  -z "${EMAIL_TO}" ]]; then
  usage
  mail "etl error" "not all required vars are set"
  exit 1
fi
if [[ -z "${S3_HOST}" ]]; then
  S3_HOST=s3.amazonaws.com
fi
if [[ -z "${S3_HOST_BUCKET}" ]]; then
  S3_HOST_BUCKET="%(bucket)s.s3.amazonaws.com"
fi

LOGFILE=$(mktemp)
#MYSQL_HOST,MYSQL_PWD EMAIL_FROM env
mysql -u "${MYSQL_USER}" "${MYSQL_DBNAME}" -e 'quit' >>"${LOGFILE}" 2>&1
if [ $? -ne 0 ]; then
  mail "etl error" "cant connect to mysql. some info:
$(cat "${LOGFILE}")"
  cat "${LOGFILE}"
  exit 1
fi
DATAFILE=$(mktemp)
mysql -u "${MYSQL_USER}" "${MYSQL_DBNAME}" -B -s -e "${MYSQL_QUERY}" >"${DATAFILE}" 2>>"${LOGFILE}"
if [ $? -ne 0 ]; then
  mail "etl error" "error doing query. some info:
$(cat "${LOGFILE}")"
  cat "${LOGFILE}"
  exit 1
fi

sed -e 's/"/""/g' -e "s/\t/\",\"/g;s/^/\"/;s/$/\"/" -e 's/\\t/ /g;s/\\n/\n/g' "${DATAFILE}" | \
gzip | \
s3cmd put - "${S3_FILE_PATH}" \
  --access_key="${S3_ACCESS_KEY}" \
  --secret_key="${S3_SECRET_KEY}" \
  --host="${S3_HOST}" \
  --host-bucket="${S3_HOST_BUCKET}" >>"${LOGFILE}" 2>&1
if [ $? -ne 0 ]; then
  mail "etl error" "error doing upload. some info:
$(cat "${LOGFILE}")"
  cat "${LOGFILE}"
  exit 1
fi

cat "${LOGFILE}"
rm -rf "${LOGFILE}" "${DATAFILE}"
