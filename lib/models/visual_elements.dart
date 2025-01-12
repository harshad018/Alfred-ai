class VisualElement {
  final String selector;
  final String text;
  final BoundingBox boundingBox;
  final bool isVisible;
  final bool isClickable;
  final Map<String, String> attributes;

  VisualElement({
    required this.selector,
    required this.text,
    required this.boundingBox,
    required this.isVisible,
    required this.isClickable,
    required this.attributes,
  });

  Map<String, dynamic> toJson() => {
    'selector': selector,
    'text': text,
    'boundingBox': boundingBox.toJson(),
    'isVisible': isVisible,
    'isClickable': isClickable,
    'attributes': attributes,
  };
}

class BoundingBox {
  final double x;
  final double y;
  final double width;
  final double height;

  BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  Map<String, dynamic> toJson() => {
    'x': x,
    'y': y,
    'width': width,
    'height': height,
  };
}