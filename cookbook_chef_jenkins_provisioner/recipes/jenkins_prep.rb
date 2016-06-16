our_install_dir = node['jenkins']['windows']['base']
jenkins_home = node['jenkins']['windows']['slave_home']

directory jenkins_home

remote_file 'c:/chef_jenkins_provisioner/SetACL.exe' do
  source node['jenkins']['windows']['set_acl_binary_url']
  checksum node['jenkins']['windows']['set_acl_binary_checksum']
end

directory "#{node['java']['java_home']}/jre/lib/security"

remote_file "#{node['java']['java_home']}/jre/lib/security/US_export_policy.jar" do
  source node['jenkins']['windows']['jce_export_policy_jar']
  checksum node['jenkins']['windows']['jce_export_policy_checksum']
end

remote_file "#{node['java']['java_home']}/jre/lib/security/local_policy.jar" do
  source node['jenkins']['windows']['jce_local_policy_jar']
  checksum node['jenkins']['windows']['jce_local_policy_checksum']
end

# Update registry settings according to
# https://wiki.jenkins-ci.org/display/JENKINS/Windows+slaves+fail+to+start+via+DCOM#WindowsslavesfailtostartviaDCOM-Windows64bitinstallationrelatedissues

execute 'update registry entry owner for HKEY_CLASSES_ROOT\CLSID\{76A64158-CB41-11D1-8B02-00600806D9B6}' do
  command "#{our_install_dir}/SetACL.exe -on \"HKEY_CLASSES_ROOT\CLSID\{76A64158-CB41-11D1-8B02-00600806D9B6}\" -ot reg -actn setowner -ownr n:Administrators"
end

execute 'update registry entry owner for HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Wow6432Node\CLSID\{72C24DD5-D70A-438B-8A42-98424B88AFB8}' do
  command "#{our_install_dir}/SetACL.exe -on \"HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Wow6432Node\CLSID\{72C24DD5-D70A-438B-8A42-98424B88AFB8}\" -ot reg -actn setowner -ownr n:Administrators"
end

execute 'update registry permission for HKEY_CLASSES_ROOT\CLSID\{76A64158-CB41-11D1-8B02-00600806D9B6}' do
  command "#{our_install_dir}/SetACL.exe -on \"HKEY_CLASSES_ROOT\CLSID\{76A64158-CB41-11D1-8B02-00600806D9B6}\" -ot reg -actn ace -ace \"n:Administrators;p:full\""
end

execute 'update registry permission for HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Wow6432Node\CLSID\{72C24DD5-D70A-438B-8A42-98424B88AFB8}' do
  command "#{our_install_dir}/SetACL.exe -on \"HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Wow6432Node\CLSID\{72C24DD5-D70A-438B-8A42-98424B88AFB8}\" -ot reg -actn ace -ace \"n:Administrators;p:full\""
end

execute 'schedule task to stop Jenkins slave service at boot' do
  command 'schtasks /F /Create /RU SYSTEM  /DELAY 0000:15 /TN "Stop Jenkins slave at boot" /TR "c:\jenkins\jenkins-slave.exe uninstall" /SC ONSTART'
end

# Put the JDK on the global path
env 'Path' do
  delim ';'
  value node['java']['java_home']
  action :modify
end
