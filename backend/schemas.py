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
    reference_note: str = ""
    # 아래 두 값이 함께 채워지면, 코멘트를 새로 쓰지 않고 previous_comment를
    # revision_request(선생님이 자연어로 적은 수정 지시)에 맞춰 다듬는다.
    previous_comment: str = ""
    revision_request: str = ""