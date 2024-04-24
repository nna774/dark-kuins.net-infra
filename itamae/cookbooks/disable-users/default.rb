(node.dig(:disable_user, :names) || []).each do |username|
  execute 'lock user' do
    command "passwd -l #{username}"
    not_if "grep -E '^#{username}:!' /etc/shadow || grep -v -E '^#{username}:' /etc/shadow"
  end
end
