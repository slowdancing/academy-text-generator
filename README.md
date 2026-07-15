# 학습 안내문 생성기 (academy-text-generator)

수학 학원(체인지수학)에서 학부모에게 보내는 주간 학습 안내문을 자동으로 만들어 주는 도구입니다.
선생님이 폼에 한 주 학습 내용을 입력하면, 정해진 서식의 안내문 문자를 만들어 주고
Gemini가 학원 말투에 맞춘 코멘트를 대신 써 줍니다.

```
※체인지수학 7월 3주차학습안내※

           ♡홍길동(중2)♡
*출결상황
  -전체 출석
*학습과정
  -쎈 수학 2-1
        연립방정식 활용
        일차함수와 그래프
*과제
  -제출완료  완성도 상
*수업태도 - 집중도 높음
*월말평가정답
  -연립방정식 : 20문항중 18개

-이번 주 길동이는 ... (AI가 작성한 코멘트)
```

## 구성

| 영역 | 스택 | 설명 |
| --- | --- | --- |
| 앱 | Flutter (Dart) | 입력 폼 + 안내문 생성 화면 |
| 서버 | FastAPI (Python) | Gemini 호출해 학부모 코멘트 작성 |

동작 순서는 이렇습니다.

1. 선생님이 앱에서 학생 정보(출결·교재/단원·과제·평가 점수·특이사항)를 입력합니다.
2. **문자 생성** 버튼 → `buildFinalReport()`가 입력값을 안내문 서식으로 조립합니다. (서버 호출 없음)
3. **AI 코멘트 생성** 버튼 → 같은 입력값을 백엔드 `POST /generate-comment`로 보내고,
   돌아온 코멘트를 코멘트 칸에 채운 뒤 안내문을 다시 만듭니다.

## 폴더 구조

```
lib/
  main.dart                    앱 진입점
  screens/report_screen.dart   입력 폼 화면 (모든 폼 상태 보유)
  services/report_api.dart     백엔드 호출 (1회 재시도, 타임아웃 60초)
  utils/report_builder.dart    안내문 문자열 조립 (서식 수정은 여기)
backend/
  main.py                      FastAPI 앱, 엔드포인트 2개
  schemas.py                   요청 스키마 (ReportInput / TestResult)
  ai_comment.py                프롬프트 생성 + Gemini 호출 (말투 수정은 여기)
  requirements.txt
```

## 실행 방법

### 백엔드

```bash
cd backend
pip install -r requirements.txt
cp .env.example .env      # .env를 열어 GEMINI_API_KEY 입력
uvicorn main:app --reload # http://127.0.0.1:8000
```

`GEMINI_API_KEY`가 없으면 `ai_comment.py`가 import 시점에 바로 에러를 냅니다.
키는 [Google AI Studio](https://aistudio.google.com/apikey)에서 발급받습니다.

### 앱

```bash
flutter pub get
flutter run
```

앱은 기본적으로 배포된 백엔드(`https://academy-text-generator-api.onrender.com`)를 바라봅니다.
로컬 서버로 붙이려면 [report_screen.dart](lib/screens/report_screen.dart#L34)의 `baseUrl`을
`http://127.0.0.1:8000`으로 바꾸세요.

## API

### `GET /`

헬스 체크. `{"message": "academy text generator backend is running"}`

### `POST /generate-comment`

요청 (`ReportInput`):

```json
{
  "student_name": "홍길동",
  "grade": "중2",
  "week": "3주차",
  "attendance": "전체 출석",
  "books": "쎈 수학 2-1",
  "units": ["연립방정식 활용"],
  "homework_submit": "성실",
  "homework_quality": "상",
  "attitude": "집중도 높음",
  "test_results": [{ "unit": "연립방정식", "total": 20, "correct": 18 }],
  "weak_points": "활용 문제 식 세우기",
  "plan": "다음 주 일차함수 진도",
  "reference_note": ""
}
```

응답: `{"comment": "..."}`

코멘트는 `gemini-2.5-flash-lite`로 먼저 시도하고, 실패하면 `gemini-2.5-flash`로
넘어갑니다. 모델당 3회까지 재시도합니다.

## 개발 메모

- **안내문 서식**을 바꾸려면 `lib/utils/report_builder.dart`를 수정합니다.
- **AI 코멘트 말투·구조**를 바꾸려면 `backend/ai_comment.py`의 `build_prompt()` 안에 있는
  예시 코멘트와 "작성 규칙" 부분을 수정합니다. 결과 품질에 가장 크게 영향을 주는 곳입니다.
- 폼에 항목을 추가할 때는 세 곳을 함께 맞춰야 합니다:
  `report_screen.dart`의 API 호출 body → `backend/schemas.py`의 `ReportInput` →
  `build_prompt()`.
- CORS는 `http://localhost:*` / `http://127.0.0.1:*`만 허용합니다. 웹으로 배포한다면
  `backend/main.py`의 `allow_origin_regex`에 해당 도메인을 추가해야 합니다.
- 정적 분석: `flutter analyze`
- `test/widget_test.dart`는 아직 Flutter 기본 템플릿이라 현재 상태로는 실패합니다.

## 라이선스

내부용 프로젝트입니다.
