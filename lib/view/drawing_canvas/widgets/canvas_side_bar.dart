import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sketch_app/main.dart';
import 'package:sketch_app/view/drawing_canvas/controller/canvasProvider.dart';
import 'package:sketch_app/view/drawing_canvas/models/drawing_mode.dart';
import 'package:sketch_app/view/drawing_canvas/models/sketch.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';

class CanvasSideBar extends StatelessWidget {
  const CanvasSideBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: MediaQuery.of(context).size.height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 3,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child:
          Consumer<CanvasProvider>(builder: (context, canvasProvider, child) {
        return ListView(
          padding: const EdgeInsets.symmetric(),
          physics: const BouncingScrollPhysics(),
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => canvasProvider.drawingMode = DrawingMode.pencil,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: const Color(0xFFbcc2d7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              canvasProvider.drawingMode == DrawingMode.pencil
                                  ? const Color(0xFF8c65ff)
                                  : Colors.transparent,
                          width: 3,
                        )),
                    child: const Icon(
                      FontAwesomeIcons.pencil,
                      size: 40,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => canvasProvider.drawingMode = DrawingMode.eraser,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: const Color(0xFFbcc2d7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              canvasProvider.drawingMode == DrawingMode.eraser
                                  ? const Color(0xFF8c65ff)
                                  : Colors.transparent,
                          width: 3,
                        )),
                    child: const Icon(
                      FontAwesomeIcons.eraser,
                      size: 40,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Size (${canvasProvider.strokeSize})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: () {
                      if (canvasProvider.strokeSize > 0) {
                        canvasProvider.strokeSize--;
                      }
                    },
                    icon: const Icon(CupertinoIcons.minus)),
                IconButton(
                    onPressed: () {
                      canvasProvider.strokeSize++;
                    },
                    icon: const Icon(CupertinoIcons.add)),
              ],
            ),
            const Center(
              child: Text(
                'Stroke Type:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => canvasProvider.drawingMode = DrawingMode.pencil,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: const Color(0xFFbcc2d7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              canvasProvider.drawingMode == DrawingMode.pencil
                                  ? const Color(0xFF8c65ff)
                                  : Colors.transparent,
                          width: 3,
                        )),
                    child: const Icon(
                      CupertinoIcons.pen,
                      size: 40,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => canvasProvider.drawingMode = DrawingMode.line,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: const Color(0xFFbcc2d7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: canvasProvider.drawingMode == DrawingMode.line
                              ? const Color(0xFF8c65ff)
                              : Colors.transparent,
                          width: 3,
                        )),
                    child: const Icon(
                      Icons.straight,
                      size: 40,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => canvasProvider.drawingMode = DrawingMode.circle,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: const Color(0xFFbcc2d7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              canvasProvider.drawingMode == DrawingMode.circle
                                  ? const Color(0xFF8c65ff)
                                  : Colors.transparent,
                          width: 3,
                        )),
                    child: const Icon(
                      FontAwesomeIcons.circle,
                      size: 40,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => canvasProvider.drawingMode = DrawingMode.square,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: const Color(0xFFbcc2d7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              canvasProvider.drawingMode == DrawingMode.square
                                  ? const Color(0xFF8c65ff)
                                  : Colors.transparent,
                          width: 3,
                        )),
                    child: const Icon(
                      FontAwesomeIcons.square,
                      size: 40,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => canvasProvider.drawingMode = DrawingMode.polygon,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: const Color(0xFFbcc2d7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              canvasProvider.drawingMode == DrawingMode.polygon
                                  ? const Color(0xFF8c65ff)
                                  : Colors.transparent,
                          width: 3,
                        )),
                    child: const Icon(
                      CupertinoIcons.triangle,
                      size: 40,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Fill Shape: ',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: canvasProvider.filled,
                  onChanged: (val) {
                    canvasProvider.filled = val ?? false;
                  },
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  void saveFile(Uint8List bytes, String extension) async {
    if (kIsWeb) {
      html.AnchorElement()
        ..href = '${Uri.dataFromBytes(bytes, mimeType: 'image/$extension')}'
        ..download =
            'FlutterLetsDraw-${DateTime.now().toIso8601String()}.$extension'
        ..style.display = 'none'
        ..click();
    } else {
      await FileSaver.instance.saveFile(
        name: 'FlutterLetsDraw-${DateTime.now().toIso8601String()}.$extension',
        bytes: bytes,
        ext: extension,
        mimeType: extension == 'png' ? MimeType.png : MimeType.jpeg,
      );
    }
  }

  Future<ui.Image> get _getImage async {
    final completer = Completer<ui.Image>();
    if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS) {
      final file = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (file != null) {
        final filePath = file.files.single.path;
        final bytes = filePath == null
            ? file.files.first.bytes
            : File(filePath).readAsBytesSync();
        if (bytes != null) {
          completer.complete(decodeImageFromList(bytes));
        } else {
          completer.completeError('No image selected');
        }
      }
    } else {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        completer.complete(
          decodeImageFromList(bytes),
        );
      } else {
        completer.completeError('No image selected');
      }
    }

