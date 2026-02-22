#!/bin/bash

# Install dependencies
npm install

# Set up environment variables
# Create .env.local file with:
# VITE_SUPABASE_PROJECT_ID=your_project_id
# VITE_SUPABASE_PUBLISHABLE_KEY=your_key
# VITE_SUPABASE_URL=your_url

# Run database migrations in Supabase SQL editor
# Copy and paste the content from database/schema.sql

# Start development server
npm run dev

# Build for production
npm run build

# Deploy
npm run build && npm run preview