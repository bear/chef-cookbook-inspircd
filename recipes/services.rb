#
# Cookbook Name:: inspircd
# Recipe:: services
#

unless(node[:anope]['prefix'])
  node.set['anope']['prefix'] = "/opt/anope-#{node[:anope]['version']}"
end
unless(node[:anope]['conf_path'])
  node.set['anope']['conf_path'] = "#{node[:anope]['conf_dir']}/anope.conf"
end
unless(node[:anope]['binary'])
  node.set['anope']['binary'] = "#{node[:anope]['bin_dir']}/anope"
end
unless(node[:anope]['default_configure_flags'])
  node.set['anope']['default_configure_flags'] = [
    "--with-bindir=#{node[:anope]['bin_dir']}",
    "--with-datadir=#{node[:anope]['lib_dir']}",
    "--with-rungroup=#{node[:anope]['user']}",
    "--with-permissions=007",
    "--without-mysql",
  ]
end

inspircd_url = "http://downloads.sourceforge.net/project/anope/anope-stable/Anope-#{node[:anope]['version']}/anope-#{node[:anope]['version']}.tar.gz"
src_filepath = "#{Chef::Config['file_cache_path'] || '/tmp'}/anope-#{node[:anope]['version']}.tar.gz"
bin_filepath = "#{node[:anope]['binary']}"

include_recipe "build-essential"

packages = value_for_platform(
  [ "centos","redhat","fedora"] => {'default' => ['pkg-config','gnutls', 'gnutls-devel']},
    "default" => ['pkg-config', 'gnutls-bin', 'libgnutls-dev']
)

packages.each do |devpkg|
  package devpkg
end

remote_file anope_url do
  source anope_url
  path   src_filepath
  backup false
end

user node[:anope]['user'] do
  system true
  shell  "/bin/false"
  home   "/var/lib/anope"
end

inspircd_force_recompile = node.run_state['anope_force_recompile']
node.run_state['anope_configure_flags'] = node[:anope]['default_configure_flags']

bash "compile_anope_source" do
  not_if { File.exists?(bin_filepath) }

  cwd ::File.dirname(src_filepath)
  code <<-EOH
    tar xjf #{::File.basename(src_filepath)} -C #{::File.dirname(src_filepath)}
    cd inspircd
    ./configure #{node.run_state['anope_configure_flags'].join(" ")}
    make
    make install
    rm -f #{node[:anope]['conf_dir']}/anope.conf
  EOH
end

node.run_state.delete(:anope_configure_flags)
node.run_state.delete(:anope_force_recompile)

template "/etc/init.d/anope" do
  source "anope.init.erb"
  mode   0755
  owner  "root"
  group  "root"
  variables(
    :working_dir  => node[:anope][:prefix],
    :binary       => node[:anope][:binary],
    :conf_dir     => node[:anope][:conf_dir],
    :log_dir      => node[:anope][:log_dir],
    :lib_dir      => node[:anope][:lib_dir],
    :pid          => node[:anope][:pid],
    :ircd_user    => node[:anope][:user],
    :config_file  => node[:anope][:conf_path]
  )
end

template "anope.conf" do
  path "#{node[:anope]['conf_dir']}/anope.conf"
  source   "anope.conf.erb"
  mode     0644
  owner    "root"
  group    "root"
  variables(
    :working_dir        => node[:anope][:prefix],
    :binary             => node[:anope][:binary],
    :conf_dir           => node[:anope][:conf_dir],
    :log_dir            => node[:anope][:log_dir],
    :lib_dir            => node[:anope][:lib_dir],
    :pid                => node[:anope][:pid],
    :ircd_user          => node[:anope][:user],
    :config_file        => node[:anope][:conf_path],
    :fqdn               => node[:anope][:fqdn],
    :description        => node[:anope][:server_description],
    :network            => node[:anope][:server_network],
    :server_listen      => node[:anope][:listen],
  )
  notifies :reload, 'service[anope]', :immediately
end

service 'anope' do
  supports :status => true, :restart => true, :reload => true
  action :start
end

service "anope" do
  supports :status => true, :restart => true, :reload => true
  action :enable
end
