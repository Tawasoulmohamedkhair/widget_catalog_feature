import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mini App: Widget Catalog',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const WidgetCatalogFeature(title: 'Widget Catalog'),
    );
  }
}

class WidgetCatalogFeature extends StatefulWidget {
  const WidgetCatalogFeature({super.key, required this.title});
  final String title;

  @override
  State<WidgetCatalogFeature> createState() => _WidgetCatalogFeatureState();
}

class _WidgetCatalogFeatureState extends State<WidgetCatalogFeature> {
  double screenWidth = 0;

  final Map<String, List<String>> sections = {
    "Lesser-known Widgets": [
      "IntrinsicHeight",
      "LimitedBox",
      "RotatedBox",
      "Wrap",
      "FittedBox",
      "AspectRatio",
    ],
    "Animations": [
      "AnimatedContainer",
      "AnimatedAlign",
      "AnimatedDefaultTextStyle",
    ],
    "Buttons": ["ElevatedButton", "TextButton", "OutlinedButton"],
  };

  Map<String, List<bool>> elementVisible = {};

  @override
  void initState() {
    super.initState();
    for (var key in sections.keys) {
      elementVisible[key] = List<bool>.filled(sections[key]!.length, false);
    }
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        startStaggeredAnimation();
      }
    });
  }

  void startStaggeredAnimation() async {
    for (var section in sections.keys) {
      List<String> items = sections[section]!;
      for (int i = 0; i < items.length; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          setState(() {
            elementVisible[section]![i] = true;
          });
        }
      }
      await Future.delayed(const Duration(milliseconds: 400));
    }
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth / 20,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sections.keys.map((section) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  children: sections[section]!.asMap().entries.map((entry) {
                    int index = entry.key;
                    String item = entry.value;
                    bool visible = elementVisible[section]![index];

                    AnimationType type = AnimationType
                        .values[index % AnimationType.values.length];

                    return MultiAnimatedCatalogItem(
                      title: item,
                      screenWidth: screenWidth,
                      visible: visible,
                      animationType: type,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

enum AnimationType { slideLeft, slideBottom, fade, scale, rotate }

class MultiAnimatedCatalogItem extends StatefulWidget {
  final String title;
  final double screenWidth;
  final bool visible;
  final AnimationType animationType;

  const MultiAnimatedCatalogItem({
    super.key,
    required this.title,
    required this.screenWidth,
    required this.visible,
    required this.animationType,
  });

  @override
  State<MultiAnimatedCatalogItem> createState() =>
      _MultiAnimatedCatalogItemState();
}

class _MultiAnimatedCatalogItemState extends State<MultiAnimatedCatalogItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;
  late final Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _opacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _scale = Tween<double>(
      begin: 0.8,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _slide = Tween<Offset>(
      begin: widget.animationType == AnimationType.slideLeft
          ? const Offset(-0.5, 0)
          : const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _rotation = Tween<double>(
      begin: widget.animationType == AnimationType.rotate ? 0.3 : 0,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.visible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant MultiAnimatedCatalogItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !oldWidget.visible) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: SlideTransition(
          position: _slide,
          child: RotationTransition(
            turns: _rotation,
            child: Container(
              height: 70,
              width: widget.screenWidth,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
