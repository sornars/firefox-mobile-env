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

exec { 'apt-get update':
}

package { 'unzip':
    ensure => present,
    require => Exec['apt-get update']
}

package { 'openjdk-7-jdk':
    ensure => present,
    require => Exec['apt-get update']
}

package { 'ant':
    ensure => present,
    require => Exec['apt-get update']
}

package { 'mercurial':
    ensure => present,
    require => Exec['apt-get update']
}

package { 'ccache':
    ensure => present,
    require => Exec['apt-get update']
}

package { 'python-dev':
    ensure => present,
    require => Exec['apt-get update']
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

# notify { 'update android sdk':
#     message => 'To update the Android SDK execute: /opt/adt-bundle-linux-x86-20140702/sdk/tools/android update sdk -u',
#     require => Exec['install android-adt-bundle']
# }

# notify { 'update android adb':
#     message => 'To update the Android Device Bridge execute: /opt/adt-bundle-linux-x86-20140702/sdk/tools/android update adb -u',
#     require => Exec['install android-adt-bundle']
# }

# notify { 'list android sdk updates':
#     message => 'To update the Android Device Bridge execute: /opt/adt-bundle-linux-x86-20140702/sdk/tools/android list sdk -a',
#     require => Exec['install android-adt-bundle']
# }

exec { 'install minimum sdk':
    command => 'echo y | /opt/adt-bundle-linux-x86-20140702/sdk/tools/android update sdk -u -a -t 3,2,1,113,118,20',
    require => Exec['install android-adt-bundle']
}

exec { 'clone mozilla repository':
    command => 'hg clone http://hg.mozilla.org/mozilla-central/ /home/vagrant/mozilla/src',
    creates => '/home/vagrant/mozilla/src',
    timeout => 0,
    require => Package['mercurial']
}

file { '/home/vagrant/mozilla/src/.mozconfig':
    replace => 'no',
    source => '/vagrant/.mozconfig',
    group => 'android',
    require => Exec['clone mozilla repository']
}

exec { 'ccache --max-size 4G':
    require => Package['ccache']
}

