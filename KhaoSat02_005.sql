CREATE DATABASE IF NOT EXISTS db_football;
USE db_football;

CREATE TABLE Teams (
	team_id VARCHAR(5) PRIMARY KEY,
	team_name VARCHAR(100) UNIQUE NOT NULL,
	stadium VARCHAR(100) NOT NULL,
	coach VARCHAR(100) NOT NULL,
	market_value DECIMAL(15,2) NOT NULL,
	status VARCHAR(20) NOT NULL
);

CREATE TABLE Players (
	player_id VARCHAR(5) PRIMARY KEY,
	full_name VARCHAR(100) NOT NULL,
	position VARCHAR(50) NOT NULL,
	nationality VARCHAR(50) NOT NULL,
	team_id VARCHAR(5),
    FOREIGN KEY (team_id) REFERENCES Teams(team_id),
	salary DECIMAL(15,2) NOT NULL
);

CREATE TABLE Matches (
	match_id INT PRIMARY KEY AUTO_INCREMENT,
	team_id VARCHAR(5),
    FOREIGN KEY (team_id) REFERENCES Teams(team_id),
	opponent_name VARCHAR(100) NOT NULL,
	match_date DATETIME NOT NULL,
	ticket_sold INT
);

CREATE TABLE Statistics (
	stat_id INT PRIMARY KEY AUTO_INCREMENT,
	match_id INT,
    FOREIGN KEY (match_id) REFERENCES Matches(match_id),
	player_id VARCHAR(5),
    FOREIGN KEY (player_id) REFERENCES Players(player_id),
	goals INT NOT NULL,
	assists INT NOT NULL
);

# Thêm ràng buộc cho cột market_value: giá trị đội hình phải lớn hơn 0.
ALTER TABLE Teams
ADD CHECK(market_value > 0);

# Thiết lập giá trị mặc định cho cột status là 'Active'.
ALTER TABLE Teams
MODIFY COLUMN status VARCHAR(20) DEFAULT 'Active';

# Thêm cột birth_year (INT) vào bảng Players.
ALTER TABLE Players
ADD COLUMN birth_year INT;

-- ----------------------------------------------------------------------------------------------------- --

INSERT INTO Teams VALUES
('T01', 'Manchester City', 'Etihad', 'Pep Guardiola', 1200000000.00, 'Active'), 
('T02', 'Arsenal', 'Emirates', 'Mikel Arteta', 1100000000.00, 'Active'), 
('T03', 'Liverpool', 'Anfield', 'Arne Slot', 900000000.00, 'Active'), 
('T04', 'Manchester United', 'Old Trafford', 'Erik ten Hag', 850000000.00, 'Suspended'), 
('T05', 'Chelsea', 'Stamford Bridge', 'Enzo Maresca', 950000000.00, 'Active');  

INSERT INTO Players VALUES
('P01', 'Erling Haaland', 'Tiền đạo', 'Na Uy', 'T01', 400000.00, 2000), 
('P02', 'Bukayo Saka', 'Tiền vệ', 'Anh', 'T02', 300000.00, 2001), 
('P03', 'Mohamed Salah', 'Tiền đạo', 'Ai Cập', 'T03', 350000.00, 1992), 
('P04', 'Bruno Fernandes', 'Tiền vệ', 'Bồ Đào Nha', 'T04', 250000.00, 1994), 
('P05', 'Cole Palmer', 'Tiền đạo', 'Anh', 'T05', 150000.00, 2002);  

INSERT INTO Matches VALUES
(1, 'T01', 'Arsenal', '2025-11-10 20:00:00', 55000), 
(2, 'T03', 'Manchester United', '2025-11-12 18:30:00', 60000), 
(3, 'T05', 'Manchester City', '2025-11-15 22:00:00', 40000), 
(4, 'T02', 'Liverpool', '2025-12-01 21:00:00', 60000);

INSERT INTO Statistics VALUES
(1, 1, 'P01', 2, 0),
(2, 1, 'P02', 1, 1), 
(3, 2, 'P03', 1, 0), 
(4, 3, 'P01', 1, 0),
(5, 3, 'P05', 0, 1);

# Cập nhật coach của đội bóng 'T04' thành 'Ruud van Nistelrooy'.
UPDATE Teams
SET coach = 'Ruud van Nistelrooy'
WHERE team_id = 'T04';

# Tăng lương tuần (salary) thêm 10% cho tất cả cầu thủ có quốc tịch 'Anh'.
UPDATE Players
SET salary = salary * 1.1
WHERE nationality = 'Anh';

