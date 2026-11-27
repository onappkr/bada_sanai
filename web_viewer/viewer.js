/*
 * 공유 링크 웹 뷰어 화면. 앱이 없는 사람이 링크를 열었을 때 포인트를 보여 준다.
 * 화면에 쓰는 값은 모두 textContent/속성 설정으로만 넣어 스크립트가 끼어들 틈을 주지 않는다.
 */

import { decodeHash } from './codec.js';

function show(id) {
  for (const el of document.querySelectorAll('main > section')) el.hidden = el.id !== id;
}

function render(p) {
  document.title = `${p.name} · 바다 사나이`;
  document.getElementById('name').textContent = p.name;
  document.getElementById('coords').textContent = `${p.lat.toFixed(5)}, ${p.lng.toFixed(5)}`;

  const genre = document.getElementById('genre');
  genre.hidden = p.genre === null;
  genre.textContent = p.genre ?? '';

  const memo = document.getElementById('memo');
  memo.hidden = p.memo === null;
  memo.textContent = p.memo ?? '';

  const q = `${p.lat},${p.lng}`;
  const label = encodeURIComponent(p.name);
  document.getElementById('google').href =
    `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(q)}`;
  document.getElementById('kakao').href = `https://map.kakao.com/link/map/${label},${q}`;
  document.getElementById('kakao-route').href = `https://map.kakao.com/link/to/${label},${q}`;

  const copy = document.getElementById('copy');
  copy.onclick = async () => {
    try {
      await navigator.clipboard.writeText(q);
      copy.textContent = '복사했어요';
    } catch (e) {
      copy.textContent = '복사하지 못했어요';
    }
    setTimeout(() => { copy.textContent = '좌표 복사'; }, 2000);
  };

  show('point');
  document.getElementById('app').hidden = false;
}

async function main() {
  try {
    render(await decodeHash(location.hash));
  } catch (e) {
    document.getElementById('error-message').textContent = e.message;
    show('error');
  }
}

// 링크를 다른 링크로 바꿔 붙여 넣는 경우에도 다시 읽는다.
window.addEventListener('hashchange', main);
main();
