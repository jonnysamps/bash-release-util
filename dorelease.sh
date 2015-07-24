#!/usr/bin/env bash

# Configuration #############
release_script="./release_app.sh"
#############################

# Arguments #################
app_list_file=$1
log_dir=$2
version=$3
#############################

# Colors! ###################
BLACK=`tput setaf 0`
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
MAGENTA=`tput setaf 5`
CYAN=`tput setaf 6`
GRAY=`tput setaf 7`
BOLD=`tput bold`
DIM=`tput dim`
UNDER=`tput smul`
RESET=`tput sgr0`
#############################

# Remember the original working directory
# Change working directory to script dir
ORIG_WD="`pwd`"

#############################
# Validate args and conf ####

# App List
if [ -e "`pwd`/$app_list_file" ] ; then
  app_list_file="`pwd`/$app_list_file"
elif ! [ -e $app_list_file ] ; then
  echo "applist not found: $app_list_file"
  exit
fi

# Log Dir
if [ -d "`pwd`/$log_dir" ] ; then
  log_dir="`pwd`/$log_dir"
elif ! [ -d $log_dir ] ; then
  echo "Logging dir not found: $log_dir"
  exit
fi

# Release script
# Change working directory to script dir to look for the script
cd "$(dirname "$0")"
if [ -e "`pwd`/$release_script" ] ; then
  release_script="`pwd`/$release_script"
else
  cd $ORIG_WD
  if [ -e "`pwd`/$release_script" ] ; then
    release_script="`pwd`/$release_script"
  elif ! [ -e $release_script ] ; then
    echo "Release script not found: $release_script"
    exit
  fi
fi


cd $ORIG_WD
echo "$GREEN$BOLD"
echo "Running Release"
echo "==============================================="
echo "$RESET"
echo "${GRAY}Git Version   : $YELLOW$BOLD $version $RESET"
echo "${GRAY}Log directory : $YELLOW$BOLD $log_dir $RESET"
echo "${GRAY}Release script: $YELLOW$BOLD $release_script $RESET"
echo "${GRAY}App List File : $YELLOW$BOLD $app_list_file $RESET"

i=1
skip_count=0
pids=() # Array of process ids to watch
while read p || [[ -n $p ]]; do
  if [[ $p == *"#"* ]]
  then
    i=$[$i+1]
    skip_count=$[$i+1]
    continue
  fi

  sh $release_script $p $version > $log_dir/$p.log 2>&1 &
  PID=$!
  pids+=($PID)

  i=$[$i+1]
done < $app_list_file

# Bash can't do floating point arithmetic so
# we have to be creative with ints
num_pids=${#pids[@]}
marker_percent=5
pid_div=$((100/marker_percent))
marker=$((num_pids/pid_div))

if [ $marker -eq 0 ] ; then
  marker=num_pids
fi

total_markers=$((num_pids/marker))

echo "${GRAY}Skipping      : $YELLOW$BOLD $skip_count $RESET"
echo "${GRAY}Releasing to  : $YELLOW$BOLD $num_pids $RESET"
echo

prog_count=0
#prints the progress bar
print_progress_bar(){
  echo -ne "["
  counter=0
  echo -ne $GREEN
  while (( $counter < $num_markers )) ; do
    echo -ne "#"
    let counter=counter+1
  done
  while (( $counter < total_markers )) ; do
    echo -ne " "
    let counter=counter+1
  done
  echo -ne "$RESET] - $YELLOW$num_done/$num_pids"

  spinner="\\"
  modulo=$(( prog_count % 4 ))

  case $modulo in
  0)
    spinner="\\" ;;
  1)
    spinner="|" ;;
  2)
    spinner="/" ;;
  3)
    spinner="-" ;;
  esac

  echo -ne "$GRAY$BOLD $spinner $RESET \r"
}

# Checks on the progress of the PIDs that are still alive and
# prints out the progress bar
progress(){
  count=0
  for pid in "${pids[@]}"
  do
    if kill -s 0 $pid > /dev/null 2>&1
    then
      count=$[$count+1]
    fi
  done

  # 5 percent = num_pids / 20

  num_done=$((num_pids-count))
  num_markers=$((num_done/marker))

  print_progress_bar

  if (( $count < 1 )) ; then
    echo
    echo
    exit
  fi

  prog_count=$[$prog_count+1]
}

while true; do
  sleep 0.5
  progress
done
