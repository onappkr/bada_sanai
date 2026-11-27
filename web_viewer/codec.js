/*
 * 공유 링크 해독(순수 로직). 화면(DOM)에 의존하지 않아 node로 시험할 수 있다.
 *
 * 링크 형식 v1: https://도메인/p#v=1&d={base64url(raw deflate(JSON))}
 * 데이터는 # 뒤(fragment)에만 있어 서버로 전송되지 않는다. 앱의 share_link_codec.dart와
 * 같은 형식이다.
 */

export const GENRE_LABELS = { lure: '루어', cast: '원투', jjik: '찍낚시', boat: '보트' };

export function base64UrlToBytes(text) {
  const b64 = text.replace(/-/g, '+').replace(/_/g, '/');
  const padded = b64 + '='.repeat((4 - (b64.length % 4)) % 4);
  const bin = atob(padded);
  const bytes = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i);
  return bytes;
}

export async function inflateRaw(bytes) {
  const stream = new Blob([bytes]).stream().pipeThrough(new DecompressionStream('deflate-raw'));
  return new Uint8Array(await new Response(stream).arrayBuffer());
}

/** 받은 값을 믿지 않고 검증한다. 문제가 있으면 Error(사용자에게 보일 문장). */
export function validatePoint(raw) {
  if (raw === null || typeof raw !== 'object' || Array.isArray(raw)) {
    throw new Error('잘못된 데이터 형식이에요.');
  }
  const { n, la, ln, g, m } = raw;
  if (typeof n !== 'string' || n.trim() === '') throw new Error('포인트 이름이 없어요.');
  if (n.length > 100) throw new Error('포인트 이름이 너무 길어요.');
  if (typeof la !== 'number' || !Number.isFinite(la) || la < -90 || la > 90) {
    throw new Error('위도가 올바르지 않아요.');
  }
  if (typeof ln !== 'number' || !Number.isFinite(ln) || ln < -180 || ln > 180) {
    throw new Error('경도가 올바르지 않아요.');
  }
  if (m !== undefined && m !== null && (typeof m !== 'string' || m.length > 2000)) {
    throw new Error('메모가 올바르지 않아요.');
  }
  return {
    name: n.trim(),
    lat: la,
    lng: ln,
    // 모르는 장르(앱이 새로 추가한 것)는 표시하지 않는다.
    genre: typeof g === 'string' && Object.hasOwn(GENRE_LABELS, g) ? GENRE_LABELS[g] : null,
    memo: typeof m === 'string' && m !== '' ? m : null,
  };
}

/** location.hash → 포인트. 읽을 수 없으면 Error(사용자에게 보일 문장). */
export async function decodeHash(hash) {
  const params = new URLSearchParams(hash.replace(/^#/, ''));
  if (!params.has('d')) throw new Error('링크에 포인트 정보가 없어요.');
  if (params.get('v') !== '1') throw new Error('지원하지 않는 링크 버전이에요. 앱을 최신 버전으로 업데이트해 보세요.');
  if (typeof DecompressionStream === 'undefined') {
    throw new Error('이 브라우저에서는 열 수 없어요. 최신 크롬·사파리·삼성 인터넷에서 열어 주세요.');
  }
  let json;
  try {
    const bytes = await inflateRaw(base64UrlToBytes(params.get('d')));
    json = JSON.parse(new TextDecoder('utf-8', { fatal: true }).decode(bytes));
  } catch (e) {
    throw new Error('링크가 손상되었거나 중간에 잘렸어요.');
  }
  return validatePoint(json);
}
