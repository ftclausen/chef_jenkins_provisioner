name             'chef_jenkins_provisioner'
maintainer       'Fred Clausen'
maintainer_email 'ftclausen@gmail.com'
license          'Apache 2.0'
description      'Preps a node to be a Windows Jenkins slave'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.0'

depends 'windows'
depends 'java'
