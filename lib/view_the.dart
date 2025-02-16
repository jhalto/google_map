import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewThePdf extends StatefulWidget {
  final String? pdfPath; // Path of the PDF file

  const ViewThePdf({super.key, this.pdfPath});

  @override
  State<ViewThePdf> createState() => _ViewThePdfState();
}

class _ViewThePdfState extends State<ViewThePdf> {
  List<List<Offset>> allDrawingPoints = [];
  List<List<Color>> allDrawingColors = [];
  List<Offset> currentStrokePoints = [];
  List<Color> currentStrokeColors = [];
  String pdfPath = "assets/Sample Map.pdf"; // Default PDF
  bool isDrawingMode = false; // Toggle between draw mode & view
  Color selectedColor = Colors.blue; // Default drawing color
  double scale = 1.0; // Scale factor for zoom

  @override
  void initState() {
    super.initState();
    _loadPdf(); // Load saved PDF path
    _loadDrawings(); // Load saved drawings
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    List<String> drawingStrings = [];
    for (int i = 0; i < allDrawingPoints.length; i++) {
      drawingStrings.add(allDrawingPoints[i].asMap().entries.map((entry) {
        int index = entry.key;
        Offset point = entry.value;
        return "${point.dx},${point.dy},${allDrawingColors[i][index].value}";
      }).join(';'));
    }

    if (widget.pdfPath != null) {
      await prefs.setString('saved_pdf', widget.pdfPath!);
    }
    await prefs.setStringList('pdf_drawings', drawingStrings);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF & Drawings Saved!')),
    );
  }

  Future<void> _loadPdf() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      pdfPath = prefs.getString('saved_pdf') ?? 'assets/Sample Map.pdf';
    });
  }

  Future<void> _loadDrawings() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? drawingStrings = prefs.getStringList('pdf_drawings');

    if (drawingStrings != null) {
      setState(() {
        allDrawingPoints.clear();
        allDrawingColors.clear();
        for (String strokeString in drawingStrings) {
          List<String> strokeParts = strokeString.split(';');
          List<Offset> strokePoints = [];
          List<Color> strokeColors = [];
          for (String pointString in strokeParts) {
            List<String> parts = pointString.split(',');
            if (parts.length == 3) {
              strokePoints
                  .add(Offset(double.parse(parts[0]), double.parse(parts[1])));
              strokeColors.add(Color(int.parse(parts[2])));
            }
          }
          allDrawingPoints.add(strokePoints);
          allDrawingColors.add(strokeColors);
        }
      });
    }
  }

  Future<void> _clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pdf_drawings');
    setState(() {
      allDrawingPoints.clear();
      allDrawingColors.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Drawings Cleared!')),
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('View PDF'),
      actions: [
        IconButton(
          icon: Icon(isDrawingMode ? Icons.visibility : Icons.brush),
          onPressed: () {
            setState(() {
              isDrawingMode = !isDrawingMode;
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.color_lens),
          onPressed: () {
            _showColorPicker();
          },
        ),
        IconButton(icon: const Icon(Icons.save), onPressed: _saveData),
        IconButton(icon: const Icon(Icons.delete), onPressed: _clearData),
        IconButton(
          icon: const Icon(Icons.zoom_in),
          onPressed: () {
            setState(() {
              scale = (scale * 1.1).clamp(1.0, 5.0); // Zoom in
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.zoom_out),
          onPressed: () {
            setState(() {
              scale = (scale / 1.1).clamp(1.0, 5.0); // Zoom out
            });
          },
        ),
      ],
    ),
    body: Stack(
      children: [
        // PDF Viewer with scaling
        Positioned.fill(
          child: GestureDetector(
            onScaleUpdate: (details) {
              setState(() {
                scale = (scale * details.scale).clamp(1.0, 5.0); // Adjust scale on pinch
                print('Scale: $scale'); // Debug scale value
              });
            },
            child: Transform.scale(
              scale: scale,
              child: PDF(
                enableSwipe: true,
                swipeHorizontal: true,
                autoSpacing: false,
                pageFling: false,
                backgroundColor: Colors.grey,
                onError: (error) {
                  print(error.toString());
                },
                onPageError: (page, error) {
                  print('$page: ${error.toString()}');
                },
              ).fromAsset(pdfPath),
            ),
          ),
        ),
        // Drawing layer on top of the PDF
        Positioned.fill(
          child: GestureDetector(
            onPanUpdate: (details) {
              if (isDrawingMode) {
                setState(() {
                  currentStrokePoints.add(details.localPosition);
                  currentStrokeColors.add(selectedColor);
                });
              }
            },
            onPanEnd: (_) {
              if (isDrawingMode) {
                setState(() {
                  allDrawingPoints.add(List.from(currentStrokePoints));
                  allDrawingColors.add(List.from(currentStrokeColors));
                  currentStrokePoints.clear();
                  currentStrokeColors.clear();
                });
              }
            },
            child: Transform.scale(
              scale: scale, // Apply scale to the drawing layer as well
              child: CustomPaint(
                painter: DrawPainter(allDrawingPoints, allDrawingColors),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Pick a Color"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 10,
                children: [
                  _colorButton(Colors.blue),
                  _colorButton(Colors.red),
                  _colorButton(Colors.green),
                  _colorButton(Colors.orange),
                  _colorButton(Colors.purple),
                  _colorButton(Colors.black),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _colorButton(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
        Navigator.pop(context);
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    );
  }
}

class DrawPainter extends CustomPainter {
  final List<List<Offset>> allPoints;
  final List<List<Color>> allColors;
  DrawPainter(this.allPoints, this.allColors);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < allPoints.length; i++) {
      List<Offset> points = allPoints[i];
      List<Color> colors = allColors[i];
      for (int j = 0; j < points.length - 1; j++) {
        if (j + 1 < points.length &&
            points[j] != Offset.zero &&
            points[j + 1] != Offset.zero) {
          Paint paint = Paint()
            ..color = colors[j]
            ..strokeWidth = 3.0
            ..strokeCap = StrokeCap.round;
          canvas.drawLine(points[j], points[j + 1], paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(DrawPainter oldDelegate) => true;
}
