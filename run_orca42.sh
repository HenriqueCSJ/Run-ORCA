#! /bin/bash

WEBMAIL="henriquecsj@gmail.com"
FILENAME=$1
NODE=$2
USERNAME=$3
JOBNAME=`echo "$1" | cut -d'.' -f1`
JOBDIR="~/tmp/orca_jobs/job-$JOBNAME"

# if ls ~/.ssh/id_rsa.pub; then
#     echo "You do have a public SSH key :-)"
#     read -p "Let's use it to make your SSH login automatic? [Y/n]" -n 1 -r
#     echo
#     if [[ ! $REPLY =~ ^[Yy]$ ]]
#     then
#         ssh-keygen -t rsa
#     fi
# else
#     echo "You don't have a public SSH key. :-("
#     echo 
#     read -p "Let's create one?" -n 1 -r
#     echo
#     if [[ ! $REPLY =~ ^[Yy]$ ]]
#     then
#         ssh-keygen -t rsa
#     fi
# fi

#Logs-in to our node and creates a directory ~/tmp/orca_jobs/job-$JOBNAME (where JOBNAME 
#is extracted from the FILENAME)
ssh -o StrictHostKeyChecking=no -l $USERNAME $NODE "mkdir -p $JOBDIR"

#Copy our input to ~/tmp/orca_jobs/job-$JOBNAME
scp $FILENAME $USERNAME@$NODE:$JOBDIR

#Sends a mail at the end of the process
orca4 $FILENAME > $JOBNAME.out && tar -Jcvf $JOBNAME.tar.xz $JOBDIR; echo "Your calculation for $JOBNAME is done. Come and get it." | mail -s "Calculation $JOBNAME finished" $WEBMAIL