    return completer.future;
  }

  Future<void> _launchUrl(String url) async {
    if (kIsWeb) {
      html.window.open(
        url,
        url,
      );
    } else {
      if (!await launchUrl(Uri.parse(url))) {
        throw 'Could not launch $url';
      }
    }
  }

  Future<Uint8List?> getBytes(BuildContext context) async {
    CanvasProvider canvasProvider = Provider.of<CanvasProvider>(context);
    RenderRepaintBoundary boundary =
        canvasProvider.canvasGlobalKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List? pngBytes = byteData?.buffer.asUint8List();
    return pngBytes;
  }
}

class _IconBox extends StatelessWidget {
  final IconData? iconData;
  final Widget? child;
  final bool selected;
  final VoidCallback onTap;
  final String? tooltip;

  const _IconBox({
    Key? key,
    this.iconData,
    this.child,
    this.tooltip,
    required this.selected,
    required this.onTap,
  })  : assert(child != null || iconData != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? Colors.grey[900]! : Colors.grey,
              width: 1.5,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
          child: Tooltip(
            message: tooltip,
            preferBelow: false,
            child: child ??
                Icon(
                  iconData,
                  color: selected ? Colors.grey[900] : Colors.grey,
                  size: 20,
                ),
          ),
        ),
      ),
    );
  }
}

///A data structure for undoing and redoing sketches.
class UndoRedoStack {
  UndoRedoStack({
    required this.sketchesNotifier,
    required this.currentSketchNotifier,
  }) {
    _sketchCount = sketchesNotifier.value.length;
    sketchesNotifier.addListener(_sketchesCountListener);
  }

  final ValueNotifier<List<Sketch>> sketchesNotifier;
  final ValueNotifier<Sketch?> currentSketchNotifier;

  ///Collection of sketches that can be redone.
  late final List<Sketch> _redoStack = [];

  ///Whether redo operation is possible.
  ValueNotifier<bool> get canRedo => _canRedo;
  late final ValueNotifier<bool> _canRedo = ValueNotifier(false);

  late int _sketchCount;

  void _sketchesCountListener() {
    if (sketchesNotifier.value.length > _sketchCount) {
      //if a new sketch is drawn,
      //history is invalidated so clear redo stack
      _redoStack.clear();
      _canRedo.value = false;
      _sketchCount = sketchesNotifier.value.length;
    }
  }

  void clear() {
    _sketchCount = 0;
    sketchesNotifier.value = [];
    _canRedo.value = false;
    currentSketchNotifier.value = null;
  }

  void undo() {
    final sketches = List<Sketch>.from(sketchesNotifier.value);
    if (sketches.isNotEmpty) {
      _sketchCount--;
      _redoStack.add(sketches.removeLast());
      sketchesNotifier.value = sketches;
      _canRedo.value = true;
      currentSketchNotifier.value = null;
    }
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    final sketch = _redoStack.removeLast();
    _canRedo.value = _redoStack.isNotEmpty;
    _sketchCount++;
    sketchesNotifier.value = [...sketchesNotifier.value, sketch];
  }

  void dispose() {
    sketchesNotifier.removeListener(_sketchesCountListener);
  }
}
