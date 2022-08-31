# dark-kuins.net-infra

## tools

### itamae

``` sh
cd itamae/

bundle exec hocho apply servername --dry-run
bundle exec hocho apply servername
```

## iii.dark-kuins.netのRR追加方法

`iii/iii.json` に足してpushするとR53についてはActionsで更新される。
Cloud DNSのほうの更新はなんかうまく動いていないから直して……。
