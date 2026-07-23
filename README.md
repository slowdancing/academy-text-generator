# 학습 안내문 생성기 (academy-text-generator)

수학 학원에서 학부모에게 보내는 주간 학습 안내문을 자동으로 만들어 주는 도구입니다.
선생님이 폼에 한 주 학습 내용을 입력하면, 정해진 서식의 안내문 문자를 만들어 주고
Gemini가 학원 말투에 맞춘 코멘트를 대신 써 줍니다.

```
※[학원명] 7월 3주차학습안내※

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
| 서버 | FastAPI (Python), Render 배포 | Gemini 호출해 학부모 코멘트 작성 |

서버는 Render에 배포되어 상시 떠 있으므로, 앱을 쓰는 쪽에서 백엔드를 따로 실행할 필요는 없습니다.

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

**백엔드는 이미 Render에 배포되어 상시 동작 중입니다.** 앱만 실행하면 AI 코멘트까지 바로
쓸 수 있고, `uvicorn`을 따로 띄울 필요가 없습니다.

```bash
flutter pub get
flutter run
```

앱은 배포된 백엔드(`https://academy-text-generator-api.onrender.com`)를 바라보도록
[report_screen.dart](lib/screens/report_screen.dart#L34)에 `baseUrl`이 지정돼 있습니다.

> **첫 요청이 느린 이유**
> Render 무료 플랜이라 15분간 요청이 없으면 인스턴스가 잠듭니다. 그 뒤 첫 "AI 코멘트 생성"은
> 서버가 깨어나는 시간(대략 50초)만큼 기다려야 합니다. 앱은 요청당 60초 타임아웃에 1회
> 재시도하므로([report_api.dart](lib/services/report_api.dart#L50-L63)) 보통은 그 안에
> 응답이 오지만, 오랜만에 켰을 때 한 번 실패하고 두 번째에 되는 건 정상입니다.
> 두 번째 요청부터는 바로 응답합니다.

### 백엔드를 로컬에서 띄우는 경우

프롬프트나 API를 고칠 때만 필요합니다.

```bash
cd backend
pip install -r requirements.txt
cp .env.example .env      # .env를 열어 GEMINI_API_KEY 입력
uvicorn main:app --reload # http://127.0.0.1:8000
```

`GEMINI_API_KEY`가 없으면 `ai_comment.py`가 import 시점에 바로 에러를 냅니다.
키는 [Google AI Studio](https://aistudio.google.com/apikey)에서 발급받습니다.
앱을 로컬 서버에 붙이려면 `baseUrl`을 `http://127.0.0.1:8000`으로 바꾸세요.

### 배포

백엔드는 Render의 웹 서비스로 올라가 있습니다. `GEMINI_API_KEY`는 Render 대시보드의
Environment에 등록된 값을 쓰며, 로컬 `backend/.env`와는 별개입니다. 따라서 키를 교체할 때는
양쪽을 모두 바꿔야 합니다. 배포 설정(자동 배포 여부, 빌드/시작 명령)은 Render 대시보드에서
확인하세요.

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
  "reference_note": "",
  "previous_comment": "",
  "revision_request": ""
}
```

응답: `{"comment": "..."}`

`previous_comment`와 `revision_request`는 선택 필드(기본값 `""`)입니다. 둘 다 비어 있으면
입력값을 바탕으로 코멘트를 새로 씁니다. 두 값이 함께 채워지면 새로 쓰지 않고,
`previous_comment`를 `revision_request`(선생님이 자연어로 적은 수정 지시, 예: "도형 부분을
더 강조해줘")에 맞춰 다듬어 돌려줍니다. 앱의 "수정 요청 반영해 다시 생성" 버튼이 이 방식으로
동작합니다.

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
