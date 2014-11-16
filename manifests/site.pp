Exec {
    path => ['/usr/local/bin', '/opt/local/bin', '/usr/bin', '/usr/sbin', '/bin', '/sbin']
}

group { 'android':
    ensure => 'present'
}

user { 'vagrant':
    groups => ['android'],
    require => Group['android']
}

package { 'unzip':
    ensure => present
}

package { 'openjdk-7-jdk':
    ensure => present
}

package { 'ant':
    ensure => present
}

package { 'mercurial':
    ensure => present
}

package { 'ccache':
    ensure => present
}


exec { 'apt-get update':
}

exec { 'install firefox dependencies':
    command => 'apt-get --assume-yes build-dep firefox',
    require => Exec['apt-get update']
}

exec { 'download android-ndk':
    command => 'wget http://dl.google.com/android/ndk/android-ndk-r8e-linux-x86.tar.bz2 -P /vagrant',
    creates => '/vagrant/android-ndk-r8e-linux-x86.tar.bz2'
}

exec { 'install android-ndk':
    command => 'tar -xjf /vagrant/android-ndk-r8e-linux-x86.tar.bz2 -C /opt;chmod -R 775 /opt/android-ndk-r8e;chgrp -R android /opt/android-ndk-r8e',
    creates => '/opt/android-ndk-r8e',
    require => [Group['android'],Exec['download android-ndk']]
}

exec { 'download android-adt-bundle':
    command => 'wget https://dl.google.com/android/adt/adt-bundle-linux-x86-20140702.zip -P /vagrant                                                                                                                                                                                                                        ',
    creates => '/vagrant/adt-bundle-linux-x86-20140702.zip'
}

exec { 'install android-adt-bundle':
    command => 'unzip /vagrant/adt-bundle-linux-x86-20140702.zip -d /opt;chmod -R 775 /opt/adt-bundle-linux-x86-20140702;chgrp -R android /opt/adt-bundle-linux-x86-20140702',
    creates => '/opt/adt-bundle-linux-x86-20140702',
    require => [Package['unzip'],Group['android'],Exec['download android-adt-bundle']]
}

notify { 'update androidk sdk':
    message => 'To update the Android SDK execute: /opt/adt-bundle-linux-x86-20140702/sdk/tools/android update sdk -u',
    require => Exec['install android-adt-bundle']
}
