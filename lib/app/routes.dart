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
  static const pointList = '/points'; // S07의 목록 보기
  static const pointNew = '/points/new'; // S09 (등록)
  static const pointDetail = '/points/:id'; // S08
  static const pointEdit = '/points/:id/edit'; // S09
  static const arrival = '/arrival'; // S10
  static const tracking = '/tracking'; // S11
  static const candidates = '/tracking/:trackId/candidates'; // S12
  static const tracks = '/tracks'; // 저장된 경로 목록
  static const trackDetail = '/tracks/:id'; // 저장된 경로 상세
  static const species = '/species'; // S13
  static const forecast = '/forecast'; // S14
  static const share = '/share/:pointId'; // S15
  static const sharedPoint = '/p'; // S16 (딥링크: 데이터는 fragment)
  static const settings = '/settings'; // S17
  static const backup = '/settings/backup'; // S18
  static const teams = '/teams'; // 2차: 팀 목록
  static const team = '/teams/:id'; // 팀 상세
  static const tripNew = '/teams/:id/trips/new'; // 출조 추가
  static const trip = '/trips/:id'; // 출조 상세(비용·정산)
  static const tripEdit = '/trips/:id/edit';
  static const expenseNew = '/trips/:id/expenses/new';
  static const expenseEdit = '/trips/:id/expenses/:expenseId';

  /// [fragment]는 링크의 `v=1&d=...` 부분. 쿼리 `f`로 넘긴다.
  static String sharedPointOf(String fragment) =>
      '/p?f=${Uri.encodeQueryComponent(fragment)}';
  static String logDetailOf(String id) => '/logs/$id';
  static String logEditOf(String id) => '/logs/$id/edit';
  static String pointDetailOf(String id) => '/points/$id';
  static String pointEditOf(String id) => '/points/$id/edit';
  static String trackDetailOf(String id) => '/tracks/$id';
  static String candidatesOf(String trackId) => '/tracking/$trackId/candidates';
  static String shareOf(String pointId) => '/share/$pointId';
  static String teamOf(String id) => '/teams/$id';
  static String tripNewOf(String teamId) => '/teams/$teamId/trips/new';
  static String tripOf(String id) => '/trips/$id';
  static String tripEditOf(String id) => '/trips/$id/edit';
  static String expenseNewOf(String tripId) => '/trips/$tripId/expenses/new';
  static String expenseEditOf(String tripId, String id) => '/trips/$tripId/expenses/$id';
}
