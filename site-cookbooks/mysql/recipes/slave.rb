change_master_path = value_for_platform(
  ["centos", "redhat", "suse", "fedora" ] => {
    "default" => "/etc/mysql_change_master.sql"
  },
  "default" => "/etc/mysql/change_master.sql"
)

template "/etc/mysql/change_master.sql" do
  path change_master_path
  source "change_master.sql.erb"
  owner "root"
  group "root"
  mode "0600"
  action :create
end

execute "mysql-install-privileges" do
  command "/usr/bin/mysql -u root #{node['mysql']['server_root_password'].empty? ? '' : '-p' }#{node['mysql']['server_root_password']} < #{change_master_path}"
  action :nothing
  subscribes :run, resources("template[/etc/mysql/change_master.sql]"), :immediately
end
