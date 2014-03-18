#!/bin/sh
 
SCRIPT_DIRIRECTORY="$( cd "$( dirname "$0" )" && pwd )"
PROJECT_DIRIRECTORY=$SCRIPT_DIRIRECTORY/..


#   ----------------------------------------------------------------
#   Function for exit due to fatal program error
#     Accepts 1 argument:
#       string containing descriptive error message
#   ----------------------------------------------------------------
error_exit () {
  PROGNAME=$(basename $0)
  echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
  exit 1
}

MONITORED_DIRECTORY=$PROJECT_DIRIRECTORY/test/monitored
DATA_DIRECTORY=$PROJECT_DIRIRECTORY/test/data

# Throw exception if monitored directory doesn't exist
if [ ! -d "$MONITORED_DIRECTORY" ]; then
  error_exit "monitored directory ($MONITORED_DIRECTORY) does not exist"
fi

# Create data directory if it doesn't exist
if [ ! -d "$DATA_DIRECTORY" ]; then
  mkdir -p $DATA_DIRECTORY

  # Initialize an empty git repository to track changes
  git init $DATA_DIRECTORY --quiet
fi

# Copy files from the monitored directory to the data directory
rsync -av --quiet $MONITORED_DIRECTORY/* $DATA_DIRECTORY --exclude=.git --exclude=.gitignore --exclude=.gitmodules

# Save changes in the monitored directory to a variable FILES_CHANGED
cd $DATA_DIRECTORY;
FILES_CHANGED=`git status --porcelain | wc -l`;

# Check if something has changed
if [ "$FILES_CHANGED" -gt 0 ]; then
  # Print out changes information
  echo "Changes:"
  git status --porcelain

  # Add all files
  git add -A

  # Commit changes with a message equal to the current timestamp followed by a human readable date
  git commit -m "Commit changes for `date +"%s-%y%m%d %T"`" --quiet

  exit 0
else
  echo "No changes found"
  exit 0
fi