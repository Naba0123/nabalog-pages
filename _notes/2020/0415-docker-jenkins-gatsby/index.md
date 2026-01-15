---
layout: post
title: "Docker + Jenkins で GatsbyJs ビルド環境作成"
date: 2020-04-15
---
環境構築で躓く人用と自分のためにメモ。

## 検証、構築環境
* Windows 10 Pro
  * Insider Preview 19041.207
* WSL2
  * Ubuntu-18.04
* Jenkins
  * 実行当時は 2.222.1
* node -v
  * v12.16.2
* npm -v
  * 6.14.4
* gatsby -v
  * Gatsby CLI version: 2.11.8

<!--more-->

## docker-compose ファイル

```
version: '3'
services:
  jenkins:
    image: jenkins/jenkins:lts
    volumes:
      - ./jenkins_home:/var/jenkins_home
    working_dir: /var/jenkins_home
    ports:
      - "8080:8080"
      - "50000:50000"
    tty: true
```

* Jenkins イメージは公式の LTS を指定
* コンテナ内において、 */var/jenkins_home* を Jenkins のワーキングディレクトリに指定し、データを永続化させるためにローカルの *./jenkins_home* とボリューム共有化
* ポートは基本 8080 で大丈夫だと思う。50000 番はスレーブ用らしい。

### 参考

https://qiita.com/legitwhiz/items/e6ac1f5a94f09ff2bb1d

https://tsubalog.hatenablog.com/entry/2017/08/12/090000

## コンテナ起動

コンテナとの共有用のディレクトリ作成
```
WSL $ mkdir jenkins_home
```

コンテナ起動
```
WSL $ docker-compose up
コンソールに起動時に入力するパスワードが表示されるので、必ずメモ
～
jenkins_1  | *************************************************************
jenkins_1  | *************************************************************
jenkins_1  | *************************************************************
jenkins_1  |
jenkins_1  | Jenkins initial setup is required. An admin user has been created and a password generated.
jenkins_1  | Please use the following password to proceed to installation:
jenkins_1  |
jenkins_1  | XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
jenkins_1  |
jenkins_1  | This may also be found at: /var/jenkins_home/secrets/initialAdminPassword
jenkins_1  |
jenkins_1  | *************************************************************
jenkins_1  | *************************************************************
jenkins_1  | *************************************************************
～
```
Jenkins のセットアップについては、他を参照。

https://qiita.com/zb185423/items/af2643fa6ebf0639b6ab

## Node.js インストール

コンテナにルートユーザーで入る。
```
WSL $ docker-compose exec --user root jenkins /bin/bash
```

公式のセットアップ方法を利用。
```
Conaitner # curl -sL https://deb.nodesource.com/setup_12.x | bash -
Container # apt-get install -y nodejs
```

### 参照
https://github.com/nodesource/distributions/blob/master/README.md

## GatsbyJS インストール

一旦コンテナを抜けて、jenkins ユーザーで入り直す
```
WSL $ docker-compose exec jenkins /bin/bash
```

そのままインストールしようとすると、多分 *permission denied* エラーが起きるので、インストールパスを *~/.npm-global* に変更。
global インストールしてるのは許して＞＜
```
Container $ mkdir ~/.npm-global
Container $ npm config set prefix '~/.npm-global'
Container $ vim ~/.profile
.profile 多分新規作成。下記を追加して保存
export PATH=~/.npm-global/bin:$PATH
Container $ source ~/.profile
Container $ npm install -g gatsby-cli
```

### 参照
https://qiita.com/okohs/items/ced3c3de30af1035242d

セットアップについてはこれで完了。

## GatsbyJS ビルドについて

ビルド時は、毎回 *gatsby clean* をしたほうが良いかもしれない。（Jenkins に限らずローカルでも再現した） 
勉強し初めなので理由はまだ分からないが、公式チュートリアルで一旦動くことまで確認してジョブを実行したところ、1回目は成功するが、2回目から *ERROR #98123 WEBPACK* エラーが起きてしまった。 
キャッシュデータを消さないとうまく行かないらしい？

サンプルジョブシェル
```
#!/bin/bash

source ~/.profile

cd "GatsbyJS プロジェクトパス"
npm install
gatsby clean
gatsby build

～これ以降はコミットするなりデプロイするなり～
```
* 1行目の *#!/bin/bash* は、source 行を実行するために必要
  * デフォルトシェルが sh だから？
  * https://stackoverflow.com/questions/13702425/source-command-not-found-in-sh-shell/13702876
* source 行は、先程作成した *.profile* を指定。そうしないと先程 global でインストールした gatsby コマンドが見当たらない、と言われる

### 参考
https://github.com/gatsbyjs/gatsby/issues/22755

