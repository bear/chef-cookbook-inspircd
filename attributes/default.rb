#
# Cookbook Name:: inspircd
# Attributes:: default

default[:inspircd]['version']     = "2.0.8"
default[:inspircd]['conf_dir']    = "/etc/inspircd"
default[:inspircd]['log_dir']     = "/var/log/inspircd"
default[:inspircd]['lib_dir']     = "/var/lib/inspircd"
default[:inspircd]['bin_dir']     = "/usr/sbin"
default[:inspircd]['modules_dir'] = "/var/lib/inspircd/modules"
default[:inspircd]['binary']      = "/usr/sbin/inspircd"
default[:inspircd]['pid']         = "/var/run/inspircd.pid"

default[:inspircd]['listen']      = ['127.0.0.1']
default[:inspircd]['fqdn']        = 'irc.tfoundry.com'

case node['platform']
when "debian","ubuntu"
  default[:inspircd]['user']       = "irc"
  default[:inspircd]['init_style'] = "runit"
when "redhat","centos","scientific","amazon","oracle","fedora"
  default[:inspircd]['user']       = "irc"
  default[:inspircd]['init_style'] = "init"
else
  default[:inspircd]['user']       = "irc"
  default[:inspircd]['init_style'] = "init"
end

set[:inspircd]['version']   = "2.0.8"
set[:inspircd]['prefix']    = "/opt/inspircd-#{node[:inspircd]['version']}"
set[:inspircd]['conf_path'] = "#{node[:inspircd]['conf_dir']}/inspircd.conf"
set[:inspircd]['default_configure_flags'] = [
  "--prefix=#{node[:inspircd]['prefix']}",
  "--config-dir=#{node[:inspircd]['conf_dir']}",
  "--module-dir=#{node[:inspircd]['modules_dir']}",
  "--binary-dir=#{node[:inspircd]['bin_dir']}",
  "--library-dir=#{node[:inspircd]['lib_dir']}",
  "--enable-gnutls",
  "--enable-epoll"
]


default[:anope]['version']     = "1.8.7"
default[:anope]['conf_dir']    = "/etc/inspircd"
default[:anope]['log_dir']     = "/var/log/inspircd"
default[:anope]['lib_dir']     = "/var/lib/inspircd/services"
default[:anope]['bin_dir']     = "/usr/sbin"
default[:anope]['binary']      = "/usr/sbin/anope"
default[:anope]['pid']         = "/var/run/anope.pid"

case node['platform']
when "debian","ubuntu"
  default[:anope]['user']       = "irc"
  default[:anope]['init_style'] = "runit"
when "redhat","centos","scientific","amazon","oracle","fedora"
  default[:anope]['user']       = "irc"
  default[:anope]['init_style'] = "init"
else
  default[:anope]['user']       = "irc"
  default[:anope]['init_style'] = "init"
end

set[:anope]['version']   = "1.8.7"
set[:anope]['conf_path'] = "#{node[:anope]['conf_dir']}/anope.conf"
set[:anope]['default_configure_flags'] = [
    "--with-bindir=#{node[:anope]['bin_dir']}",
    "--with-datadir=#{node[:anope]['lib_dir']}",
    "--with-rungroup=#{node[:anope]['user']}",
    "--with-permissions=007",
    "--without-mysql",
]
