-- ============================================================
-- 🚑 你的處方箋（工單 1~5 的解法寫在這裡）
--
-- 寫法：對症下索引，例如
--   CREATE INDEX idx_xxx ON 表名 (欄位);
--
-- 提醒：
-- 1. 跑 npm run optimize 會執行這個檔案（重複執行可在 CREATE INDEX 後加上 IF NOT EXISTS）
-- 2. 如果更換新索引，原先沒有使用的索引記得 DROP（索引並非越多越好）
-- 3. 工單 6 的撰寫可到：queries/06-rewrite.sql
-- ============================================================

-- 工單 1：客服查會員
CREATE INDEX IF NOT EXISTS idx_user_email ON users (email);

-- 工單 2：企業會員的課表
CREATE
INDEX IF NOT EXISTS idx_user_id ON course_bookings (user_id, cancelled_at);

-- 工單 3：最新購買紀錄牆
CREATE
INDEX IF NOT EXISTS idx_purchase_at ON credit_purchases (purchase_at DESC);
-- 工單 4：首頁「進行中課程」
CREATE
INDEX IF NOT EXISTS idx_class_date ON courses (start_at, end_at);

-- 工單 5：上週開課課程的教練報名統計（思考方向：需新增兩個索引）
-- 目的：
-- 統計「上週開課的課程」中，每位教練有多少筆「未取消報名」
-- 拆解：
-- 1. 先找上週開課的課程
-- 1-a. 上週開課由哪個欄位決定？
--      -> courses.start_at

-- 2. 找這些課程的報名資料
-- 2-a. course_bookings 怎麼知道自己屬於哪堂課？
--      -> course_bookings.course_id
--      要對應 courses.id

-- 2-b. 哪些報名才要算？(沒被取消報名的課程)
--      -> course_bookings.cancelled_at IS NULL

-- 3. 找這堂課是哪位教練開的
-- 3-a. courses 用哪個欄位指向教練？
--      -> courses.user_id
-- 3-b. 對應 users.id

--4.這些欄位裡，哪些地方 PostgreSQL 已經有好的存取方式？哪些地方還在掃大量資料？-> EXPLAIN ANALYZE
--a.users.id → 已經有索引 → 不用重複建
--b.courses.start_at → 已經吃到 idx_class_date
--c.Parallel Seq Scan on course_bookings b Filter: cancelled_at IS NULL....這段掃很多筆資料
---WHY?
---回到 SQL：
---JOIN course_bookings b ON b.course_id = c.id
---AND b.cancelled_at IS NULL
----這代表 PostgreSQL 真正需要的不只是：所有 cancelled_at IS NULL 的 booking
----而是： 「指定那些上週 courses 的 booking，而且 booking 還沒取消。」
----所以對 course_bookings 來說，這兩個欄位其實是一起工作的：course_id + cancelled_at

CREATE
INDEX IF NOT EXISTS idx_cancelled_at ON course_bookings (course_id, cancelled_at);

-- 加分題（選做）：使用部分索引（partial index）讓工單 2 的索引更小、更有效率