# dark-kuins.net-infra

## tools

### itamae

``` sh
cd itamae/

bundle exec hocho apply servername --dry-run
bundle exec hocho apply servername
```

#### TTY の無い環境(CI・自動化・AIエージェント等)から

hocho は `ask_sudo_password` が true だと起動時に sudo パスワードを noecho で読むため、
TTY が無いと `Errno::ENODEV` で落ちる。対象ホストが NOPASSWD sudo(`ask_sudo_password: false`)なら
`hocho-noinput.rb` 経由で空パスワードを食わせて回せる。

``` sh
cd itamae/

bundle exec ruby hocho-noinput.rb apply -n servername   # dry-run
bundle exec ruby hocho-noinput.rb apply    servername   # 本番
```

## iii.dark-kuins.netのRR追加方法

`iii/iii.json` に足してpushするとR53についてはActionsで更新される。
Cloud DNSのほうの更新はなんかうまく動いていないから直して……。
