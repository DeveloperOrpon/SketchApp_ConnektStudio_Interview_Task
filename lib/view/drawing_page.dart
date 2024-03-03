import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/material.dart' as IMG;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sketch_app/main.dart';
import 'package:sketch_app/view/drawing_canvas/controller/canvasProvider.dart';
import 'package:sketch_app/view/drawing_canvas/drawing_canvas.dart';
import 'package:sketch_app/view/drawing_canvas/models/drawing_mode.dart';
import 'package:sketch_app/view/drawing_canvas/models/sketch.dart';
import 'package:sketch_app/view/drawing_canvas/widgets/canvas_side_bar.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});

  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      value: 1,);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CanvasProvider>(builder: (context, canvasProvider, child) {
      return Scaffold(
        appBar: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.grey,
              statusBarIconBrightness: Brightness.light),
          backgroundColor: Colors.grey,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              if (animationController.value == 0) {
                animationController.forward();
              } else {
                animationController.reverse();
              }
            },
            icon: const Icon(Icons.drive_file_rename_outline),
          ),
          actions: [
            const SizedBox(
              width: 50,
            ),
            Container(
              margin: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  onSurface: Colors.transparent,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                onPressed: canvasProvider.sketchesNotifier.isNotEmpty
                    ? () => canvasProvider.undo()
                    : null,
                label: const Text('Undo'),
                icon: const Icon(
                  Icons.undo,
                  size: 15,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  onSurface: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                onPressed:
                    canvasProvider.canRedo ? () => canvasProvider.redo() : null,
                label: const Text(
                  'Redo',
                  style: TextStyle(color: Colors.white),
                ),
                icon: const Icon(
                  Icons.redo,
                  size: 15,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  onSurface: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                onPressed: () => canvasProvider.clear(),
                label: const Text('Clear'),
                icon: const Icon(
                  Icons.cleaning_services_rounded,
                  size: 15,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [
                    Color(0xFF5100ad),
                    Color(0xFFad004b),
                    //add more colors
                  ]),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.57),
                        //shadow for button
                        blurRadius: 5) //blur radius of shadow
                  ]),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.transparent,
                  elevation: 0,
                  onSurface: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                onPressed: () async {
                  Uint8List? pngBytes =
                      await getBytes(canvasProvider.canvasGlobalKey);
                  log('pngBytes: ${pngBytes}');
                  if (pngBytes != null) saveFile(pngBytes, 'png', context);
                },
                // label: const Text(overflow: TextOverflow.ellipsis,'Download',style: TextStyle(color: Colors.white),),
                child: const Icon(
                  Icons.file_download,
                  size: 15,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
        body: Stack(
          children: [
            Container(
              color: kCanvasColor,
              width: double.maxFinite,
              height: double.maxFinite,
              child: DrawingCanvas(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                sideBarController: animationController,
              ),
            ),
            Positioned(
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(-1, 0),
                  end: Offset.zero,
                ).animate(animationController),
                child: const CanvasSideBar(),
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<Uint8List?> getBytes(
      GlobalKey<State<StatefulWidget>> canvasGlobalKey) async {
    RenderRepaintBoundary boundary = canvasGlobalKey.currentContext
        ?.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List? pngBytes = byteData?.buffer.asUint8List();
    return pngBytes;
  }

  void saveFile(Uint8List bytes, String extension, BuildContext context) async {
    log("saveFile: ${extension}---\n $bytes");
    try {
      final Directory downloadsDirectory =
          await getApplicationDocumentsDirectory();

      // Create a new file in the downloads directory with a unique name
      final String filePath =
          '${downloadsDirectory!.path}/image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File file = File(filePath);
      await file.writeAsBytes(bytes);
      final String dir = (await getApplicationDocumentsDirectory()).path;
      GallerySaver.saveImage(file.path).then((value){
        const snackBar = SnackBar(
          content: Text('Image Save to the gallery!'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }).catchError((onError){

        const snackBar = SnackBar(
          content: Text('Something Error Try Again!'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    } catch (e) {
      log('Error saving image: $e');
    }
  }
}
