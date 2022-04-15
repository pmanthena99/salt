param ($install_folder,
$nssm_version,
$nssm_execFile,
$release,
$artifact_id,
$version,
$packaging,
$lokiPlugin, 
$fluentd_bat_file,
$fluentd_config_folder, 
$fluentd_log_file_path, 
$propertiesFile,
$nssm_artifacts_url
$fluentd_artifacts_url)

$nssm_target_folder= $install_folder + '\\' + $nssm_version
$nssm_zip= $nssm_target_folder+ 'zip'
$nssm_bin= $nssm_target_folder + '\\' + $nssm_version + '\\' + $nssm_execFile
$artifact_dir= $install_folder + '\\' + $release
$artifact_install= $artifact_dir + '\\' + $artifact_id
$artifact_msi= $artifact_install + '-' + $version + '.' + $packaging
$fluentd_loki_plugin= $artifact_dir + '\\' + $lokiPlugin
$fluentd_bat_file= $artifact_install + '\\opt\\td-agent\\bin\\td-agent.bat'
$fluentd_config_folder= $artifact_install + '\\opt\\td-agent\\etc\\td-agent'
$fluentd_config_file= $artifact_install + '\\opt\\td-agent\\etc\\td-agent\\td-agent.conf'
$fluentd_properties_file= $artifact_install + '\\' + $propertiesFile

#download nssm:
Invoke-WebRequest -UseBasicParsing  -Headers @{"User-Agent"="powershell"} -Method Get -Uri $nssm_artifacts_url  -OutFile $nssm_zip

#extract nssm artifacts
Expand-Archive -Path $nssm_zip -DestinationPath $nssm_target_folder

#download fluentd msi
Invoke-WebRequest -UseBasicParsing  -Headers @{"User-Agent"="powershell"} -Method Get -Uri $fluentd_artifacts_url }}  -OutFile $artifact_msi

#create fluentd installation folder
New-Item $artifact_install -ItemType Directory

#Remove old Fluentd configs
Remove-Item $fluentd_config_file -Recurse

#Install Fluentd NeedReview
Start-Process msiexec.exe -Wait -ArgumentList '/a "$artifact_msi" /qn TARGETDIR="$artifact_install" /L*v fluentd-msi.log'

#download fluentd loki plugin
Invoke-WebRequest -UseBasicParsing  -Headers @{"User-Agent"="powershell"} -Method Get -Uri $fluentd_loki_plugin_artifacts_url -OutFile $fluentd_loki_plugin

#install fluentd loki plugin:
Start-Process $artifact_install + '\\opt\\td-agent\\bin\\fluent-gem.bat'  -Wait -ArgumentList "install -l $fluentd_loki_plugin"

#deploy fluentd configuration:
Remove-Item $fluentd_config_folder -Recurse
New-Item -Path $fluentd_config_folder
Copy-Item "\\aurora\\fluentd-configs" -Destination $fluentd_config_folder

# clenaup fluentd configuration properties:
Remove-Item $fluentd_properties_file
 
#create fluentd configuration properties:
New-Item $fluentd_properties_file -ItemType "file"
Set-Content -Path $fluentd_properties_file -Value $artifact_args

Set-ExecutionPolicy -ExecutionPolicy Bypass
\\aurora\\scripts\\setup_configuration.ps1 $fluentd_config_file $fluentd_properties_file $artifact_zip $environment_variables
 
#configure fluentd application configuration: #TODO Check script path
 
 
#install fluentd application as service:
$Secure= ConvertTo-SecureString $service_account_pwd -AsPlainText -Force
\\aurora\\scripts\\install_fluentd.ps1 -BinPath $nssm_bin -BatFile $fluentd_bat_file -ConfigurationPath $fluentd_config_file -LogOutputFile $fluentd_log_file_path -Username $service_account -Password $secure -Release $release

