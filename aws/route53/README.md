# つかいかた

```
bundle exec roadwork -a
```

でも何もしなくても、 iii.jsonを更新してpushするとGitHub ActionsでR53にはあたるようになった。
でもCloud DNSと相違が出るとマズいので、気をつけて(あっちも自動化するだけだったら簡単にできるのだけれども、Cloud IAM Conditionsで権限を絞る方法が不明なので(そもそもまだできないのでは？)自動化にふみきれない)。
