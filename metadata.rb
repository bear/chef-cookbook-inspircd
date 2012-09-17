maintainer        "Mike Taylor"
maintainer_email  "bear@andyet.net"
license           "MIT"
description       "Install InspIRCd"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "0.5.3"

recipe "inspircd", "Install InspIRCd from source"
recipe "services", "Install and configure Anope"

depends "build-essential"

%w{ ubuntu debian redhat centos arch }.each do |os|
  supports os
end

attribute "inspircd/dir",
  :display_name => "inspircd Directory",
  :description => "Location of inspircd configuration files",
  :default => "/etc/inspircd"

attribute "inspircd/log_dir",
  :display_name => "InspIRCd Log Directory",
  :description => "Location for InspIRCd logs",
  :default => "/var/log/inspircd"

attribute "inspircd/library_dir",
  :display_name => "InspIRCd Library Directory",
  :description => "Location for InspIRCd library files",
  :default => "/var/lib/inspircd"

attribute "inspircd/modules_dir",
  :display_name => "InspIRCd Modules Directory",
  :description => "Location for InspIRCd modules",
  :default => "/var/lib/inspircd/modules"

attribute "inspircd/user",
  :display_name => "InspIRCd User",
  :description => "User InspIRCd will run as",
  :default => "ircd"

attribute "inspircd/binary",
  :display_name => "InspIRCd Binary",
  :description => "Location of the InspIRCd server binary",
  :default => "/usr/sbin/inspircd"

