import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../application/photo_providers.dart';
import '../domain/photo_models.dart';

/// 사진 한 장의 화면 표시 단위. 이미 저장된 사진이거나 방금 고른 사진 중 하나.
class PhotoSlot {
  PhotoSlot.saved(PhotoView view)
      : id = view.id,
        path = view.filePath,
        picked = null;
  PhotoSlot.picked(PickedPhoto this.picked)
      : id = null,
        path = null;

  final String? id;
  final String? path;
  final PickedPhoto? picked;
}

/// 작성 화면의 사진 편집 줄: 썸네일 + 삭제, 갤러리·카메라 추가 버튼.
class PhotoEditor extends ConsumerWidget {
  const PhotoEditor({
    super.key,
    required this.slots,
    required this.onAdd,
    required this.onRemove,
  });

  final List<PhotoSlot> slots;
  final void Function(List<PickedPhoto> added) onAdd;
  final void Function(PhotoSlot slot) onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final picker = ref.read(photoPickerProvider);
    final store = ref.watch(photoStoreProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('사진', style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            TextButton.icon(
              onPressed: () async => _run(context, () async {
                final p = await picker.takePhoto();
                if (p != null) onAdd([p]);
              }),
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('촬영'),
            ),
            TextButton.icon(
              onPressed: () async => _run(context, () async {
                final list = await picker.pickFromGallery();
                if (list.isNotEmpty) onAdd(list);
              }),
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('앨범'),
            ),
          ],
        ),
        if (slots.isEmpty) const Text('사진을 추가해 보세요.'),
        if (slots.isNotEmpty)
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: slots.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final s = slots[i];
                return Stack(
                  children: [
                    _Thumb(
                      image: s.picked != null
                          ? MemoryImage(s.picked!.bytes)
                          : store.imageFor(s.path!),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton.filled(
                        visualDensity: VisualDensity.compact,
                        iconSize: 16,
                        tooltip: '사진 삭제',
                        icon: const Icon(Icons.close),
                        onPressed: () => onRemove(s),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  /// 권한 거부·카메라 없음 같은 실패는 앱이 죽지 않고 안내만 보여 준다.
  Future<void> _run(BuildContext context, Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('사진을 가져오지 못했습니다: $e')));
      }
    }
  }
}

/// 상세 화면의 읽기 전용 사진 줄. 누르면 크게 본다.
class PhotoStrip extends ConsumerWidget {
  const PhotoStrip({super.key, required this.photos});

  final List<PhotoView> photos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(photoStoreProvider);
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final image = store.imageFor(photos[i].filePath);
          return GestureDetector(
            onTap: () => showDialog<void>(
              context: context,
              builder: (c) => Dialog(
                child: InteractiveViewer(child: Image(image: image)),
              ),
            ),
            child: _Thumb(image: image),
          );
        },
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.image});

  final ImageProvider image;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image(image: image, width: 96, height: 96, fit: BoxFit.cover),
    );
  }
}
