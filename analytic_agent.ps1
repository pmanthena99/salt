param ($artifacts_install_folder,
$artifact_args_artifact_id,
$artifact_args_version,
$artifacts_release,
$artifact_args_classifier,    
$artifact_args_packaging,
$artifact_args_execFile,
$artifact_args_appSettingsFile, 
$artifact_args_propertiesFile,
$artifact_args_properties,
$artifact_args_certificateFile,
$fqdn,
$ssl-cert,
$service_account_pwd,
$service_account)

$artifact_dir = $artifacts_install_folder + '\\' + $artifacts_release 
$artifact_zip = $artifact_dir + '\\' + $artifact_args_artifact_id + '-' + $artifact_args_version + '-' + $artifact_args_classifier + '.' + $artifact_args_packaging
$artifact_install = $artifact_dir + '\\' + $artifact_args_artifact_id + '-' + $artifact_args_classifier  
$analytic_agent_bin = $artifact_install + '\\' + $artifact_args_execFile
$analytic_agent_config_file = $artifact_install + '\\' + $artifact_args_appSettingsFile
$analytic_agent_properties_file = $artifact_install + '\\' + $artifact_args_propertiesFile
$ssl_cert_location = $artifact_dir + '\\' + $artifact_args_certificateFile
 

#clean analytic agent archive:

Remove-Item "$artifact_zip"

# ensure analytic agent worker root directory:
New-Item -Path "$artifact_install"

#ensure analytic agent target directory:
New-Item -Path "$artifact_dir"


    $artifact_version= $artifact_args_version.split('-')[0]-SNAPSHOT 
    $file_name = $artifact_id + '-' + $artifact_version + '-' + $artifact_args_classifier + '.' + $packaging
    $artifactory_url  = " http://odyssey.apps.csintra.net/artifactory/libs-snapshot-local/com/csg/credit/aurora"+ '/'+$artifact_version+$file_name
    Write-Output $artifactory_url
    Expand-Archive -LiteralPath "$artifact_zip" -DestinationPath "$artifact_install"
    
    
# clenaup analytic agent configuration properties:
#   file.absent:
#     - name: {{ analytic_agent_properties_file }}
Remove-Item "$analytic_agent_properties_file" -Recurse
 
#create analytic agent configuration properties: #MAKESURE to provide properties in json format in Jenkins
Set-Content -Path analytic_agent_properties_file -Value analytic_agent_properties

# setup host in analytic agent configuration:
 
$analytic_agent_config_file.replace('serverHost' , ('"serverHost": "' + grains[$fqdn] + '",' ) | quote )

# create certificate file:
#   file.managed:
#     - name: {{ ssl_cert_location }}
#     - contents_pillar: ssl-cert

    New-Item -Path $ssl_cert_location  -ItemType File -Value $ssl-cert
 
# set ssl certificate location:
#   cmd.script:
#     - shell: powershell
#     - source: salt://aurora/scripts/set_env_variable.ps1
#     - args: {{ ('-Name SSL_CERT_LOCATION -Value ' ~ ssl_cert_location ) | quote }}
#     - env:
#       - ExecutionPolicy: "bypass"
#       - ErrorActionPreference: "Stop"
#       - ProgressPreference: "SilentlyContinue"

Powershell.exe  -ExecutionPolicy Bypass -ErrorActionPreference Stop -ProgressPreference SilentlyContinue
-File ".\aurora\scripts\set_env_variable.ps1" -SSL_CERT_LOCATION $ssl_cert_location
 
 
# set ssl certificate password:
#   cmd.script:
#     - shell: powershell
#     - source: salt://aurora/scripts/set_env_variable.ps1
#     - args: {{ ('-Name SSL_CERT_PASSWORD -Value ' ~ pillar['ssl-cert-pass'] ) | quote }}
#     - env:
#       - ExecutionPolicy: "bypass"
#       - ErrorActionPreference: "Stop"
#       - ProgressPreference: "SilentlyContinue"

Powershell.exe  -ExecutionPolicy Bypass -ErrorActionPreference Stop -ProgressPreference SilentlyContinue
-File ".\aurora\scripts\set_env_variable.ps1" -SSL_CERT_PASSWORD $ssl_cert_location
 
 
# configure analytic agent application settings:
#   cmd.script:
#     - shell: powershell
#     - source: salt://aurora/scripts/setup_configuration.ps1
#     - args: {{ ('-ConfigurationFilePath ' ~ analytic_agent_config_file ~ ' -ConfigurationParametersPath ' ~ analytic_agent_properties_file  ) | quote }}
#     - env:
#       - ExecutionPolicy: "bypass"
      
Powershell.exe  -ExecutionPolicy Bypass -ErrorActionPreference Stop -ProgressPreference SilentlyContinue
-File ".\aurora\scripts\setup_configuration.ps1" -ConfigurationFilePath $analytic_agent_config_file -ConfigurationParametersPath $analytic_agent_properties_file
            
 
# install analytic agent application as service:
#   cmd.script:
#     - shell: powershell
#     - source: salt://aurora/scripts/install_analytic_agent.ps1
#     - args: {{ ('-BinPath ' ~ analytic_agent_bin ~ ' -Username ' ~ pillar['service_account'] ~ ' -Password (ConvertTo-SecureString "' ~ pillar['service_account_pwd'] ~ '" -AsPlainText -Force)' ~ ' -Release ' ~ pillar['release']  ) | quote }}
#     - env:
#       - ExecutionPolicy: "bypass"

$Secure= ConvertTo-SecureString $service_account_pwd -AsPlainText -Force
Powershell.exe -ExecutionPolicy Bypass 
 -File ".\aurora\scripts\install_analytic_agent.ps1" -BinPath  $analytic_agent_bin -Username $service_account -Password $service_account_pwd -Release $release
        
