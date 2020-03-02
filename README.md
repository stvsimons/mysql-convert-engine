# Check and Convert MySQL database tables to InnoDB or MyISAM

Lists and/or changed database tables from InnoDB to MyISAM or MyISAM to InnoDB.


## Requires
* bash or sh
* mysql

## Installation
Clone or copy repo, run shell 'sh mysql-convert-engine.sh --all' or options/database.

## Usage
`$ sh <path-to>/mysql-convert-engine.sh <options> <databases>

**-e, --engine <path>**  
Engine to convert database tables to. Must be 'InnoDB' or 'MyISAM' (case insensitive). If no engine is provided will only display Engine Type.

**-a, --all**  
All databases (skips mysql, performance_schema, and information_schema).

**-n, --no-backup**  
Default when converting is to create database backup in working directory.
