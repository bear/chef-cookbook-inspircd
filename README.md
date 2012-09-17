Description
===========

Installs InspIRCd.

Target OS's: Ubuntu, Debian, Redhat, Centos

Requirements
============

* build-essential

Attributes
==========

Directories: 

* `node['inspircd']['dir']`
* `node['inspircd']['log_dir']`
* `node['inspircd']['pid']`

inspircd.conf values:

* `node['inspircd']['user']`
* `node['inspircd']['binary']`

Data Bags
=========

ircd_admin
    admin.json    {"id":"adminname","nick":"admin","email":"admin@email.net"}

ircd_opers:
    *.json        {"id":"oper1","hash":"secret","host":"*@localhost","type":"NetAdmin"}

ircd_services:
    services.json {"id":"services.fqdn.com",
                   "ip":"127.0.0.1","port":"7000","allowmask":"127.0.0.1/24",
                   "send_password":"foo","recv_password":"bar"}

Recipes
=======

default.rb - Use the default recipe to install inspircd via a source tarball.

Source build will enable the following modules:

* m_sha256
* m_md5
* m_ripemd160
* m_autoop

