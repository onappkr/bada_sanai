/// 라우트 경로 상수. 화면 ID(S01~S18)는 1차 화면 명세와 같다.
abstract final class Routes {
  static const onboarding = '/onboarding'; // S01
  static const permissions = '/permissions'; // S02
  static const home = '/'; // S03
  static const logs = '/logs'; // S04
  static const logNew = '/logs/new'; // S05
  static const logDetail = '/logs/:id'; // S06
  static const logEdit = '/logs/:id/edit'; // S05 (수정)
  static const map = '/map'; // S07
  static const pointDetail = '/points/:id'; // S08
  static const pointEdit = '/points/:id/edit'; // S09
  static const arrival = '/arrival'; // S10
  static const tracking = '/tracking'; // S11
  static const candidates = '/tracking/:trackId/candidates'; // S12
  static const species = '/species'; // S13
  static const forecast = '/forecast'; // S14
  static const share = '/share/:pointId'; // S15
  static const sharedPoint = '/p'; // S16 (딥링크: 데이터는 fragment)
  static const settings = '/settings'; // S17
  static const backup = '/settings/backup'; // S18

  static String logDetailOf(String id) => '/logs/$id';
  static String logEditOf(String id) => '/logs/$id/edit';
  static String pointDetailOf(String id) => '/points/$id';
  static String pointEditOf(String id) => '/points/$id/edit';
  static String candidatesOf(String trackId) => '/tracking/$trackId/candidates';
  static String shareOf(String pointId) => '/share/$pointId';
}
