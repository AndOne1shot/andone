import 'package:andone/equipment_page/equipment_page_view_model.dart';
import 'package:andone/model/item_model.dart';
import 'package:andone/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EquipmentPageView extends ConsumerStatefulWidget {
  const EquipmentPageView({super.key});

  @override
  ConsumerState<EquipmentPageView> createState() => _EquipmentPageViewState();
}

class _EquipmentPageViewState extends ConsumerState<EquipmentPageView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 골드 표시
            _GoldBar(),
            // 탭바
            Container(
              color: const Color(0xFF2D2D2D),
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.blue,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white38,
                tabs: const [
                  Tab(text: '상점'),
                  Tab(text: '꾸미기'),
                ],
              ),
            ),
            // 탭 콘텐츠
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _ShopTab(),
                  _CustomizeTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 골드 표시 바
class _GoldBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gold = ref.watch(userProvider).value?.gold ?? 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFF2D2D2D),
      child: Row(
        children: [
          const Text('🪙', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            '$gold',
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 상점 탭 ──────────────────────────────────────────
class _ShopTab extends ConsumerStatefulWidget {
  const _ShopTab();

  @override
  ConsumerState<_ShopTab> createState() => _ShopTabState();
}

class _ShopTabState extends ConsumerState<_ShopTab> {
  String _selectedCategory = 'accessory';

  Future<void> _onPurchase(ItemModel item) async {
    final user = ref.read(userProvider).value;
    if (user == null) return;

    final viewModel = ref.read(equipmentViewModelProvider);
    final error = await viewModel.purchaseItem(item, user.gold, user.ownedItems);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? '${item.name} 구매 완료!'),
        backgroundColor: error != null ? Colors.red[700] : Colors.green[700],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemAsync = ref.watch(itemListProvider);

    return Column(
      children: [
        // 카테고리 필터
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _CategoryChip(
                label: '악세서리',
                selected: _selectedCategory == 'accessory',
                onTap: () => setState(() => _selectedCategory = 'accessory'),
              ),
              const SizedBox(width: 8),
              _CategoryChip(
                label: '배경',
                selected: _selectedCategory == 'background',
                onTap: () => setState(() => _selectedCategory = 'background'),
              ),
            ],
          ),
        ),
        // 아이템 그리드
        Expanded(
          child: itemAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('오류: $e', style: const TextStyle(color: Colors.white54))),
            data: (items) {
              final ownedItems = ref.watch(userProvider).value?.ownedItems ?? [];
              final filtered = items.where((i) => i.category == _selectedCategory).toList();
              if (filtered.isEmpty) {
                return const Center(
                  child: Text('아이템이 없어요', style: TextStyle(color: Colors.white38)),
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  return _ShopItemCard(
                    item: item,
                    isOwned: ownedItems.contains(item.id),
                    onPurchase: () => _onPurchase(item),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// 카테고리 필터 칩
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.blue : const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.blue : Colors.white24,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white54,
            fontSize: 13,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// 상점 아이템 카드
class _ShopItemCard extends StatelessWidget {
  final ItemModel item;
  final bool isOwned;
  final VoidCallback onPurchase;

  const _ShopItemCard({
    required this.item,
    required this.isOwned,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 아이템 이미지
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(8),
            ),
            child: item.displayPath.isNotEmpty
                ? Image.asset(
                    item.displayPath,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.none,
                    errorBuilder: (context, e, stack) =>
                        const Icon(Icons.image, color: Colors.white24, size: 36),
                  )
                : const Icon(Icons.image, color: Colors.white24, size: 36),
          ),
          const SizedBox(height: 8),
          // 아이템 이름
          Text(
            item.name,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          const SizedBox(height: 4),
          // 가격
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🪙', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 2),
              Text(
                '${item.price}',
                style: const TextStyle(color: Colors.amber, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 구매 버튼
          SizedBox(
            width: 80,
            height: 30,
            child: ElevatedButton(
              onPressed: isOwned ? null : onPurchase,
              style: ElevatedButton.styleFrom(
                backgroundColor: isOwned ? Colors.white12 : Colors.blue,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                isOwned ? '보유중' : '구매',
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 꾸미기 탭 ──────────────────────────────────────────
class _CustomizeTab extends ConsumerStatefulWidget {
  const _CustomizeTab();

  @override
  ConsumerState<_CustomizeTab> createState() => _CustomizeTabState();
}

class _CustomizeTabState extends ConsumerState<_CustomizeTab> {
  String _selectedCategory = 'accessory';

  Future<void> _onTapItem(ItemModel item, Map<String, String> equippedItems) async {
    final viewModel = ref.read(equipmentViewModelProvider);
    final isEquipped = equippedItems[item.category] == item.id;

    if (isEquipped) {
      await viewModel.unequipItem(item.category);
    } else {
      await viewModel.equipItem(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider).value;
    final itemAsync = ref.watch(itemListProvider);
    final ownedItems = user?.ownedItems ?? [];
    final equippedItems = user?.equippedItems ?? {};

    return Column(
      children: [
        // 캐릭터 미리보기
        Container(
          height: 160,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D2D),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white10),
          ),
          child: Center(
            child: itemAsync.maybeWhen(
              data: (items) {
                final equippedAccessoryId = equippedItems['accessory'];
                final equippedAccessory = equippedAccessoryId != null
                    ? items.where((i) => i.id == equippedAccessoryId).firstOrNull
                    : null;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // 캐릭터 - 먼저 그려서 뒤로
                    const Image(
                      image: AssetImage('assets/image/character/my_pet_right.png'),
                      width: 96,
                      height: 128,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.none,
                    ),
                    // 악세서리 - 나중에 그려서 앞으로
                    if (equippedAccessory != null && equippedAccessory.assetPath.isNotEmpty)
                      Image.asset(
                        equippedAccessory.assetPath,
                        width: 96,
                        height: 128,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.none,
                      ),
                  ],
                );
              },
              orElse: () => const Image(
                image: AssetImage('assets/image/character/my_pet_right.png'),
                height: 100,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.none,
              ),
            ),
          ),
        ),
        // 카테고리 필터
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _CategoryChip(
                label: '악세서리',
                selected: _selectedCategory == 'accessory',
                onTap: () => setState(() => _selectedCategory = 'accessory'),
              ),
              const SizedBox(width: 8),
              _CategoryChip(
                label: '배경',
                selected: _selectedCategory == 'background',
                onTap: () => setState(() => _selectedCategory = 'background'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // 보유 아이템 그리드
        Expanded(
          child: itemAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('오류: $e', style: const TextStyle(color: Colors.white54))),
            data: (items) {
              final filtered = items
                  .where((i) => i.category == _selectedCategory && ownedItems.contains(i.id))
                  .toList();
              if (filtered.isEmpty) {
                return const Center(
                  child: Text('보유한 아이템이 없어요', style: TextStyle(color: Colors.white38)),
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  final isEquipped = equippedItems[item.category] == item.id;
                  return _OwnedItemCard(
                    item: item,
                    isEquipped: isEquipped,
                    onTap: () => _onTapItem(item, equippedItems),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// 꾸미기 탭 아이템 카드
class _OwnedItemCard extends StatelessWidget {
  final ItemModel item;
  final bool isEquipped;
  final VoidCallback onTap;

  const _OwnedItemCard({
    required this.item,
    required this.isEquipped,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isEquipped ? Colors.blue : Colors.white10,
            width: isEquipped ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: item.displayPath.isNotEmpty
                  ? Image.asset(
                      item.displayPath,
                      width: 64,
                      height: 64,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.none,
                      errorBuilder: (context, e, stack) =>
                          const Icon(Icons.image, color: Colors.white24, size: 32),
                    )
                  : const Icon(Icons.image, color: Colors.white24, size: 32),
            ),
            if (isEquipped)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '장착중',
                    style: TextStyle(color: Colors.white, fontSize: 9),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
