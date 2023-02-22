#!/bin/bash

#usage linux_user_creation_script.sh $pass
#pass=<use the secret stored in kv-np-edc-security-001\qualys-linux>
pass=$1
user=qualys

if [[ "$user" = "" ]]
then
  echo "\$user is empty"
  exit 1
fi
if [[ "$pass" = "" ]]
then
  echo "\$pass is empty"
  exit 1
fi

if [[ ! $(id $user) ]]
then
  echo $?
  echo "adding user '$user'"
  salt="$(openssl rand -base64 12)""$(echo $RANDOM | md5sum | head -c 12; echo;)"
  sudo useradd -p "$(openssl passwd -1 -salt "$salt" "$pass")" "$user"
else
  echo "user '$user' already added - updating password"
  salt="$(openssl rand -base64 12)""$(echo $RANDOM | md5sum | head -c 12; echo;)"

  if sudo usermod -p "$(openssl passwd -1 -salt "$salt" "$pass")" "$user"
  then
    echo "password updated"
  else
    echo "ERROR - password updated failed"
    exit 1
  fi
fi

# Take a backup of sudoers file and change the backup file.

sudo cp /etc/sudoers /tmp/sudoers.bak

#echo '=== BEFORE > ================='
#sudo grep "^$user" /tmp/sudoers.bak
#echo '=== < BEFORE ================='
#echo ''

lines=("$user ALL=(root) NOPASSWD: ALL")

for line in "${lines[@]}"; do
  lineExpression="$(echo -n "$line" | sed 's/\*/\\*/g')"
  if grep '^'"$lineExpression"'$' /tmp/sudoers.bak
  then
    echo "line '$line' already in sudoers file."
  else
    echo "adding line '$line'"
    echo "$line" | sudo tee -a /tmp/sudoers.bak
  fi
done

#echo '=== AFTER > ================='
#sudo grep "^$user" /tmp/sudoers.bak
#echo '=== < AFTER ================='
#echo ''

# Check syntax of the backup file to make sure it is correct.



if sudo visudo -cf /tmp/sudoers.bak
then

  # Replace the sudoers file with the new only if syntax is correct.

  sudo cp /tmp/sudoers.bak /etc/sudoers

else

  echo "Could not modify /etc/sudoers file. Please do this manually."

fi
