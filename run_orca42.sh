#! /bin/bash

WEBMAIL="henriquecsj@gmail.com"
FILENAME=$1
NODE=200.164.238.180
USERNAME=cpd
JOBNAME=`echo "$1" | cut -d'.' -f1`
JOBDIR="/tmp/orca_jobs/job-$JOBNAME"

### This section enables an optional automatic login using
### SSH public keys
#####----------------------STARTS HERE------------------------------------------
if ls ~/.ssh/id_rsa.pub 2> /dev/null; then
    echo "You do have a public SSH key :-)"
    echo "Let's use it to make your SSH login automatic? [Y/n]"
    read answer
    if [[ "$answer" =~ ^([yY])+$ ]]
        then
        PUBKEY=$(< ~/.ssh/id_rsa.pub)
        ssh -o StrictHostKeyChecking=no -l $USERNAME $NODE -p 1979 "mkdir -p ~/.ssh; touch ~/.ssh/authorized_keys; echo -e $PUBKEY >> ~/.ssh/authorized_keys" 
    fi
else
    echo "You don't have a public SSH key. :-("
    echo  "Let's create one? [Y/n]"
    read answer2
    echo
    if [[ "$answer2" =~ ^([yY])+$ ]]
        then
            ssh-keygen -t rsa
            echo "Now you have a public SSH key :-)"
            echo "Let's use it to make your SSH login automatic? [Y/n]"
            read answer3
                if [[ "$answer3" =~ ^([yY])+$ ]]
                    then
                        PUBKEY=$(< ~/.ssh/id_rsa.pub)
                        ssh -o StrictHostKeyChecking=no -l $USERNAME $NODE -p 1979 "mkdir -p ~/.ssh; touch ~/.ssh/authorized_keys; echo -e $PUBKEY >> ~/.ssh/authorized_keys" 
                fi
        else
            echo
            echo "Alright, you don't want a SSH key"
    fi
fi
#####----------------------ENDS HERE------------------------------------------


#Logs-in to our node and creates a directory ~/tmp/orca_jobs/job-$JOBNAME (where JOBNAME 
#is extracted from the FILENAME)
ssh -o StrictHostKeyChecking=no -l $USERNAME $NODE -p 1979 "mkdir -p $JOBDIR" 

#Copy our input to ~/tmp/orca_jobs/job-$JOBNAME
scp -P 1979 $FILENAME $USERNAME@$NODE:$JOBDIR

#Sends a mail at the end of the process
ssh -o StrictHostKeyChecking=no -l $USERNAME $NODE -p 1979 "/home/cpd/bin/orca4/orca $JOBDIR/$FILENAME > $JOBDIR/$JOBNAME.out && tar -Jcvf /tmp/orca_jobs/$JOBNAME.tar.xz $JOBDIR && echo "Your calculation for $JOBNAME is done. Come and get it." | mail -s "Calculation $JOBNAME finished" $WEBMAIL" 