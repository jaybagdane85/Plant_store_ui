import 'package:flutter/material.dart';
import 'plant_details_screen.dart';
import 'category_tab.dart';
import 'plant_card.dart';
import 'search_bar.dart';
import 'delivery_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> recentlyViewed = [];

  final List<String> categories = ["Popular", "Outdoor", "Indoor", "Top Pick"];
  String selectedCategory = "Popular"; // ✅ default selected

  final List<Map<String, dynamic>> plants = [
    {
      "name": "Peace Lily",
      "price": "\$20",
      "image": "assets/images/peace_lily.png",
      "type": "Indoor",
      "category": "Indoor",
    },
    {
      "name": "Aloe Vera",
      "price": "\$25",
      "image": "assets/images/aloe.png",
      "type": "Outdoor",
      "category": "Outdoor",
    },
    {
      "name": "Orchid",
      "price": "\$36",
      "image": "assets/images/pothoss.png",
      "type": "Indoor",
      "category": "Indoor",
    },
  ];

  // 🔎 Search
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredPlants = [];

  @override
  void initState() {
    super.initState();
    _applyFilters(); // ✅ initialize list
  }

  void _filterPlants(String query) {
    setState(() {
      _applyFilters(query: query);
    });
  }

  void _applyFilters({String query = ""}) {
    filteredPlants = plants.where((plant) {
      final matchQuery = query.isEmpty ||
          plant['name'].toLowerCase().contains(query.toLowerCase()) ||
          plant['type'].toLowerCase().contains(query.toLowerCase());

      final matchCategory =
          selectedCategory == "Popular" || plant['category'] == selectedCategory;

      return matchQuery && matchCategory;
    }).toList();
  }

  void addToRecentlyViewed(Map<String, dynamic> plant) {
    setState(() {
      recentlyViewed.removeWhere((item) => item['name'] == plant['name']);
      recentlyViewed.insert(0, plant);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Hello Jay",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            Text("Take care of your plants !",
                style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shopping_cart, color: Colors.black),
          ),
        ],
      ),

      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔎 Search bar
                SearchBarWidget(
                  controller: _searchController,
                  onChanged: _filterPlants,
                  onClear: () {
                    _searchController.clear();
                    _filterPlants("");
                  },
                ),
                const SizedBox(height: 20),

                // Recently Viewed
                if (recentlyViewed.isNotEmpty) ...[
                  const Text("Recently Viewed",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: recentlyViewed.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final item = recentlyViewed[index];
                        return Container(
                          width: 120,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(item["image"], height: 40),
                              const SizedBox(height: 8),
                              Text(item["name"],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  textAlign: TextAlign.center),
                              Text(item["type"],
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ✅ Categories (Clickable)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: categories.map((c) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = c;
                          _applyFilters(query: _searchController.text);
                        });
                      },
                      child: CategoryTab(label: c, selected: c == selectedCategory),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Plants Horizontal Scroll
                SizedBox(
                  height: 220,
                  child: filteredPlants.isEmpty
                      ? const Center(child: Text("No plants found"))
                      : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: filteredPlants.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final plant = filteredPlants[index];
                      return SizedBox(
                        width: 160,
                        child: PlantCard(
                          name: plant['name'],
                          price: plant['price'],
                          image: plant['image'],
                          onTap: () {
                            addToRecentlyViewed(plant);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PlantDetailsScreen(
                                  name: plant['name'],
                                  price: plant['price'],
                                  image: plant['image'],
                                  type: plant['type'],
                                  category: plant['category'], // ✅ FIXED
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Delivery Banner bottom
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: DeliveryBanner(
              title: "Free Shipping",
              subtitle: "On orders above \$50",
              imagePath: "assets/images/delivery.png",
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Shop Now clicked!")),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
