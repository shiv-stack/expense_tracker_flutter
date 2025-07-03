import 'package:expensely_app/Screens/HomeScreen.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Curved top background
          Stack(
            children: [
              Container(
                height: 250,
                decoration: const BoxDecoration(
                  color: Color(0xFF1A8E74),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
              ),
              const Positioned(
                top: 50,
                left: 16,
                child: BackButton(color: Colors.white),
              ),
              const Positioned(
                top: 50,
                right: 16,
                child: Icon(Icons.notifications_none, color: Colors.white),
              ),
              const Positioned(
                top: 100,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/avatar.png'), // Replace with your image
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Shivam Thapa',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '@shivamthapa',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Profile Options
          Expanded(
            child: ListView(
              children: [
                profileItem('Invite Friends', Icons.card_giftcard),
                profileItem('Account info', Icons.person_outline),
                profileItem('Personal profile', Icons.group_outlined),
                profileItem('Message center', Icons.mail_outline),
                profileItem('Login and security', Icons.shield_outlined),
                profileItem('Data and privacy', Icons.lock_outline),
              ],
            ),
          ),
        ],
      ),
     bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen(userName: '',)),
                    );
                  },
                  icon: const Icon(Icons.home)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.pie_chart)),
              const SizedBox(width: 40), // For FAB space
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.receipt_long)),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileScreen()),
                    );
                  },
                  icon: const Icon(Icons.person)),
            ],
          ),
        ),
      ),
    );
  }

  Widget profileItem(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Handle navigation here
      },
    );
  }
}
