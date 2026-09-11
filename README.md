# MealDesk

Multi-tenant restaurant billing system built with Ruby on Rails 8, ReactJS 19, and PostgreSQL 16.

## Tech Stack
- **Backend**: Rails 8.0.4, Ruby 4.0.1, PostgreSQL 16.14
- **Frontend**: React 19.2.8, TypeScript, Vite 8.2.0, MUI 9.3.1, Tailwind CSS 4.3.3, Zustand 5.0.14

## Prerequisites
- Ruby 4.0.1+
- PostgreSQL 16+
- Node.js 20+ or Bun

## Setup — Backend
1. Navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Copy the environment variables template and configure your values:
   ```bash
   cp .env.example .env
   ```
3. Install gem dependencies:
   ```bash
   bundle install
   ```
4. Create, migrate, and seed the database:
   ```bash
   bin/rails db:create db:migrate db:seed
   ```
   5. Start the Rails application server:
   ```bash
   bin/rails server
   ```

## Setup — Frontend
1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```
2. Copy the environment variables template:
   ```bash
   cp .env.example .env
   ```
3. Install frontend dependencies (Node npm or Bun):
   ```bash
   npm install  # or bun install
   ```
4. Start the Vite development server:
   ```bash
   npm run dev  # or bun run dev
   ```
   *The development server starts on `http://localhost:5173`.*
