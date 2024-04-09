#!/bin/bash

## WARNING: DO NOT modify the content of entrypoint.sh
# Use ./config/static_tests/pre-entrypoint-helpers.sh or ./config/static_tests/post-entrypoint-helpers.sh 
# to load any customizations or additional configurations

## NOTE: paths may differ when running in a managed task. To ensure behavior is consistent between
# managed and local tasks always use these variables for the project and project type path
PROJECT_PATH=${BASE_PATH}/project
PROJECT_TYPE_PATH=${BASE_PATH}/projecttype

#********** helper functions *************
pre_entrypoint() {
    if [ -f ${PROJECT_PATH}/.config/static_tests/pre-entrypoint-helpers.sh ]; then
        echo "Pre-entrypoint helper found"
        source ${PROJECT_PATH}/.config/static_tests/pre-entrypoint-helpers.sh
        echo "Pre-entrypoint helper loaded"
    else
        echo "Pre-entrypoint helper not found - skipped"
    fi
}
post_entrypoint() {
    if [ -f ${PROJECT_PATH}/.config/static_tests/post-entrypoint-helpers.sh ]; then
        echo "Post-entrypoint helper found"
        source ${PROJECT_PATH}/.config/static_tests/post-entrypoint-helpers.sh        
        echo "Post-entrypoint helper loaded"
    else
        echo "Post-entrypoint helper not found - skipped"
    fi
}

#********** Pre-entrypoint helper *************
pre_entrypoint

<<<<<<< before updating
#********** tflint ********************
echo 'Starting tflint'
tflint --init --config ${PROJECT_PATH}/.config/.tflint.hcl
MYLINT=$(tflint --force --config ${PROJECT_PATH}/.config/.tflint.hcl)
if [ -z "$MYLINT" ]
then
    echo "Success - tflint found no linting issues!"
else
    echo "Failure - tflint found linting issues!"
    echo "$MYLINT"
    exit 1
fi
#********** tfsec *********************
echo 'Starting tfsec'
MYTFSEC=$(tfsec . --config-file ${PROJECT_PATH}/.config/.tfsec.yml || true)
if [[ $MYTFSEC == *"No problems detected!"* ]];
=======
#********** Static Test *************
/bin/bash ${PROJECT_PATH}/.project_automation/static_tests/static_tests.sh
if [ $? -eq 0 ]
>>>>>>> after updating
then
    echo "Static test completed"
    EXIT_CODE=0
else
    echo "Static test failed"
    EXIT_CODE=1
fi

<<<<<<< before updating
#********** Markdown Lint **************
echo 'Starting markdown lint'
MYMDL=$(mdl --config ${PROJECT_PATH}/.config/.mdlrc .header.md examples/*/.header.md || true)
if [ -z "$MYMDL" ]
then
    echo "Success - markdown lint found no linting issues!"
else
    echo "Failure - markdown lint found linting issues!"
    echo "$MYMDL"
    exit 1
fi
#********** Terraform Docs *************
echo 'Starting terraform-docs'
TDOCS="$(terraform-docs --config ${PROJECT_PATH}/.config/.terraform-docs.yaml --lockfile=false ./)"
git add -N README.md
GDIFF="$(git diff --compact-summary)"
if [ -z "$GDIFF" ]
then
    echo "Success - Terraform Docs creation verified!"
else
    echo "Failure - Terraform Docs creation failed, ensure you have precommit installed and running before submitting the Pull Request"
    exit 1
fi
#***************************************
echo "End of Static Tests"
=======
#********** Post-entrypoint helper *************
post_entrypoint

#********** Exit Code *************
exit $EXIT_CODE
>>>>>>> after updating
