#!/bin/bash

DBS=()
NOBK=
ENGINE=
MYSQL_PATH=mysql

get_usage() {
  if [ -n "$1" ]; then
    echo "Error: $1"
    echo
  fi
  echo "Usage: %0 <options> <database1> [<database2> ...]"
  echo "-e, --engine <(MyISAM|InnoDB)>   Engine Type. In no Engine Type is provided, will only display Engine Type of each table."
  echo "-n, --no-backup                  Do not create backup before converting (default is <db>-<table>.sql created in working directory)."
  echo "-a, --all                        All databases."
}

if [ $# -gt 0 ]; then
  args=`getopt -o e:na --long engine:,no-backup,all "$@"`
  eval "set -- $args"
else
  get_usage "No arguments passed"
  exit 1
fi

while [ $# -gt 0 ]; do
  case "$1" in
    -e|--engine)
      ENGINE=$2
      shift
      ;;

    -n|--no-backup)
      NOBK=liveDangerous
      ;;

    -a|--all)
      DBS=`echo show databases | $MYSQL_PATH | grep -v Database`;
      ;;

    --)
      ;;

    *)
      DBS=("${DBS[@]}" $1)
      ;;
  esac
  shift
done

# Need a database or two
if [ "${#DBS[@]}" -eq 0 ]; then
  get_usage "No Database selected to convert."
  exit 1
fi

# Clean engine case
if [ `echo "$ENGINE" | tr '[:upper:]' '[:lower:]'` = "myisam" ]; then
  ENGINE=MyISAM
fi
if [ `echo "$ENGINE" | tr '[:upper:]' '[:lower:]'` = "innodb" ]; then
  ENGINE=InnoDB
fi


for db in $DBS; do
  if [ $db = "mysql" -o $db = "information_schema" -o $db = "performance_schema" ]; then
    continue;
  fi

  tables=`echo show tables | $MYSQL_PATH $db | grep -v Tables_in_`
  if [ $? -ne 0 ]; then
    continue
  fi

  ts=`date +"%Y%m%d-%H%m%S"`
  for table in $tables; do
    ttype=`echo show create table $table | $MYSQL_PATH $db | sed -e's/.*ENGINE=\([[:alnum:]\]\+\)[[:space:]].*/\1/'|grep -v 'Create Table'`
    echo -n "Type: $ttype, Db: $db, Table: $table"
    if [ -n "$ENGINE" -a ! $ttype = "$ENGINE" ]; then
      echo -n " Converting to $ENGINE... "
      if [ -z "$NOBK" ]; then

        mysqldump --opt $db $table > "$db-$table.$ts.sql"
      fi
      echo "ALTER TABLE \`$db\`.\`$table\` ENGINE = $ENGINE" | $MYSQL_PATH $db
      echo -n "Done"
    fi
    echo
  done
done

