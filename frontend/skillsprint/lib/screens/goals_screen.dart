import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/goal_card.dart';
import '../widgets/floating_nav_dock.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/glass_card.dart';
import 'roadmap_screen.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-populate search query if any exists in provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final query = Provider.of<AppProvider>(context, listen: false).searchQuery;
      _searchController.text = query;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF070707),
      appBar: AppBar(
        title: const Text('EXPLORE GOALS'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => provider.refreshGoals(),
          color: Colors.orangeAccent,
          backgroundColor: const Color(0xFF141414),
          child: Column(
            children: [
              // 1. Search Bar & Filter Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  children: [
                    // Search Textfield
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        onChanged: (val) => provider.updateSearchQuery(val),
                        decoration: InputDecoration(
                          hintText: 'Search goals...',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                          border: InputBorder.none,
                          icon: const Icon(Icons.search, color: Colors.orangeAccent, size: 20),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    provider.updateSearchQuery('');
                                  },
                                  child: const Icon(Icons.clear, color: Colors.white54, size: 16),
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Categories Scrollable List
                    SizedBox(
                      height: 32,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: provider.categories.length,
                        itemBuilder: (context, index) {
                          final cat = provider.categories[index];
                          final bool isSelected = provider.activeCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(
                                cat,
                                style: TextStyle(
                                  color: isSelected ? Colors.black : Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (_) => provider.updateCategory(cat),
                              selectedColor: Colors.orangeAccent,
                              backgroundColor: Colors.white.withOpacity(0.04),
                              checkmarkColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected ? Colors.orangeAccent : Colors.white.withOpacity(0.08),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // 2. Goals List
              Expanded(
                child: provider.isLoadingGoals
                    ? const SkeletonLoader(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              CardSkeleton(),
                              CardSkeleton(),
                              CardSkeleton(),
                            ],
                          ),
                        ),
                      )
                    : provider.hasError
                        ? _buildErrorState(provider)
                        : provider.filteredGoals.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 90),
                                itemCount: provider.filteredGoals.length,
                                itemBuilder: (context, index) {
                                  final goal = provider.filteredGoals[index];
                                  return GoalCard(
                                    goal: goal,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => RoadmapScreen(
                                            goalTitle: goal.title,
                                            themeColor: goal.themeColor,
                                            progress: goal.progress,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const FloatingNavDock(activeIndex: 1),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.explore_off_outlined, color: Colors.orangeAccent.withOpacity(0.4), size: 65),
          const SizedBox(height: 16),
          const Text(
            "NO GOALS FOUND",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          const Text(
            "Try searching another keyword or select 'All'.",
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AppProvider provider) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_outlined, color: Colors.redAccent.withOpacity(0.5), size: 65),
          const SizedBox(height: 16),
          const Text(
            "CONNECTION FAILURE",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          const Text(
            "Could not connect to mock server endpoints.",
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => provider.initializeData(),
            icon: const Icon(Icons.refresh, color: Colors.orangeAccent),
            label: const Text("RETRY CONNECTION", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
