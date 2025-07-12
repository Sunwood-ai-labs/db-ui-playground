-- サンプルデータベースの初期化
-- ユーザーテーブル
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);

-- カテゴリテーブル
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 商品テーブル
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    category_id INTEGER REFERENCES categories(id),
    stock_quantity INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 注文テーブル
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    total_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 注文詳細テーブル
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id),
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL
);

-- サンプルデータの挿入
INSERT INTO users (username, email, first_name, last_name) VALUES
('yamada_taro', 'yamada@example.com', '太郎', '山田'),
('suzuki_hanako', 'suzuki@example.com', '花子', '鈴木'),
('tanaka_ichiro', 'tanaka@example.com', '一郎', '田中'),
('watanabe_yuki', 'watanabe@example.com', '雪', '渡辺'),
('sato_hiroshi', 'sato@example.com', '寛', '佐藤');

INSERT INTO categories (name, description) VALUES
('電子機器', 'スマートフォン、パソコン、タブレットなどの電子機器'),
('書籍', '小説、技術書、雑誌などの書籍類'),
('衣類', '洋服、靴、アクセサリーなどのファッション商品'),
('ホーム＆ガーデン', '家具、インテリア、ガーデニング用品'),
('スポーツ', 'スポーツ用品、フィットネス器具、アウトドア用品');

INSERT INTO products (name, description, price, category_id, stock_quantity) VALUES
('スマートフォン', '最新機能搭載の高性能スマートフォン', 89999, 1, 50),
('ノートパソコン', '仕事やゲームに最適な高性能ノートPC', 149999, 1, 25),
('プログラミング入門書', '初心者向けプログラミング学習書', 2980, 2, 100),
('Tシャツ', '綿100%の着心地の良いTシャツ', 1980, 3, 200),
('ジーンズ', 'クラシックなデニムパンツ', 6980, 3, 150),
('コーヒーメーカー', '全自動コーヒー抽出マシン', 12800, 4, 30),
('テニスラケット', 'プロ仕様の軽量テニスラケット', 15800, 5, 40),
('ランニングシューズ', '軽量でクッション性抜群のランニングシューズ', 9800, 5, 80),
('タブレット', '10インチ高解像度ディスプレイタブレット', 45999, 1, 35),
('推理小説', 'ベストセラー推理小説', 1580, 2, 500);

INSERT INTO orders (user_id, total_amount, status) VALUES
(1, 94759, 'completed'),
(2, 154979, 'completed'),
(3, 25600, 'pending'),
(4, 13960, 'shipped'),
(5, 45999, 'completed');

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 89999),
(1, 4, 2, 1980),
(1, 6, 1, 12800),
(2, 2, 1, 149999),
(2, 3, 1, 2980),
(3, 7, 1, 15800),
(3, 8, 1, 9800),
(4, 5, 2, 6980),
(5, 9, 1, 45999);

-- インデックスの作成（パフォーマンス向上のため）
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);

-- ビューの作成（よく使用されるクエリのため）
CREATE VIEW order_summary AS
SELECT 
    o.id as order_id,
    u.username,
    u.email,
    o.total_amount,
    o.status,
    o.order_date,
    COUNT(oi.id) as item_count
FROM orders o
JOIN users u ON o.user_id = u.id
LEFT JOIN order_items oi ON o.id = oi.order_id
GROUP BY o.id, u.username, u.email, o.total_amount, o.status, o.order_date;

CREATE VIEW product_sales AS
SELECT 
    p.id,
    p.name,
    p.price,
    c.name as category_name,
    COALESCE(SUM(oi.quantity), 0) as total_sold,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0) as total_revenue
FROM products p
LEFT JOIN categories c ON p.category_id = c.id
LEFT JOIN order_items oi ON p.id = oi.product_id
GROUP BY p.id, p.name, p.price, c.name;

-- 売上ランキングビュー
CREATE VIEW sales_ranking AS
SELECT 
    p.name as product_name,
    c.name as category_name,
    SUM(oi.quantity) as total_quantity,
    SUM(oi.quantity * oi.unit_price) as total_sales,
    AVG(oi.unit_price) as avg_price
FROM products p
JOIN categories c ON p.category_id = c.id
JOIN order_items oi ON p.id = oi.product_id
GROUP BY p.id, p.name, c.name
ORDER BY total_sales DESC;

-- 顧客注文統計ビュー
CREATE VIEW customer_stats AS
SELECT 
    u.username,
    CONCAT(u.last_name, ' ', u.first_name) as full_name,
    u.email,
    COUNT(o.id) as total_orders,
    SUM(o.total_amount) as total_spent,
    AVG(o.total_amount) as avg_order_value,
    MAX(o.order_date) as last_order_date
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.username, u.first_name, u.last_name, u.email;