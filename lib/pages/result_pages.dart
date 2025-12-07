import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const ResultPage({super.key, required this.resultData});

  @override
  Widget build(BuildContext context) {
    bool isDanger = resultData['isDanger'];
    List<String> adviceList = resultData['advice'] ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text("Hasil Analisa AI")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // BAGIAN 1: Indikator Utama
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDanger ? Colors.red.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDanger ? Colors.red.shade200 : Colors.green.shade200,
                  width: 2
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    isDanger ? Icons.warning_rounded : Icons.check_circle_rounded,
                    size: 80,
                    color: isDanger ? Colors.red : Colors.green,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    resultData['result'],
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: isDanger ? Colors.red.shade800 : Colors.green.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    resultData['detail'],
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // BAGIAN 2: Judul Saran
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Saran & Rekomendasi:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            // BAGIAN 3: List Saran (Dynamic)
            ListView.builder(
              shrinkWrap: true, // Agar bisa masuk dalam SingleChildScrollView
              physics: const NeverScrollableScrollPhysics(),
              itemCount: adviceList.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: CircleAvatar(
                      // ignore: deprecated_member_use
                      backgroundColor: Colors.blueAccent.withOpacity(0.1),
                      child: const Icon(Icons.lightbulb, color: Colors.blueAccent),
                    ),
                    title: Text(
                      adviceList[index],
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
            
            // Tombol Kembali
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.blueAccent),
                ),
                child: const Text("Cek Kondisi Lainnya"),
              ),
            )
          ],
        ),
      ),
    );
  }
}