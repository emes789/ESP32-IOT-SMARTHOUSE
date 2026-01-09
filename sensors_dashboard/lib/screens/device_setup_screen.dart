import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/*
 * Ekran konfiguracji (Provisioning) urządzenia ESP32.
 * Realizuje: Skanowanie -> Łączenie -> Wysłanie danych Wi-Fi (SSID/Hasło)
 */
class DeviceSetupScreen extends StatefulWidget {
  const DeviceSetupScreen({super.key});

  @override
  State<DeviceSetupScreen> createState() => _DeviceSetupScreenState();
}

class _DeviceSetupScreenState extends State<DeviceSetupScreen> {
  // UUID zdefiniowane w kodzie ESP32 (muszą być takie same!)
  final String SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String CHARACTERISTIC_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  bool _isScanning = false;
  List<ScanResult> _scanResults = [];
  BluetoothDevice? _connectedDevice;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    _connectedDevice?.disconnect();
    super.dispose();
  }

  Future<void> _startScan() async {
    if (_isScanning) return;
    
    setState(() {
      _isScanning = true;
      _scanResults = [];
    });

    try {
      // Sprawdź czy BT jest włączony
      if (await FlutterBluePlus.adapterState.first == BluetoothAdapterState.off) {
         if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bluetooth jest wyłączony. Włącz go.')),
          );
         }
         setState(() => _isScanning = false);
         return;
      }

      var subscription = FlutterBluePlus.scanResults.listen((results) {
        setState(() {
          // Filtrujemy urządzenia, które mają nazwę i nie są już dodane
          _scanResults = results
              .where((r) => r.device.platformName.isNotEmpty)
              .toList();
        });
      });

      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
      
      await Future.delayed(const Duration(seconds: 5));
      await subscription.cancel();

    } catch (e) {
      debugPrint("Błąd BLE: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Future<void> _connectAndSetup(BluetoothDevice device) async {
    setState(() => _isConnecting = true);
    
    try {
      await device.connect();
      _connectedDevice = device;
      
      if (!mounted) return;
      
      // Pokaż dialog do wpisania danych Wi-Fi
      _showWiFiDialog(device);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nie udało się połączyć: $e')),
        );
      }
      setState(() => _isConnecting = false);
    }
  }

  void _showWiFiDialog(BluetoothDevice device) {
    final ssidController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('Konfiguracja Wi-Fi dla ${device.platformName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ssidController,
              decoration: const InputDecoration(labelText: 'Nazwa sieci (SSID)'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Hasło Wi-Fi'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              device.disconnect();
              Navigator.pop(ctx);
              setState(() => _isConnecting = false);
            },
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _sendCredentials(device, ssidController.text, passwordController.text);
            },
            child: const Text('Wyślij'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendCredentials(BluetoothDevice device, String ssid, String password) async {
    try {
      // Odkryj serwisy
      List<BluetoothService> services = await device.discoverServices();
      BluetoothCharacteristic? targetCharacteristic;

      // Znajdź właściwą charakterystykę
      for (var service in services) {
        if (service.uuid.toString() == SERVICE_UUID) {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString() == CHARACTERISTIC_UUID) {
              targetCharacteristic = characteristic;
              break;
            }
          }
        }
      }

      if (targetCharacteristic == null) {
        throw Exception("Nie znaleziono serwisu konfiguracyjnego na urządzeniu.");
      }

      // Przygotuj dane JSON
      String data = jsonEncode({'ssid': ssid, 'password': password});
      
      // Wyślij dane
      await targetCharacteristic.write(utf8.encode(data));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dane wysłane! Urządzenie powinno się zrestartować.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Wróć do ustawień
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd wysyłania: $e')),
        );
      }
    } finally {
      device.disconnect();
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skaner BLE'),
        actions: [
          if (_isScanning)
            const Center(child: Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
            ))
        ],
      ),
      body: Column(
        children: [
          if (_isConnecting)
            const LinearProgressIndicator(),
            
          Expanded(
            child: _scanResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.bluetooth_searching, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('Brak urządzeń w pobliżu.'),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _startScan, child: const Text("Szukaj"))
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _scanResults.length,
                    itemBuilder: (context, index) {
                      final result = _scanResults[index];
                      return ListTile(
                        leading: const Icon(Icons.smart_toy),
                        title: Text(result.device.platformName.isNotEmpty ? result.device.platformName : "Nieznane urządzenie"),
                        subtitle: Text(result.device.remoteId.toString()),
                        trailing: ElevatedButton(
                          onPressed: _isConnecting ? null : () => _connectAndSetup(result.device),
                          child: const Text("Połącz"),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}