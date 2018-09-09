#!/bin/bash

HOME_DIR=$HOME
DROPBOXES=("$HOME" "$HOME/.dropbox-teh")
function start_dropbox() {
  HOME=$HOME_DIR
  local flag
  local home_dir
  local OPTIND;
  local verbose=0
  local wait=0

  while getopts p:vw opt; do
    case $opt in
      p) home_dir="$(echo $OPTARG | sed 's:/*$::')/" ;;
      v) verbose=1 ;;
      w) wait=1 ;;
      *) ;;
    esac
  done
  shift $((OPTIND-1))

  # Test if the process is already running
  local pid=$(ps aux|grep "${home_dir}.dropbox-dist"|grep -v 'grep'|tr -s ' '| cut -d' ' -f 2)
  if [ -n "$pid" ]
  then
    echo "Process already running with home dir. of: $home_dir"
    return 8 # Process already running
  fi

  # Create home directory if it doesn't exist
  if [ ! -e "$home_dir" ]
  then
    if mkdir -p "$home_dir";
    then
      echo "Created directory: $home_dir"
    else
      echo "Failed to create directory: $home_dir"
      return 9 # Failed
    fi
  fi

  # Set up so works with GUI from command line
  xauthority="${home_dir}.Xauthority"
  if [ ! -e "$xauthority" ]
  then
    ln -s "$HOME/.Xauthority" "$xauthority"
  fi

  HOME="$home_dir"

  # Start the dropbox daemon
  if [[ $verbose -gt 0 ]]; then
    echo '~/.dropbox-dist/dropboxd & '$home_dir
  fi
  ~/.dropbox-dist/dropboxd &
  if [[ $wait -eq 0 ]]; then
    sleep 2 # Give each instance time to startup completely before starting another one
  else
    read -n 1 -s -p 'Press any key to continue.'
    echo
  fi
}

function start_dropboxes() {
  local dropbox

  for dropbox in "${DROPBOXES[@]}"
  do
    start_dropbox $@ -p "$dropbox"
  done
}

#
# For testing & setup we can choose just one to startup
#
while getopts f:wv opt; do
  case $opt in
    f) start_dropbox -p "${DROPBOXES[$OPTARG]}" # NOTE: bash array indexes start at 0.
       exit ;;
    *) ;;
  esac
done
OPTIND=1

start_dropboxes $@
