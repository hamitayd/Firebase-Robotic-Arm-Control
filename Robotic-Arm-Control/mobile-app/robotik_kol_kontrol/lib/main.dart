import 'dart:collection';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Robotik Kol Kontrol',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 0, 4, 255)),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[100],
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const MyHomePage(title: 'Robotik Kol Kontrol'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final refKisiler = FirebaseDatabase.instance.ref().child("motor_konumlari");

  final motor1 = TextEditingController();
  final motor2 = TextEditingController();
  final motor3 = TextEditingController();
  final motor4 = TextEditingController();
  final slowController = TextEditingController();

  bool isLoading = false;
  Map<String, dynamic> mevcutVeri = {};

  @override
  void initState() {
    super.initState();
    kontrolEtVeOlustur();
    dinleVeri();
  }

  void kontrolEtVeOlustur() async {
    try {
      final snapshot = await refKisiler.get();
      if (!snapshot.exists) {
        await refKisiler.set({
          "motor_1": 45,
          "motor_2": 45,
          "motor_3": 45,
          "motor_4": 45,
          "durum": 0
        });
      }
    } catch (e) {
      print(e);
      return;
    }
  }

  void dinleVeri() {
    refKisiler.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        setState(() {
          mevcutVeri = Map<String, dynamic>.from(
              data.map((key, value) => MapEntry(key.toString(), value)));
        });
      }
    });
  }

  void durumGuncelle() async {
    var bilgi = HashMap<String, dynamic>();
    if (slowController.text.isNotEmpty) {
      bilgi["durum"] = "1";
      bilgi["motor_1"] = slowController.text;

      try {
        final snapshot = await refKisiler.get();
        if (snapshot.exists) {
          await refKisiler.update(bilgi);
        } else {
          await refKisiler.set(bilgi);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('Kayıt Güncellendi: '
                '${bilgi["motor_1"] ?? "-"} '
                '${bilgi["motor_2"] ?? "-"} '
                '${bilgi["motor_3"] ?? "-"} '
                '${bilgi["motor_4"] ?? "-"}'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: \$e')),
        );
      }
    }
  }

  void Guncelle() async {
    if (isLoading) return;

    var bilgi = HashMap<String, dynamic>();

    if (motor1.text.isNotEmpty) bilgi["motor_1"] = motor1.text;
    if (motor2.text.isNotEmpty) bilgi["motor_2"] = motor2.text;
    if (motor3.text.isNotEmpty) bilgi["motor_3"] = motor3.text;
    if (motor4.text.isNotEmpty) bilgi["motor_4"] = motor4.text;

    if (bilgi.isEmpty && slowController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Text("Herhangi bir değer girmediniz."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tamam"),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Veri g\u00fcncelleniyor..."),
            ],
          ),
        );
      },
    );

    try {
      final snapshot = await refKisiler.get();
      if (snapshot.exists) {
        await refKisiler.update(bilgi);
      } else {
        await refKisiler.set(bilgi);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Kayıt Güncellendi: '
              '${bilgi["motor_1"] ?? "-"} '
              '${bilgi["motor_2"] ?? "-"} '
              '${bilgi["motor_3"] ?? "-"} '
              '${bilgi["motor_4"] ?? "-"}'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: \$e')),
      );
    } finally {
      Navigator.pop(context);
      setState(() {
        isLoading = false;
      });
      motor1.clear();
      motor2.clear();
      motor3.clear();
      motor4.clear();
      slowController.clear();
    }
  }

  void checkMaxValue(TextEditingController controller) {
    if (controller.text.isEmpty) return;
    final value = int.tryParse(controller.text);
    if (value != null && value > 90) {
      controller.text = '90';
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    }
  }

  Widget buildMotorField(
      String label, String fieldKey, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      decoration: const InputDecoration(
                        hintText: "0 - 90",
                        counterText: '',
                      ),
                      onChanged: (value) => checkMaxValue(controller),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Column(
                children: [
                  const Text("Mevcut",
                      style: TextStyle(fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 4),
                  Container(
                    width: 50,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.deepPurple),
                    ),
                    child: Center(
                      child: Text(
                        mevcutVeri[fieldKey]?.toString() ?? "-",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                buildMotorField("Motor 1", "motor_1", motor1),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 15.0),
                          child: TextField(
                            controller: slowController,
                            keyboardType: TextInputType.number,
                            maxLength: 3,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                            decoration: const InputDecoration(
                              hintText: "0 - 90",
                              counterText: '',
                            ),
                            onChanged: (value) => checkMaxValue(slowController),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          durumGuncelle();
                          Guncelle();
                        },
                        child: Text("Yavaş Döndür"),
                      ),
                    ],
                  ),
                ),
                buildMotorField("Motor 2", "motor_2", motor2),
                buildMotorField("Motor 3", "motor_3", motor3),
                buildMotorField("Motor 4", "motor_4", motor4),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isLoading ? null : Guncelle,
                    child: const Text("Motoru Ayarla",
                        style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
