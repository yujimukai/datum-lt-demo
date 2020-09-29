# datum-lt-demo 
2020/09/28 CTO室主催LT会で行ったデモのリポジトリです。発表内容は[こちら](https://datumstudio.atlassian.net/wiki/spaces/DSEBE/pages/220889102/IaC)。

# requirement
- docker
- aws cli

# usage
[provider.tf](https://github.com/yujimukai/datum-lt-demo/blob/master/provider.tf#L3)内のattribute`provider`を適宜自分が使っているプロファイル名に変更してください。 
## build
```
docker-compose build
```
## terraform実行環境に入る
```
docker-compose run tf_lt
```
## 初期化
```
terraform init
```
## 実行計画
```
terraform plan
```
## デプロイ
```
terraform apply
```

# CI/CD
[.github/workflows](https://github.com/yujimukai/datum-lt-demo/tree/master/.github/workflows)内の`.yml`ファイルで定義します。

今回はmasterへpushされたときに`terraform init`と`terraform apply`を自動で実行します。
## secrets
AWSの認証情報はgit secretsで環境変数として定義しています。適宜自分のアカウントの認証情報を設定してください。

Setting->secretsで設定可能です(管理者権限が必要です)。

<img width="912" alt="キャプチャ" src="https://user-images.githubusercontent.com/68636577/94514765-00965b80-025d-11eb-89cd-edf5eda7ffd3.PNG">

