import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_repository/user_repository.dart';
import 'package:http/http.dart' as http;
import '/widgets/profile_networkimage.dart';

class SettingException implements Exception {
  final String message;

  SettingException(this.message); // Pass your message in constructor.

  @override
  String toString() {
    return message;
  }
}

class ProfileWidget extends StatefulWidget {
  final User user;
  final bool isEdit;
  final Function onUpdate;

  const ProfileWidget({
    Key? key,
    required this.user,
    required this.isEdit,
    required this.onUpdate,
  }) : super(key: key);

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  XFile? _imageFile;
  Uint8List webImage = Uint8List(8);
  bool sending = false;
  final ImagePicker _picker = ImagePicker();
  late SharedPreferences prefs;
  String _serviceUrl = "";
  String token = "";

  void loadServiceURL() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _serviceUrl = (prefs.getString('serviceUrl') ?? "");
      token = (prefs.getString('token') ?? "");
    });
  }

  @override
  void initState() {
    super.initState();
    loadServiceURL();
  }

  @override
  Widget build(BuildContext context) {
    return imageProfile(widget.isEdit);
  }

  String initials(String fullname, String email) {
    if (fullname.isEmpty) {
      return email.substring(0, 2).toUpperCase();
    } else {
      List nm = fullname.split(" ");
      if (nm.length >= 2) {
        return nm[0].substring(0, 1).toUpperCase() + nm[1].substring(0, 1).toUpperCase();
      }
      return fullname.substring(0, 2).toUpperCase();
    }
  }

  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );

  Widget buildEditIcon(double size, Color color) => buildCircle(
        color: Theme.of(context).scaffoldBackgroundColor,
        all: 3,
        child: buildCircle(
          color: color,
          all: size / 3,
          child: Icon(
            Icons.camera_alt,
            color: Colors.white,
            size: size,
          ),
        ),
      );

  Widget imageProfile(bool editable) {
    double circleSize = 40.0;
    final color = Theme.of(context).colorScheme.inversePrimary;
    final Widget content = Stack(clipBehavior: Clip.none, children: <Widget>[
      (widget.user.image.isEmpty || _serviceUrl.isEmpty || token.isEmpty) && _imageFile == null
          ? CircleAvatar(
              radius: circleSize,
              child: Text(initials(widget.user.fullname, widget.user.email),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: circleSize / 1.7,
                    fontWeight: FontWeight.bold,
                  )))
          : CircleAvatar(
              radius: circleSize,
              backgroundImage: _imageFile == null
                  ? profileNetworkImage(_serviceUrl, token, widget.user.email)
                  : kIsWeb
                      ? Image.memory(webImage) as ImageProvider
                      : FileImage(File(_imageFile!.path)),
            ),
      Positioned(
        bottom: -circleSize / 4,
        right: -circleSize / 4,
        child: sending
            ? Stack(children: <Widget>[
                buildEditIcon(circleSize / 2.2, color),
                const CircularProgressIndicator(strokeWidth: 5)
              ])
            : buildEditIcon(circleSize / 2.2, color),
      ),
    ]);
    return Center(
      child: editable && !sending
          ? InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: ((builder) => bottomSheet()),
                );
              },
              child: content)
          : content,
    );
  }

  Widget bottomSheet() {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        children: <Widget>[
          const Text(
            "Choose Profile photo",
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            TextButton.icon(
              icon: const Icon(Icons.camera),
              onPressed: () {
                takePhoto(ImageSource.camera);
                Navigator.of(context).pop();
              },
              label: const Text("Camera"),
            ),
            TextButton.icon(
              icon: const Icon(Icons.image),
              onPressed: () {
                takePhoto(ImageSource.gallery);
                Navigator.of(context).pop();
              },
              label: const Text("Gallery"),
            ),
          ])
        ],
      ),
    );
  }

  Future<bool> asyncFileUpload(String whatFor, File file) async {
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();
    String? backendUrl = prefs.getString('serviceUrl');
    if (backendUrl == null || backendUrl == "") {
      throw SettingException('Missing backendUrl');
    }
    String? token = prefs.getString('token');
    //create multipart request for POST or PATCH method
    var request = http.MultipartRequest("POST", Uri.parse("http://$backendUrl/api/new_user_avatar"));
    request.headers.addAll({
      "Access-Control-Allow-Origin": "*",
      "Content-Type": "application/json; charset=UTF-8",
      "Accept": "application/json",
      "Authorization": "Bearer $token|:|:|${widget.user.email}"
    });
    //add an information as text field
    request.fields["whatFor"] = whatFor;
    //create multipart using filepath, string or bytes
    var pic = await http.MultipartFile.fromPath("file", file.path);
    //add multipart to request
    request.files.add(pic);
    var response = await request.send();

    //Get the response from the server
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    widget.onUpdate(responseString);
    return true;
  }

  Future<void> sendImageToServer(XFile pickedFile) async {
    setState(() {
      sending = true;
    });
    await asyncFileUpload("new avatar", File(pickedFile.path));
    setState(() {
      sending = false;
    });
  }

  void takePhoto(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
    );
    if (pickedFile != null) {
      if (!kIsWeb) {
        setState(() {
          _imageFile = pickedFile;
        });
      } else {
        var f = await pickedFile.readAsBytes();
        setState(() {
          webImage = f;
          _imageFile = XFile('forUpdate');
        });
      }
      sendImageToServer(pickedFile);
    }
  }
}
