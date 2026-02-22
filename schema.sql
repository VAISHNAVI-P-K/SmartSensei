-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users Table
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email VARCHAR(255) NOT NULL UNIQUE,
  name VARCHAR(255) NOT NULL,
  avatar TEXT,
  bio TEXT,
  phone VARCHAR(20),
  date_of_birth DATE,
  language VARCHAR(10) DEFAULT 'en',
  timezone VARCHAR(50) DEFAULT 'UTC',
  preferences JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Wellness Goals Table
CREATE TABLE wellness_goals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  category VARCHAR(100) NOT NULL, -- 'screen-time', 'sleep', 'exercise', etc.
  target_value NUMERIC NOT NULL,
  current_value NUMERIC DEFAULT 0,
  unit VARCHAR(50), -- 'minutes', 'hours', 'days', etc.
  status VARCHAR(50) DEFAULT 'active', -- 'active', 'completed', 'paused'
  priority VARCHAR(20) DEFAULT 'medium', -- 'low', 'medium', 'high'
  start_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  target_date TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Daily Usage Logs Table
CREATE TABLE daily_usage_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  screen_time_minutes INT DEFAULT 0,
  apps_used JSONB DEFAULT '[]',
  notifications_count INT DEFAULT 0,
  focus_sessions INT DEFAULT 0,
  breaks_taken INT DEFAULT 0,
  sleep_hours NUMERIC,
  mood_rating INT, -- 1-5 scale
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, date)
);

-- Progress Tracking Table
CREATE TABLE progress_tracking (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  goal_id UUID REFERENCES wellness_goals(id) ON DELETE SET NULL,
  date DATE NOT NULL,
  progress_value NUMERIC NOT NULL,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, goal_id, date)
);

-- Coaching Sessions Table
CREATE TABLE coaching_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  session_type VARCHAR(100) NOT NULL, -- 'mindfulness', 'motivation', 'advice', etc.
  content TEXT NOT NULL,
  recommendations JSONB DEFAULT '[]',
  ai_response TEXT,
  session_rating INT, -- 1-5 scale
  feedback TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Contact Messages Table
CREATE TABLE contact_messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  phone VARCHAR(20),
  subject VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  status VARCHAR(50) DEFAULT 'new', -- 'new', 'read', 'responded'
  response TEXT,
  responded_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Settings Table
CREATE TABLE user_settings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  notifications_enabled BOOLEAN DEFAULT TRUE,
  email_notifications BOOLEAN DEFAULT TRUE,
  push_notifications BOOLEAN DEFAULT TRUE,
  daily_reminder_time TIME DEFAULT '09:00:00',
  theme VARCHAR(20) DEFAULT 'light', -- 'light', 'dark', 'system'
  privacy_level VARCHAR(20) DEFAULT 'private', -- 'private', 'friends', 'public'
  data_sharing BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Achievements Table
CREATE TABLE achievements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  badge_name VARCHAR(255) NOT NULL,
  description TEXT,
  icon_url TEXT,
  achievement_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_wellness_goals_user ON wellness_goals(user_id);
CREATE INDEX idx_wellness_goals_status ON wellness_goals(status);
CREATE INDEX idx_daily_usage_logs_user ON daily_usage_logs(user_id);
CREATE INDEX idx_daily_usage_logs_date ON daily_usage_logs(date);
CREATE INDEX idx_progress_tracking_user ON progress_tracking(user_id);
CREATE INDEX idx_progress_tracking_goal ON progress_tracking(goal_id);
CREATE INDEX idx_coaching_sessions_user ON coaching_sessions(user_id);
CREATE INDEX idx_contact_messages_email ON contact_messages(email);
CREATE INDEX idx_user_settings_user ON user_settings(user_id);
CREATE INDEX idx_achievements_user ON achievements(user_id);

-- Create updated_at triggers
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_wellness_goals_updated_at BEFORE UPDATE ON wellness_goals
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_daily_usage_logs_updated_at BEFORE UPDATE ON daily_usage_logs
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_coaching_sessions_updated_at BEFORE UPDATE ON coaching_sessions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_settings_updated_at BEFORE UPDATE ON user_settings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security (RLS) Policies
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE wellness_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_usage_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE progress_tracking ENABLE ROW LEVEL SECURITY;
ALTER TABLE coaching_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;

-- Users RLS
CREATE POLICY "Users can view their own profile" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON users
  FOR UPDATE USING (auth.uid() = id);

-- Wellness Goals RLS
CREATE POLICY "Users can view their own goals" ON wellness_goals
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create goals" ON wellness_goals
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own goals" ON wellness_goals
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own goals" ON wellness_goals
  FOR DELETE USING (auth.uid() = user_id);

-- Daily Usage Logs RLS
CREATE POLICY "Users can view their own logs" ON daily_usage_logs
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create logs" ON daily_usage_logs
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own logs" ON daily_usage_logs
  FOR UPDATE USING (auth.uid() = user_id);

-- Coaching Sessions RLS
CREATE POLICY "Users can view their own sessions" ON coaching_sessions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create sessions" ON coaching_sessions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- User Settings RLS
CREATE POLICY "Users can view their own settings" ON user_settings
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own settings" ON user_settings
  FOR UPDATE USING (auth.uid() = user_id);