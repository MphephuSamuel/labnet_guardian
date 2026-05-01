import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import '../providers/app_theme.dart';
import '../providers/theme_provider.dart';
import '../models/history.dart';
import '../services/history_service.dart';
import '../utils/colors.dart';
import 'profile_screen.dart';
import '../layout/main_layout.dart';
import '../main.dart';

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  // ── State ──────────────────────────────────────────────────────────────────
  List<HistoryItem> _items = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onQueryChanged);
    _loadHistory();
  }

  void _onQueryChanged() {
    final q = _searchCtrl.text.toLowerCase().trim();
    setState(() => _query = q);
    // Re-fetch from backend with search query (debounce-like: only when settled)
    _debouncedSearch(q);
  }

  // Simple debounce via delayed call
  DateTime _lastSearch = DateTime.now();
  void _debouncedSearch(String q) {
    _lastSearch = DateTime.now();
    final captured = _lastSearch;
    Future.delayed(const Duration(milliseconds: 450), () {
      if (_lastSearch == captured && mounted) {
        _loadHistory(query: q);
      }
    });
  }

  Future<void> _loadHistory({String query = ''}) async {
    setState(() { _isLoading = true; _error = null; });
    final result = await ApiService.fetchHistory(query: query);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result.hasError) {
        _error = result.error;
      } else {
        _items = result.data ?? [];
      }
    });
  }

  List<HistoryItem> get _displayed => _items;

  Map<String, List<HistoryItem>> get _grouped {
    final map = <String, List<HistoryItem>>{};
    for (final item in _displayed) {
      map.putIfAbsent(item.dateGroup, () => []).add(item);
    }
    return map;
  }

  List<String> get _groupOrder {
    final seen = <String>[];
    for (final item in _displayed) {
      if (!seen.contains(item.dateGroup)) seen.add(item.dateGroup);
    }
    return seen;
  }

  void _openProfile(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onQueryChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme   = Provider.of<ThemeProvider>(context);
    final isDark  = theme.isDarkMode;
    final bgColor   = isDark ? AppColors.darkBg     : AppColors.lightBg;
    final cardColor = isDark ? AppColors.darkCard    : AppColors.lightCard;
    final textColor = isDark ? AppColors.textDarkPrimary    : AppColors.textLight;
    final subColor  = isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _topBar(isDark, theme, textColor, context),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.gradientStart,
                onRefresh: () => _loadHistory(query: _query),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    const SizedBox(height: 8),
                    Text('Activity History',
                        style: TextStyle(
                          color: textColor, fontSize: 26,
                          fontWeight: FontWeight.w800, letterSpacing: -0.5,
                        )),
                    const SizedBox(height: 20),
                    _searchBar(isDark, subColor, cardColor, textColor),
                    const SizedBox(height: 20),
                    if (_isLoading)
                      _loadingState(subColor)
                    else if (_error != null)
                      _errorState(subColor)
                    else if (_displayed.isEmpty)
                      _emptyState(subColor)
                    else
                      for (final group in _groupOrder) ...[
                        Text(group,
                            style: TextStyle(
                              color: subColor, fontSize: 13,
                              fontWeight: FontWeight.w600, letterSpacing: 0.2,
                            )),
                        const SizedBox(height: 12),
                        ..._grouped[group]!.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _historyCard(
                                isDark: isDark, cardColor: cardColor,
                                textColor: textColor, subColor: subColor,
                                item: item, query: _query,
                              ),
                            )),
                        const SizedBox(height: 8),
                      ],
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top bar ────────────────────────────────────────────────────────────────
  Widget _topBar(bool isDark, ThemeProvider theme, Color textColor, BuildContext ctx) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          Icon(Icons.menu, color: textColor, size: 26),
          const Spacer(),
          _circleBtn(
            isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round_outlined,
            isDark, textColor, onTap: theme.toggleTheme,
          ),
          const SizedBox(width: 10),
          // Notification bell → jump to Alerts tab via nav
          Stack(
            children: [
              _circleBtn(Icons.notifications_outlined, isDark, textColor,
                  onTap: () => _jumpToAlerts(ctx)),
              Positioned(
                right: 8, top: 8,
                child: Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.critical, shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          // Avatar → Profile & Settings
          GestureDetector(
            onTap: () => _openProfile(ctx),
            child: Container(
              width: 40, height: 40,
              decoration: const BoxDecoration(
                color: AppColors.gradientStart, shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('A',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tells the root MainNavigation to switch to the Alerts tab (index 2)
  void _jumpToAlerts(BuildContext context) {
    final nav = context.findAncestorStateOfType<MainLayoutState>();
    nav?.jumpTo(2);
  }

  Widget _circleBtn(IconData icon, bool isDark, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06), blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  // ── Search bar ─────────────────────────────────────────────────────────────
  Widget _searchBar(bool isDark, Color subColor, Color cardColor, Color textColor) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.05), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.search, color: subColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              style: TextStyle(color: textColor, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search history…',
                hintStyle: TextStyle(color: subColor, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (_query.isNotEmpty)
            GestureDetector(
              onTap: () { _searchCtrl.clear(); setState(() => _query = ''); _loadHistory(); },
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(Icons.close_rounded, color: subColor, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  // ── States ─────────────────────────────────────────────────────────────────
  Widget _loadingState(Color subColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(children: [
          CircularProgressIndicator(color: AppColors.gradientStart, strokeWidth: 2.5),
          const SizedBox(height: 16),
          Text('Loading history…', style: TextStyle(color: subColor, fontSize: 14)),
        ]),
      ),
    );
  }

  Widget _errorState(Color subColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 4),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.critical.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.critical.withOpacity(0.25)),
        ),
        child: Column(children: [
          Icon(Icons.cloud_off_rounded, color: AppColors.critical.withOpacity(0.7), size: 44),
          const SizedBox(height: 12),
          Text(_error!, textAlign: TextAlign.center,
              style: TextStyle(color: subColor, fontSize: 13, height: 1.5)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _loadHistory(query: _query),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(color: AppColors.gradientStart, borderRadius: BorderRadius.circular(20)),
              child: const Text('Retry',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _emptyState(Color subColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(children: [
          Icon(Icons.search_off_rounded, color: subColor.withOpacity(0.4), size: 56),
          const SizedBox(height: 16),
          Text(_query.isEmpty ? 'No activity recorded yet' : 'No results for "$_query"',
              style: TextStyle(color: subColor, fontSize: 15)),
        ]),
      ),
    );
  }

  // ── History card ───────────────────────────────────────────────────────────
  Widget _historyCard({
    required bool isDark,
    required Color cardColor,
    required Color textColor,
    required Color subColor,
    required HistoryItem item,
    required String query,
  }) {
    final type   = item.type;
    final iconBg = isDark ? type.color.withOpacity(0.15) : type.color.withOpacity(0.12);
    final badgeBg = iconBg;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(type.icon, color: type.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _highlight(item.title, query, textColor,
                  fontWeight: FontWeight.w700, fontSize: 15),
              const SizedBox(height: 4),
              _highlight('${item.device} • ${item.ip}', query, subColor, fontSize: 12),
              const SizedBox(height: 8),
              Text(item.time, style: TextStyle(color: subColor, fontSize: 12)),
            ]),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(20)),
            child: Text(type.label,
                style: TextStyle(color: type.color, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _highlight(String text, String query, Color baseColor,
      {FontWeight fontWeight = FontWeight.w400, double fontSize = 14}) {
    if (query.isEmpty) {
      return Text(text,
          style: TextStyle(color: baseColor, fontWeight: fontWeight, fontSize: fontSize));
    }
    final lower = text.toLowerCase();
    final idx   = lower.indexOf(query);
    if (idx == -1) {
      return Text(text,
          style: TextStyle(color: baseColor, fontWeight: fontWeight, fontSize: fontSize));
    }
    return RichText(
      text: TextSpan(
        style: TextStyle(color: baseColor, fontWeight: fontWeight, fontSize: fontSize),
        children: [
          TextSpan(text: text.substring(0, idx)),
          TextSpan(
            text: text.substring(idx, idx + query.length),
            style: TextStyle(
              color: AppColors.gradientStart,
              fontWeight: FontWeight.w800,
              backgroundColor: AppColors.gradientStart.withOpacity(0.12),
            ),
          ),
          TextSpan(text: text.substring(idx + query.length)),
        ],
      ),
    );
  }
}

