// lib/services/qr_service.dart
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class QrService {
  static Widget buildQrScanner({
    required GlobalKey qrKey, // Gunakan GlobalKey biasa
    required Function(Barcode) onScan,
    required Function(QRViewController) onControllerCreated,
  }) {
    return QRView(
      key: qrKey,
      onQRViewCreated: (controller) {
        onControllerCreated(controller);
        controller.scannedDataStream.listen(onScan);
      },
      overlay: QrScannerOverlayShape(
        borderColor: Colors.blue,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: 300,
      ),
    );
  }

  static Future<void> pauseScanner(QRViewController controller) async {
    await controller.pauseCamera();
  }

  static Future<void> resumeScanner(QRViewController controller) async {
    await controller.resumeCamera();
  }

  static Future<void> disposeScanner(QRViewController controller) async {
    await controller.stopCamera(); // Hentikan kamera dengan aman
    controller.pauseCamera(); // Pastikan kamera dalam keadaan nonaktif
  }


  static Future<void> toggleFlash(QRViewController controller) async {
    await controller.toggleFlash();
  }

  static Future<void> flipCamera(QRViewController controller) async {
    await controller.flipCamera();
  }
}