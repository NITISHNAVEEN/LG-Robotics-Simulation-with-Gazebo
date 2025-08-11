import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  const About({super.key});

  // Launch URL helper
  Future<void> _launchUrl(String urlString) async {
    final Uri uri = Uri.parse(urlString);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch $urlString");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'About',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.asset('assets/robosimLG.png', height: 250),

            const SizedBox(height: 24),

            // About Section
            _buildSectionTitle("About the Application"),
            _buildCard(
              child: Text(
                "This application was created during the Google Summer of Code 2025 for the Liquid Galaxy project. "
                "It controls any Liquid Galaxy Robot simulated on the Liquid Galaxy Rig using ROS2 and Gazebo. "
                "The app connects to a Docker Server running ROS2 and Gazebo containers, providing real-time and interactive controls. "
                "Thanks to my main mentor Víctor Sánchez and seconday mentors Andreu Ibáñez and Moisés Martínez. And thanks to the team of the Liquid Galaxy LAB Lleida, Headquarters of the Liquid Galaxy project: Alba, Paula, Josep, Jordi, Oriol, Sharon, Alejandro, Marc, and admin Andreu, for their continuous support on my project.",
                textAlign: TextAlign.justify,
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
            ),

            const SizedBox(height: 24),

            // Credits Section
            _buildSectionTitle("Credits"),
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBullet("Created and Maintained by: Debanjan Naskar"),
                  _buildBullet(
                      "Mentors: Víctor Sánchez, Andreu Ibáñez, Moisés Martínez"),
                  _buildBullet("Organization Admin: Andreu Ibáñez"),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Links
            _buildSectionTitle("Links"),
            Column(
              children: [
                _buildLinkButton(
                  color: const Color.fromARGB(255, 230, 246, 123),
                  icon: Icons.code,
                  label: "Project Repository",
                  onPressed: () =>
                      _launchUrl('https://github.com/LiquidGalaxyLAB/LG-Robotics-Simulation-with-Gazebo/'),
                ),
                const SizedBox(height: 10),
                _buildLinkButton(
                  color: const Color.fromARGB(255, 133, 244, 134),
                  icon: Icons.group_work_rounded,
                  label: "GitHub",
                  onPressed: () =>
                      _launchUrl('https://github.com/devxdebanjan/'),
                ),
                const SizedBox(height: 10),
                _buildLinkButton(
                  color: Colors.blue,
                  icon: Icons.people,
                  label: "LinkedIn",
                  onPressed: () =>
                      _launchUrl('https://www.linkedin.com/in/dnaskar/'),
                ),
                const SizedBox(height: 10),
                _buildLinkButton(
                  color: const Color.fromARGB(255, 238, 133, 126),
                  icon: Icons.email,
                  label: "Email",
                  onPressed: () =>
                      _launchUrl('mailto:debanjannaskar1@gmail.com'),
                ),
              ],
            ),

            Image.asset('assets/RoboLGlogo.png', height: 400),

          ],
        ),
      ),
    );
  }

  // Section Title Widget
  Widget _buildSectionTitle(String title) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ),
        const SizedBox(height: 4),
        Container(height: 2, width: 50, color: Colors.green),
        const SizedBox(height: 12),
      ],
    );
  }

  // Card Wrapper
  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // Bullet Point Text
  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.arrow_right, color: Colors.green, size: 20),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  // Link Button
  Widget _buildLinkButton({
    required Color color,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.black),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

}
