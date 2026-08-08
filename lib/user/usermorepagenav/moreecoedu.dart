import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class MoreEcoEdu extends StatefulWidget {
  const MoreEcoEdu({super.key});

  @override
  State<MoreEcoEdu> createState() => _MoreEcoEduState();
}

class _MoreEcoEduState extends State<MoreEcoEdu> { // Imerekebishwa jina hapa la kufanana na createState
  // Salio la Coins za mtumiaji
  int _userCoins = 0;

  // Kufuatilia masomo yaliyokamilika
  final Set<int> _completedArticles = {};

  // Orodha ya masomo
  final List<Map<String, dynamic>> _articles = [
    {
      "id": 1,
      "title": "Misingi ya Utenganishaji wa Taka",
      "category": "Utunzaji Mazingira",
      "duration": "Dakika 5 kusoma",
      "icon": Ionicons.trash_bin_outline,
      "color": Colors.green,
      "coinsReward": 10,
      "content": "Kutenganisha taka kutoka nyumbani ni hatua ya kwanza kuelekea mazingira safi. Hakikisha unatenganisha taka za mabaki ya chakula (Organic), chupa za plastiki na karatasi iti kurahisisha uokoaji na urejelezaji."
    },
    {
      "id": 2,
      "title": "Kutengeneza Mkaa wa Karatasi na Mabaki ya Mimea",
      "category": "Nishati Mbadala",
      "duration": "Dakika 8 kusoma",
      "icon": Ionicons.flame_outline,
      "color": Colors.redAccent,
      "coinsReward": 25,
      "content": "Kutengeneza mkaa mbadala (Briquettes) ni mbinu bora ya kupunguza ukataji miti na kudhibiti taka za karatasi na mimea.\n\n"
                 "Hatua za Kufuata:\n"
                 "1. Kusanya taka za karatasi, mabaki ya mahindi, majani makavu au maranda ya mbao.\n"
                 "2. Loweka karatasi kwenye maji kwa siku 2-3 hadi zilainike kabisa na kuwa kama tope (pulp).\n"
                 "3. Twanga au saga yale masalia ya mimea/majani makavu yawe ungaunga mdogo.\n"
                 "4. Changanya lile tope la karatasi na unga wa masalia ya mimea kwa uwiano mzuri (Karatasi inasaidia kushika mchanganyiko pamoja kama gundi).\n"
                 "5. Shindilia mchanganyiko huo kwenye muundo wa duara au mstatili (unaweza kutumia bomba la plastiki au mikono kufanya hivi).\n"
                 "6. Anika mkaa huo juani kwa siku 4-7 hadi ukauke kabisa.\n\n"
                 "Mkaa huu unawaka vizuri, hauduru mazingira, na hauna moshi mwingi!"
    },
    {
      "id": 3,
      "title": "Urejelezaji wa Plastiki (Recycling)",
      "category": "Urejelezaji",
      "duration": "Dakika 7 kusoma",
      "icon": Ionicons.refresh_outline,
      "color": Colors.blue,
      "coinsReward": 15,
      "content": "Je, unajua plastiki huchukua hadi miaka 500 kuoza? Kupitia mfumo wa EcoClean, chupa zako za plastiki zinaweza kukusanywa na kupelekwa viwandani kutengeneza vifaa vipya badala ya kuchafua mazingira yetu."
    },
    {
      "id": 4,
      "title": "Taka za Kielektroniki (E-Waste)",
      "category": "Taka Hatari",
      "duration": "Dakika 4 kusoma",
      "icon": Ionicons.hardware_chip_outline,
      "color": Colors.orange,
      "coinsReward": 10,
      "content": "Simu za zamani, betri, na chaja zilizoharibika hazitakiwi kutupwa kwenye jalala la kawaida. Zina kemikali hatari zinazoweza kuvuja na kuingia kwenye udongo au vyanzo vya maji."
    },
    {
      "id": 5,
      "title": "Tengeneza Mbolea (Composting)",
      "category": "Kilimo na Mazingira",
      "duration": "Dakika 6 kusoma",
      "icon": Ionicons.leaf_outline,
      "color": Colors.brown,
      "coinsReward": 15,
      "content": "Mabaki ya mboga mboga, matunda na majani makavu yanaweza kubadilishwa kuwa mbolea safi ya asili kwa ajili ya bustani yako. Hii inapunguza kiasi cha taka zinazoenda majalala makuu."
    }
  ];

  void _claimCoins(int articleId, int rewardCoins, String title) {
    if (_completedArticles.contains(articleId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tayari ulishapokea zawadi ya somo hili!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _userCoins += rewardCoins;
      _completedArticles.add(articleId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Hongera! Umepata +$rewardCoins Eco Coins kwa kusoma: $title"),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Eco Edu",
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Chip(
              avatar: const Icon(Ionicons.cash, color: Colors.amber, size: 20),
              label: Text(
                "$_userCoins Coins",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF418E3C)),
              ),
              backgroundColor: Colors.amber.withOpacity(0.15),
              side: BorderSide.none,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF418E3C), Color(0xFF66BB6A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Ionicons.book_outline, color: Colors.white, size: 40),
                    SizedBox(height: 15),
                    Text(
                      "Elimu ya Mazingira",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Soma masomo mbalimbali, jifunze kutengeneza bidhaa kutokana na taka na ujipatie Eco Coins za kufanya manunuzi!",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Makala na Masomo ya Vitendo",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _articles.length,
                itemBuilder: (context, index) {
                  final article = _articles[index];
                  final isCompleted = _completedArticles.contains(article['id']);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey[200]!),
                    ),
                    child: ExpansionTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: article['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(article['icon'], color: article['color']),
                      ),
                      title: Text(
                        article['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          Text(
                            article['category'],
                            style: TextStyle(
                              color: article['color'],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Ionicons.gift_outline, size: 12, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            "+${article['coinsReward']} Coins",
                            style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article['content'],
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    _claimCoins(article['id'], article['coinsReward'], article['title']);
                                  },
                                  icon: Icon(
                                    isCompleted ? Ionicons.checkmark_circle : Ionicons.star_outline,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    isCompleted ? "Umeshamaliza Somo Hili" : "Kamilisha Somo & Toa Zawadi",
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isCompleted ? Colors.grey : const Color(0xFF418E3C),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}