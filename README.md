# 概要
メモアプリです。保存、削除、更新ができます。

# 手順
1. `git clone` を行なってください
2. memoフォルダに移動してください
3. PostgreSQLを使ってデータベースを作成していきます。ない方は、PostgreSQLのインストールをお願いします。
    1. PostgreSQLを起動します
    2. `create database memo_app;` memo_appというデータベースを作成していきます
    3. `\c memo_app` memo_appデータベースに移動します
    4. memosというテーブルを作成していきます。以下を入力してください。
```
create table memos
(id serial,
name varchar(30) not null,
message varchar(100) not null,
primary key (id));
```
5. `bundle exec ruby main.rb`　を行なってください
6. http://localhost:4567 にアクセスしたらメモアプリが使えます！


