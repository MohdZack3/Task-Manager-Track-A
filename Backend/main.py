from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import timedelta
from datetime import datetime
import time

from database import SessionLocal, engine
import models

from fastapi.middleware.cors import CORSMiddleware

models.Base.metadata.create_all(bind=engine)

app = FastAPI()

# ✅ CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 🔌 DB Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# 📥 GET ALL TASKS
@app.get("/tasks")
def get_tasks(db: Session = Depends(get_db)):
    return db.query(models.Task).order_by(models.Task.priority).all()


# ➕ CREATE TASK (with 2s delay)
@app.post("/tasks")
def create_task(task: dict, db: Session = Depends(get_db)):
    time.sleep(2)

    # 🔥 STEP 1: Extract date
    raw_date = task.get("due_date")

    # 🔥 STEP 2: Convert safely
    parsed_date = None
    if raw_date:
        parsed_date = datetime.strptime(raw_date, "%Y-%m-%d").date()

    # 🔥 STEP 3: Use parsed_date (NOT raw)
    new_task = models.Task(
        title=task.get("title"),
        description=task.get("description"),
        due_date=parsed_date,   # ✅ THIS IS IMPORTANT
        status=task.get("status", "To-Do"),
        blocked_by=task.get("blocked_by"),
        is_recurring=task.get("is_recurring", False),
        recurring_type=task.get("recurring_type"),
        priority=task.get("priority", 0),
    )

    db.add(new_task)
    db.commit()
    db.refresh(new_task)

    return new_task


# ✏️ UPDATE TASK (with delay + recurring logic)
@app.put("/tasks/{task_id}")
def update_task(task_id: int, task: dict, db: Session = Depends(get_db)):
    time.sleep(2)  # 🔥 REQUIRED DELAY

    db_task = db.query(models.Task).filter(models.Task.id == task_id).first()

    if not db_task:
        return {"error": "Task not found"}

    # ✅ Convert due_date string → Python date
    due_date = task.get("due_date")
    if due_date:
        due_date = datetime.strptime(due_date, "%Y-%m-%d").date()

    # ✅ Update fields
    db_task.title = task.get("title")
    db_task.description = task.get("description")
    db_task.due_date = due_date
    db_task.status = task.get("status")
    db_task.blocked_by = task.get("blocked_by")
    db_task.is_recurring = task.get("is_recurring", False)
    db_task.recurring_type = task.get("recurring_type")
    db_task.priority = task.get("priority", 0)

    db.commit()
    db.refresh(db_task)

    # 🔥 RECURRING LOGIC
    if db_task.status == "Done" and db_task.is_recurring:
        new_due_date = db_task.due_date

        if db_task.recurring_type == "daily":
            new_due_date = new_due_date + timedelta(days=1)
        elif db_task.recurring_type == "weekly":
            new_due_date = new_due_date + timedelta(days=7)

        new_task = models.Task(
            title=db_task.title,
            description=db_task.description,
            due_date=new_due_date,
            status="To-Do",
            blocked_by=None,
            is_recurring=True,
            recurring_type=db_task.recurring_type,
            priority=db_task.priority + 1,
        )

        db.add(new_task)
        db.commit()

    return db_task


# ❌ DELETE TASK
@app.delete("/tasks/{task_id}")
def delete_task(task_id: int, db: Session = Depends(get_db)):
    task = db.query(models.Task).filter(models.Task.id == task_id).first()

    if not task:
        raise HTTPException(status_code=404, detail="Task not found")

    db.delete(task)
    db.commit()

    return {"message": "Deleted"}


# 🔄 REORDER TASKS
@app.post("/tasks/reorder")
def reorder_tasks(order: list[int], db: Session = Depends(get_db)):
    for index, task_id in enumerate(order):
        task = db.query(models.Task).filter(models.Task.id == task_id).first()
        if task:
            task.priority = index

    db.commit()
    return {"message": "Order updated"}