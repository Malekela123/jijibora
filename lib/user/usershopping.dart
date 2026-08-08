import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class UserShopping extends StatefulWidget {
  const UserShopping({super.key});

  @override
  State<UserShopping> createState() => _UserShoppingState();
}

class _UserShoppingState extends State<UserShopping> {
  // Mfano wa list ya bidhaa za usafi zilizopo dukani
  final List<Map<String, dynamic>> products = [
    {
      "name": "Mifuko ya Taka (Roll)",
      "price": "TSH 5,000",
      "image": "assets/imges/garbagecat.png", // Unaweza kuweka picha halisi baadae
      "desc": "Mifuko imara ya kuwekea taka ngumu na nyepesi.",
    },
    {
      "name": "Dumu la Taka la Ndani",
      "price": "TSH 12,000",
      "image": "assets/imges/binstatus.png",
      "desc": "Dumu la kisasa la plastiki kwa ajili ya jikoni au sebuleni.",
    },
    {
      "name": "Gloves za Usafi",
      "price": "TSH 3,500",
      "image": "assets/imges/user.png",
      "desc": "Gloves imara kulinda mikono yako wakati wa kufanya usafi.",
    },
    {
      "name": "Brashi ya Kusafishia",
      "price": "TSH 4,500",
      "image": "assets/imges/instruction.png",
      "desc": "Brashi ngumu kwa ajili ya kusafisha maeneo yenye uchafu sugu.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Eco Clean Shop",
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
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {
              // Option ya kwenda kwenye Kikapu (Cart) baadae
            },
            icon: const Icon(Ionicons.cart_outline, size: 26),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Vifaa vya Usafi",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              "Nunua vifaa bora kwa ajili ya kutunza mazingira yako",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            
            // GridView ya kuonyesha bidhaa mbili mbili kwenye mstari mmoja
            Expanded(
              child: GridView.builder(
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.72,
                ),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Picha ya Bidhaa
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(15),
                              ),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Image.asset(
                              product["image"],
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        
                        // Maelezo ya Bidhaa (Jina, Bei, na Button)
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product["name"],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                product["desc"],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    product["price"],
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF418E3C),
                                    ),
                                  ),
                                  
                                  // Button ya kuongeza kwenye kikapu au kununua
                                  GestureDetector(
                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("${product['name']} kimeongezwa kwenye kikapu!"),
                                          backgroundColor: const Color(0xFF418E3C),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF418E3C),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Ionicons.add,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
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