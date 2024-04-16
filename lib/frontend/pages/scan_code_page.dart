import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mental_health/backend/services/navigation_service.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:torch_light/torch_light.dart';

class ScanCodePage extends StatefulWidget {
  const ScanCodePage({Key? key}) : super(key: key);

  @override
  State<ScanCodePage> createState() => _ScanCodePageState();
}

class _ScanCodePageState extends State<ScanCodePage> {
  late NavigationService _navigationService;
  final GetIt _getIt = GetIt.instance;

  bool isScanning = false;
  bool istorchon = false;
  bool showRescanButton = false;

  @override
  void initState() {
    super.initState();
    _navigationService = _getIt.get<NavigationService>();
  }

  void startScanning() {
    setState(() {
      isScanning = true;
    });
  }

  void stopScanning() {
    setState(() {
      isScanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'SERENE',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          // IconButton(
          //   onPressed: () async {
          //     istorchon
          //         ? await TorchLight.disableTorch()
          //         : await TorchLight.enableTorch();
          //     setState(() {
          //       istorchon = !istorchon;
          //     });
          //   },
          //   icon: Icon(
          //     istorchon ? Icons.flash_on : Icons.flash_off,
          //     color: Colors.black,
          //   ),
          // ),
          IconButton(
            onPressed: () {
              _navigationService.pushNamed('/generate');
            },
            icon: const Icon(
              Icons.qr_code_rounded,
            ),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Column(
            children: [
              if (!isScanning)
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      startScanning();
                    },
                    child: const Text('Scan QR code'),
                  ),
                ),
              Visibility(
                visible: isScanning,
                child: Expanded(
                  flex: 2,
                  child: MobileScanner(
                    controller: MobileScannerController(
                      detectionSpeed: DetectionSpeed.noDuplicates,
                      returnImage: true,
                      torchEnabled: true,
                    ),
                    onDetect: (capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      final Uint8List? image = capture.image;
                      for (final barcode in barcodes) {
                        print('Barcode found! ${barcode.rawValue}');
                      }
                      if (image != null) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(
                                barcodes.first.rawValue ?? "",
                              ),
                              content: Image(
                                image: MemoryImage(image),
                              ),
                            );
                          },
                        );
                      }
                      stopScanning();
                    },
                  ),
                ),
              ),
              const Spacer(
                flex: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
