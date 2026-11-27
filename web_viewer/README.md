# 공유 링크 웹 뷰어

앱이 없는 사람이 공유 링크(`https://도메인/p#v=1&d=...`)를 열었을 때 포인트를 보여 주는 정적 페이지입니다.
서버 코드가 없고 빌드도 필요 없습니다. 이 폴더를 그대로 정적 호스팅(Cloudflare Pages, GitHub Pages 등)에 올리면 됩니다.

- 포인트 정보는 주소의 `#` 뒤(fragment)에만 있어 서버로 전송되지 않습니다.
- 지원: 구글 지도, 카카오맵 보기·길찾기, 좌표 복사. 앱 설치 안내는 출시 후 채웁니다.
- 브라우저의 `DecompressionStream('deflate-raw')`가 필요합니다(최신 크롬·사파리·삼성 인터넷).
- 링크 형식은 앱의 `lib/features/share/data/share_link_codec.dart`와 같아야 합니다.
  형식을 바꾸면 `v` 값을 올리고 두 쪽을 함께 고치세요.

## 로컬에서 보기

```
cd web_viewer
python -m http.server 8766
# http://localhost:8766/index.html#v=1&d=... 로 열기
```

## 테스트

```
cd web_viewer
node --test
```

## 배포 전에 정할 것

- 공유 도메인. 정해지면 앱을 `--dart-define=SHARE_BASE_URL=https://도메인/p`로 빌드하고,
  호스팅에서 `/p`가 `index.html`을 열도록 설정하세요.
