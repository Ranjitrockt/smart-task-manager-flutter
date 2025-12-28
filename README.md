Smart Task Manager is a full-stack task management application that automatically
classifies and prioritizes tasks based on their content.  
The system analyzes task descriptions to detect category, priority, extract key
entities, and suggest relevant actions, providing a productivity-focused experience.
Project Overview

This project is a Smart Task Management System built to demonstrate full-stack development capabilities as required by the developer assessment. The application's architecture is centered around a powerful and intelligent backend, supported by a functional and clean Flutter mobile interface.
Backend Architecture (Core Expertise)
My primary focus and expertise lie in backend development, and this project heavily reflects that. The backend was built using Java and the Spring Boot framework, following modern software engineering principles.
Intelligent Services: The core logic resides in the backend, which automatically classifies tasks by category (e.g., Scheduling, Finance) and priority (High, Medium, Low) through content analysis. It also generates contextual suggested actions.
Robust API: A complete RESTful API was designed and implemented with clear, logical endpoints for all CRUD (Create, Read, Update, Delete) operations, including pagination and filtering.
•
Database Design: The system uses a PostgreSQL database with a normalized schema, including a task_history table to ensure a complete audit trail for every task.
•
Deployment & DevOps: The entire backend, along with its database, is professionally deployed on Render, demonstrating my ability to manage the full lifecycle of a service from development to live deployment.

/*Frontend Development Learning Challenge
While my core strength is the backend, I enthusiastically took on the challenge of building the frontend with Flutter. This part of the assessment was a significant learning opportunity for me.
I am not a Flutter expert, and building a polished, production-ready mobile UI was a difficult task. However, I was determined to complete the full-stack challenge. I successfully implemented the required features, including the task dashboard, state management with Riverpod, and API integration using Dio. This experience has proven my ability to quickly learn new technologies and adapt to the requirements of a hybrid role.
I am confident that my strong foundation in backend architecture, combined with my proven ability to tackle and deliver on new challenges like the Flutter frontend, makes me a strong candidate for this internship. I am eager to continue learning and growing in a professional environment.

## Tech Stack

### Backend
- Java Spring Boot
- PostgreSQL (Supabase)
- Hibernate / JPA
- Swagger (OpenAPI)
- Render (Deployment)

### Frontend
- Flutter (Material Design 3)
- Dart
- Dio (API calls)
- Provider (State management)

### Tools
- Git & GitHub
- Postman / Swagger UI
🌐 
## Live Backend URL

https://smart-task-manager-backend-5.onrender.com

Swagger UI:
https://smart-task-manager-backend-5.onrender.com/swagger-ui.html
🔌 4️⃣ API Endpoints (request / response)

## API Endpoints

### Create Task
**POST** `/api/tasks`

Request:
```json
{
  "title": "Urgent meeting with client",
  "description": "Schedule a meeting today to discuss invoice payment",
  "assignedTo": "Ranjit",
  "dueDate": "2025-12-29T10:00:00"
}
Response:

json

{
  "id": "uuid",
  "category": "scheduling",
  "priority": "high",
  "status": "pending",
  "suggestedActions": ["Block calendar", "Send invite"]
}
Get Tasks (Pagination)
GET /api/tasks?page=0&size=5

Update Task
PATCH /api/tasks/{id}

Delete Task
DELETE /api/tasks/{id}

Get Task with History
GET /api/tasks/{id}

pgsql

## 🗄 5️⃣ Database Schema
Yahan **table structure likhna hota hai**, SQL optional.


## Database Schema

### tasks
- id (UUID, PK)
- title (text)
- description (text)
- category (scheduling, finance, technical, safety, general)
- priority (high, medium, low)
- status (pending, in_progress, completed)
- assigned_to (text)
- due_date (timestamp)
- extracted_entities (jsonb)
- suggested_actions (jsonb)
- created_at (timestamp)
- updated_at (timestamp)

### task_history
- id (UUID, PK)
- task_id (FK → tasks.id)
- action (created, updated, status_changed)
- old_value (jsonb)
- new_value (jsonb)
- changed_by (text)
- changed_at (timestamp)