# Xóa các thống kê (Statistics) của cầu thủ không ghi bàn và không kiến tạo (goals = 0 và assists = 0).
DELETE FROM Statistics
WHERE goals = 0 AND assists = 0;

# Cập nhật status của các đội bóng có giá trị đội hình dưới 900,000,000 thành 'Relegated'.
UPDATE Teams
SET status = 'Relegated'
WHERE market_value < 900000000;

# Cập nhật ticket_sold thành 0 cho các trận đấu diễn ra trong tháng 11/2025 mà số vé đang để trống (NULL). 
UPDATE Matches
SET ticket_sold = 0
WHERE (MONTH(match_date) = 11 AND YEAR(match_date) = 2025) AND ticket_sold IS NULL;

-- ----------------------------------------------------------------------------------------------------- --

# Liệt kê các cầu thủ có mức lương tuần từ 200,000 đến 400,000 Euro.
SELECT * FROM Players
WHERE salary BETWEEN 200000 AND 400000;

# Lấy full_name, position của cầu thủ có họ 'b'.
SELECT full_name, position FROM Players
WHERE full_name LIKE '%b%';

# Hiển thị team_name, stadium, sắp xếp theo market_value giảm dần.
SELECT team_name, stadium FROM Teams
ORDER BY market_value DESC;

# Lấy ra 3 cầu thủ trẻ nhất (dựa trên birth_year).
SELECT * FROM Players
ORDER BY birth_year DESC
LIMIT 3;

# Hiển thị danh sách các trận đấu diễn ra trong tháng 11/2025.
SELECT * FROM Matches
WHERE MONTH(match_date) = 11 AND YEAR(match_date) = 2025;

# Tìm đội bóng có tên bắt đầu bằng 'Man' hoặc kết thúc bằng 'City'.
SELECT * FROM Teams
WHERE team_name LIKE 'Man%' OR '%City';

# Lấy thông tin cầu thủ có số bàn thắng trong một trận đấu từ 1 đến 3 bàn.
SELECT p.* FROM Players AS p
JOIN Statistics AS s ON p.player_id = s.player_id
WHERE s.goals BETWEEN 1 AND 3;

# Sắp xếp danh sách đội bóng theo tên sân vận động (stadium) từ A-Z..
SELECT * FROM Teams 
ORDER BY stadium;

# Hiển thị match_id, full_name (cầu thủ), goals, match_date của các cầu thủ thuộc quốc tịch 'Na Uy'.
SELECT m.match_id, p.full_name, s.goals, m.match_date
FROM Statistics AS s
JOIN Matches AS m ON s.match_id = m.match_id
JOIN Players AS p ON s.player_id = p.player_id
WHERE p.nationality = 'Na Uy';

# Thống kê mỗi quốc tịch (nationality) hiện có bao nhiêu cầu thủ trong giải đấu.
SELECT nationality, COUNT(nationality) AS total_player FROM Players
GROUP BY nationality;

# Liệt kê tên đội bóng và tổng số trận đấu mà họ đã tham gia với tư cách là đội chủ nhà (hiển thị cả đội chưa đá trận chủ nhà nào).
SELECT t.team_name, COUNT(m.team_id) AS matches FROM Teams AS t
LEFT JOIN Matches AS m ON t.team_id = m.team_id
GROUP BY t.team_name;

# Tìm các cầu thủ chưa từng ghi bàn hoặc kiến tạo trong bất kỳ trận đấu nào.
SELECT p.* FROM Players AS p
JOIN Statistics AS s ON p.player_id = s.player_id
WHERE s.goals = 0 or s.assists = 0;

# Tính tổng số tiền lương tuần mà mỗi đội bóng phải chi trả (dựa trên danh sách cầu thủ hiện có).
SELECT t.team_name, SUM(p.salary) AS total_salary FROM Teams AS t
JOIN Players AS p ON t.team_id = p.team_id
GROUP BY t.team_name;

# Hiển thị tên các cầu thủ đã từng ghi bàn trong từ 2 trận đấu khác nhau trở lên.
SELECT p.full_name FROM Players AS p
JOIN Statistics AS s ON p.player_id = s.player_id
GROUP BY p.full_name
HAVING COUNT(p.player_id) >= 2;

# Tìm cầu thủ có mức lương tuần cao nhất giải đấu.
SELECT * FROM Players
ORDER BY salary DESC
LIMIT 1;

# Liệt kê thông tin các trận đấu có sự tham gia của đội 'Manchester City' và có số vé bán ra trên 50,000.  
SELECT m.* FROM Matches AS m
JOIN Teams AS t ON m.team_id = t.team_id
WHERE (t.team_name = 'Manchester City' OR m.opponent_name = 'Manchester City') AND ticket_sold >50000;
