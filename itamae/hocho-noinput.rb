# TTY の無い環境(CI・自動化・AIエージェント等)で hocho を回すための shim。
#
# hocho の apply は config の ask_sudo_password が true だと起動時に
#   $stdin.noecho { $stdin.gets.chomp }
# で sudo パスワードを読む。TTY が無いと noecho が Errno::ENODEV で落ちる。
# この shim は noecho を素通りさせ gets に空文字を返させることで、対象ホストが
# NOPASSWD sudo(各ホストの ask_sudo_password: false 相当)なら空パスワードで通す。
#
# 使い方(itamae/ ディレクトリから):
#   bundle exec ruby hocho-noinput.rb apply -n servername   # dry-run
#   bundle exec ruby hocho-noinput.rb apply    servername   # 本番
class << $stdin
  def noecho
    yield
  end

  def gets
    "\n"
  end
end

load Gem.bin_path('hocho', 'hocho')
