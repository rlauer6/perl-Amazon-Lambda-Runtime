AWS_PROFILE                           = @AWS_PROFILE@

AWS_CLI_CREATE_FUNCTION               = AWS_PROFILE=$(AWS_PROFILE) @AWS_CLI@ lambda create-function
AWS_CLI_UPDATE_FUNCTION               = AWS_PROFILE=$(AWS_PROFILE) @AWS_CLI@ lambda update-function-code
AWS_CLI_LIST_FUNCTIONS                = AWS_PROFILE=$(AWS_PROFILE) @AWS_CLI@ lambda list-functions
AWS_CLI_LIST_LAYERS                   = AWS_PROFILE=$(AWS_PROFILE) @AWS_CLI@ lambda list-layers
AWS_CLI_PUBLISH_LAYER                 = AWS_PROFILE=$(AWS_PROFILE) @AWS_CLI@ lambda publish-layer-version
AWS_CLI_UPDATE_FUNCTION_CONFIGURATION = AWS_PROFILE=$(AWS_PROFILE) @AWS_CLI@ lambda update-function-configuration

AWS_CLI_IAM_LIST_ROLES                 = AWS_PROFILE=$(AWS_PROFILE) @AWS_CLI@ iam list-roles
AWS_CLI_IAM_CREATE_ROLE                = AWS_PROFILE=$(AWS_PROFILE) @AWS_CLI@ iam create-role
AWS_CLI_IAM_ATTACH_POLICY              = AWS_PROFILE=$(AWS_PROFILE) @AWS_CLI@ iam attach-role-policy
