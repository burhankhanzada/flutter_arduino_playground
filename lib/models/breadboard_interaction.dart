enum BreadboardChannel { plus, minus, signal }

class BreadboardHoverState {
  final BreadboardChannel channel;
  final int? rowIndex; // Only relevant for signal
  final bool isRightSide;

  const BreadboardHoverState({
    required this.channel,
    this.rowIndex,
    this.isRightSide = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BreadboardHoverState &&
          runtimeType == other.runtimeType &&
          channel == other.channel &&
          rowIndex == other.rowIndex &&
          isRightSide == other.isRightSide;

  @override
  int get hashCode => channel.hashCode ^ rowIndex.hashCode ^ isRightSide.hashCode;
  
  @override
  String toString() => 'BreadboardHoverState(channel: $channel, rowIndex: $rowIndex, isRightSide: $isRightSide)';
}
