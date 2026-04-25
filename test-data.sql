-- 门店服务测试数据

-- 创建服务表
CREATE TABLE IF NOT EXISTS `services` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  `icon` VARCHAR(20) NOT NULL,
  `description` VARCHAR(255) NOT NULL,
  `price` DECIMAL(10,2) NOT NULL,
  `duration` VARCHAR(20) NOT NULL,
  `status` TINYINT(1) DEFAULT 1,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 创建服务详情表
CREATE TABLE IF NOT EXISTS `service_details` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `service_id` INT NOT NULL,
  `content` TEXT NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`service_id`) REFERENCES `services` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 创建预约表
CREATE TABLE IF NOT EXISTS `appointments` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `service_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `name` VARCHAR(50) NOT NULL,
  `phone` VARCHAR(20) NOT NULL,
  `appointment_time` DATETIME NOT NULL,
  `status` VARCHAR(20) DEFAULT 'pending',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`service_id`) REFERENCES `services` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 创建文章表
CREATE TABLE IF NOT EXISTS `articles` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(100) NOT NULL,
  `content` TEXT NOT NULL,
  `cover_image` VARCHAR(255),
  `read_count` INT DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 创建课程表
CREATE TABLE IF NOT EXISTS `courses` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  `description` VARCHAR(255) NOT NULL,
  `price` DECIMAL(10,2) NOT NULL,
  `duration` VARCHAR(20) NOT NULL,
  `teacher_id` INT,
  `cover_image` VARCHAR(255),
  `status` TINYINT(1) DEFAULT 1,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 创建教师表
CREATE TABLE IF NOT EXISTS `teachers` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  `avatar` VARCHAR(255),
  `title` VARCHAR(50) NOT NULL,
  `description` VARCHAR(255),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 插入服务数据
INSERT INTO `services` (`name`, `icon`, `description`, `price`, `duration`) VALUES
('婴儿洗澡', '🛁', '专业婴儿洗澡服务，包含洗浴、抚触等', 58.00, '30分钟'),
('婴儿理发', '✂️', '专业婴儿理发服务，使用安全工具', 38.00, '20分钟'),
('满月照', '📷', '专业满月照拍摄服务', 299.00, '1小时'),
('儿童游乐场', '🎠', '儿童游乐场游玩服务', 48.00, '2小时'),
('早教课程', '🎨', '专业早教课程，促进宝宝全面发展', 128.00, '45分钟');

-- 插入服务详情数据
INSERT INTO `service_details` (`service_id`, `content`) VALUES
(1, '婴儿洗澡服务包含：\n1. 温水洗浴\n2. 专业抚触\n3. 脐带护理\n4. 皮肤护理\n\n适合年龄：0-12个月\n\n注意事项：\n1. 请提前10分钟到达\n2. 请携带宝宝的换洗衣物\n3. 请勿在宝宝刚吃完奶后立即洗澡'),
(2, '婴儿理发服务包含：\n1. 专业理发工具\n2. 安全理发流程\n3. 理发后清理\n\n适合年龄：0-36个月\n\n注意事项：\n1. 请选择宝宝精神状态好的时候\n2. 理发前请勿让宝宝吃得过饱\n3. 可以提前准备一些宝宝喜欢的玩具'),
(3, '满月照服务包含：\n1. 专业摄影师拍摄\n2. 多套服装造型\n3. 精修照片\n4. 相册制作\n\n注意事项：\n1. 请提前预约\n2. 拍摄前让宝宝充分休息\n3. 请携带宝宝的换洗衣物和必需品'),
(4, '儿童游乐场服务包含：\n1. 安全游玩环境\n2. 多种游乐设施\n3. 专业人员看护\n4. 消毒清洁\n\n适合年龄：1-6岁\n\n注意事项：\n1. 请家长陪同\n2. 请穿着适合运动的服装\n3. 请勿携带尖锐物品'),
(5, '早教课程服务包含：\n1. 专业早教老师授课\n2. 互动游戏\n3. 感统训练\n4. 音乐启蒙\n\n适合年龄：6个月-3岁\n\n注意事项：\n1. 请提前10分钟到达\n2. 请家长陪同参与\n3. 请携带宝宝的水杯');

-- 插入文章数据
INSERT INTO `articles` (`title`, `content`, `cover_image`) VALUES
('新手爸爸必看：如何正确抱宝宝', '作为新手爸爸，正确抱宝宝是一项必备技能。以下是一些抱宝宝的基本技巧：\n\n1. 摇篮式抱法：\n   - 将宝宝的头部放在你的臂弯里\n   - 用另一只手托住宝宝的臀部\n   - 确保宝宝的头部和颈部得到支撑\n\n2. 橄榄球式抱法：\n   - 将宝宝的身体放在你的手臂上\n   - 宝宝的头部靠近你的肘部\n   - 用另一只手托住宝宝的头部\n\n3. 注意事项：\n   - 始终支撑宝宝的头部和颈部\n   - 避免剧烈摇晃宝宝\n   - 抱宝宝时要保持稳定', '/static/articles/dad1.png'),
('新手爸爸必看：如何给宝宝换尿布', '给宝宝换尿布是新手爸爸的必备技能，以下是步骤：\n\n1. 准备用品：\n   - 干净的尿布\n   - 湿巾\n   - 护臀霜\n   - 垃圾篓\n\n2. 换尿布步骤：\n   - 将宝宝放在平坦的表面上\n   - 解开尿布\n   - 用湿巾清洁宝宝的臀部\n   - 涂上护臀霜\n   - 换上干净的尿布\n\n3. 注意事项：\n   - 动作要轻柔\n   - 保持手部清洁\n   - 定期更换尿布', '/static/articles/dad2.png'),
('新手爸爸必看：如何给宝宝喂奶', '给宝宝喂奶是新手爸爸的重要任务，以下是步骤：\n\n1. 准备工作：\n   - 洗净双手\n   - 准备好奶瓶和奶粉\n   - 测试奶温\n\n2. 喂奶步骤：\n   - 将宝宝抱在怀里\n   - 让宝宝的头部略高于身体\n   - 轻轻将奶嘴放入宝宝口中\n   - 观察宝宝的吸吮情况\n\n3. 注意事项：\n   - 喂奶时要保持安静\n   - 不要让宝宝吃得太快\n   - 喂完后要拍嗝', '/static/articles/dad3.png');

-- 插入教师数据
INSERT INTO `teachers` (`name`, `avatar`, `title`, `description`) VALUES
('张老师', '/static/teachers/teacher1.png', '早教专家', '从事早教工作10年，拥有丰富的教学经验'),
('李老师', '/static/teachers/teacher2.png', '音乐教师', '专业音乐教育背景，擅长婴幼儿音乐启蒙'),
('王老师', '/static/teachers/teacher3.png', '感统训练师', '专注于婴幼儿感统训练，帮助宝宝全面发展');

-- 插入课程数据
INSERT INTO `courses` (`name`, `description`, `price`, `duration`, `teacher_id`, `cover_image`) VALUES
('亲子互动课', '通过亲子互动游戏，增进亲子感情，促进宝宝发育', 128.00, '45分钟', 1, '/static/courses/course1.png'),
('音乐启蒙课', '通过音乐游戏，培养宝宝的音乐感知能力', 98.00, '30分钟', 2, '/static/courses/course2.png'),
('感统训练课', '通过各种感官刺激，促进宝宝的感统发展', 158.00, '45分钟', 3, '/static/courses/course3.png'),
('语言启蒙课', '通过故事和游戏，促进宝宝的语言发展', 118.00, '40分钟', 1, '/static/courses/course4.png');

-- 插入预约数据
INSERT INTO `appointments` (`service_id`, `user_id`, `name`, `phone`, `appointment_time`, `status`) VALUES
(1, 1, '张三', '13800138000', '2026-04-26 10:00:00', 'pending'),
(2, 2, '李四', '13900139000', '2026-04-26 14:30:00', 'pending'),
(3, 3, '王五', '13700137000', '2026-04-27 09:00:00', 'pending'),
(4, 4, '赵六', '13600136000', '2026-04-27 15:00:00', 'pending'),
(5, 5, '钱七', '13500135000', '2026-04-28 10:30:00', 'pending');
