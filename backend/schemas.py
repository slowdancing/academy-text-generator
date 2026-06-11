from pydantic import BaseModel
from typing import List


class TestResult(BaseModel):
    unit: str
    total: int
    correct: int


class ReportInput(BaseModel):
    student_name: str
    grade: str
    week: str
    attendance: str
    books: str
    units: List[str]
    homework_submit: str
    homework_quality: str
    attitude: str
    test_results: List[TestResult]
    weak_points: str
    plan: str