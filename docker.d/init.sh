#!/bin/bash
set -e

export ARTIFACTS_DIR=/app/artifacts
export CONFIG_DIR=/app/configs
export CONFIG_LOADER=/app/bin/configloader
export ED25519_PRIVKEY_PATH=$CONFIG_DIR/ed25519_privkey
export LOGS_DIR=/app/logs
export SCRIPTWORKER=/app/bin/scriptworker
export TASK_CONFIG=$CONFIG_DIR/worker.json
export TASK_LOGS_DIR=$ARTIFACTS_DIR/public/logs
export TEMPLATE_DIR=/app/docker.d
export WORK_DIR=/app/workdir

# == START: this is what we need to configure ==
test $PROJECT_NAME
test $ENV
test $COT_PRODUCT
test $TASKCLUSTER_CLIENT_ID
test $TASKCLUSTER_ACCESS_TOKEN
if [ "$ENV" == "prod" ]; then
  test $ED25519_PRIVKEY
fi
# == END:   this is what we need to configure ==

export PROVISIONER_ID=scriptworker-k8s-v1
export WORKER_GROUP="${PROJECT_NAME}script-${COT_PRODUCT}-${ENV}-v1"
export WORKER_TYPE="${PROJECT_NAME}script-${COT_PRODUCT}-${ENV}-v1"
export WORKER_ID_PREFIX="${PROJECT_NAME}script-${COT_PRODUCT}-${ENV}-"
export TASK_SCRIPT=/app/bin/${PROJECT_NAME}script
export VERBOSE=true
export ARTIFACT_UPLOAD_TIMEOUT=1200
export GITHUB_OAUTH_TOKEN=
export TASK_MAX_TIMEOUT=3600
export VERIFY_CHAIN_OF_TRUST=true
export SIGN_CHAIN_OF_TRUST=false
if [ "$ENV" == "prod" ]; then
  export SIGN_CHAIN_OF_TRUST=true
fi
export VERIFY_COT_SIGNATURE=false
if [ "$ENV" == "prod" ]; then
  export VERIFY_COT_SIGNATURE=true
fi

mkdir -p -m 700 $CONFIG_DIR

source $(dirname $0)/init_worker.sh

$CONFIG_LOADER --worker-id-prefix=$WORKER_ID_PREFIX $TEMPLATE_DIR/scriptworker.yml $CONFIG_DIR/scriptworker.json
$CONFIG_LOADER $TEMPLATE_DIR/worker.yml $CONFIG_DIR/worker.json

echo $ED25519_PRIVKEY > $ED25519_PRIVKEY_PATH
chmod 600 $ED25519_PRIVKEY_PATH

# == START: unset all of the variables to not potentially leak them ==
unset AMO_SERVER
unset ARTIFACTS_DIR
unset ARTIFACT_UPLOAD_TIMEOUT
unset CONFIG_DIR
unset CONFIG_LOADER
unset COT_PRODUCT
unset ED25519_PRIVKEY
unset ED25519_PRIVKEY_PATH
unset ENV
unset GITHUB_OAUTH_TOKEN
unset JWT_SECRET
unset JWT_USER
unset LOGS_DIR
unset PROJECT_NAME
unset PROVISIONER_ID
unset SCRIPTWORKER
unset SIGN_CHAIN_OF_TRUST
unset TASKCLUSTER_ACCESS_TOKEN
unset TASKCLUSTER_CLIENT_ID
unset TASK_CONFIG
unset TASK_LOGS_DIR
unset TASK_MAX_TIMEOUT
unset TASK_SCRIPT
unset TEMPLATE_DIR
unset VERBOSE
unset VERIFY_CHAIN_OF_TRUST
unset VERIFY_COT_SIGNATURE
unset WORKER_GROUP
unset WORKER_ID_PREFIX
unset WORKER_TYPE
unset WORK_DIR
# == END:   unset all of the variables to not potentially leak them ==

exec /app/bin/scriptworker /app/configs/scriptworker.json
