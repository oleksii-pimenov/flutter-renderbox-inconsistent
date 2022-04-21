library measurement_editor_module;

import 'dart:async';
import 'package:flutter/material.dart';

class EditorEditView extends StatefulWidget {
  final dynamic point;

  const EditorEditView({
    Key? key,
    this.point,
  }) : super(key: key);

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditorEditView> {
  GlobalKey topIWKey = GlobalKey();
  GlobalKey botIWKey = GlobalKey();
  GlobalKey botCanvasKey = GlobalKey();

  TransformationController topIWController = TransformationController();
  TransformationController botIWController = TransformationController();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 0), () {
      botCentering(botIWController, widget.point);
      topCentering(topIWController, widget.point);
    });
  }

  void topCentering(TransformationController topIWController, dynamic points) {
    double initialStartXCoordinate = points['pointA'].dx;
    double initialStartYCoordinate = points['pointA'].dy;

    RenderBox topIWBox = getTopIWBox();
    Offset topIWPosition = getTopIWPosition(topIWBox);

    double startXCoordinate =
        (MediaQuery.of(context).size.width / 2 - topIWPosition.dx);
    double startYCoordinate = ((topIWBox.size.height / 2) - topIWPosition.dy);

    topIWController.value = Matrix4.identity()
      ..translate((startXCoordinate - initialStartXCoordinate),
          (startYCoordinate - initialStartYCoordinate));
  }

  void botCentering(TransformationController botIWController, points) {
    double initialStartXCoordinate = points['pointA'].dx;
    double initialStartYCoordinate = points['pointA'].dy;

    RenderBox botIWBox = getBotIWBox();
    Offset botIWPosition = getBotIWPosition(botIWBox);

    double startXCoordinate =
        (MediaQuery.of(context).size.width / 2 - botIWPosition.dx);
    double startYCoordinate =
        ((botIWBox.size.height + botIWBox.size.height / 2) - botIWPosition.dy);

    botIWController.value = Matrix4.identity()
      ..translate((startXCoordinate - initialStartXCoordinate * 3.0),
          (startYCoordinate - initialStartYCoordinate * 3.0))
      ..scale(3.0);
  }

  RenderBox getTopIWBox() {
    return topIWKey.currentContext?.findRenderObject() as RenderBox;
  }

  Offset getTopIWPosition(RenderBox topIWBox) {
    return topIWBox.localToGlobal(Offset.zero);
  }

  RenderBox getBotIWBox() {
    return botIWKey.currentContext?.findRenderObject() as RenderBox;
  }

  Offset getBotIWPosition(RenderBox botIWBox) {
    return botIWBox.localToGlobal(Offset.zero);
  }

  getBotCanvasBox() {
    return botCanvasKey.currentContext?.findRenderObject() as RenderBox;
  }

  Offset getBotCanvasPosition(RenderBox botCanvasBox) {
    return botCanvasBox.localToGlobal(Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: Stack(
            children: [
              InteractiveViewer(
                scaleEnabled: true,
                constrained: false,
                panEnabled: true,
                minScale: 0.1,
                transformationController: topIWController,
                key: topIWKey,
                child: CustomPaint(
                    foregroundPainter: TopCustomPainter(
                      context,
                      widget.point,
                      botCanvasKey,
                      botIWKey,
                    ),
                    child: Image.network(
                        'https://media.istockphoto.com/photos/human-heart-and-vascular-system-picture-id182043494')),
              ),
            ],
          )),
          Expanded(
              child: Stack(
            children: [
              InteractiveViewer(
                  key: botIWKey,
                  alignPanAxis: false,
                  clipBehavior: Clip.hardEdge,
                  scaleEnabled: true,
                  constrained: false,
                  boundaryMargin: const EdgeInsets.all(150.0),
                  minScale: 3.0,
                  maxScale: 3.0,
                  transformationController: botIWController,
                  child: CustomPaint(
                      key: botCanvasKey,
                      foregroundPainter: BotCustomPainter(context, botCanvasKey,
                          botIWKey, botIWController, widget.point),
                      child: Image.network(
                          'https://media.istockphoto.com/photos/human-heart-and-vascular-system-picture-id182043494'))),
              IgnorePointer(
                child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: CustomPaint(
                      painter: HitBoxPainter(context),
                    )),
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            BtnWrap(
                                text: 'Back',
                                color: MaterialStateProperty.all(
                                    Colors.transparent),
                                onPressed: () {
                                  Navigator.pop(context);
                                })
                          ])))
            ],
          )),
        ],
      ),
    ); //some action on complete}); return
  }
}

