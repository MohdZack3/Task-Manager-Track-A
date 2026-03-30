from pydantic import BaseModel
from datetime import date
from typing import Optional

class TaskCreate(BaseModel):
    title: str
    description: str
    due_date: date
    status: str
    blocked_by: Optional[int] = None

class Task(TaskCreate):
    id: int

    class Config:
        orm_mode = True