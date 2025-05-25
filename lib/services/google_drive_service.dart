import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class GoogleDriveService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.standard(
    scopes: [drive.DriveApi.driveFileScope],
  );

  Future<void> uploadFile(String data) async {
    final googleUser = await _googleSignIn.signIn();
    final authHeaders = await googleUser!.authHeaders;
    
    final client = GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(client);

    // Create temporary file
    final directory = await getTemporaryDirectory();
    final tempFile = File('${directory.path}/backup.json');
    await tempFile.writeAsString(data);

    final fileMedia = drive.Media(
      tempFile.openRead(),
      tempFile.lengthSync(),
    );

    await driveApi.files.create(
      drive.File()..name = 'backup_${DateTime.now().toIso8601String()}.json',
      uploadMedia: fileMedia,
    );
  }

  Future<String> downloadFile() async {
    // Implementasi download file
    return '';
  }
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> headers;
  final _client = http.Client();

  GoogleAuthClient(this.headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(headers);
    return _client.send(request);
  }
}