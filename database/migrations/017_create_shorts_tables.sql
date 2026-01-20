-- Shorts likes table
CREATE TABLE IF NOT EXISTS shorts_likes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    short_id UUID NOT NULL REFERENCES oto_shorts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    gallery_id UUID REFERENCES galleries(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(short_id, user_id)
);

-- Shorts comments table
CREATE TABLE IF NOT EXISTS shorts_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    short_id UUID NOT NULL REFERENCES oto_shorts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    gallery_id UUID REFERENCES galleries(id) ON DELETE SET NULL,
    gallery_name VARCHAR(255),
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Shorts reports table
CREATE TABLE IF NOT EXISTS shorts_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    short_id UUID NOT NULL REFERENCES oto_shorts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reason VARCHAR(100) NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'pending', -- pending, reviewed, resolved, dismissed
    reviewed_by UUID REFERENCES users(id),
    reviewed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add share_count to oto_shorts if not exists
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'oto_shorts' AND column_name = 'share_count') THEN
        ALTER TABLE oto_shorts ADD COLUMN share_count INTEGER DEFAULT 0;
    END IF;
END $$;

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_shorts_likes_short_id ON shorts_likes(short_id);
CREATE INDEX IF NOT EXISTS idx_shorts_likes_user_id ON shorts_likes(user_id);
CREATE INDEX IF NOT EXISTS idx_shorts_comments_short_id ON shorts_comments(short_id);
CREATE INDEX IF NOT EXISTS idx_shorts_comments_user_id ON shorts_comments(user_id);
CREATE INDEX IF NOT EXISTS idx_shorts_reports_short_id ON shorts_reports(short_id);
CREATE INDEX IF NOT EXISTS idx_shorts_reports_status ON shorts_reports(status);
