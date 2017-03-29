Veewee::Session.declare({
  :cpu_count => '1',
  :memory_size=> '384',
  :disk_size => '10140',
  :disk_format => 'VDI',
  :hostiocache => 'off',
  :os_type_id => 'Ubuntu',
  :iso_file => "ubuntu-12.04.1-server-i386.iso",
  :iso_src => "http://releases.ubuntu.com/12.04/ubuntu-12.04.1-server-i386.iso",
  :iso_md5 => "3daaa312833a7da1e85e2a02787e4b66",
  :iso_download_timeout => "1000",
  :boot_wait => "10",
  :boot_cmd_sequence => [
    '<Esc><Esc><Enter>',
    '/install/vmlinuz noapic preseed/url=http://%IP%:%PORT%/preseed.cfg ',
    'debian-installer=en_US auto locale=en_US kbd-chooser/method=us ',
    # this can be anything but needs to be consistent with the /etc/hostname templates
    # installed in travis cookbooks (travis_build_environment, to be specific). The reason for this is
    # that some services may use hostname for self-configuration during installation, for example, RabbitMQ
    # does it. Then if hostname changse after reboot, said services may fail in very obscure ways. MK.
    'hostname=nettuno ',
    'fb=false debconf/frontend=noninteractive ',
    'keyboard-configuration/layout=USA keyboard-configuration/variant=USA console-setup/ask_detect=false ',
    'initrd=/install/initrd.gz -- <Enter>'
  ],
  :kickstart_port => "7122",
  :kickstart_timeout => "10000",
  :kickstart_file => "preseed.cfg",
  :ssh_login_timeout => "10000",
  :ssh_user => "vagrant",
  :ssh_password => "vagrant",
  :ssh_key => "",
  :ssh_host_port => "7222",
  :ssh_guest_port => "22",
  :sudo_cmd => "echo '%p'|sudo -S sh '%f'",
  :shutdown_cmd => "shutdown -P now",
  :postinstall_files => [ "postinstall.sh"],
  :postinstall_timeout => "10000"
})
