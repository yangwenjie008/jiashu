-- jiashu 家族家谱应用 - 数据库初始化脚本

-- 创建数据库
CREATE DATABASE jiashu WITH ENCODING 'UTF8' LC_COLLATE 'en_US.UTF-8' LC_CTYPE 'en_US.UTF-8';

-- 连接到数据库
\c jiashu;

-- 启用UUID扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 创建家谱表
CREATE TABLE families (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    founder_id UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 创建用户表
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    avatar VARCHAR(500),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 创建成员表
CREATE TABLE members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    gender VARCHAR(20) CHECK (gender IN ('male', 'female', 'other')),
    birth_date DATE,
    death_date DATE,
    avatar VARCHAR(500),
    bio TEXT,
    generation INT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 创建关系表
CREATE TABLE relations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    member_id_1 UUID NOT NULL REFERENCES members(id) ON DELETE CASCADE,
    member_id_2 UUID NOT NULL REFERENCES members(id) ON DELETE CASCADE,
    relation_type VARCHAR(50) NOT NULL CHECK (relation_type IN (
        'parent-child', 'spouse', 'sibling', 'grandparent-grandchild'
    )),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(member_id_1, member_id_2, relation_type)
);

-- 创建媒体表
CREATE TABLE media (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    member_id UUID REFERENCES members(id) ON DELETE SET NULL,
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    file_url VARCHAR(500) NOT NULL,
    file_type VARCHAR(50) NOT NULL CHECK (file_type IN ('image', 'video', 'document')),
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 创建索引
CREATE INDEX idx_members_family_id ON members(family_id);
CREATE INDEX idx_relations_member_id_1 ON relations(member_id_1);
CREATE INDEX idx_relations_member_id_2 ON relations(member_id_2);
CREATE INDEX idx_media_family_id ON media(family_id);
CREATE INDEX idx_media_member_id ON media(member_id);

-- 创建更新时间触发器函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 为各表创建更新时间触发器
CREATE TRIGGER update_families_updated_at BEFORE UPDATE ON families
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_members_updated_at BEFORE UPDATE ON members
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 插入示例数据
INSERT INTO families (name, description) VALUES 
    ('张氏家族', '张氏家族家谱');

-- 获取刚插入的家谱ID
DO $$
DECLARE
    family_id UUID;
BEGIN
    SELECT id INTO family_id FROM families WHERE name = '张氏家族';
    
    -- 插入示例成员
    INSERT INTO members (family_id, name, gender, birth_date, generation) VALUES 
    (family_id, '张大山', 'male', '1940-01-01', 1),
    (family_id, '李秀英', 'female', '1942-05-15', 1),
    (family_id, '张明', 'male', '1965-08-20', 2),
    (family_id, '王芳', 'female', '1967-03-10', 2),
    (family_id, '张小明', 'male', '1990-12-05', 3);
END $$;

-- 完成提示
DO $$
BEGIN
    RAISE NOTICE '数据库初始化完成！';
    RAISE NOTICE '已创建表：families, users, members, relations, media';
    RAISE NOTICE '已插入示例数据';
END $$;
