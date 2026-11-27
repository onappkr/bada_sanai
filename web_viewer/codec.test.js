import assert from 'node:assert/strict';
import test from 'node:test';
import { deflateRawSync } from 'node:zlib';

import { base64UrlToBytes, decodeHash, validatePoint } from './codec.js';

function makeHash(payload, { v = '1' } = {}) {
  const json = typeof payload === 'string' ? payload : JSON.stringify(payload);
  const d = deflateRawSync(Buffer.from(json, 'utf-8'))
    .toString('base64url');
  return `#v=${v}&d=${d}`;
}

const sample = { n: '영도 방파제 끝', la: 35.0779, ln: 129.0868, g: 'lure', m: '새벽 만조에 농어' };

test('base64url: 패딩 없는 입력과 -_ 문자를 읽는다', () => {
  assert.deepEqual([...base64UrlToBytes('-_-_')], [...Buffer.from('-_-_', 'base64url')]);
  assert.deepEqual([...base64UrlToBytes('YQ')], [0x61]); // "a"
});

test('링크를 풀어 포인트로 만든다', async () => {
  const p = await decodeHash(makeHash(sample));
  assert.deepEqual(p, {
    name: '영도 방파제 끝',
    lat: 35.0779,
    lng: 129.0868,
    genre: '루어',
    memo: '새벽 만조에 농어',
  });
});

// 앱(Dart)의 ShareLinkCodec이 실제로 만든 링크. 두 구현이 서로 호환되는지 확인한다.
test('Dart 앱이 만든 링크를 읽는다', async () => {
  const fromApp =
    '#v=1&d=q1bKU7JSerNzzquta15taFB4M7Xn9YIlb5Y0KLzasP71hilv5rQo6SjlJCpZGZvqGZoCmUD1hkaWeoZGOkrpQK3JicUlQBW5IFN6N7xes0fh9dQehTcLJr7avgdoRsPrrqVKtQA';
  const p = await decodeHash(fromApp);
  assert.equal(p.name, '친구가 알려준 갯바위');
  assert.equal(p.lat, 35.15);
  assert.equal(p.lng, 129.12);
  assert.equal(p.genre, '원투');
  assert.equal(p.memo, '썰물 때 접근 가능');
});

test('메모·장르가 없어도 읽고, 모르는 장르는 표시하지 않는다', async () => {
  const bare = await decodeHash(makeHash({ n: 'a', la: 1, ln: 2 }));
  assert.equal(bare.genre, null);
  assert.equal(bare.memo, null);
  const unknown = await decodeHash(makeHash({ n: 'a', la: 1, ln: 2, g: 'jetski' }));
  assert.equal(unknown.genre, null);
});

test('프로토타입 이름(toString 등)을 장르로 오인하지 않는다', async () => {
  const p = await decodeHash(makeHash({ n: 'a', la: 1, ln: 2, g: 'toString' }));
  assert.equal(p.genre, null);
});

test('링크가 아니거나 버전이 다르면 사람이 읽을 수 있는 오류', async () => {
  await assert.rejects(decodeHash(''), /포인트 정보가 없어요/);
  await assert.rejects(decodeHash('#v=1'), /포인트 정보가 없어요/);
  await assert.rejects(decodeHash(makeHash(sample, { v: '2' })), /지원하지 않는 링크 버전/);
});

test('손상되었거나 잘린 링크', async () => {
  await assert.rejects(decodeHash('#v=1&d=AAAA'), /손상되었거나/);
  const whole = makeHash(sample);
  await assert.rejects(decodeHash(whole.slice(0, whole.length - 10)), /손상되었거나/);
  await assert.rejects(decodeHash(makeHash('not json')), /손상되었거나/);
});

test('형식이 맞아도 값이 이상하면 거부한다', () => {
  assert.throws(() => validatePoint(null), /잘못된 데이터/);
  assert.throws(() => validatePoint([]), /잘못된 데이터/);
  assert.throws(() => validatePoint({ ...sample, n: '  ' }), /이름이 없어요/);
  assert.throws(() => validatePoint({ ...sample, n: 'x'.repeat(101) }), /너무 길어요/);
  assert.throws(() => validatePoint({ ...sample, la: 91 }), /위도/);
  assert.throws(() => validatePoint({ ...sample, ln: -181 }), /경도/);
  assert.throws(() => validatePoint({ ...sample, la: '35' }), /위도/);
  assert.throws(() => validatePoint({ ...sample, la: NaN }), /위도/);
  assert.throws(() => validatePoint({ ...sample, m: 5 }), /메모/);
  assert.throws(() => validatePoint({ ...sample, m: 'x'.repeat(2001) }), /메모/);
});

test('이름 앞뒤 공백은 지우고, 태그 문자는 그대로 둔다(화면에서 textContent로만 쓴다)', () => {
  const p = validatePoint({ n: '  <b>곳</b> ', la: 0, ln: 0 });
  assert.equal(p.name, '<b>곳</b>');
});
