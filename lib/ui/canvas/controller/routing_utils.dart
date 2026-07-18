import 'dart:ui';

class RoutingUtils {
  static const double tolerance = 1.0;

  /// Returns a list of intermediate points to create an orthogonal (L-shape) path
  /// between [start] and [end].
  static List<Offset> getOrthogonalPath(Offset start, Offset end) {
    if ((start.dx - end.dx).abs() < tolerance || (start.dy - end.dy).abs() < tolerance) {
      return [];
    }

    final double dx = (end.dx - start.dx).abs();
    final double dy = (end.dy - start.dy).abs();

    if (dx > dy) {
      return [Offset(end.dx, start.dy)];
    } else {
      return [Offset(start.dx, end.dy)];
    }
  }

  /// Ensures that all segments in [points] are strictly horizontal or vertical.
  /// If a segment is diagonal, it inserts a corner point.
  static List<Offset> orthogonalize(List<Offset> points) {
    if (points.length < 2) return points;

    List<Offset> result = [points.first];
    for (int i = 0; i < points.length - 1; i++) {
      final a = points[i];
      final b = points[i + 1];

      if ((a.dx - b.dx).abs() > tolerance && (a.dy - b.dy).abs() > tolerance) {
        // Segment is diagonal, insert a corner
        final intermediate = getOrthogonalPath(a, b);
        for (final p in intermediate) {
          if ((p - result.last).distance > tolerance) {
            result.add(p);
          }
        }
      }
      if ((b - result.last).distance > tolerance) {
        result.add(b);
      }
    }
    
    return simplify(result);
  }

  /// Removes redundant points from the path (collinear or coincident).
  static List<Offset> simplify(List<Offset> points) {
    if (points.length <= 2) return points;

    final List<Offset> simplified = [points.first];
    
    for (int i = 1; i < points.length - 1; i++) {
      final prev = simplified.last;
      final curr = points[i];
      final next = points[i + 1];

      // 1. Remove coincident points
      if ((curr - prev).distance < tolerance) continue;

      // 2. Remove collinear points (Horizontal or Vertical alignment)
      final isCollinearH = (prev.dy - curr.dy).abs() < tolerance && (curr.dy - next.dy).abs() < tolerance;
      final isCollinearV = (prev.dx - curr.dx).abs() < tolerance && (curr.dx - next.dx).abs() < tolerance;
      
      if (!isCollinearH && !isCollinearV) {
        simplified.add(curr);
      }
    }

    // Add back the last point if it's not too close to the previous one
    if ((points.last - simplified.last).distance > tolerance) {
      simplified.add(points.last);
    } else if (simplified.length > 1) {
      // If last is too close, ensure the previous point is the ACTUAL end point
      simplified[simplified.length -1] = points.last;
    }

    return simplified;
  }
}
