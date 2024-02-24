#!/bin/bash

# Note: This is a heavily modified version of
# https://github.com/EricZimmerman/Voron-Documentation/blob/main/community/howto/EricZimmerman/BackupConfigToGithub.md

# Set this to true if you want ONLY the history table to be dumped from data.mdb.
history_only=true

grab_version(){
    cd ~
    current_commit=$(git rev-parse --short=7 HEAD)
    m1="on commit: $current_commit"
}

# Here we dump stats database to text format for backup, IF the right software is found
# To RESTORE the database, use the following command:
# mdb_load -f ~/backups/database/data.mdb.backup -s -T ~/printer_data/database/

if command -v /usr/bin/mdb_dump &> /dev/null
then
    if $history_only
    then
        echo "mdb_dump found! Exporting history table from data.mdb to ~/backups/database/data.mdb.backup"
        mdb_dump -s history -n ~/printer_data/database/data.mdb -f ~/backups/database/data.mdb.backup
    else
        echo "mdb_dump found! Exporting ALL tables data.mdb to ~/backups/database/data.mdb.backup"
        mdb_dump -a -n ~/printer_data/database/data.mdb -f ~/backups/database/data.mdb.backup
    fi
else
    echo "mdb_dump not found! Consider installing it via 'sudo apt install lmdb-utils' if you want to back up your statistics database!"
fi

# To fully automate this and not have to deal with auth issues, generate a legacy token on Github
# then update the command below to use the token. Run the command in your base directory and it will
# handle auth. This should just be executed in your shell and not committed to any files or
# Github will revoke the token. =)
# git remote set-url origin https://XXXXXXXXXXX@github.com/EricZimmerman/Voron24Configs.git/
# Note that that format is for changing things after the repository is in use, vs initially

push_config(){
  cd ~
  current_date=$(date +"%Y-%m-%d %T")
  git commit -m "Autocommit from $current_date " -m "$m1"
  git push origin $branch
}

grab_version
push_config
