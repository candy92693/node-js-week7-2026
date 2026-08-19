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
CREATE INDEX IF NOT EXISTS idx_user_id ON course_bookings (user_id);
-- 工單 3：最新購買紀錄牆

-- 工單 4：首頁「進行中課程」

-- 工單 5：上週開課課程的教練報名統計（思考方向：需新增兩個索引）

-- 加分題（選做）：使用部分索引（partial index）讓工單 2 的索引更小、更有效率