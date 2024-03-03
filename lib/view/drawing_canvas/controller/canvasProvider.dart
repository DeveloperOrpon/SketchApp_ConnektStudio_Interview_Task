import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import '../models/drawing_mode.dart';
import '../models/sketch.dart';
import '../widgets/canvas_side_bar.dart';

class CanvasProvider extends ChangeNotifier {
  Color _selectedColor = Colors.black;
  int _strokeSize = 8;
  var _drawingMode = DrawingMode.pencil;
  bool _filled = false;
  int _polygonSides = 3;
  Image? backgroundImage;
  Sketch? _currentSketch;
  final canvasGlobalKey = GlobalKey();


  Sketch? get currentSketch => _currentSketch;

  set currentSketch(Sketch? value) {
    _currentSketch = value;
    notifyListeners();
  }

  Color get selectedColor => _selectedColor;

  set selectedColor(Color value) {
    _selectedColor = value;
    notifyListeners();
  }

  int get strokeSize => _strokeSize;

  set strokeSize(int value) {
    _strokeSize = value;
    notifyListeners();
  }

  get drawingMode => _drawingMode;

  set drawingMode(value) {
    _drawingMode = value;
    notifyListeners();
  }

  bool get filled => _filled;

  set filled(bool value) {
    _filled = value;
    notifyListeners();
  }

  int get polygonSides => _polygonSides;

  set polygonSides(int value) {
    _polygonSides = value;
    notifyListeners();
  }

  ////undo
   List<Sketch> _sketchesNotifier =[];
   Sketch? _currentSketchNotifier;
  late bool _canRedo = false;
  List<Sketch> _redoStack = [];
   int _sketchCount=0;

  List<Sketch> get sketchesNotifier => _sketchesNotifier;

  set sketchesNotifier(List<Sketch> value) {
    _sketchesNotifier = value;
    _sketchesCountListener();
    notifyListeners();
  }

  Sketch? get currentSketchNotifier => _currentSketchNotifier;

  set currentSketchNotifier(Sketch? value) {
    _currentSketchNotifier = value;
    notifyListeners();
  }

  bool get canRedo => _canRedo;

  set canRedo(bool value) {
    _canRedo = value;
    notifyListeners();
  }

  List<Sketch> get redoStack => _redoStack;

  set redoStack(List<Sketch> value) {
    _redoStack = value;
    notifyListeners();
  }

  int get sketchCount => _sketchCount;

  set sketchCount(int value) {
    _sketchCount = value;
    notifyListeners();
  }
  ///function

  void _sketchesCountListener() {
    if (sketchesNotifier.length > _sketchCount) {
      //if a new sketch is drawn,
      //history is invalidated so clear redo stack
      _redoStack.clear();
      _canRedo= false;
      _sketchCount = sketchesNotifier.length;
      notifyListeners();
    }
  }

  void clear() {
    _sketchCount = 0;
    sketchesNotifier = [];
    _canRedo = false;
    currentSketchNotifier = null;
    notifyListeners();
  }

  void undo() {
    final sketches = sketchesNotifier;
    log("sketches:${sketches.length}");
    if (sketches.isNotEmpty) {
      _sketchCount--;
      _redoStack.add(sketches.removeLast());
      sketchesNotifier = [...sketches];
      _canRedo = true;
      currentSketchNotifier = null;
      notifyListeners();
    }
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    final sketch = _redoStack.removeLast();
    _canRedo = _redoStack.isNotEmpty;
    _sketchCount++;
    sketchesNotifier = [...sketchesNotifier, sketch];
    notifyListeners();
  }
}
