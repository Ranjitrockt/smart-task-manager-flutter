Smart Task Manager is a full-stack task management application that automatically
classifies and prioritizes tasks based on their content.  
The system analyzes task descriptions to detect category, priority, extract key
entities, and suggest relevant actions, providing a productivity-focused experience.

This project was built as part of the Backend + Flutter Hybrid Developer Assessment.
🛠 2️⃣ Tech Stack
Sirf bullet points me likhna hota hai.

md
Copy code
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
🌐 3️⃣ Live Backend URL (Render)
Yahan sirf URL + short line.

md
Copy code
## Live Backend URL

https://smart-task-manager-backend-5.onrender.com

Swagger UI:
https://smart-task-manager-backend-5.onrender.com/swagger-ui.html
🔌 4️⃣ API Endpoints (request / response)
Ye interviewer sabse zyada dekhta hai.

md
Copy code
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
Copy code
{
  "id": "uuid",
  "category": "scheduling",
  "priority": "high",
  "status": "pending",
  "extractedEntities": ["client", "invoice"],
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
Copy code

---

## 🗄 5️⃣ Database Schema
Yahan **table structure likhna hota hai**, SQL optional.

```md
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
