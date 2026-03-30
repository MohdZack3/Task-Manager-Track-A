from sqlalchemy import Column, Integer, String, Date, Boolean
from database import Base

class Task(Base):
    __tablename__ = "tasks"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    description = Column(String, nullable=False)
    due_date = Column(Date, nullable=False)
    status = Column(String, nullable=False)
    blocked_by = Column(Integer, nullable=True)
    is_recurring = Column(Boolean, default=False)
    recurring_type = Column(String, nullable=True)  # "daily" or "weekly"
    priority = Column(Integer, default=0)