import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class UserCategories extends StatefulWidget {
  const UserCategories({super.key});

  @override
  State<UserCategories> createState() => _UserCategoriesState();
}

class _UserCategoriesState extends State<UserCategories> {
  // Orodha ya makundi ya taka na maelezo yake
  final List<Map<String, dynamic>> categories = [
    {
      "name": "Taka za Kikaboni (Organic)",
      "color": const Color(0xFF418E3C), // Kijani
      "icon": Ionicons.leaf_outline,
      "items": "Mabaki ya chakula, maganda ya matunda, majani na mboga mboga.",
      "tip": "Hizi zinaweza kutumika kutengenezea mbolea ya asili (compost)."
    },
    {
      "name": "Plastiki (Plastic)",
      "color": const Color(0xFF1E88E5), // Bluu
      "icon": Ionicons.wine_outline,
      "items": "Chupa za maji, mifuko ya nailoni, vyombo vya plastiki vilivyovunjika.",
      "tip": "Hakikisha unazisuuza kwanza kabla ya kuzitupa kwa ajili ya usindikaji (recycling)."
    },
    {
      "name": "Karatasi na Katoni (Paper)",
      "color": const Color(0xFFFFB300), // Manjano/Chungwa
      "icon": Ionicons.document_text_outline,
      "items": "Vitabu vya zamani, katoni za bidhaa, magazeti na bahasha.",
      "tip": "Weka mahali pakavu ili zisipoteze ubora wa kurejerezwa."
    },
    {
      "name": "Kioo na Chuma (Glass & Metal)",
      "color": const Color(0xFFE53935), // Nyekundu
      "icon": Ionicons.construct_outline,
      "items": "Chupa za kioo, makopo ya soda, vyuma chakavu, na misumari.",
      "tip": "Tupa kwa umangalifu mkubwa ili kuepusha majeraha kwa wakusanyaji."
    },
    {
      "name": "Taka za Kielektroniki (E-Waste)",
      "color": const Color(0xFF8E24AA), // Zambarau
      "icon": Ionicons.hardware_chip_outline,
      "items": "Simu mbovu, betri, waya, na vifaa vya kompyuta vilivyoharibika.",
      "tip": "Zina sumu kali, zisichanganywe kabisa na taka za nyumbani za kawaida."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Makundi ya Taka",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Ionicons.chevron_back_outline),
        ),
        leadingWidth: 60,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tenganisha Taka Zako",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              "Chagua kundi kujifunza jinsi ya kuhifadhi taka kwa usahihi kabla ya kukusanywa.",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            
            // Orodha ya makundi ya taka kwa kutumia ListView
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: cat["color"].withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            cat["icon"],
                            color: cat["color"],
                            size: 26,
                          ),
                        ),
                        title: Text(
                          cat["name"],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "Mifano: ${cat['items']}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(),
                                const SizedBox(height: 5),
                                const Text(
                                  "Inajumuisha nini:",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  cat["items"],
                                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: cat["color"].withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: cat["color"].withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Ionicons.bulb_outline, color: cat["color"], size: 20),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          cat["tip"],
                                          style: TextStyle(
                                            fontSize: 13, 
                                            fontStyle: FontStyle.italic,
                                            color: Colors.grey.shade800
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}