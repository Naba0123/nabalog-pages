---
layout: post
title: "Laradock を使った Jenkins が起動しない"
date: 2019-11-15
---
## 記事の概要

Laradock を使用して Jenkins を起動する際に、起動直後にコンテナが Exit してしまう現象と解決策

### 記事の環境

* Windows 10 Pro 1903 (Windows 10 May 2019 Update)
  * Docker for Windows 2.1.0.4 
* Laradock 8.0.0

<!--more-->

## Exit してしまう状況

Windows 環境で Laradock を clone し、そこから jenkins コンテナを立ち上げると、すぐにコンテナが閉じてしまう現象に陥った。
```
$ docker-compose up -d --build jenkins
（中略）
Successfully built a96c9f074be1
Successfully tagged laradock_jenkins:latest
Creating laradock_jenkins_1 ... done
```

コンテナの状況を確かめる。コンテナが終了してしまっている
```
$ docker ps -a
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                      PORTS               NAMES
f868ae118d24        laradock_jenkins    "/bin/tini -- /usr/l…"   15 seconds ago      Exited (1) 14 seconds ago                       laradock_jenkins_1
```

コンテナのログを確認してみる。
```
$ docker logs laradock_jenkins_1
: invalid option
```

なんだこりゃ。

## 解決策

原因は、Windows で Laradock を clone してきたときの改行コードの設定であり、
git config の **core.autocrlf** が **true** の場合、改行コードが **CR+LF**になり、その影響でエラーが起きているようで、 
**autocrlf** を **false** にした上で再度 laradock をクローンし直す。
```
git config --global core.autocrlf false
```

詳しい原因は調べたけど突き詰められなかった。
**invalid option** なので、何かしらの設定ファイルの改行コード周りなのかな、と思います。

### 参考

https://github.com/laradock/laradock/issues/1861