class TopCustomPainter extends CustomPainter {
  TopCustomPainter(this.context, this.point, this.botCanvasKey, this.botIWKey);

  BuildContext context;
  dynamic point;
  GlobalKey botCanvasKey;
  GlobalKey botIWKey;

  @override
  void paint(Canvas canvas, Size size) {
    double startXCoordinate = 0.0;
    double startYCoordinate = 0.0;

    RenderBox botIWBox =
        botIWKey.currentContext?.findRenderObject() as RenderBox;
    RenderBox botCanvasBox =
        botCanvasKey.currentContext?.findRenderObject() as RenderBox;

    Offset botCanvasPosition = botCanvasBox.localToGlobal(Offset.zero);

    print(botCanvasPosition);

    startXCoordinate =
        (MediaQuery.of(context).size.width / 2 - botCanvasPosition.dx) / 3.0;
    startYCoordinate = ((botIWBox.size.height + botIWBox.size.height / 2) -
            botCanvasPosition.dy) /
        3.0;

    Paint circlePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
        Offset(startXCoordinate, startYCoordinate), 8.0, circlePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class BotCustomPainter extends CustomPainter {
  BotCustomPainter(this.context, this.botCanvasKey, this.botIWKey,
      this.botIWController, this.point);

  BuildContext context;
  GlobalKey botCanvasKey;
  GlobalKey botIWKey;
  TransformationController botIWController;
  dynamic point;
  late double startXCoordinate;
  late double startYCoordinate;

  @override
  void paint(Canvas canvas, Size size) {
    RenderBox botCanvasBox =
        botCanvasKey.currentContext?.findRenderObject() as RenderBox;
    Offset botCanvasPosition = botCanvasBox.localToGlobal(Offset.zero);

    print(botCanvasPosition);
    RenderBox botIWBox =
        botIWKey.currentContext?.findRenderObject() as RenderBox;

    startXCoordinate =
        (MediaQuery.of(context).size.width / 2 - botCanvasPosition.dx) / 3.0;
    startYCoordinate = ((botIWBox.size.height + botIWBox.size.height / 2) -
            botCanvasPosition.dy) /
        3.0;

    Paint circlePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
        Offset(startXCoordinate, startYCoordinate), 3.0, circlePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class HitBoxPainter extends CustomPainter {
  const HitBoxPainter(this.context);

  final BuildContext context;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;

    // Vertical lines
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height / 2 - 20),
      paint,
    );

    canvas.drawLine(
      Offset(size.width / 2, size.height - 70.0),
      Offset(size.width / 2, size.height / 2 + 20),
      paint,
    );

    // Horizontal lines
    canvas.drawLine(
      Offset(size.width / 2 + 20, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width / 2 - 20, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class BtnWrap extends StatelessWidget {
  BtnWrap(
      {Key? key,
      required this.text,
      this.width = 150.0,
      this.textColor = Colors.white,
      required this.color,
      required this.onPressed})
      : super(key: key);

  String text;
  double width;
  MaterialStateProperty<Color> color;
  Function() onPressed;
  Color textColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: width,
        child: ElevatedButton(
          onPressed: (onPressed),
          child: Text(
            text,
            style: TextStyle(color: textColor),
          ),
          style: ButtonStyle(
            backgroundColor: color,
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: const BorderSide(color: Colors.white))),
          ),
        ));
  }
}
