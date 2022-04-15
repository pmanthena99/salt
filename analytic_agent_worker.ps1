{% set artifacts = pillar.get('artifacts', {}) %}

{% set artifact =  'analytic_agent_worker' %}

{% set artifact_args = artifacts[artifact] %}

 

{% set artifact_dir = artifacts.install_folder ~ '\\' ~ pillar['release'] %}
$artifact_dir=$args[0]+'\'+$args[1]   # G:\\App\\Aurora + "aurora"
{% set artifact_zip = artifact_dir ~ '\\' ~ artifact_args.artifact_id ~ '-' ~ artifact_args.version ~ '-' ~ artifact_args.classifier ~ '.' ~ artifact_args.packaging %}
$artifact_zip= $artifact_dir+'\'+$args[2]+'-'+$args[3]+'-'+$args[4]+'.'+$args[5]  # G:\App\Aurora  arora  analytic-engine  6.5.0-beta.24  sxs  zip
{% set artifact_install = artifact_dir ~ '\\' ~ artifact_args.artifact_id ~ '-' ~ artifact_args.classifier %}
$artifact_install= $artifact_dir+'\'+$args[2]+'-'+$args[5]
 

# clean analytic agent worker archive:

#   file.absent:

#     - name: {{ artifact_zip }}
    Remove-Item "$artifact_zip"
 

# ensure analytic agent worker root directory:

#   file.directory:

#     - name: {{ artifact_install }}

#     - makedirs: True
    New-Item -Path "$artifact_install"
 

# ensure analytic agent worker target directory:

#   file.directory:

#     - name: {{ artifact_dir }}

#     - makedirs: True
    New-Item -Path "$artifact_dir"
 

# download analytic agent worker:

#   module.run:

#     - name: artifactory.get_snapshot

#     - artifactory_url: http://odyssey.apps.csintra.net/artifactory

#     - repository: 'libs-snapshot-local'

#     - group_id: 'com.csg.credit.aurora'

#     - artifact_id: {{ artifact_args.artifact_id }}

#     - packaging: {{ artifact_args.packaging }}

#     - version: {{ artifact_args.version.split('-')[0] }}-SNAPSHOT

#     - snapshot_version: {{ artifact_args.version }}

#     - classifier: {{ artifact_args.classifier }}

#     - target_dir: {{ artifact_dir }}

 

# extract analytic agent worker:

#   archive.extracted:

#     - name: {{ artifact_install }}

#     - source: {{ artifact_zip }}

#     - overwrite: true

#     - enforce_toplevel: false

    Expand-Archive -LiteralPath "$artifact_zip" -DestinationPath "$artifact_install"