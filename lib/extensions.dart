import 'package:flutter/material.dart';

extension ToMaterialColor on Color {
  MaterialColor get asMaterialColor {
    Map<int, Color> shades = [50, 100, 200, 300, 400, 500, 600, 700, 800, 900]
        .asMap()
        .map((key, value) => MapEntry(value, withOpacity(1 - (1 - (key + 1) / 10))));

    return MaterialColor(value, shades);
  }
}

class EmptyBox extends StatelessWidget {
  const EmptyBox({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 0, height: 0);
  }
}

class ImageWidget extends StatefulWidget {
  const ImageWidget(
      {super.key, required this.url,
        required this.w,
        required this.h,
        this.defImagePath = "assets/images/no_image.png"});

  final String url;
  final double w;
  final double h;
  final String defImagePath;

  @override
  State<StatefulWidget> createState() {
    return _StateImageWidget();
  }
}

class _StateImageWidget extends State<ImageWidget> {
  late Image _image;

  @override
  void initState() {
    super.initState();
    _image = Image.network(
      widget.url,
      width: widget.w,
      height: widget.h,
    );
    var resolve = _image.image.resolve(ImageConfiguration.empty);
    resolve.addListener(ImageStreamListener((_, __) {
    }, onError: (Object exception, StackTrace? stackTrace) {
      setState(() {
        _image = Image.asset(
          widget.defImagePath,
          width: widget.w,
          height: widget.h,
        );
      });
    }));
  }

  @override
  Widget build(BuildContext context) {
    return _image;
  }
}