#/bin/sh

set -e
test $PROJECT_NAME
test $GIT_HEAD_REV
test $TASK_ID

version=$(cat version.txt)

cat > version.json <<EOF
{
    "commit": "${GIT_HEAD_REV}",
    "version": "${version}",
    "source": "https://github.com/mozilla-releng/${PROJECT_NAME}script",
    "build": "https://tools.taskcluster.net/tasks/${TASK_ID}"
}
EOF
