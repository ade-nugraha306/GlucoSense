import 'package:flutter/material.dart';
import 'package:flutter_uas/logic/knn_service.dart';
import 'package:flutter_uas/pages/result_pages.dart';

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller untuk mengambil input user
  final TextEditingController glucController = TextEditingController();
  final TextEditingController bpController = TextEditingController();
  final TextEditingController bmiController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  final KNNService _knnService = KNNService();
  
  // [BARU] Variable untuk mengecek apakah data CSV sudah selesai dimuat
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    // [BARU] Panggil fungsi loading saat halaman pertama kali dibuka
    _loadDataset();
  }

  // [BARU] Fungsi asinkron untuk memuat data dari CSV
  Future<void> _loadDataset() async {
    // Memanggil fungsi loadCSV yang ada di KNNService
    await _knnService.loadCSV();
    
    // Jika widget masih aktif (tidak ditutup), update status
    if (mounted) {
      setState(() {
        _isDataLoaded = true; // Data siap!
      });
    }
  }

  void _analyze() {
    // [BARU] Cek dulu apakah data sudah siap
    if (!_isDataLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harap tunggu, sedang memuat dataset..."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      // Konversi input teks ke double
      double gluc = double.parse(glucController.text);
      double bp = double.parse(bpController.text);
      double bmi = double.parse(bmiController.text);
      double age = double.parse(ageController.text);

      // JALANKAN ALGORITMA K-NN (K=5)
      var result = _knnService.classify(gluc, bp, bmi, age, 5);

      // Pindah ke halaman hasil membawa data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(resultData: result),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Deteksi Dini Diabetes")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Masukkan Data Klinis",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              _buildInput("Glukosa (mg/dL)", glucController),
              _buildInput("Tekanan Darah (mm Hg)", bpController),
              _buildInput("BMI (Berat/Tinggi²)", bmiController),
              _buildInput("Usia (Tahun)", ageController),

              const SizedBox(height: 30),
              
              // [UPDATE] Tombol berubah tampilan tergantung status data
              ElevatedButton(
                onPressed: _isDataLoaded ? _analyze : null, // Tombol mati jika data belum siap
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  disabledBackgroundColor: Colors.grey, // Warna saat loading
                ),
                child: _isDataLoaded 
                  ? const Text(
                      "ANALISA SEKARANG",
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20, height: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        ),
                        SizedBox(width: 10),
                        Text("Memuat Data...", style: TextStyle(color: Colors.white)),
                      ],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Wajib diisi';
          return null;
        },
      ),
    );
  }
}