#!/bin/sh

usage()
{
    BASENAME=$(basename $0)
    echo "Usage: $BASENAME [-u githubusername ] [ -p githubpersonalaccesstoken ]"
    echo
    echo "Requirements:"
    echo " - Must be in a git repo"
    echo " - Must have access to curl, git, sed and grep"
    exit 2
}

while getopts 'u:p:?h' o
do
  case $o in
    u) GHUSER="$OPTARG";;
    p) GHPAT="$OPTARG";;
    h|?) usage;;
  esac
done

if [ -n "$GHUSER" ] && [ -z "$GHPAT" ]; then
    echo "Fatal: Username specified without PAT"
    exit 1
fi

if [ -n "$GHPAT" ] && [ -z "$GHUSER" ]; then
    echo "Fatal: PAT specified without username"
    exit 1
fi

COMMANDS="git grep curl sed"
for COMMAND in $COMMANDS; do
  if [ ! $(command -v $COMMAND) ]; then
    echo "Fatal: Could not find '$COMMAND' command. Is it installed?"
    exit 1
  fi
done

INSIDEGITWORKTREE=$(git rev-parse --is-inside-work-tree)
if [ "$INSIDEGITWORKTREE" = "false" ]; then
    echo "Fatal: Not inside git work tree"
    exit 1
fi

ORIGINDOMAIN=$(git remote -v | grep origin | head -n1 | cut -d/ -f3)
if [ "$ORIGINDOMAIN" != "github.com" ]; then
    echo "Fatal: origin is not github.com"
    exit 1
fi

REPONAME=$(git remote -v | grep origin | head -n1 | cut -d/ -f5 | cut -d' ' -f1 | sed s/\.git//)
if [ -z $REPONAME ]; then
    echo "Fatal: Could not determine the repo name"
    exit 1
fi
echo "Repo name: $REPONAME"

REPOUSER=$(git remote -v | grep origin | head -n1 | cut -d/ -f4)
if [ -z $REPOUSER ]; then
    echo "Fatal: Could not determine the repo user/org"
    exit 1
fi
echo "Repo user: $REPOUSER"

if [ -n "$GHPAT" ] && [ -n "$GHUSER" ]; then
    echo "Using git credentials specified on command line"
    CREDENTIALS="$GHUSER:$GHPAT"
else
    if [ -e $HOME/.git-credentials ]; then
        echo "Trying to get git credentials from ~/.git-credentials"
        CREDENTIALS=$(grep @github.com ~/.git-credentials | cut -d/ -f3 | cut -d@ -f1)
    fi
fi

if [ -z $CREDENTIALS ]; then
    echo "Fatal: Could not determine git credentials"
    exit 1
fi
    
curl -u "$CREDENTIALS" -H "Accept: application/vnd.github.everest-preview+json"  -H "Content-Type: application/json" https://api.github.com/repos/$REPOUSER/$REPONAME/dispatches --data '{"event_type": "activity-logs"}'
if [ $? -eq 0 ]; then
    echo 'Successfully sent repository dispatch'
else
    echo 'Non-zero exit code from curl command'
fi

exit $?
