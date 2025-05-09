import 'dart:ui' as ui;
import 'dart:math' as math;

// Base class for drawable objects with size information
abstract class DrawableObject {
  // Position of the object (top-left corner)
  ui.Offset position = ui.Offset.zero;

  // Size constraints
  ui.Size minSize = ui.Size.zero;
  ui.Size maxSize = const ui.Size(double.infinity, double.infinity);

  // Current size of the object
  ui.Size _size = ui.Size.zero;

  // Getter and setter for size with constraint enforcement
  ui.Size get size => _size;
  set size(ui.Size newSize) {
    _size = ui.Size(
      math.max(minSize.width, math.min(maxSize.width, newSize.width)),
      math.max(minSize.height, math.min(maxSize.height, newSize.height)),
    );
  }

  // Draw the object on the canvas
  void draw(ui.Canvas canvas);

  // Check if a point is inside the object
  bool containsPoint(ui.Offset point) {
    return point.dx >= position.dx && 
           point.dx <= position.dx + size.width &&
           point.dy >= position.dy && 
           point.dy <= position.dy + size.height;
  }

  // Handle interaction with the object
  void onTap() {}
}

// Rectangle object with color
class ColoredRectangle extends DrawableObject {
  ui.Color color;

  ColoredRectangle({
    required ui.Size initialSize,
    required this.color,
  }) {
    size = initialSize;
  }

  @override
  void draw(ui.Canvas canvas) {
    final paint = ui.Paint()..color = color;
    canvas.drawRect(
      ui.Rect.fromLTWH(position.dx, position.dy, size.width, size.height),
      paint,
    );
  }

  @override
  void onTap() {
    // Change color on tap
    final random = math.Random();
    color = ui.Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }
}

// Vertical layout manager
class VerticalLayoutManager {
  final List<DrawableObject> objects = [];
  ui.Size minConstraint = ui.Size.zero;
  ui.Size maxConstraint;
  double leftPadding = 20.0; // Left padding for all objects

  VerticalLayoutManager({required this.maxConstraint});

  // Add an object to the layout
  void addObject(DrawableObject object) {
    objects.add(object);
    updateLayout();
  }

  // Update the layout of all objects
  void updateLayout() {
    double currentY = 20.0; // Start with some top padding

    for (final object in objects) {
      // Set position with left edges aligned
      object.position = ui.Offset(leftPadding, currentY);

      // Move to the next vertical position
      currentY += object.size.height + 10.0; // Add some spacing between objects
    }
  }

  // Draw all objects
  void drawObjects(ui.Canvas canvas) {
    for (final object in objects) {
      object.draw(canvas);
    }
  }

  // Handle tap events
  bool handleTap(ui.Offset position) {
    // Check objects in reverse order (top-most first)
    for (int i = objects.length - 1; i >= 0; i--) {
      if (objects[i].containsPoint(position)) {
        objects[i].onTap();
        return true;
      }
    }
    return false;
  }
}

// Interactive rectangle that can be resized
class ResizableRectangle extends ColoredRectangle {
  ResizableRectangle({
    required ui.Size initialSize,
    required ui.Color color,
  }) : super(initialSize: initialSize, color: color);

  @override
  void onTap() {
    // Change size on tap
    final random = math.Random();
    size = ui.Size(
      50.0 + random.nextDouble() * 150.0,
      50.0 + random.nextDouble() * 150.0,
    );
    super.onTap();
  }
}

// Global layout manager
late VerticalLayoutManager layoutManager;

void main() {
  // Connect to Flutter engine
  ui.PlatformDispatcher.instance.onBeginFrame = beginFrame;
  ui.PlatformDispatcher.instance.onDrawFrame = drawFrame;
  ui.PlatformDispatcher.instance.onPointerDataPacket = handlePointer;

  // Get the screen size
  final screenSize = ui.PlatformDispatcher.instance.views.first.physicalSize;
  final devicePixelRatio = ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
  final logicalScreenSize = screenSize / devicePixelRatio;

  // Create layout manager
  layoutManager = VerticalLayoutManager(maxConstraint: logicalScreenSize);

  // Add objects to the layout
  layoutManager.addObject(ResizableRectangle(
    initialSize: const ui.Size(200, 100),
    color: const ui.Color.fromARGB(255, 255, 0, 0),
  ));

  layoutManager.addObject(ResizableRectangle(
    initialSize: const ui.Size(150, 150),
    color: const ui.Color.fromARGB(255, 0, 255, 0),
  ));

  layoutManager.addObject(ResizableRectangle(
    initialSize: const ui.Size(250, 80),
    color: const ui.Color.fromARGB(255, 0, 0, 255),
  ));

  // Schedule the first frame
  ui.PlatformDispatcher.instance.scheduleFrame();
}

// Handle pointer events (taps)
void handlePointer(ui.PointerDataPacket packet) {
  for (final pointer in packet.data) {
    if (pointer.change == ui.PointerChange.down) {
      final devicePixelRatio = ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
      final position = ui.Offset(
        pointer.physicalX / devicePixelRatio,
        pointer.physicalY / devicePixelRatio,
      );

      if (layoutManager.handleTap(position)) {
        // Update layout if an object was tapped
        layoutManager.updateLayout();
        // Schedule a new frame to redraw
        ui.PlatformDispatcher.instance.scheduleFrame();
      }
    }
  }
}

// Begin frame callback
void beginFrame(Duration timeStamp) {
  final devicePixelRatio = ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
  final screenSize = ui.PlatformDispatcher.instance.views.first.physicalSize;
  final logicalScreenSize = screenSize / devicePixelRatio;

  // Create a recorder to record drawing operations
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);

  // Clear the background
  canvas.drawColor(const ui.Color(0xFFFFFFFF), ui.BlendMode.src);

  // Draw all objects
  layoutManager.drawObjects(canvas);

  // Convert the recorded drawing operations to a picture
  final picture = recorder.endRecording();

  // Create a scene with the picture
  final sceneBuilder = ui.SceneBuilder()
    ..pushClipRect(ui.Rect.fromLTWH(0, 0, screenSize.width, screenSize.height))
    ..addPicture(ui.Offset.zero, picture)
    ..pop();

  // Build the scene
  ui.PlatformDispatcher.instance.views.first.render(sceneBuilder.build());
}

// Draw frame callback
void drawFrame() {
  // This is called after beginFrame
}