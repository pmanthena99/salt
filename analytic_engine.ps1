# $args[0] = "6.6.0"
# $args[1] = "C:\\App\\Aurora"
# $args[2] = "analytic_engine\\6.6.0-SNAPSHOT"
# $args[3] = "analytic-engine"
# $args[4] = "6.6.0-beta.24"
# $args[5] = "sxs"
# $args[6] = "zip"
# $args[7] = "MCClientFlagFilesPath=.\\C_MCClientConfig64_20210916.A.DEV%3BMOB_PARAM:mdsx_mode=PRODPL"

$credit_version = $args[0] # artifacts['credit_build'].version , sample_value = 6.6.0 
$artifact_dir = $args[1]+'\'+$args[2]   # artifacts.install_folder ~ '\\' ~ pillar['release'] , sample_value = G:\App\Aurora\analytic_engine\6.6.0-SNAPSHOT
$artifact_zip = $artifact_dir+'\'+$args[3]+'-'+$args[4]+'-'+$args[5]+'.'+$args[6]  #artifact_dir ~ '\\' ~ artifact_args.artifact_id ~ '-' ~ artifact_args.version ~ '-' ~ artifact_args.classifier ~ '.' ~ artifact_args.packaging, Sample_value = G:\App\Aurora\analytic_engine\6.6.0-SNAPSHOT\analytic_engine-6.6.0-beta.24-sxs.zip
$artifact_install = $artifact_dir+'\'+$args[3]+'-'+$args[6] # artifact_dir ~ '\\' ~ artifact_args.artifact_id ~ '-' ~ artifact_args.classifier, sample_value = G:\App\Aurora\analytic_engine-sxs  
$envvironment_variable = $args[7]   
"credit_version: $credit_version"
"artifact_dir: $artifact_dir"
"artifact_zip: $artifact_zip"
"artifact_install: $artifact_install"

# clean analytic engine archive:
Remove-Item "$artifact_zip"

# ensure analytic engine root directory:
New-Item -Path "$artifact_install" -Force

# ensure analytic engine target directory:
New-Item -Path "$artifact_dir" -Force

# install analytic engine:
# Set-ExecutionPolicy -ExecutionPolicy Bypass
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
C:\MyData\Workspace_cloud_devops\1-salt-to-powershell\install_analytic_engine.ps1 $credit_version $artifact_install $artifact_zip $envvironment_variable
# \\aurora\\scripts\\install_analytic_engine.ps1 $credit_version $artifact_install $artifact_zip $args[7]
