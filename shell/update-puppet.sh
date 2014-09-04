#!/bin/bash
source /usr/local/rvm/scripts/rvm

PWD=/usr/src/elasticsearch-talk/shell
OS=$(/bin/bash $PWD/os-detect.sh ID)
RELEASE=$(/bin/bash $PWD/os-detect.sh RELEASE)
CODENAME=$(/bin/bash $PWD/os-detect.sh CODENAME)

function check_puppet_symlink() {
    if [[ -f '/usr/local/rvm/gems/ruby-1.9.3-p547/bin/puppet' ]]; then
        rm '/usr/bin/puppet'
        ln -s '/usr/local/rvm/gems/ruby-1.9.3-p547/bin/puppet' '/usr/bin/puppet'

        return 0;
    fi

    # Puppet not installed
    if [ ! -L '/usr/bin/puppet' ]; then
        rm '/var/puppet-init/install-puppet'

        return 0;
    fi

    PUPPET_SYMLINK=$(ls -l /usr/bin/puppet);

    # If puppet symlink is old-style pointing to /usr/local/rvm/wrappers/default/ruby
    if [ "grep '/usr/local/rvm/wrappers/default' ${PUPPET_SYMLINK}" ]; then
        rm '/usr/bin/puppet'

        if [[ -f '/usr/local/rvm/gems/ruby-1.9.3-p547/bin/puppet' ]]; then
            ln -s '/usr/local/rvm/gems/ruby-1.9.3-p547/bin/puppet' '/usr/bin/puppet'

        else
            rm '/var/puppet-init/install-puppet'
        fi
    fi
}

check_puppet_symlink

source /usr/local/rvm/scripts/rvm

if [[ -f '/var/puppet-init/install-puppet' ]]; then
    exit 0
fi

if [ "${OS}" == 'debian' ] || [ "${OS}" == 'ubuntu' ]; then
    apt-get -y install augeas-tools libaugeas-dev
elif [[ "${OS}" == 'centos' ]]; then
    yum -y install augeas-devel
fi

echo 'Installing Puppet requirements'
/usr/bin/gem install haml hiera facter json ruby-augeas --no-document
echo 'Finished installing Puppet requirements'

echo 'Installing Puppet 3.4.3'
/usr/bin/gem install puppet --version 3.4.3 --no-document

if [[ -f '/usr/bin/puppet' ]]; then
    mv /usr/bin/puppet /usr/bin/puppet-old
fi

ln -s /usr/local/rvm/gems/ruby-1.9.3-p*/bin/puppet /usr/bin/puppet
ln -s /usr/local/rvm/gems/ruby-1.9.3-p*/bin/facter /usr/bin/facter

echo 'Finished installing Puppet 3.4.3'

touch '/var/puppet-init/install-puppet'
