# 🚀 Task Manager App (Track A)

## 📌 Overview
This is a full-stack Task Manager application built using **Flutter (frontend)** and **FastAPI (backend)**.  
The app allows users to manage tasks efficiently with advanced features like recurring tasks.

---
 
## ✅ Track & Stretch Goals
- Track Chosen: Track A (Full Stack Task Manager)

---

### ✅ Stretch Goals Implemented:
- Recurring Tasks Logic
-	Debounced Autocomplete Search 

---

## 🚀 Features

### ✅ Core Features (Track A)
- Create, Read, Update, Delete (CRUD) tasks
- Task status management (To-Do, In Progress, Done)
- Due date selection
- Blocked tasks (dependency handling)

---

### 🔁 Stretch Feature: Recurring Tasks
- Mark tasks as **recurring**
- Choose recurrence type:
  - Daily
  - Weekly
- When a recurring task is marked as **Done**, a new task is automatically created with the next due date

---

### 🔍 Bonus Feature: Debounced Search with Highlight
- Search tasks in real-time
- Debounced input (300ms delay)
- Matching text is highlighted in results

---

#### ⏳ Async UX Handling
- 2-second delay simulated on create/update APIs
- UI remains responsive
- Loading indicator shown
- Prevents multiple clicks on Save button

---

## 🛠 Tech Stack

| Layer       | Technology |
|------------|------------|
| Frontend   | Flutter |
| Backend    | FastAPI |
| Database   | SQLite |
| State Mgmt | Provider |

---

## ⚙️ Setup Instructions

---

### 🔧 Backend Setup (FastAPI)

```bash
cd backend

# Create virtual environment
python -m venv venv

# Activate (Windows)
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run server
uvicorn main:app --reload

# Backend runs at:
http://127.0.0.1:8000

---

### 🔧 Frontend Setup (Flutter)

#In bash
cd task_manager

flutter pub get

flutter run