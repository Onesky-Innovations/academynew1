import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:academynew1/theme/ModernAppTheme.dart';

class SharePage extends StatefulWidget {
  final String academyUid;
  const SharePage({super.key, required this.academyUid});

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  bool _isUploading = false;

  Future<void> _uploadContent() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Title is required")));
      return;
    }

    setState(() => _isUploading = true);

    try {
      await FirebaseFirestore.instance
          .collection("academies") // ✅ corrected collection
          .doc(widget.academyUid)
          .collection("shares")
          .add({
            "title": _titleController.text.trim(),
            "post": _postController.text.trim(),
            "link": _linkController.text.trim().isNotEmpty
                ? _linkController.text.trim()
                : null,
            "type": _linkController.text.trim().isNotEmpty ? "link" : "text",
            "createdAt": FieldValue.serverTimestamp(),
          });

      _titleController.clear();
      _postController.clear();
      _linkController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post shared successfully ✅")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => _isUploading = false);
  }

  Future<void> _openLink(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Could not open link")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final sharesRef = FirebaseFirestore.instance
        .collection("academies") // ✅ corrected collection
        .doc(widget.academyUid)
        .collection("shares")
        .orderBy("createdAt", descending: true);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D122A), Color(0xFF1E2749)],
          ),
        ),
        child: Column(
          children: [
            // AppBar replacement for a consistent look
            Padding(
              padding: const EdgeInsets.only(
                top: 50.0,
                left: 16.0,
                right: 16.0,
                bottom: 16.0,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Share with Students",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            TextField(
                              controller: _titleController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: "Title *",
                                labelStyle: TextStyle(
                                  color: Colors.cyan.withOpacity(0.8),
                                ),
                                prefixIcon: const Icon(
                                  Icons.title,
                                  color: Colors.cyan,
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.05),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: LinkColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _postController,
                              maxLines: 3,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: "Post (text body)",
                                labelStyle: TextStyle(
                                  color: Colors.cyan.withOpacity(0.8),
                                ),
                                prefixIcon: const Icon(
                                  Icons.description,
                                  color: Colors.cyan,
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.05),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.cyan,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _linkController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: "Link (optional)",
                                labelStyle: TextStyle(
                                  color: Colors.cyan.withOpacity(0.8),
                                ),
                                prefixIcon: const Icon(
                                  Icons.link,
                                  color: Colors.cyan,
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.05),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.cyan,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            _isUploading
                                ? const CircularProgressIndicator(
                                    color: Color(0xFFE94560),
                                  )
                                : SizedBox(
                                    width: double.infinity,
                                    child: GestureDetector(
                                      onTap: _uploadContent,
                                      child: Container(
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 18,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF3366FF),
                                              Color(0xFF66CCFF),
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.cyan.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 15,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: const Text(
                                          "Share",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Recent Posts",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      StreamBuilder<QuerySnapshot>(
                        stream: sharesRef.snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.cyan,
                              ),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                "Error: ${snapshot.error}",
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Text(
                                "No posts shared yet",
                                style: TextStyle(color: Colors.white70),
                              ),
                            );
                          }
                          final docs = snapshot.data!.docs;
                          return ListView.builder(
                            physics:
                                const NeverScrollableScrollPhysics(), // To prevent nested scrolling
                            shrinkWrap: true,
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final data =
                                  docs[index].data() as Map<String, dynamic>;
                              final title = data["title"] ?? "No Title";
                              final post = data["post"] ?? "";
                              final link = data["link"];

                              return Card(
                                color: Colors.white.withOpacity(0.05),
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: const Color(
                                                0xFF66CCFF,
                                              ), // Brighter title color
                                              fontSize: 18,
                                            ),
                                      ),
                                      if (post.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          post,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                      if (link != null) ...[
                                        const SizedBox(height: 8),
                                        GestureDetector(
                                          onTap: () => _openLink(link),
                                          child: Text(
                                            link,
                                            style: const TextStyle(
                                              color:Color( 0xFF53A8B6),
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
