# 同一リリース内のセキュリティ更新を自動適用する。
# メジャーリリース移行(例: bookworm -> trixie)は対象外。それは手動でやること。
#
# メール通知の宛先は node[:unattended_upgrades][:mail] で注入する。
# 例) node.reverse_merge!(unattended_upgrades: { mail: 'nana' })
# 宛先はローカルの postfix が配送するので、/etc/aliases の転送がそのまま効く
# (nana -> nna@nna774.net 等)。envelope-from は root@<mailname> になる。
node.reverse_merge!(
  unattended_upgrades: {
    mail: nil,                  # nil なら通知しない
    mail_report: 'on-change',   # always / only-on-error / on-change
  },
)

mail = node[:unattended_upgrades][:mail]

package 'unattended-upgrades'

file '/etc/apt/apt.conf.d/20auto-upgrades' do
  owner 'root'
  group 'root'
  mode '0644'
  content [
    'APT::Periodic::Update-Package-Lists "1";',
    'APT::Periodic::Unattended-Upgrade "1";',
    '',
  ].join("\n")
end

file '/etc/apt/apt.conf.d/52unattended-upgrades-mail' do
  owner 'root'
  group 'root'
  mode '0644'
  if mail
    content [
      %{Unattended-Upgrade::Mail "#{mail}";},
      %{Unattended-Upgrade::MailReport "#{node[:unattended_upgrades][:mail_report]}";},
      '',
    ].join("\n")
  else
    action :delete
  end
end

service 'unattended-upgrades' do
  action :enable
end
