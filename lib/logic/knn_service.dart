import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

class KNNService {
  List<List<double>> dataset = [];
  List<double> minVals = [];
  List<double> maxVals = [];

  Future<void> loadCSV() async {
    try {
      final String rawData = await rootBundle.loadString('assets/diabetes.csv');
      List<String> lines = rawData.split('\n');
      dataset.clear();
      minVals = [];
      maxVals = [];

      for (int i = 1; i < lines.length; i++) {
        String line = lines[i].trim();
        if (line.isEmpty) continue;
        List<String> cols = line.split(',');

        if (cols.length >= 9) {
          try {
            double glucose = double.parse(cols[1]);
            double bp = double.parse(cols[2]);
            double bmi = double.parse(cols[5]);
            double age = double.parse(cols[7]);
            double label = double.parse(cols[8]);

            if (glucose == 0 || bp == 0 || bmi == 0) continue;
            dataset.add([glucose, bp, bmi, age, label]);
          } catch (e) {
            continue;
          }
        }
      }

      if (dataset.isNotEmpty) _calculateMinMax();
      if (kDebugMode) {
        print("Sukses: ${dataset.length} data bersih dimuat.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
    }
  }

  void _calculateMinMax() {
    if (dataset.isEmpty) return;
    minVals = [dataset[0][0], dataset[0][1], dataset[0][2], dataset[0][3]];
    maxVals = [dataset[0][0], dataset[0][1], dataset[0][2], dataset[0][3]];

    for (var row in dataset) {
      for (int i = 0; i < 4; i++) {
        if (row[i] < minVals[i]) minVals[i] = row[i];
        if (row[i] > maxVals[i]) maxVals[i] = row[i];
      }
    }
  }

  double _normalize(double value, int colIndex) {
    if (maxVals.isEmpty || minVals.isEmpty) return value;
    if (maxVals[colIndex] == minVals[colIndex]) return 0.0;
    return (value - minVals[colIndex]) / (maxVals[colIndex] - minVals[colIndex]);
  }

  // --- LOGIKA UTAMA ---
  Map<String, dynamic> classify(double gluc, double bp, double bmi, double age, int k) {
    if (dataset.isEmpty) return {'result': "Error", 'isDanger': false};

    // 1. Algoritma K-NN (Menentukan Risiko)
    List<Map<String, dynamic>> distances = [];
    double nGluc = _normalize(gluc, 0);
    double nBp = _normalize(bp, 1);
    double nBmi = _normalize(bmi, 2);
    double nAge = _normalize(age, 3);

    for (var data in dataset) {
      double dGluc = _normalize(data[0], 0);
      double dBp = _normalize(data[1], 1);
      double dBmi = _normalize(data[2], 2);
      double dAge = _normalize(data[3], 3);

      double dist = sqrt(
        pow(nGluc - dGluc, 2) + pow(nBp - dBp, 2) + pow(nBmi - dBmi, 2) + pow(nAge - dAge, 2)
      );
      distances.add({'label': data[4], 'distance': dist});
    }

    distances.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

    int positiveCount = 0;
    int negativeCount = 0;
    for (int i = 0; i < k; i++) {
      if (distances[i]['label'] == 1) {
        positiveCount++;
      } else {
        negativeCount++;
      }
    }

    bool isDiabetes = positiveCount > negativeCount;
    double confidence = (isDiabetes ? positiveCount : negativeCount) / k * 100;

    // 2. SISTEM PAKAR (Generate Saran / Feedback)
    List<String> adviceList = [];

    // A. Saran Utama Berdasarkan Hasil Prediksi
    if (isDiabetes) {
      adviceList.add("Segera konsultasikan hasil ini ke dokter penyakit dalam.");
      adviceList.add("Kurangi konsumsi karbohidrat sederhana (nasi putih, roti, gula).");
      adviceList.add("Cek gula darah puasa secara rutin.");
    } else {
      adviceList.add("Pertahankan gaya hidup sehat Anda.");
      adviceList.add("Tetap lakukan olahraga kardio minimal 30 menit/hari.");
    }

    // B. Saran Spesifik Berdasarkan Data (Personalized)
    // Cek Gula
    if (gluc > 200) {
      adviceList.add("⚠️ PERHATIAN: Gula darah Anda ($gluc) tergolong Sangat Tinggi.");
    } else if (gluc > 140) {
       adviceList.add("⚠️ Waspada: Gula darah Anda ($gluc) sedikit di atas normal.");
    }

    // Cek BMI (Obesitas)
    if (bmi > 30) {
      adviceList.add("⚠️ BMI Anda ($bmi) menunjukkan Obesitas. Menurunkan berat badan dapat mengurangi risiko diabetes secara drastis.");
    } else if (bmi > 25) {
      adviceList.add("Tips: Berat badan Anda 'Overweight'. Coba defisit kalori harian.");
    }

    // Cek Tensi
    if (bp > 90) {
      adviceList.add("Info: Tekanan darah Anda ($bp) terpantau cukup tinggi.");
    }

    return {
      'result': isDiabetes ? "RISIKO TINGGI" : "RISIKO RENDAH",
      'detail': isDiabetes 
          ? "Prediksi ML: ${confidence.toStringAsFixed(0)}% mirip pola pasien diabetes." 
          : "Prediksi ML: ${confidence.toStringAsFixed(0)}% mirip pola orang sehat.",
      'isDanger': isDiabetes,
      'advice': adviceList, // <--- Ini data saran yang akan kita tampilkan
    };
  }
}