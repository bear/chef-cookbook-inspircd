#
# Cookbook Name:: inspircd
# Recipe:: default
#

unless(node[:inspircd]['prefix'])
  node.set['inspircd']['prefix'] = "/opt/inspircd-#{node[:inspircd]['version']}"
end
unless(node[:inspircd]['conf_path'])
  node.set['inspircd']['conf_path'] = "#{node[:inspircd]['conf_dir']}/inspircd.conf"
end
unless(node[:inspircd]['binary'])
  node.set['inspircd']['binary'] = "#{node[:inspircd]['bin_dir']}/inspircd"
end
unless(node[:inspircd]['default_configure_flags'])
  node.set['inspircd']['default_configure_flags'] = [
    "--prefix=#{node[:inspircd]['source']['prefix']}",
    "--config-dir=#{node[:inspircd]['conf_dir']}",
    "--module-dir=#{node[:inspircd]['modules_dir']}",
    "--binary-dir=#{node[:inspircd]['bin_dir']}",
    "--library-dir=#{node[:inspircd]['lib_dir']}",
    "--enable-gnutls",
    "--enable-epoll"
  ]
end

inspircd_url = "https://github.com/downloads/inspircd/inspircd/inspircd-#{node[:inspircd]['version']}.tar.bz2"
src_filepath = "#{Chef::Config['file_cache_path'] || '/tmp'}/inspircd-#{node[:inspircd]['version']}.tar.bz2"
bin_filepath = "#{node[:inspircd]['binary']}"

include_recipe "build-essential"

packages = value_for_platform(
  [ "centos","redhat","fedora"] => {'default' => ['pkg-config','gnutls', 'gnutls-devel']},
    "default" => ['pkg-config', 'gnutls-bin', 'libgnutls-dev']
)

packages.each do |devpkg|
  package devpkg
end

remote_file inspircd_url do
  source inspircd_url
  path   src_filepath
  backup false
end

user node[:inspircd]['user'] do
  system true
  shell  "/bin/false"
  home   "/var/lib/inspircd"
end

inspircd_force_recompile = node.run_state['inspircd_force_recompile']
node.run_state['inspircd_configure_flags'] = node[:inspircd]['default_configure_flags']

bash "compile_inspircd_source" do
  not_if { File.exists?(bin_filepath) }

  cwd ::File.dirname(src_filepath)
  code <<-EOH
    tar xjf #{::File.basename(src_filepath)} -C #{::File.dirname(src_filepath)}
    cd inspircd
    ./configure #{node.run_state['inspircd_configure_flags'].join(" ")}
    make
    make INSTUID=#{node[:inspircd]['user']} install
    rm -f #{node[:inspircd]['conf_dir']}/inspircd.conf
  EOH
end

node.run_state.delete(:inspircd_configure_flags)
node.run_state.delete(:inspircd_force_recompile)

template "/etc/init.d/inspircd" do
  source "inspircd.init.erb"
  mode   0755
  owner  "root"
  group  "root"
  variables(
    :working_dir  => node[:inspircd][:prefix],
    :binary       => node[:inspircd][:binary],
    :conf_dir     => node[:inspircd][:conf_dir],
    :log_dir      => node[:inspircd][:log_dir],
    :lib_dir      => node[:inspircd][:lib_dir],
    :pid          => node[:inspircd][:pid],
    :ircd_user    => node[:inspircd][:user],
    :config_file  => node[:inspircd][:conf_path]
  )
end

directory node[:inspircd]['conf_dir'] do
  mode  0755
  owner "root"
  group "root"
end

directory node[:inspircd]['log_dir'] do
  mode   0755
  owner  node[:inspircd]['user']
  action :create
end

template "inspircd.conf" do
  path "#{node[:inspircd]['conf_dir']}/inspircd.conf"
  source   "inspircd.conf.erb"
  mode     0644
  owner    "root"
  group    "root"
  variables(
    :working_dir        => node[:inspircd][:prefix],
    :binary             => node[:inspircd][:binary],
    :conf_dir           => node[:inspircd][:conf_dir],
    :log_dir            => node[:inspircd][:log_dir],
    :lib_dir            => node[:inspircd][:lib_dir],
    :pid                => node[:inspircd][:pid],
    :ircd_user          => node[:inspircd][:user],
    :config_file        => node[:inspircd][:conf_path],
    :fqdn               => node[:inspircd][:fqdn],
    :description        => node[:inspircd][:server_description],
    :network            => node[:inspircd][:server_network],
    :server_listen      => node[:inspircd][:listen],
    :server_admin       => search(:ircd_admin, "*:*").first,
  )
  notifies :reload, 'service[inspircd]', :immediately
end

template "opers.conf" do
  path "#{node[:inspircd]['conf_dir']}/opers.conf"
  source   "opers.conf.erb"
  mode     0644
  owner    "root"
  group    "root"
  variables(
    :working_dir        => node[:inspircd][:prefix],
    :binary             => node[:inspircd][:binary],
    :conf_dir           => node[:inspircd][:conf_dir],
    :log_dir            => node[:inspircd][:log_dir],
    :lib_dir            => node[:inspircd][:lib_dir],
    :pid                => node[:inspircd][:pid],
    :ircd_user          => node[:inspircd][:user],
    :config_file        => node[:inspircd][:conf_path],
    :fqdn               => node[:inspircd][:fqdn],
    :description        => node[:inspircd][:server_description],
    :network            => node[:inspircd][:server_network],
    :server_admin_name  => node[:inspircd][:server_admin_name],
    :server_admin_nick  => node[:inspircd][:server_admin_nick],
    :server_admin_email => node[:inspircd][:server_admin_email],
    :server_listen      => node[:inspircd][:listen],
    :opers              => search(:ircd_opers, "*:*"),
  )
  notifies :reload, 'service[inspircd]', :immediately
end

template "inspircd.motd" do
  path "#{node[:inspircd]['conf_dir']}/inspircd.motd"
  source   "inspircd.motd.erb"
  mode     0644
  owner    "root"
  group    "root"
end

template "inspircd.rules" do
  path "#{node[:inspircd]['conf_dir']}/inspircd.rules"
  source   "inspircd.rules.erb"
  mode     0644
  owner    "root"
  group    "root"
end

template "modules.conf" do
  path "#{node[:inspircd]['conf_dir']}/modules.conf"
  source   "modules.conf.erb"
  mode     0644
  owner    "root"
  group    "root"
end

service 'inspircd' do
  supports :status => true, :restart => true, :reload => true
  action :start
end

service "inspircd" do
  supports :status => true, :restart => true, :reload => true
  action :enable
end

include_recipe "chef-cookbook-inspircd::services"
