<div align="center">

![](https://github.com/user-attachments/assets/142e794a-6f33-47c3-a48a-faaa094c0108)

# DB-UI Playground

## DB-UI with PostgreSQL Sample Database

![Docker](https://img.shields.io/badge/docker-blue?logo=docker)
![PostgreSQL](https://img.shields.io/badge/postgresql-15-blue?logo=postgresql)
![db-ui](https://img.shields.io/badge/db--ui-latest-brightgreen)

</div>

このプロジェクトは、db-uiとサンプルデータを含むPostgreSQLデータベースをDocker Composeで簡単にセットアップできる構成です。


## 🚀 クイックスタート

### 1. ファイルの準備

以下のファイルを同じディレクトリに配置してください：

- `docker-compose.yml`
- `init-db.sql`

### 2. 起動

```bash
# バックグラウンドで起動
docker-compose up -d

# ログを確認したい場合
docker-compose up
```

### 3. アクセス

- **DB-UI**: http://localhost:3000
- **PostgreSQL**: localhost:5432

## 📊 サンプルデータベース構造

### テーブル構成

- **users** - ユーザー情報
- **categories** - 商品カテゴリ
- **products** - 商品情報
- **orders** - 注文情報
- **order_items** - 注文詳細

### サンプルデータ

- 5人のユーザー
- 5つのカテゴリ
- 10個の商品
- 5つの注文（合計9個の注文アイテム）

### ビュー

- **order_summary** - 注文サマリー
- **product_sales** - 商品売上統計

## 🔧 設定情報

### データベース接続情報

- **ホスト**: localhost
- **ポート**: 5432
- **データベース名**: sampledb
- **ユーザー名**: dbuser
- **パスワード**: dbpassword

### 環境変数のカスタマイズ

`docker-compose.yml`ファイルの環境変数を変更することで設定をカスタマイズできます：

```yaml
environment:
  POSTGRES_DB: your_database_name
  POSTGRES_USER: your_username
  POSTGRES_PASSWORD: your_password
  # Groq API (オプション)
  # GROQ_API_KEY: your_groq_api_key
  # GROQ_MODEL: llama-3.1-70b-versatile
```

## 🛠️ 操作例

### 基本的なクエリ例

```sql
-- 全ユーザーを表示
SELECT * FROM users;

-- 商品と価格を表示
SELECT name, price FROM products ORDER BY price DESC;

-- 注文サマリーを表示
SELECT * FROM order_summary;

-- カテゴリ別商品数
SELECT c.name, COUNT(p.id) as product_count 
FROM categories c 
LEFT JOIN products p ON c.id = p.category_id 
GROUP BY c.name;
```

### 管理操作

```bash
# コンテナの状態確認
docker-compose ps

# ログの確認
docker-compose logs db-ui
docker-compose logs postgres

# 停止
docker-compose down

# 完全削除（データも含む）
docker-compose down -v
```

## 🎯 DB-UIの機能

- **テーブルブラウザ**: 直感的なインターフェースでデータを表示・編集
- **SQLエディタ**: シンタックスハイライト付きクエリエディタ
- **スキーマビューア**: データベース構造の可視化
- **データエクスポート**: CSV形式でのデータエクスポート
- **フィルタリング**: 高度なフィルタリングとソート機能

## 📝 トラブルシューティング

### ポートが既に使用されている場合

`docker-compose.yml`のポート番号を変更してください：

```yaml
ports:
  - "3001:3000"  # db-ui
  - "5433:5432"  # postgres
```

### データベース接続エラー

1. PostgreSQLコンテナが正常に起動しているか確認
2. ヘルスチェックが通っているか確認
3. 環境変数が正しく設定されているか確認

### データの永続化

データはDockerボリューム`postgres_data`に保存されます。コンテナを削除してもデータは保持されます。

