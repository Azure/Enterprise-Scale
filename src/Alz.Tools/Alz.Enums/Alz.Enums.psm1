#!/usr/bin/pwsh

############################################
# Custom enum data sets used within module #
############################################

enum PolicyDefinitionPropertiesMode {
    All
    Indexed
}

enum PolicyAssignmentPropertiesEnforcementMode {
    Default
    DoNotEnforce
}

enum PolicyAssignmentIdentityType {
    None
    SystemAssigned
}

enum PolicySetDefinitionPropertiesPolicyType {
    NotSpecified
    BuiltIn
    Custom
    Static
}

enum GetFileNameCaseModifier {
    ToString
    ToLower
    ToUpper
}

enum LineEndingTypes {
    Darwin
    Unix
    Win
}

enum ExportFormat {
    ArmResource
    ArmVariable
    Raw
    Jinja2
    Terraform
    Bicep
}
