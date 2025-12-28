Smart Task Manager – Full Stack Application
📌 Project Overview

Smart Task Manager is a full-stack task management application designed to automatically classify and prioritize tasks based on their content.
The system intelligently analyzes task descriptions to determine category, priority, extract key entities, and generate relevant suggested actions, helping users stay organized and productive.

This project was developed as part of a Backend + Flutter Hybrid Developer Assessment to demonstrate real-world full-stack development skills, with a strong focus on backend architecture and system design, supported by a functional Flutter mobile interface.

🧠 Backend Architecture (Core Expertise)

My primary strength lies in backend development, and this project strongly reflects that focus.

The backend is built using Java and Spring Boot, following clean architecture principles and industry best practices.

Key Backend Highlights

Intelligent Classification Logic
Tasks are automatically classified by:

Category (Scheduling, Finance, Technical, Safety, General)

Priority (High, Medium, Low)
based on keyword and content analysis.

Entity Extraction & Suggested Actions
The backend extracts important entities (such as people, dates, or context keywords) and generates category-specific suggested actions to guide task execution.

Robust REST API
A complete RESTful API is implemented with clear and well-structured endpoints for:

Create, Read, Update, Delete (CRUD)

Pagination and sorting

Task history retrieval

Database Design
PostgreSQL is used with a normalized schema.
A dedicated task_history table ensures a complete audit trail for every task update or status change.

Deployment & DevOps
The backend and database are fully deployed on Render, demonstrating the ability to take a service from development to live production.

📱 Frontend Development (Learning Challenge)

While backend development is my core expertise, I took this assessment as an opportunity to step outside my comfort zone and build the frontend using Flutter.

Flutter was a learning challenge for me, especially building a clean and production-ready UI. Despite this, I successfully implemented all required frontend features:

Task dashboard screen

API integration using Dio

Pagination support

Loading and error states

Material Design 3 UI

Clean component structure

This experience highlights my ability to learn new technologies quickly, adapt to unfamiliar stacks, and still deliver a working full-stack solution — an essential skill for hybrid development roles.

🛠 Tech Stack
Backend

Java

Spring Boot

Hibernate / JPA

PostgreSQL (Supabase compatible)

Swagger (OpenAPI)

Render (Deployment)

Frontend

Flutter (Material Design 3)

Dart

Dio (API integration)

Provider / basic state handling

Tools

Git & GitHub

Swagger UI

Postman

🌐 Live Backend URL

Base API URL

https://smart-task-manager-backend-5.onrender.com


Swagger UI

https://smart-task-manager-backend-5.onrender.com/swagger-ui.html

🔌 API Endpoints (Request / Response Examples)
➕ Create Task

POST /api/tasks

Request

{
  "title": "Urgent meeting with client",
  "description": "Schedule a meeting today to discuss invoice payment",
  "assignedTo": "Ranjit",
  "dueDate": "2025-12-29T10:00:00"
}


Response

{
  "id": "uuid",
  "category": "scheduling",
  "priority": "high",
  "status": "pending",
  "suggestedActions": [
    "Block calendar",
    "Send invite"
  ]
}

📄 Get Tasks (Pagination)

GET /api/tasks?page=0&size=5

✏️ Update Task

PATCH /api/tasks/{id}

🗑 Delete Task

DELETE /api/tasks/{id}

📜 Get Task with History

GET /api/tasks/{id}

🗄 Database Schema
tasks

id (UUID, Primary Key)

title (text)

description (text)

category (scheduling, finance, technical, safety, general)

priority (high, medium, low)

status (pending, in_progress, completed)

assigned_to (text)

due_date (timestamp)

extracted_entities (jsonb)

suggested_actions (jsonb)

created_at (timestamp)

updated_at (timestamp)

task_history

id (UUID, Primary Key)

task_id (Foreign Key → tasks.id)

action (created, updated, status_changed, completed)

old_value (jsonb)

new_value (jsonb)

changed_by (text)

changed_at (timestamp)

▶️ How to Run Locally
Backend
 backend-repo-url https://github.com/Ranjitrockt/smart-task-manager-backend-.
cd backend
mvn spring-boot:run

Flutter (Web – easiest)
 flutter-repo-url  https://github.com/Ranjitrockt/smart-task-manager-flutter
cd smart_task_manager_ui
flutter pub get
flutter run -d chrome
